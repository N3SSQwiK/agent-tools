# Maestro Plan Command

Decompose a high-level goal into atomic tasks for multi-agent orchestration.

## Behavior

1. Parse goal from user input: `/maestro plan <goal>` or `/maestro plan "<goal with spaces>"`

2. Use Explore subagent to understand codebase context:
   - Find existing patterns relevant to the goal
   - Identify key files and dependencies
   - Understand current architecture

3. Decompose goal into atomic tasks:
   - Each task has single responsibility
   - Clear success criteria
   - Dependencies between tasks identified

4. Assign specialist and tool to each task:
   - **Specialists:** `code`, `review`, `test`, `research`
   - **Tools:** `Claude Code`, `Gemini CLI`, `Codex CLI`
   - User can modify assignments before approval

5. Present plan to user for approval:
   - Show goal, tasks, assignments
   - Ask: "Approve plan? (yes/no/modify)"

6. If approved, write to `.ai/MAESTRO.md`

7. If logging enabled (`--log=summary` or `--log=detailed`), initialize `.ai/MAESTRO-LOG.md`

## Precondition Checks (AAVSR)

Validate each task against:

| Check | Question |
|-------|----------|
| **A**tomic | Single responsibility, one clear outcome? |
| **A**uthority | Assigned specialist can complete this? |
| **V**erifiable | Success criteria are testable? |
| **S**cope | Task fits within boundaries? |
| **R**isk | Acceptable failure impact? |

If any check fails, decompose further or adjust assignment.

## Plan Output Format

```markdown
## Goal
[User's high-level objective]

## Reconnaissance
[Summary of codebase analysis - patterns found, key files, constraints discovered]

## Tasks

### Task 1: [description]
- **Specialist:** code
- **Tool:** Gemini CLI
- **Depends:** -
- **Success Criteria:**
  - [ ] [Testable criterion]

### Task 2: [description]
- **Specialist:** test
- **Tool:** Codex CLI
- **Depends:** 1
- **Success Criteria:**
  - [ ] [Testable criterion]

[Additional tasks...]

## Parallelization
[Which tasks can run concurrently after dependencies are satisfied]

## Estimated Token Budget
[Rough estimate based on task complexity]
```

## State File Format

After approval, write to `.ai/MAESTRO.md`:

```markdown
# Maestro Orchestration

## Goal
[High-level objective]

## Tasks
| ID | Description | Status | Specialist | Tool | Depends |
|----|-------------|--------|------------|------|---------|
| 1 | [description] | pending | code | Gemini CLI | - |
| 2 | [description] | pending | test | Codex CLI | 1 |

## Source
Claude Code | [YYYY-MM-DD HH:MM UTC]
```

## Logging Flag

| Flag | Behavior |
|------|----------|
| (none) | No logging |
| `--log=summary` | Create `.ai/MAESTRO-LOG.md`, log actions and outcomes |
| `--log=detailed` | Log full prompts and outputs |

Initialize log if enabled:

```markdown
# Maestro Execution Log

## Session: [YYYY-MM-DD HH:MM UTC]
**Goal:** [objective]

| Time | Actor | Action | Target | Tokens | Duration | Outcome | Notes |
|------|-------|--------|--------|--------|----------|---------|-------|
| [time] | Hub | Plan | - | [tokens] | [duration] | success | Plan created |
```

## Rules

- Always use Explore subagent for reconnaissance before decomposing
- Tasks must be atomic - if unsure, decompose further
- Each task needs at least one testable success criterion
- Never auto-approve - always get user confirmation
- Use UTC timezone for timestamps
- Hub tool name is "Claude Code"

## Examples

### Simple Feature
```
/maestro plan "add logout button to navbar"
```

### Complex Feature with Logging
```
/maestro plan "implement user authentication with JWT" --log=summary
```

### Multi-Step Refactor
```
/maestro plan "refactor database layer to use repository pattern"
```
