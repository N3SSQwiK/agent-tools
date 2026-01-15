---
description: Show continuity notes and ask whether to update them
argument-hint:
---

Check if `.ai/CONTINUITY.md` exists in the current working directory.

**If unified file exists:**
- Read and display its contents verbatim
- Ask the user: "Update continuity?"

**If unified file does not exist:**
- Check for legacy file at `.codex/CONTINUITY.md`
- If legacy exists, display content and ask: "Found legacy continuity file. Migrate to unified location (.ai/CONTINUITY.md)?"
- If no files exist, say: "No continuity file found."

If updating or creating, use this expanded format (~500 tokens):

```markdown
# Continuity

## Summary
[High-level project context - what is being built and why, 1-2 sentences]

## Completed
- [Finished work item 1]
- [Finished work item 2]

## In Progress
- [Active work item not yet complete]

## Blocked
[Impediments or decisions needed - or "None"]

## Key Files
- `path/to/file.ext` - [brief description]

## Context
[Session-specific state: user preferences, environment details, constraints]

## Suggested Prompt
> [Actionable, copy-pasteable prompt to continue the work]
> [Include specific next steps and any pending decisions]

## Source
[Tool Name] | [YYYY-MM-DD HH:MM UTC]
```

Rules:
- Total content should be approximately 500 tokens
- Prioritize the Suggested Prompt section (~120 tokens) - this is the key handoff mechanism
- Keep Summary concise (1-2 sentences)
- List only the most relevant Key Files (3-5 max)
- Use UTC timezone
- Tool name is "Codex CLI"
