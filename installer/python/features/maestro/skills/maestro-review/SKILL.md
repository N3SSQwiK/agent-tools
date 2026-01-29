---
name: maestro-review
description: Have a different spoke review completed work before hub accepts it
---

# Maestro Review Command

Have a different spoke review completed work before hub accepts it.

## Purpose

Cross-tool review catches issues the original spoke missed. Mirrors human code review principle: author != reviewer.

## When to Use

After a spoke completes a task, before hub marks it as done.

Can be invoked:
- Automatically during `/maestro run` (if configured)
- Manually via `/maestro review [task-id]`

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

**Changes:**
[List of changes from spoke result]

**Spoke's Verification:**
[How spoke verified criteria]

## Context
[Relevant files for review - use @path syntax for Gemini]

## Review Focus
- Do changes satisfy success criteria?
- Are there bugs, security issues, or quality concerns?
- Does the work follow codebase patterns and conventions?
- Is there scope creep (work beyond what was asked)?
- Are there edge cases not handled?

## Output Format
Return review as markdown with sections: Verdict, Issues Found, Recommendations.
```

## Review Output Format

Display to user:

```markdown
## Task Review

**Task:** [description]
**Original Spoke:** [tool name]
**Reviewer:** [tool name]

### Verdict
[approve | request-changes | flag-issues]

### Issues Found
- [Issue 1]: [severity] - [explanation]
- [Issue 2]: [severity] - [explanation]

### Recommendations
- [Recommendation 1]
- [Recommendation 2]

```

Then present the response menu:
```
How would you like to proceed?

1. Accept — Approve the work as-is
2. Revise — Request changes from original spoke
3. Flag — Escalate for manual resolution
4. Other — Type a different response
```

## Verdict Values

| Verdict | Meaning | Suggested Action |
|---------|---------|------------------|
| `approve` | Work meets criteria | Accept and mark done |
| `request-changes` | Fixable issues found | Send back to original spoke |
| `flag-issues` | Significant concerns | Escalate to user |

## Issue Severity

| Severity | Description |
|----------|-------------|
| `critical` | Breaks functionality, security vulnerability |
| `major` | Significant bug or missing requirement |
| `minor` | Style issue, minor improvement |
| `note` | Observation, no action required |

## Flags

| Flag | Behavior |
|------|----------|
| `--tool=<name>` | Specify reviewer tool |
| `--auto` | Auto-accept if verdict is approve |

## Default Reviewer Selection

If no tool specified:
- If original spoke was Gemini → Review with Codex
- If original spoke was Codex → Review with Gemini
- If original spoke was Claude → Review with Gemini

## State Updates

Based on user decision:

| Decision | State Change |
|----------|--------------|
| Accept | Mark task `done` in state file |
| Revision | Keep task status, note revision request |
| Flag | Mark task `blocked` with issue description |

Log if logging enabled:
```
| [time] | Hub | Review | [Reviewer] (review) | [tokens] | [duration] | [verdict] | [summary] |
```

## Rules

- Never skip review for security-sensitive tasks
- Reviewer must be different from original spoke
- Present all issues objectively
- Let user make final accept/reject decision
- Log review results if logging enabled

## Examples

### Review most recent task
```
/maestro review
```

### Review specific task
```
/maestro review 3
```

### Review with specific tool
```
/maestro review --tool="Codex CLI"
```

### Auto-accept approved reviews
```
/maestro review --auto
```
