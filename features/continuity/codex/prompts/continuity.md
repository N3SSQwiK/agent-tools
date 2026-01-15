---
description: Show continuity notes and ask whether to update them
argument-hint:
---

Check if `.codex/CONTINUITY.md` exists in the current working directory.

**If it exists:**
- Read and display its contents verbatim
- Ask the user: "Update continuity?"

**If it does not exist:**
- Say: "No continuity file found at .codex/CONTINUITY.md"

If updating, use this format (~60 tokens max):

```markdown
# Continuity

## Done
[Brief summary of completed work]

## Next
[What to work on next]

## Source
[Tool Name] | [YYYY-MM-DD HH:MM UTC]
```

Rules:
- Keep each section to 1-2 lines
- Use UTC timezone
- Tool name is "Codex CLI"
