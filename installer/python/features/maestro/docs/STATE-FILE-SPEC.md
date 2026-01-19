# Maestro State File Specification

## Overview

The state file `.ai/MAESTRO.md` tracks orchestration state within a project. It is the single source of truth for task status, dependencies, and execution progress.

## Location

- **State file:** `.ai/MAESTRO.md`
- **Execution log:** `.ai/MAESTRO-LOG.md` (separate file, opt-in)

## File Format

```markdown
# Maestro Orchestration

## Goal
[High-level objective from /maestro plan]

## Tasks
| ID | Description | Status | Specialist | Tool | Depends |
|----|-------------|--------|------------|------|---------|
| 1 | [task description] | pending | code | Gemini | - |
| 2 | [task description] | pending | test | Codex | 1 |

## Source
[Hub Tool] | [YYYY-MM-DD HH:MM UTC]
```

## Field Definitions

### Goal

The high-level objective provided to `/maestro plan`. Remains constant throughout orchestration.

### Tasks Table

| Column | Description | Values |
|--------|-------------|--------|
| ID | Unique task identifier | Sequential integer starting at 1 |
| Description | Clear, atomic task description | Free text |
| Status | Current execution state | `pending`, `running`, `done`, `failed`, `blocked` |
| Specialist | Task role assignment | `code`, `review`, `test`, `research` |
| Tool | Assigned CLI tool | `Claude Code`, `Gemini CLI`, `Codex CLI` |
| Depends | Task dependencies | Comma-separated IDs or `-` for none |

### Status Values

| Status | Meaning |
|--------|---------|
| `pending` | Not yet started, waiting for dependencies or dispatch |
| `running` | Currently being executed by assigned tool |
| `done` | Successfully completed, all criteria satisfied |
| `failed` | Execution failed, may trigger retry or escalation |
| `blocked` | Cannot proceed, requires user intervention |

### Source

Attribution field with:
- **Hub Tool:** The tool acting as orchestrator (e.g., "Claude Code")
- **Timestamp:** UTC timestamp of last update

## Execution Log Format

When logging is enabled (`--log=summary` or `--log=detailed`), execution details are written to `.ai/MAESTRO-LOG.md`:

```markdown
# Maestro Execution Log

## Session: [YYYY-MM-DD HH:MM UTC]
**Goal:** [objective]

| Time | Actor | Action | Target | Tokens | Duration | Outcome | Notes |
|------|-------|--------|--------|--------|----------|---------|-------|
| HH:MM:SS | Hub | Recon | Explore subagent | 1,247 | 12s | success | Found patterns |
| HH:MM:SS | Hub | Dispatch | Gemini (code) | 27,316 | 45s | success | Task 1 complete |
| HH:MM:SS | Hub | Dispatch | Codex (test) | 8,072 | 23s | failed | Missing context |
| HH:MM:SS | Hub | Retry | Codex (test) | 12,105 | 31s | success | Context expanded |

## Totals
| Tool | Dispatches | Tokens | Failures | Retries |
|------|------------|--------|----------|---------|
| Gemini CLI | 2 | 42,546 | 0 | 0 |
| Codex CLI | 2 | 20,177 | 1 | 1 |
| Subagents | 1 | 1,247 | 0 | 0 |
| **Total** | **5** | **63,970** | **1** | **1** |
```

### Log Columns

| Column | Description |
|--------|-------------|
| Time | HH:MM:SS timestamp |
| Actor | Always "Hub" - the orchestrating tool |
| Action | `Recon`, `Dispatch`, `Retry`, `Review`, `Complete` |
| Target | Tool and specialist (e.g., "Gemini (code)") or subagent name |
| Tokens | Token count for this action |
| Duration | Execution time in seconds |
| Outcome | `success`, `failed`, `partial`, `blocked` |
| Notes | Brief context or reason |

## Verbosity Levels

| Level | State File | Log File | Use Case |
|-------|------------|----------|----------|
| `off` (default) | Updated | Not created | Quick tasks |
| `summary` | Updated | Actions + outcomes | Cost tracking |
| `detailed` | Updated | Full prompts/outputs | Debugging |

### Setting Logging Level

Logging level can be set two ways:

1. **Interactive menu** (recommended) — After plan approval, select from:
   ```
   Select logging level for this orchestration:

   1. None (default) — No execution log created
   2. Summary — Log actions, outcomes, token counts to .ai/MAESTRO-LOG.md
   3. Detailed — Log full prompts and outputs (useful for debugging)
   ```

2. **Command flag** — Pass `--log=summary` or `--log=detailed` with the plan command:
   ```
   /maestro plan "goal" --log=summary
   ```
   This skips the interactive menu.

## Lifecycle

1. **Created:** When `/maestro plan` is approved by user
2. **Updated:** After each task status change
3. **Archived:** User may rename/delete after orchestration completes
4. **Not created:** If user rejects plan or orchestration never starts

## Example

```markdown
# Maestro Orchestration

## Goal
Add user authentication with JWT tokens and session management

## Tasks
| ID | Description | Status | Specialist | Tool | Depends |
|----|-------------|--------|------------|------|---------|
| 1 | Implement JWT token generation utility | done | code | Gemini CLI | - |
| 2 | Create auth middleware for protected routes | running | code | Gemini CLI | 1 |
| 3 | Write unit tests for JWT utility | pending | test | Codex CLI | 1 |
| 4 | Write integration tests for auth flow | pending | test | Codex CLI | 2,3 |
| 5 | Security review of auth implementation | pending | review | Claude Code | 2 |

## Source
Claude Code | 2026-01-16 14:30 UTC
```
