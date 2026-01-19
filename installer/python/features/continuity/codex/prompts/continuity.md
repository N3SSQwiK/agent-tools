---
description: Show continuity notes and ask whether to update them
argument-hint:
---

## Behavior

1. Check for `.ai/.legacy-checked` flag file
   - If exists, skip legacy scan and proceed to step 4
   - If not exists, proceed to step 2

2. Scan ALL legacy paths: `.claude/CONTINUITY.md`, `.gemini/CONTINUITY.md`, `.codex/CONTINUITY.md`

3. Handle legacy files based on whether `.ai/CONTINUITY.md` exists (see Legacy Check Logic below)

4. If `.ai/CONTINUITY.md` exists, display contents

5. Ask user: "Update continuity?"

6. If yes, write new summary using the format below

## Legacy Check Logic

### Case A: .ai/CONTINUITY.md EXISTS + legacy files found
Display warning listing all legacy files with their Source timestamps. Suggest user delete stale files after verifying `.ai/CONTINUITY.md` has latest context. After user acknowledges, create `.ai/.legacy-checked` with current UTC timestamp.

### Case B: .ai/CONTINUITY.md DOES NOT EXIST + ONE legacy file found
Offer to migrate: "Found legacy continuity file at [path]. Migrate to unified location (.ai/CONTINUITY.md)?"
If yes, migrate content (convert to new format if possible), then create `.ai/.legacy-checked`.

### Case C: .ai/CONTINUITY.md DOES NOT EXIST + MULTIPLE legacy files found
List all legacy files with their Source timestamps. Let user choose which to migrate to `.ai/CONTINUITY.md`. After migration, create `.ai/.legacy-checked`.

### Case D: No legacy files found
Proceed normally. Create `.ai/.legacy-checked` when first writing `.ai/CONTINUITY.md`.

## Format (~500 tokens)

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

## Rules
- Total content should be approximately 500 tokens
- Prioritize the Suggested Prompt section (~120 tokens) - this is the key handoff mechanism
- Keep Summary concise (1-2 sentences)
- List only the most relevant Key Files (3-5 max)
- Use UTC timezone
- Tool name is "Codex CLI"

## Update Rules (CRITICAL)

When updating an existing file, you MUST:

1. **Prune "In Progress"** - Move completed items to "Completed", remove finished work entirely from this section. Only list work that is genuinely incomplete.

2. **Prune "Completed"** - Keep only the 5-7 most recent/relevant items. Remove old items that are no longer useful context for the next session.

3. **Refresh "Suggested Prompt"** - This MUST reflect the ACTUAL next steps. Never leave stale instructions. Ask yourself: "If I started a fresh session and copy-pasted this prompt, would it make sense?"

4. **Update "Context"** - Remove outdated statements. If something was true last session but isn't now (e.g., "uncommitted changes" after committing), remove it.

5. **Update "Key Files"** - Reflect currently relevant files, not historical ones.
