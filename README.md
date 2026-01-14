# agent-tools

Configuration and commands for AI agent tools.

## Install

```bash
git clone https://github.com/N3SSQwiK/agent-tools.git ~/agent-tools
cd ~/agent-tools
chmod +x *.sh
```

**All tools:**
```bash
./install.sh
```

**Individual tools:**
```bash
./install-claude.sh   # Claude Code only
./install-gemini.sh   # Gemini CLI only
./install-codex.sh    # Codex CLI only
```

The installer uses **managed blocks** - your existing config is preserved.

## What's Included

### Claude Code

| File | Purpose |
|------|---------|
| `claude/CLAUDE.md` | Global instructions (managed block) |
| `claude/commands/continuity.md` | `/continuity` command |

Config location: `~/.claude/`

### Gemini CLI

| File | Purpose |
|------|---------|
| `gemini/GEMINI.md` | Global instructions (managed block) |
| `gemini/extensions/agent-tools/` | Extension with commands |

Config location: `~/.gemini/`

### Codex CLI

| File | Purpose |
|------|---------|
| `codex/prompts/continuity.md` | `/continuity` command |

Config location: `~/.codex/`

Note: Codex uses `AGENTS.md` per-project for global instructions.

## Session Continuity System

Tracks work across sessions via a `CONTINUITY.md` file in each project.

**Workflow:**
1. Session start → Agent reads project's CONTINUITY.md, asks to proceed or adjust
2. Milestone reached (PR merged, etc.) → Agent updates CONTINUITY.md
3. Manual update → Run `/continuity`

**Format (~60 tokens):**
```markdown
# Continuity

## Done
[Brief summary of completed work]

## Next
[What to work on next]

## Source
[Tool Name] | [YYYY-MM-DD HH:MM UTC]
```

**File locations by tool:**
| Tool | Continuity file |
|------|----------------|
| Claude Code | `.claude/CONTINUITY.md` |
| Gemini CLI | `.gemini/CONTINUITY.md` |
| Codex CLI | `.codex/CONTINUITY.md` |

## Adding New Tools

1. Create a new directory: `<tool>/`
2. Add config files
3. Create `install-<tool>.sh`
4. Update `install.sh` to include it
