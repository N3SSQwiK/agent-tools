---
name: maestro-challenge
description: Have spokes challenge the hub's plan before execution
disable-model-invocation: true
---

# Maestro Challenge Command

Have spokes challenge the hub's plan before execution.

## Purpose

Different AI models have different blind spots. Cross-tool challenge leverages this diversity to catch plan flaws before expensive execution.

## When to Use

After `/maestro plan`, before user approval or `/maestro run`.

## Behavior

1. Load plan from `.ai/MAESTRO.md`
   - If not exists: "No active plan. Run `/maestro plan <goal>` first."

2. Build challenge prompt with plan summary and codebase context

3. Dispatch to one or more spokes for analysis:
   - Default: Use a different tool than the hub
   - Flag `--tool=<name>` to specify challenger

4. Collect challenge responses

5. Synthesize feedback into categories:
   - Assumption issues
   - Missing dependencies
   - Scope concerns
   - Alternative approaches

6. Present challenges to user with response menu:
   ```
   How would you like to proceed?

   1. Revise — Incorporate feedback and update the plan
   2. Proceed — Continue with current plan despite concerns
   3. Reject — Discard this plan and start over
   4. Other — Type a different response
   ```

7. If user chooses to revise, update `.ai/MAESTRO.md`

## Challenge Handoff Template

Send to challenger spoke:

```markdown
## Task
Review this orchestration plan and challenge any assumptions, gaps, or issues.

## Plan Summary
**Goal:** [objective]

**Tasks:**
1. [task 1 description] - [specialist] via [tool]
2. [task 2 description] - [specialist] via [tool]
[etc.]

## Context
[Key files and patterns from reconnaissance]

## Challenge Focus
- Are there flawed assumptions about the codebase?
- Are dependencies between tasks correct?
- Are tasks appropriately scoped (not too large/small)?
- Are there better approaches the plan missed?
- Are success criteria testable and complete?

## Output Format
Return challenges as markdown with sections: Assumption Issues, Missing Dependencies, Scope Concerns, Alternative Approaches.
```

## Challenge Output Format

Display to user:

```markdown
## Plan Challenges

### Assumption Issues
- [Issue 1]: [explanation]
- [Issue 2]: [explanation]

### Missing Dependencies
- [Dependency 1]: [why needed]

### Scope Concerns
- [Task X]: [too large/small because...]

### Alternative Approaches
- [Alternative]: [why it might be better]

---
Challenger: [Tool Name]
```

Then present the response menu:
```
How would you like to proceed?

1. Revise — Incorporate feedback and update the plan
2. Proceed — Continue with current plan despite concerns
3. Reject — Discard this plan and start over
4. Other — Type a different response
```

## Flags

| Flag | Behavior |
|------|----------|
| `--tool=<name>` | Specify challenger tool (Gemini CLI, Codex CLI) |
| `--all` | Challenge with all available tools |

## Default Challenger Selection

If no tool specified:
- If hub is Claude → Challenge with Gemini CLI
- If hub is Gemini → Challenge with Codex CLI
- If hub is Codex → Challenge with Gemini CLI

## State Updates

If user chooses to revise:
1. Update tasks in `.ai/MAESTRO.md` based on feedback
2. Update Source timestamp
3. Add note to execution log (if logging enabled):

```
| [time] | Hub | Challenge | [Tool] | [tokens] | [duration] | revised | [summary of changes] |
```

## Rules

- Challenge before execution, not after
- Present all challenges objectively, don't dismiss concerns
- Let user make final decision on how to proceed
- Log challenge results if logging enabled
- A challenge finding "no issues" is valid and should be reported

## Examples

### Default challenge
```
/maestro challenge
```

### Challenge with specific tool
```
/maestro challenge --tool="Codex CLI"
```

### Challenge with all tools
```
/maestro challenge --all
```
