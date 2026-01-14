# Claude Code Slash Commands

Reference for creating custom slash commands in Claude Code.

## Location

`~/.claude/commands/<name>.md`

## Format

Markdown file with optional YAML frontmatter:

```markdown
---
description: Brief description shown in command list
allowed-tools: Bash, Read, Write  # Optional: restrict available tools
---

Your prompt instructions here.

User input: $ARGUMENTS
```

## Invocation

- `/<name>` - Run command without arguments
- `/<name> <args>` - Run command with arguments

## Placeholders

| Placeholder | Description |
|-------------|-------------|
| `$ARGUMENTS` | User input after the command |

## Notes

- Filename becomes command name (e.g., `foo.md` → `/foo`)
- Can reference files with `@file` syntax in prompt
- Subdirectories create namespaced commands (e.g., `git/status.md` → `/git:status`)

## Example

**File:** `~/.claude/commands/review.md`

```markdown
---
description: Review code changes in the current branch
allowed-tools: Bash, Read
---

Review the code changes in the current git branch.
Focus on: code quality, potential bugs, and style.

Additional focus areas: $ARGUMENTS
```

**Usage:** `/review security concerns`
