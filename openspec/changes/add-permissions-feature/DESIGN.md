# Design: Permissions Feature Architecture

## Overview

This document covers the architectural decisions for Phases 1-2 of the Permissions feature: documentation/templates and audit logging.

## Phase 1: Feature Structure

### Directory Layout

```
installer/python/features/permissions/
├── claude/
│   ├── CLAUDE.md                    # Empty or minimal (no global instructions needed)
│   └── commands/
│       └── permissions.md           # Placeholder for Phase 4
├── codex/
│   ├── AGENTS.md                    # Empty or minimal
│   └── prompts/
│       └── permissions.md           # Placeholder for Phase 4
├── gemini/
│   ├── GEMINI.md                    # Empty or minimal
│   └── extensions/permissions/
│       ├── gemini-extension.json
│       └── commands/
│           └── permissions.toml     # Placeholder for Phase 4
├── templates/                       # Config templates (moved from Research)
│   ├── claude/
│   │   ├── conservative.json
│   │   ├── balanced.json
│   │   └── autonomous.json
│   ├── codex/
│   │   ├── conservative.toml
│   │   ├── balanced.toml
│   │   └── autonomous.toml
│   └── gemini/
│       ├── conservative.json
│       ├── balanced.json
│       ├── autonomous.json
│       └── *-policy.toml            # Companion policy files
└── docs/                            # Feature documentation
    ├── PERMISSION-EQUIVALENCE.md
    └── PERMISSION-SNIPPETS.md
```

### Template Format

Templates use native config formats with Nexus-managed block markers:

**Claude Code** (`templates/claude/balanced.json`):
```json
{
  "_nexus": {
    "preset": "balanced",
    "version": "1.0.0",
    "description": "Auto-approve safe operations, ask for writes"
  },
  "permissions": {
    "allow": ["Read", "Glob", "Grep", "Bash(git status)", "..."],
    "deny": ["Read(**/.env*)", "Bash(rm -rf:*)"],
    "ask": ["Edit", "Write"]
  }
}
```

The `_nexus` metadata key is ignored by Claude Code but used by Nexus for:
- Identifying which preset is active
- Version tracking for template updates
- User-friendly descriptions

### Installation Behavior

Phase 1 templates are **reference files**, not auto-applied configs:

1. Installer copies templates to `~/.nexus/permissions/templates/`
2. User manually copies desired preset to their tool's config location
3. Phase 4 will add `/permissions preset <name>` for automated application

## Phase 2: Audit Logging Architecture

### Log Location

```
.ai/permissions.log          # Project-level audit log
~/.nexus/permissions.log     # Global fallback (if no .ai/ directory)
```

Project-level is preferred because:
- Permission contexts differ per project (dev vs production)
- Easier to `.gitignore` if needed
- Matches `.ai/` convention for Nexus state files

### Log Format

Structured, append-only log optimized for both human reading and parsing:

```
2026-01-20T10:15:32Z INFO  [claude] ALLOWED  Read: src/main.rs
2026-01-20T10:15:45Z INFO  [claude] ASKED    Bash: npm install
2026-01-20T10:15:47Z INFO  [claude] APPROVED Bash: npm install (user)
2026-01-20T10:16:02Z WARN  [claude] DENIED   Read: .env (rule: deny **/.env*)
```

| Field | Format | Description |
|-------|--------|-------------|
| Timestamp | ISO 8601 UTC | When the event occurred |
| Level | `INFO`/`WARN` | `WARN` for denials |
| Tool | `[claude]`/`[codex]`/`[gemini]` | Which CLI tool |
| Action | `ALLOWED`/`ASKED`/`APPROVED`/`DENIED` | Permission outcome |
| Tool:Target | `Bash: npm install` | Tool name and argument |
| Rule | `(rule: ...)` | Optional: which rule matched |

### Hook Implementation (Claude Code)

**PreToolUse hook** (`~/.claude/hooks/permissions-audit.sh`):

```bash
#!/bin/bash
# Nexus-AI Permissions Audit Hook
# Logs permission checks to .ai/permissions.log

TOOL_NAME="$1"
TOOL_INPUT="$2"
LOG_FILE="${NEXUS_AUDIT_LOG:-.ai/permissions.log}"

# Determine log level based on built-in permission check
# (This hook runs BEFORE Claude's permission system)
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Log the request (outcome determined later by PostToolUse)
echo "$TIMESTAMP INFO  [claude] CHECKING $TOOL_NAME: $TOOL_INPUT" >> "$LOG_FILE"
```

**PostToolUse hook** captures the outcome:

```bash
#!/bin/bash
# Post-execution: log whether the tool ran successfully

TOOL_NAME="$1"
TOOL_RESULT="$2"  # success/denied/error
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
LOG_FILE="${NEXUS_AUDIT_LOG:-.ai/permissions.log}"

case "$TOOL_RESULT" in
  success) echo "$TIMESTAMP INFO  [claude] ALLOWED  $TOOL_NAME" >> "$LOG_FILE" ;;
  denied)  echo "$TIMESTAMP WARN  [claude] DENIED   $TOOL_NAME" >> "$LOG_FILE" ;;
  *)       echo "$TIMESTAMP INFO  [claude] $TOOL_RESULT $TOOL_NAME" >> "$LOG_FILE" ;;
esac
```

### Log Rotation

Simple rotation to prevent unbounded growth:

- **Trigger**: Log exceeds 10MB or 10,000 lines
- **Action**: Rename to `permissions.log.1`, start fresh
- **Retention**: Keep last 2 rotations (`.log.1`, `.log.2`)

Rotation is handled by the audit analysis command, not the hooks (keeps hooks simple).

### Codex/Gemini Support

**Codex CLI**: Research needed on extensibility. Likely outcome:
- No native hook support → document limitation
- Possible workaround: wrapper script that logs before invoking `codex`

**Gemini CLI**: Research needed. Similar situation:
- Experimental hooks may exist
- Document whatever is possible

**Phase 2 MVP**: Claude Code audit logging only. Other tools documented as "future work."

## Analysis Commands (Phase 2)

### `/permissions audit`

```
Recent permission events (last 24 hours):

TIME        TOOL    ACTION   TARGET
10:15:32    claude  ALLOWED  Read: src/main.rs
10:15:45    claude  ASKED    Bash: npm install
10:15:47    claude  APPROVED Bash: npm install
10:16:02    claude  DENIED   Read: .env

Options:
  --tool <name>    Filter by tool (claude, codex, gemini)
  --action <name>  Filter by action (allowed, denied, asked)
  --since <time>   Show events since (e.g., "1h", "2024-01-20")
  --stats          Show permission fatigue analysis
```

### `/permissions audit --stats`

```
Permission Fatigue Analysis (last 7 days):

Most frequently asked permissions:
  1. Bash: npm install (47 asks, 45 approved → candidate for auto-allow)
  2. Edit: *.test.ts (31 asks, 31 approved → candidate for auto-allow)
  3. Bash: git push (12 asks, 10 approved → keep asking)

Denial rate: 3.2% (typical: 1-5%)
Asks per hour: 4.7 (typical: 2-10)

Recommendations:
  - Consider auto-allowing: npm install, Edit *.test.ts
  - Review: no unusual patterns detected
```

## Security Considerations

1. **Log file permissions**: 600 (owner read/write only)
2. **No secrets in logs**: Tool arguments may contain sensitive data; logs are local-only
3. **Gitignore recommended**: Add `.ai/permissions.log` to `.gitignore`
4. **No remote transmission**: Audit data stays local; Phase 3 survey is opt-in

## Testing Strategy

1. **Hook installation**: Verify hooks are copied to correct locations
2. **Log format**: Validate log entries match expected format
3. **Rotation**: Verify rotation triggers at threshold
4. **Analysis commands**: Test filtering and stats calculations

## Future Considerations (Phase 3-4)

- Survey questions informed by audit data patterns
- Preset commands with `--merge`, `--dry-run` safety flags
- Drift detection (deviation from preset)
