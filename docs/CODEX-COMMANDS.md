# Codex CLI Custom Prompts

Reference for creating custom slash commands (prompts) in Codex CLI.

## Location

`~/.codex/prompts/<name>.md`

Note: Codex scans only top-level `.md` files. Subdirectories are not supported.

## Format

Markdown file with YAML frontmatter:

```markdown
---
description: Brief description shown in command list
argument-hint: [KEY=<value>] [KEY2=<value>]
---

Your prompt instructions here.

Use placeholders: $1 $2 $ARGUMENTS $NAMED_PARAM
```

## Invocation

- `/prompts:<name>` - Run command without arguments
- `/prompts:<name> <args>` - Run command with arguments

Note: Use colon (`:`) not slash (`/`) after `prompts`.

## Frontmatter Fields

| Field | Required | Description |
|-------|----------|-------------|
| `description` | No | Brief description shown in slash menu |
| `argument-hint` | No | Documents expected parameters and format |

## Placeholders

| Type | Syntax | Description |
|------|--------|-------------|
| Positional | `$1` through `$9` | Space-separated arguments by position |
| All arguments | `$ARGUMENTS` | Entire argument string |
| Named | `$UPPERCASE_NAME` | Supplied via `KEY=value` syntax |
| Literal `$` | `$$` | Outputs a single dollar sign |

## Global Instructions

Codex supports a global instruction file:

`~/.codex/AGENTS.md`

This file provides persistent context across all sessions, similar to Claude's `CLAUDE.md`.

## Example

**File:** `~/.codex/prompts/draftpr.md`

```markdown
---
description: Prep a branch, commit, and open a draft PR
argument-hint: [FILES=<paths>] [PR_TITLE="<title>"]
---

Create a branch named `dev/<feature_name>`.
If files specified, stage them: $FILES.
Commit staged changes.
Open draft PR with $PR_TITLE or generate a summary.
```

**Usage:**
```
/prompts:draftpr FILES="src/index.ts" PR_TITLE="Add feature"
```

## Management

- **Edit/delete:** Modify files under `~/.codex/prompts/`
- **Reload:** Restart CLI session after changes
- **Discovery:** Type `/` then `prompts:` to see available commands

## Notes

- Prompts are local to your machine (not shared across repos)
- Only top-level `.md` files are discovered
- Works in both Codex CLI and IDE extension

## Resources

- [Codex CLI Custom Prompts Docs](https://developers.openai.com/codex/custom-prompts)
