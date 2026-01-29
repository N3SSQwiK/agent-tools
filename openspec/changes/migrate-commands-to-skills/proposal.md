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

## Terminology

- **Skill** — A unit of capability defined by a SKILL.md file
- **Skill directory** — The filesystem folder `skills/<name>/` containing SKILL.md
- **Skill bundle** — A skill directory plus its supporting files (`hooks/`, `templates/`, `scripts/`)

## SKILL.md Format Specification

Skills follow the [Agent Skills](https://agentskills.io) open standard. Each skill directory MUST contain a `SKILL.md` file with YAML frontmatter.

### Frontmatter Reference

```yaml
---
name: skill-name                    # Recommended: kebab-case identifier (max 64 chars)
description: What this skill does   # Recommended: When to use this skill (for auto-invocation)
argument-hint: [argument]           # Optional: Shown during autocomplete
disable-model-invocation: false     # Optional: true = manual /slash only
user-invocable: true                # Optional: false = hide from / menu
allowed-tools: Read, Grep, Bash     # Optional: Comma-separated tool restrictions
model: claude-sonnet                # Optional: Override model for this skill
context: fork                       # Optional: Run in isolated subagent
agent: Explore                      # Optional: Subagent type when context: fork
hooks:                              # Optional: Skill-scoped hooks (Claude only)
  on-success: |
    instructions
---
```

### Field Details

| Field | Required | Default | Notes |
|-------|----------|---------|-------|
| `name` | No | Directory name | Lowercase, numbers, hyphens only |
| `description` | Recommended | First paragraph | Critical for auto-invocation |
| `disable-model-invocation` | No | `false` | Use for side-effects (deploy, commit) |
| `user-invocable` | No | `true` | Use `false` for background knowledge |
| `allowed-tools` | No | All tools | Restrict to specific tools |
| `hooks` | No | None | **Claude Code only** — ignored by Gemini/Codex |

### Minimal Example

```markdown
---
name: continuity
description: Check and update project continuity state in .ai/CONTINUITY.md
---

# Continuity Skill

When starting work on a project, check for `.ai/CONTINUITY.md`...
```

### Full Example (with hooks)

```markdown
---
name: maestro-run
description: Execute approved orchestration plan or specific task
disable-model-invocation: true
allowed-tools: Read, Bash, Edit, Write
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "./hooks/safety-rails.py"
---

# Maestro Run

Execute the approved plan from `.ai/MAESTRO.md`...
```

### Cross-Tool Compatibility

| Feature | Claude Code | Gemini CLI | Codex CLI |
|---------|-------------|------------|-----------|
| `name` | ✅ | ✅ | ✅ |
| `description` | ✅ | ✅ | ✅ |
| `disable-model-invocation` | ✅ | ✅* | ✅* |
| `allowed-tools` | ✅ | ❌ Ignored | ❌ Ignored |
| `hooks` | ✅ | ❌ Ignored | ❌ Ignored |
| `context: fork` | ✅ | ❌ Ignored | ❌ Ignored |

*Gemini/Codex respect invocation flags but may have different naming conventions.

### Hook Portability Note

Skills with `hooks/` directories work correctly on all tools, but hooks only execute on Claude Code. The installer copies all files uniformly; non-Claude tools simply ignore the hooks directory at runtime. This is intentional: hooks provide Claude-specific enforcement, while Gemini/Codex rely on prompt-based guardrails (documented in Maestro hooks research).

### Gemini Enablement Detection

The installer detects Gemini skills readiness through the following checks:

1. **Binary Check**: Verify `gemini` command exists in PATH
2. **Skills List Check**: Run `gemini skills list` to verify skills subsystem is functional
3. **Skills Location Check**: Verify `~/.gemini/skills/` directory exists or can be created

**Note:** Unlike Claude Code, Gemini CLI does not require a global "enable" command. Skills are automatically discovered when placed in the skills directory. The TUI confirmation explains the skills system and confirms the user wants Nexus-AI to install skills.

### Migration Path for Existing Users

This is a **breaking change** requiring a major version bump to v2.0.0.

#### Detection Phase

The installer detects previous Nexus-AI installations by checking for known file patterns:

```
# Claude Code
~/.claude/commands/maestro-*.md, continuity.md

# Gemini CLI
~/.gemini/extensions/maestro/, continuity/

# Codex CLI
~/.codex/prompts/maestro-*.md, continuity.md
```

#### Automatic Cleanup

When legacy files are detected, the installer **automatically removes** them during installation and displays a summary of what was removed. Only known Nexus-AI patterns are targeted — custom user files are never touched.

| Feature | Claude Pattern | Gemini Pattern | Codex Pattern |
|---------|---------------|----------------|---------------|
| Maestro | `maestro-{plan,run,review,challenge,status,report}.md` | `extensions/maestro/` (entire dir) | `maestro-{plan,run,review,challenge,status,report}.md` |
| Continuity | `continuity.md` | `extensions/continuity/` | `continuity.md` |

Files with non-standard names (e.g., `maestro-plan-custom.md`) are NOT removed.

#### Failure Handling

If a file cannot be removed (permissions, etc.), the installer logs a warning and continues. Skills installation proceeds regardless of cleanup outcome.

## Impact

- **Affected specs**: `installer`
- **Affected code**: `installer/python/nexus.py`, feature directories
- **New TUI screen**: Gemini skills enablement confirmation
- **Documentation**: Update CLAUDE.md with skills installation info
