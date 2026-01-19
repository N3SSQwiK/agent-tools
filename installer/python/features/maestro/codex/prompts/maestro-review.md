---
description: Have a different spoke review completed work
argument-hint: [task-id]
---

## Goal

Have a different spoke review completed work before hub accepts it.

## Purpose

Cross-tool review catches issues the original spoke missed. Mirrors human code review principle: author != reviewer.

## Behavior

1. Identify task to review:
   - If task ID provided: Review that task
   - Otherwise: Review most recently completed task

2. Verify task is reviewable:
   - Status must be `done` or have pending result
   - If no reviewable tasks: "No completed tasks to review."

3. Build review prompt with:
   - Original task description
   - Success criteria
   - Spoke's result (changes, verification)
   - Relevant codebase context

4. Dispatch to reviewer spoke:
   - Default: Use different tool than original spoke
   - Flag `--tool=<name>` to specify reviewer

5. Collect review feedback

6. Present review to user with response menu:
   ```
   How would you like to proceed?

   1. Accept — Approve the work as-is
   2. Revise — Request changes from original spoke
   3. Flag — Escalate for manual resolution
   4. Other — Type a different response
   ```

7. Update state based on user decision

## Review Handoff Template

Send to reviewer spoke:

```markdown
## Task
Review the following completed work against success criteria.

## Original Task
[Task description from plan]

## Success Criteria
- [ ] [Criterion 1]
- [ ] [Criterion 2]

## Completed Work
**Status:** [spoke's reported status]
**Changes:** [List of changes from spoke result]
**Spoke's Verification:** [How spoke verified criteria]

## Context
[Relevant files for review]

## Review Focus
- Do changes satisfy success criteria?
- Are there bugs, security issues, or quality concerns?
- Does the work follow codebase patterns and conventions?
- Is there scope creep?
- Are there edge cases not handled?

## Output Format
Return review as markdown with sections: Verdict, Issues Found, Recommendations.
```

## Verdict Values

- `approve`: Work meets criteria - Accept and mark done
- `request-changes`: Fixable issues found - Send back to original spoke
- `flag-issues`: Significant concerns - Escalate to user

## Default Reviewer Selection

If no tool specified:
- If original spoke was Gemini → Review with Claude Code
- If original spoke was Codex → Review with Gemini
- If original spoke was Claude → Review with Gemini

## Rules

- Never skip review for security-sensitive tasks
- Reviewer must be different from original spoke
- Present all issues objectively
- Let user make final accept/reject decision
- Hub tool name is "Codex CLI"

## Flags

- `--tool=<name>`: Specify reviewer tool
- `--auto`: Auto-accept if verdict is approve
