# Continuity Command

Update the project's session continuity file.

## Behavior
1. Read `.claude/CONTINUITY.md` if it exists and display contents
2. Ask user: "Update continuity?"
3. If yes, write new summary using the format below

## Format (~60 tokens max)
```markdown
# Continuity

## Done
[Brief summary of completed work]

## Next
[What to work on next]

## Source
[Tool Name] | [YYYY-MM-DD HH:MM UTC]
```

## Rules
- Keep each section to 1-2 lines
- Use UTC timezone (run `date -u "+%Y-%m-%d %H:%M UTC"`)
- Include tool name that performed the update (e.g., "Claude Code")
