# agent-tools

Configuration and commands for AI agent tools.

## Install

```bash
git clone https://github.com/N3SSQwiK/agent-tools.git ~/agent-tools
cd ~/agent-tools
chmod +x install.sh
./install.sh
```

The installer uses **managed blocks** - your existing config is preserved:

```markdown
# Your custom instructions here...

<!-- AGENT-TOOLS:START -->
(managed content - safe to update)
<!-- AGENT-TOOLS:END -->

# More of your content...
```

Re-run `./install.sh` anytime to update managed content without losing your customizations.

## What's Included

### Claude Code

| File | Purpose |
|------|---------|
| `claude/CLAUDE.md` | Global instructions loaded in every project |
| `claude/commands/continuity.md` | `/continuity` command for session handoff |

#### Session Continuity System

Tracks work across sessions via `.claude/CONTINUITY.md` in each project.

**Workflow:**
1. Session start → Claude reads project's CONTINUITY.md, asks to proceed or adjust
2. Milestone reached (PR merged, etc.) → Claude updates CONTINUITY.md
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

## Adding New Tools

Create a new directory for each tool:

```
agent-tools/
├── claude/          # Claude Code
├── cursor/          # Cursor (future)
├── aider/           # Aider (future)
└── install.sh       # Update to handle new tools
```
