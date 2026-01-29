# Agent Skills

Reference for the unified skill format used by Nexus-AI across Claude Code, Gemini CLI, and Codex CLI.

## What Are Skills?

Skills are markdown files with YAML frontmatter that provide AI assistants with reusable capabilities — slash commands, workflows, and behavioral instructions. A single skill works across all three tools.

## Skill Structure

```
~/.{tool}/skills/<skill-name>/
├── SKILL.md              # Skill definition (required)
└── templates/            # Supporting files (optional)
    └── *.md
```

**Installation directories:**

| Tool | Location |
|------|----------|
| Claude Code | `~/.claude/skills/<skill-name>/` |
| Gemini CLI | `~/.gemini/skills/<skill-name>/` |
| Codex CLI | `~/.codex/skills/<skill-name>/` |

## SKILL.md Format

```markdown
---
name: my-skill
description: Brief description of what this skill does
---

# My Skill

Your prompt instructions here.

User input: $ARGUMENTS
```

### Frontmatter Fields

| Field | Required | Constraints | Description |
|-------|----------|-------------|-------------|
| `name` | Yes | kebab-case, ≤64 chars, single-line | Unique identifier for the skill |
| `description` | Yes | single-line | Brief description shown in skill list |
| `disable-model-invocation` | No | `true` or `false` | If `true`, skill can only be invoked manually (not auto-triggered) |

### Frontmatter Constraints

- **YAML must be parseable** — invalid YAML causes the skill to be silently skipped (especially on Codex CLI)
- **`name`** must be kebab-case (lowercase letters, numbers, hyphens), single-line, max 64 characters
- **`description`** must be single-line

## Invocation

| Tool | Invocation |
|------|-----------|
| Claude Code | `/<skill-name>` or `/<skill-name> <args>` |
| Gemini CLI | `/<skill-name>` or `/<skill-name> <args>` |
| Codex CLI | `/<skill-name>` or `/<skill-name> <args>` |

## Discovery

| Tool | Behavior |
|------|----------|
| Claude Code | Skills discovered automatically on startup |
| Gemini CLI | Skills auto-discovered from `~/.gemini/skills/` — no enablement needed |
| Codex CLI | Skills discovered after CLI restart |

## Templates

Skills can include supporting template files in a `templates/` subdirectory:

```
skills/maestro-plan/
├── SKILL.md
└── templates/
    └── plan-format.md
```

Reference templates from the SKILL.md body using relative paths. Templates are plain markdown (no templating engine).

## Cross-Tool Compatibility

| Feature | Claude Code | Gemini CLI | Codex CLI |
|---------|------------|------------|-----------|
| YAML frontmatter | ✅ | ✅ | ✅ |
| `disable-model-invocation` | ✅ | ✅ | ✅ |
| `allowed-tools` | ✅ | ❌ Ignored | ❌ Ignored |
| Hooks (`hooks/`) | ✅ | ❌ Not supported | ❌ Not supported |
| Templates | ✅ | ✅ | ✅ |
| Auto-discovery | ✅ | ✅ | After restart |

## Example

**Skill:** `~/.claude/skills/review/SKILL.md`

```markdown
---
name: review
description: Review code changes in the current branch
---

# Review Command

Review the code changes in the current git branch.

## Behavior

1. Run `git diff` to see current changes
2. Analyze for: code quality, potential bugs, style issues
3. Present findings with severity ratings

## Focus Areas

Additional focus: $ARGUMENTS
```

**Usage:** `/review security concerns`

## Migration from v1.x

Nexus-AI v2.0 automatically cleans up legacy v1.x files during installation:

| Tool | Legacy Location | New Location |
|------|----------------|--------------|
| Claude Code | `~/.claude/commands/<name>.md` | `~/.claude/skills/<name>/SKILL.md` |
| Gemini CLI | `~/.gemini/extensions/<name>/` | `~/.gemini/skills/<name>/SKILL.md` |
| Codex CLI | `~/.codex/prompts/<name>.md` | `~/.codex/skills/<name>/SKILL.md` |

Legacy files matching known Nexus-AI patterns are removed automatically. Custom user files are preserved.
