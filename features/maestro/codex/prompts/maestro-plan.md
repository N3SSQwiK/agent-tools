---
description: Decompose a goal into atomic tasks for multi-agent orchestration
argument-hint: <goal>
---

## Goal

Decompose a high-level goal into atomic tasks for multi-agent orchestration.

## Behavior

1. Parse the goal from user input

2. Understand codebase context:
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
   - Present approval menu:
   ```
   Ready to proceed with this plan?

   1. Approve — Accept the plan and continue
   2. Modify — Adjust tasks, tools, or dependencies
   3. Reject — Discard this plan and start over
   ```

6. If approved, prompt for logging level (unless `--log` flag was provided):
   ```
   Select logging level for this orchestration:

   1. None (default) — No execution log created
   2. Summary — Log actions, outcomes, token counts to .ai/MAESTRO-LOG.md
   3. Detailed — Log full prompts and outputs (useful for debugging)
   ```

7. Write plan to `.ai/MAESTRO.md`

8. If logging enabled (via menu selection or `--log` flag), initialize `.ai/MAESTRO-LOG.md`

## Precondition Checks (AAVSR)

Validate each task against:
- **Atomic:** Single responsibility, one clear outcome?
- **Authority:** Assigned specialist can complete this?
- **Verifiable:** Success criteria are testable?
- **Scope:** Task fits within boundaries?
- **Risk:** Acceptable failure impact?

If any check fails, decompose further or adjust assignment.

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
Codex CLI | [YYYY-MM-DD HH:MM UTC]
```

## Rules

- Tasks must be atomic - if unsure, decompose further
- Each task needs at least one testable success criterion
- Never auto-approve - always get user confirmation
- Use UTC timezone for timestamps
- Hub tool name is "Codex CLI"

## Logging Configuration

Logging level can be set two ways:

1. **Interactive selection** (recommended) — After plan approval, user selects from menu
2. **Flag** — Pass `--log=summary` or `--log=detailed` with the command

| Method | Behavior |
|--------|----------|
| Menu: "None" or no flag | No logging |
| Menu: "Summary" or `--log=summary` | Create `.ai/MAESTRO-LOG.md`, log actions and outcomes |
| Menu: "Detailed" or `--log=detailed` | Log full prompts and outputs |

**Note:** If `--log` flag is provided, skip the interactive menu.
