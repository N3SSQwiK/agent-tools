# Change: Migrate Commands to Agent Skills

## Why

All three supported CLI tools (Claude Code, Gemini CLI, Codex CLI) now support the [Agent Skills](https://agentskills.io) open standard. Skills provide significant advantages over the current command/prompt approach:

1. **Cross-tool portability** — One `SKILL.md` format works for all three tools
2. **Supporting files** — Skills can bundle hooks, templates, scripts, and reference docs
3. **Auto-invocation** — Tools can automatically activate skills based on context
4. **Tool restrictions** — Skills can limit which tools are available during execution
5. **Better organization** — Related files grouped in skill directories

Currently, Nexus-AI maintains separate file formats per tool (`.md` commands for Claude/Codex, `.toml` extensions for Gemini). Migrating to unified skills simplifies the codebase and enables richer features like the Maestro hooks researched in `docs/Research/maestro-hooks/`.

## What Changes

- **Feature structure**: Add `skills/` directory at feature root (shared across tools)
- **Installer logic**: Copy skill directories to tool-specific locations
- **Gemini enablement**: Add TUI confirmation to run `gemini skills enable --global`
- **Spec updates**: Document skill installation behavior
- **Migration**: Convert Maestro and Continuity from commands to skills
- **Deprecation**: Remove command/extension/prompt installation (skills replace them)

### New Feature Structure

```
features/<feature>/
├── skills/                          # NEW: Unified skills (all tools)
│   └── <skill-name>/
│       ├── SKILL.md                 # Required: Instructions + frontmatter
│       ├── hooks/                   # Optional: Hook scripts
│       ├── templates/               # Optional: Output templates
│       └── scripts/                 # Optional: Helper scripts
├── claude/
│   └── CLAUDE.md                    # Global instructions (unchanged)
├── gemini/
│   └── GEMINI.md                    # Global instructions (unchanged)
└── codex/
    └── AGENTS.md                    # Global instructions (unchanged)
```

**Removed (deprecated):**
- `claude/commands/` → Replaced by `skills/`
- `gemini/extensions/` → Replaced by `skills/`
- `codex/prompts/` → Replaced by `skills/`

### Installation Destinations

| Tool | Skills Location |
|------|----------------|
| Claude Code | `~/.claude/skills/<skill-name>/` |
| Gemini CLI | `~/.gemini/skills/<skill-name>/` |
| Codex CLI | `~/.codex/skills/<skill-name>/` |

## Impact

- **Affected specs**: `installer`
- **Affected code**: `installer/python/nexus.py`, feature directories
- **New TUI screen**: Gemini skills enablement confirmation
- **Documentation**: Update CLAUDE.md with skills installation info
