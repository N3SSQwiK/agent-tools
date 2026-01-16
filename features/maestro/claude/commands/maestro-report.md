# Maestro Report Command

Generate a human-readable walkthrough from the execution log.

## Behavior

1. Check for `.ai/MAESTRO-LOG.md`
   - If not exists: "No execution log found. Run with `--log=summary` or `--log=detailed` to enable logging."

2. Parse execution log entries

3. Generate narrative report with:
   - Goal and plan summary
   - Step-by-step execution narrative
   - Token usage breakdown
   - Failure analysis (if any)
   - Timing analysis
   - Recommendations

4. Output to stdout or file (if `--output` specified)

## Report Format

```markdown
# Maestro Execution Report

## Summary
**Goal:** [objective]
**Duration:** [total time]
**Outcome:** [success | partial | failed]

## Execution Narrative

### Phase 1: Planning
[timestamp] - Hub analyzed goal and codebase context.
[timestamp] - Plan created with [N] tasks.
[If challenged] - Plan challenged by [tool], [N] issues found.
[If revised] - Plan revised based on feedback.

### Phase 2: Execution

**Task 1: [description]**
- Dispatched to [tool] ([specialist])
- Duration: [time], Tokens: [count]
- Outcome: [success/failed]
- [If failed] Retry: [context expansion/decomposition/etc.]

**Task 2: [description]**
...

### Phase 3: Review
[If reviews occurred]
- Task [N] reviewed by [tool]: [verdict]
...

## Token Usage

| Tool | Dispatches | Tokens | Avg/Dispatch |
|------|------------|--------|--------------|
| Gemini CLI | [N] | [total] | [avg] |
| Codex CLI | [N] | [total] | [avg] |
| Subagents | [N] | [total] | [avg] |
| **Total** | **[N]** | **[total]** | - |

## Failures & Resolutions

| Task | Failure | Resolution |
|------|---------|------------|
| [task] | [error] | [how resolved] |

## Timing Analysis

| Phase | Duration | % of Total |
|-------|----------|------------|
| Planning | [time] | [%] |
| Execution | [time] | [%] |
| Review | [time] | [%] |
| Retries | [time] | [%] |

## Recommendations

Based on this execution:

1. **[Category]**: [specific recommendation]
2. **[Category]**: [specific recommendation]

---
Generated: [timestamp]
Source: `.ai/MAESTRO-LOG.md`
```

## Recommendation Categories

Generate actionable recommendations based on patterns:

| Pattern | Recommendation |
|---------|----------------|
| High retry rate | "Consider decomposing tasks further" |
| Token budget exceeded | "Review context injection - may be including too much" |
| One tool consistently fails | "Check [tool] configuration or avoid for [task type]" |
| Long execution time | "Identify parallelization opportunities" |
| Scope creep in reviews | "Add clearer constraints to task handoffs" |

## Flags

| Flag | Behavior |
|------|----------|
| `--output=<path>` | Write report to file instead of stdout |
| `--format=json` | Output as JSON (for programmatic use) |
| `--brief` | Short summary only (skip detailed narrative) |

## JSON Output Format

When `--format=json`:

```json
{
  "goal": "[objective]",
  "duration": "[total time in seconds]",
  "outcome": "success",
  "tasks": {
    "total": 5,
    "completed": 5,
    "failed": 0
  },
  "tokens": {
    "gemini": 42546,
    "codex": 20177,
    "subagents": 1247,
    "total": 63970
  },
  "retries": 1,
  "reviews": 2,
  "recommendations": [
    "Consider decomposing tasks further"
  ]
}
```

## Brief Output Format

When `--brief`:

```
Maestro Report: [goal]
Outcome: success | Duration: 12m 34s | Tasks: 5/5 | Tokens: 63,970
Failures: 1 (resolved) | Recommendations: 2
Full report: /maestro report
```

## Rules

- Only available if execution logging was enabled
- Generate recommendations based on actual patterns, not generic advice
- Include all failures and how they were resolved
- Calculate percentages and averages for analysis
- Use relative time descriptions where helpful

## Examples

### Generate report to stdout
```
/maestro report
```

### Save report to file
```
/maestro report --output=reports/auth-implementation.md
```

### Brief summary
```
/maestro report --brief
```

### JSON for CI/CD
```
/maestro report --format=json
```
