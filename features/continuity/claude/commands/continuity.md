# Continuity Command

Update the project's session continuity file.

## Behavior

1. Check for `.ai/CONTINUITY.md` - if exists, display contents
2. If not found, check legacy paths (`.claude/CONTINUITY.md`) and offer migration
3. Ask user: "Update continuity?"
4. If yes, write new summary using the expanded format below

## Format (~500 tokens)

```markdown
# Continuity

## Summary
[High-level project context - what is being built and why, 1-2 sentences]

## Completed
- [Finished work item 1]
- [Finished work item 2]
- [etc.]

## In Progress
- [Active work item not yet complete]

## Blocked
[Impediments or decisions needed - or "None"]

## Key Files
- `path/to/important/file.ext` - [brief description]
- `path/to/another/file.ext` - [brief description]

## Context
[Session-specific state: user preferences, environment details, constraints]

## Suggested Prompt
> [Actionable, copy-pasteable prompt to continue the work]
> [Include specific next steps and any pending decisions]

## Source
[Tool Name] | [YYYY-MM-DD HH:MM UTC]
```

## Rules

- Total content should be approximately 500 tokens
- Prioritize the Suggested Prompt section (~120 tokens) - this is the key handoff mechanism
- Keep Summary concise (1-2 sentences)
- List only the most relevant Key Files (3-5 max)
- Use UTC timezone (run `date -u "+%Y-%m-%d %H:%M UTC"`)
- Tool name is "Claude Code"

## Migration

If `.ai/CONTINUITY.md` does not exist but `.claude/CONTINUITY.md` does:
1. Display the legacy content
2. Ask: "Found legacy continuity file. Migrate to unified location (.ai/CONTINUITY.md)?"
3. If yes, create `.ai/CONTINUITY.md` with the content (convert to new format if possible)
4. Suggest user delete the legacy file after verifying migration
