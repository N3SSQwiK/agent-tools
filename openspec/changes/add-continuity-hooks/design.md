# Design: Event-Driven Continuity Triggers

## Architectural Overview

This change introduces event-driven hooks to make continuity triggers reliable across three AI CLI tools with different capabilities.

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        Continuity Feature                                │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐                 │
│  │ Claude Code │    │ Gemini CLI  │    │  Codex CLI  │                 │
│  └──────┬──────┘    └──────┬──────┘    └──────┬──────┘                 │
│         │                  │                  │                         │
│         ▼                  ▼                  ▼                         │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐                 │
│  │   hooks/    │    │   hooks/    │    │  notify/    │                 │
│  │ - session   │    │ - session   │    │ - turn cnt  │                 │
│  │ - milestone │    │ - milestone │    │             │                 │
│  └─────────────┘    └─────────────┘    └─────────────┘                 │
│                                               │                         │
│                                        ┌──────┴──────┐                 │
│                                        │ git-hooks/  │                 │
│                                        │ - post-merge│                 │
│                                        │ - post-push │                 │
│                                        └─────────────┘                 │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

## Hook Mechanisms by Tool

### Claude Code & Gemini CLI (Full Hooks)

Both tools support an event-driven hook system with JSON-over-stdin communication.

**SessionStart Hook**:
- Event: `SessionStart` with matcher `startup`
- Input: JSON with `session_id`, `cwd`, etc.
- Output: JSON with `additionalContext` to inject into AI's awareness
- Behavior: Check for `.ai/CONTINUITY.md`, inject contents, prompt user

**PostToolUse Hook**:
- Event: `PostToolUse` with matcher `Bash` (Claude) / `Shell` (Gemini)
- Input: JSON with `tool_input.command` containing the executed command
- Output: JSON with `additionalContext` suggesting `/continuity`
- Behavior: Pattern-match milestone commands, suggest update

**Milestone Patterns**:
```regex
gh pr merge
gh pr create
git push.*main
git push.*master
git push origin HEAD
git tag v[0-9]
```

### Codex CLI (Limited—Notify + Git Hooks)

Codex lacks full hook support but provides:

1. **Notify script**: Receives `agent-turn-complete` events
   - Count turns in state file (`.ai/.codex-turn-count`)
   - At threshold (100), show desktop notification
   - Reset counter after notification

2. **Git hooks**: External to Codex, installed in `.git/hooks/`
   - `post-merge`: Notify after branch merge
   - `post-push`: Notify after push to remote
   - These catch semantic milestones regardless of turn count

**Why turn count?** It's a heuristic for "you've been working a while" since Codex can't detect milestone commands. Combined with git hooks, it provides reasonable coverage.

## File Structure

### Claude Code
```
features/continuity/claude/
├── CLAUDE.md                    # Keep existing instructions (fallback)
├── commands/continuity.md       # Existing slash command
└── hooks/
    ├── hooks.json               # Hook configuration
    ├── session-start.sh         # SessionStart handler
    └── milestone-check.sh       # PostToolUse handler
```

### Gemini CLI
```
features/continuity/gemini/
├── GEMINI.md                    # Keep existing instructions (fallback)
└── extensions/continuity/
    ├── gemini-extension.json    # Existing extension manifest
    ├── commands/continuity.toml # Existing slash command
    └── hooks/
        ├── hooks.json           # Hook configuration
        ├── session-start.sh     # SessionStart handler
        └── milestone-check.sh   # PostToolUse handler
```

### Codex CLI
```
features/continuity/codex/
├── AGENTS.md                    # Keep existing instructions (best effort)
├── prompts/continuity.md        # Existing slash command
├── notify/
│   └── turn-reminder.sh         # Turn-count notification script
└── git-hooks/
    ├── post-merge               # Git post-merge hook
    └── post-push                # Git post-push hook (custom, not standard)
```

## Hook Script Design

### Common Patterns

All hook scripts follow these patterns:

1. **Read JSON input from stdin** (or argument for Codex notify)
2. **Parse with jq** for portability
3. **Output JSON** with `additionalContext` (Claude/Gemini) or trigger notification (Codex)
4. **Exit 0** for success, allowing hook output to be processed

### Session Start Script

```bash
#!/bin/bash
# session-start.sh

CONTINUITY_FILE=".ai/CONTINUITY.md"

if [ -f "$CONTINUITY_FILE" ]; then
  CONTENT=$(cat "$CONTINUITY_FILE")
  # Escape for JSON
  ESCAPED=$(echo "$CONTENT" | jq -Rs .)

  cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "📋 **Session Continuity Found**\n\nContents of .ai/CONTINUITY.md:\n\n${ESCAPED}\n\n---\nWould you like to proceed with the suggested prompt, or work on something else?"
  }
}
EOF
fi

exit 0
```

### Milestone Check Script

```bash
#!/bin/bash
# milestone-check.sh

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Milestone patterns
if echo "$COMMAND" | grep -qE "(gh pr (merge|create)|git push.*(main|master)|git push origin HEAD|git tag v[0-9])"; then
  cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "PostToolUse",
    "additionalContext": "🎯 **Milestone detected**: \`$COMMAND\`\n\nConsider running /continuity to save your progress."
  }
}
EOF
fi

exit 0
```

### Codex Turn Reminder Script

```bash
#!/bin/bash
# turn-reminder.sh

INPUT="$1"
EVENT_TYPE=$(echo "$INPUT" | jq -r '.event_type // empty')

[ "$EVENT_TYPE" != "agent-turn-complete" ] && exit 0

STATE_FILE=".ai/.codex-turn-count"
mkdir -p .ai

COUNT=$(cat "$STATE_FILE" 2>/dev/null || echo 0)
COUNT=$((COUNT + 1))
echo "$COUNT" > "$STATE_FILE"

if [ "$COUNT" -ge 100 ]; then
  # macOS notification
  osascript -e 'display notification "You'\''ve been working a while. Consider running /continuity to save context." with title "Codex"' 2>/dev/null
  # Linux fallback
  notify-send "Codex" "You've been working a while. Consider running /continuity to save context." 2>/dev/null
  echo "0" > "$STATE_FILE"
fi

exit 0
```

## Installation Flow

### Hook Deployment (Claude/Gemini)

The installer must:
1. Detect `hooks/` directory in feature
2. Copy hook scripts to appropriate location
3. Merge `hooks.json` into tool's hook configuration

**Claude Code**: Hooks merge into `~/.claude/settings.json`
**Gemini CLI**: Hooks defined in extension's `hooks/hooks.json`

### Notify Deployment (Codex)

1. Copy `turn-reminder.sh` to `~/.codex/scripts/`
2. Update `~/.codex/config.json` to set `notify` path
3. Make script executable

### Git Hooks (Optional)

Git hooks are **not auto-installed** (would overwrite user hooks). Instead:
1. Copy to `~/.codex/git-hooks/`
2. Display instructions: "To enable milestone notifications, copy hooks to .git/hooks/"

## Trade-offs

| Decision | Alternative | Rationale |
|----------|-------------|-----------|
| JSON parsing with jq | Pure bash | jq is more robust and widely available |
| Turn count of 100 | Lower/higher threshold | Balances frequency vs. annoyance |
| Desktop notifications for Codex | File-based flag | Notifications are actionable; files are passive |
| Git hooks as optional | Auto-install | Respect existing user hooks |
| Keep CLAUDE.md/GEMINI.md/AGENTS.md | Remove passive instructions | Fallback for hook failures; no harm in keeping |

## Future Considerations

When Codex adds full hooks:
1. Add `hooks/` directory mirroring Claude/Gemini
2. Deprecate `notify/` approach
3. Update installer to deploy hooks instead of notify script
4. Keep git hooks as optional supplement
