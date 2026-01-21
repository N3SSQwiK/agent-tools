# Revision: SKILL.md Format Specification

**Addresses:** Critical Issue C1
**Source:** [Claude Code Skills Docs](https://code.claude.com/docs/en/skills), [Gemini CLI Skills Docs](https://geminicli.com/docs/cli/skills/)

## Proposed Addition to proposal.md

Add the following section after "## What Changes":

---

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
| `hooks` | No | None | **Claude Code only** - ignored by Gemini/Codex |

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

Skills with `hooks/` directories work correctly on all tools, but hooks only execute on Claude Code. The installer copies all files uniformly; non-Claude tools simply ignore the hooks directory at runtime.

This is intentional: hooks provide Claude-specific enforcement, while Gemini/Codex rely on prompt-based guardrails (documented in Maestro hooks research).

---

## Proposed Addition to spec.md

Add under `### Requirement: Skill Installation`:

```markdown
#### Scenario: SKILL.md validation
- **Given** a skill directory with SKILL.md
- **When** the installer processes the skill
- **Then** it validates the file exists
- **And** validates YAML frontmatter is parseable (if present)
- **And** validates `name` field contains only lowercase letters, numbers, and hyphens (if present)

#### Scenario: SKILL.md without frontmatter
- **Given** a skill directory with SKILL.md that has no YAML frontmatter
- **When** the installer processes the skill
- **Then** it proceeds with installation (frontmatter is optional)
- **And** the tool uses the directory name as the skill name
```

---

## Proposed Addition to tasks.md

Update tasks 3.2 and 4.2:

```markdown
- [ ] 3.2 Create `SKILL.md` with frontmatter:
  - `name: continuity`
  - `description: Check and update project continuity state in .ai/CONTINUITY.md`
  - No additional restrictions (general-purpose skill)

- [ ] 4.2 Create `SKILL.md` for each with appropriate frontmatter:
  - `maestro-plan`: `disable-model-invocation: false` (can auto-invoke)
  - `maestro-run`: `disable-model-invocation: true` (manual only)
  - `maestro-review`: `disable-model-invocation: false`
  - `maestro-challenge`: `disable-model-invocation: true` (manual only)
  - `maestro-status`: `disable-model-invocation: false`
  - `maestro-report`: `disable-model-invocation: false`
```

Add new task:

```markdown
- [ ] 4.13 Document hook cross-tool behavior in skill SKILL.md files
  - Add note that hooks only execute on Claude Code
  - Document fallback behavior for Gemini/Codex (prompt-based)
```
