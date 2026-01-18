# Maestro User Guide

## Prerequisites

Before using Maestro, ensure you have:

1. **Authenticated CLI tools** - Each tool you want to use as a spoke must be configured (OAuth or API key)
   - Claude Code: Anthropic account or API key
   - Gemini CLI: Google account or API key
   - Codex CLI: OpenAI account or API key

2. **Project context** - Maestro works best when run from a project root

## Workflow Overview

```
┌─────────────────────────────────────────────────────────────┐
│  /maestro plan "goal"                                       │
│  Hub analyzes codebase → Creates task breakdown             │
│  User approves/modifies plan                                │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│  /maestro challenge (optional)                              │
│  Different tool challenges plan assumptions                 │
│  Hub revises plan based on feedback                         │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│  /maestro run                                               │
│  Hub dispatches tasks to spokes                             │
│  Collects results, validates, updates state                 │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│  /maestro review (optional)                                 │
│  Cross-tool review of completed work                        │
│  Hub accepts or requests revision                           │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│  /maestro report (if logging enabled)                       │
│  Generate execution walkthrough and recommendations         │
└─────────────────────────────────────────────────────────────┘
```

## State Files

Maestro uses two files to track orchestration state:

| File | Purpose | Created By | Required |
|------|---------|------------|----------|
| `.ai/MAESTRO.md` | Task state, status, dependencies | `/maestro plan` | Yes |
| `.ai/MAESTRO-LOG.md` | Execution timeline, token tracking | `/maestro plan --log=*` | No (opt-in) |

### When Files Are Created and Updated

```
/maestro plan ──────► Creates .ai/MAESTRO.md (on user approval)
                      Creates .ai/MAESTRO-LOG.md (if --log flag)

/maestro challenge ──► Updates .ai/MAESTRO.md (if plan revised)
                       Appends to .ai/MAESTRO-LOG.md (if logging)

/maestro run ────────► Updates .ai/MAESTRO.md (task status changes)
                       Appends to .ai/MAESTRO-LOG.md (if logging)

/maestro review ─────► Updates .ai/MAESTRO.md (if revision requested)
                       Appends to .ai/MAESTRO-LOG.md (if logging)

/maestro status ─────► Reads .ai/MAESTRO.md (no modifications)

/maestro report ─────► Reads .ai/MAESTRO-LOG.md (no modifications)
```

### State File Format

`.ai/MAESTRO.md` contains:

```markdown
# Maestro Orchestration

## Goal
[High-level objective from /maestro plan]

## Tasks
| ID | Description | Status | Specialist | Tool | Depends |
|----|-------------|--------|------------|------|---------|
| 1 | Implement JWT validation | done | code | Gemini CLI | - |
| 2 | Write unit tests | running | test | Codex CLI | 1 |
| 3 | Security review | pending | review | Claude Code | 1 |

## Source
Claude Code | 2026-01-16 14:30 UTC
```

**Status values:** `pending`, `running`, `done`, `failed`, `blocked`

## Planning Tasks

### Basic Planning

```
/maestro plan "add logout button to navbar"
```

### Planning with Logging

```
/maestro plan "refactor database layer" --log=summary
```

### What Happens During Planning

1. **Reconnaissance**: Hub explores your codebase to understand patterns
2. **Decomposition**: Goal is broken into atomic tasks
3. **Assignment**: Each task gets a specialist and tool
4. **Validation**: Tasks are checked against AAVSR criteria
5. **Approval**: Plan is presented for your review
6. **Logging Selection**: If approved, you're prompted to select a logging level:
   ```
   Select logging level for this orchestration:

   1. None (default) — No execution log created
   2. Summary — Log actions, outcomes, token counts to .ai/MAESTRO-LOG.md
   3. Detailed — Log full prompts and outputs (useful for debugging)
   ```
   **Note:** This step is skipped if you passed `--log=summary` or `--log=detailed` with the command.

### AAVSR Criteria

Every task must pass these checks:

- **Atomic**: Single responsibility, one outcome
- **Authority**: Assigned specialist can complete it
- **Verifiable**: Success criteria are testable
- **Scope**: Fits within boundaries
- **Risk**: Acceptable failure impact

## Challenging Plans

Before execution, have another tool challenge the plan:

```
/maestro challenge
```

This catches:
- Flawed assumptions about the codebase
- Missing dependencies between tasks
- Tasks that are too large or small
- Better alternative approaches

### Specifying Challenger

```
/maestro challenge --tool="Codex CLI"
/maestro challenge --all  # All available tools
```

## Executing Tasks

### Run All

```
/maestro run
```

### Run Specific Task

```
/maestro run 3
```

### Dry Run

See what would execute without dispatching:

```
/maestro run --dry-run
```

### Run with Logging

```
/maestro run --log=detailed
```

### What Happens During Execution

For each runnable task (status=`pending`, dependencies satisfied):

```
┌─────────────────────────────────────────────────────────────────────┐
│  1. PRE-DELEGATION RECON                                            │
│     Cheap checks before expensive dispatch                          │
│     - Verify files exist                                            │
│     - Check dependencies completed successfully                     │
└──────────────────────────────┬──────────────────────────────────────┘
                               ▼
┌─────────────────────────────────────────────────────────────────────┐
│  2. AAVSR VALIDATION                                                │
│     Re-verify task is well-formed before dispatch                   │
└──────────────────────────────┬──────────────────────────────────────┘
                               ▼
┌─────────────────────────────────────────────────────────────────────┐
│  3. BUILD TASK HANDOFF                                              │
│     Create structured prompt for spoke tool                         │
└──────────────────────────────┬──────────────────────────────────────┘
                               ▼
┌─────────────────────────────────────────────────────────────────────┐
│  4. DISPATCH TO SPOKE                                               │
│     Execute CLI command for assigned tool                           │
│     - Gemini: gemini -p "<prompt>" -y -o json                       │
│     - Codex: codex exec "<prompt>" --full-auto --json               │
│     - Claude: claude -p "<prompt>" --output-format json             │
│               --dangerously-skip-permissions                        │
└──────────────────────────────┬──────────────────────────────────────┘
                               ▼
┌─────────────────────────────────────────────────────────────────────┐
│  5. COLLECT & VALIDATE RESULT                                       │
│     Parse spoke output, run quality gates                           │
└──────────────────────────────┬──────────────────────────────────────┘
                               ▼
                    ┌──────────┴──────────┐
                    ▼                     ▼
              [SUCCESS]              [FAILURE]
                    │                     │
                    ▼                     ▼
            Update state          Retry Ladder
            (task → done)         (see below)
```

### Task Handoff Format

When dispatching to a spoke, the hub sends:

```markdown
## Task
[Clear, atomic task description]

## Context
[Relevant files, patterns, constraints discovered during recon]

## Success Criteria
- [ ] [Testable criterion 1]
- [ ] [Testable criterion 2]

## Constraints
- [Scope boundary - what NOT to do]

## Guardrails

> **🚨 STRICT RULES — VIOLATIONS WILL CAUSE TASK REJECTION**
>
> 1. **ONLY modify files explicitly listed** — Do not touch any other files
> 2. **ONLY run commands required for THIS task** — No exploratory commands
> 3. **DO NOT install dependencies** unless explicitly requested
> 4. **DO NOT expand scope** — If additional work is needed, report it in Issues
> 5. **STOP if blocked** — Do not improvise solutions; report blockers instead

## Output Format
Return result as markdown with Status, Summary, Changes, Verification, Issues sections.

**You MUST use this exact format. Non-compliant responses will be rejected.**
```

### Quality Gates

Before accepting a spoke's result, the hub validates:

| Gate | Check | On Failure |
|------|-------|------------|
| **Format** | Result has required sections (Status, Summary, Changes, Verification, Issues) | Retry with clarified format |
| **Criteria** | All success criteria addressed | Retry with focus on gaps |
| **Scope** | No out-of-scope changes reported | Accept in-scope work, note scope creep |

### Retry Ladder

When a task fails, the hub escalates through these steps:

| Step | Action | When Used |
|------|--------|-----------|
| 1 | **Immediate Retry** | Network errors, timeouts with partial output |
| 2 | **Context Expansion** | Spoke reported missing context |
| 3 | **Task Decomposition** | Task too complex for single dispatch |
| 4 | **User Escalation** | All retries exhausted, human decision needed |

### Timeout Handling

CLI tools may return exit code 124 (timeout). This doesn't always mean failure:

1. Hub checks if output is structurally complete
2. If complete → Accept as "soft success", log warning
3. If incomplete → Trigger retry ladder

## Reviewing Work

After a spoke completes work, have another tool review it:

```
/maestro review        # Review most recent task
/maestro review 3      # Review specific task
/maestro review --auto # Auto-accept if approved
```

## Monitoring Status

```
/maestro status
```

Shows:
- Goal
- Task completion progress
- Current status of each task
- Blocking issues
- Suggested next action

### JSON Output

```
/maestro status --json
```

## Generating Reports

After orchestration with logging enabled:

```
/maestro report
```

Generates:
- Execution narrative
- Token usage breakdown
- Failure analysis
- Timing analysis
- Recommendations

### Report Options

```
/maestro report --output=reports/auth.md
/maestro report --format=json
/maestro report --brief
```

## Best Practices

### 1. Start Small

Begin with simple orchestrations to understand the workflow before complex multi-task plans.

### 2. Use Challenge for Complex Work

For architectural changes or security-sensitive work, always run `/maestro challenge`.

### 3. Enable Logging for Refinement

Use `--log=summary` to understand token usage and optimize future orchestrations.

### 4. Review Security-Sensitive Tasks

Never skip cross-tool review for authentication, authorization, or data handling code.

### 5. Clean Up State Files

After orchestration completes, remove or archive `.ai/MAESTRO.md` and `.ai/MAESTRO-LOG.md`.

## Token Efficiency

Maestro is designed for token efficiency:

- **Global footprint**: ~50 tokens at session start
- **On-demand loading**: Full protocol loads only when commands are invoked
- **Pre-delegation recon**: Cheap checks before expensive dispatches
- **Gemini @path syntax**: 9.2x more efficient than inline content

### Cost Management

Token and cost management is your responsibility. Each CLI tool has its own billing model:

- **Claude Code:** Subscription or API billing; use `--max-turns` and `--max-budget-usd` flags
- **Gemini CLI:** Google Cloud billing
- **Codex CLI:** OpenAI billing

**Tips:**
- Start with smaller orchestrations to calibrate cost expectations
- Enable `--log=summary` to track token usage patterns
- Review `.ai/MAESTRO-LOG.md` after orchestration to inform future planning

## Quick Reference

### Commands

| Command | Purpose | Modifies State? |
|---------|---------|-----------------|
| `/maestro plan <goal>` | Create task breakdown | Creates files |
| `/maestro challenge` | Cross-tool plan critique | May update plan |
| `/maestro run [id]` | Execute tasks | Updates status |
| `/maestro review [id]` | Cross-tool code review | May revert status |
| `/maestro status` | Show current state | Read-only |
| `/maestro report` | Generate walkthrough | Read-only |

### Specialists

| Specialist | Role | Example Tasks |
|------------|------|---------------|
| `code` | Implementation | Write code, refactor, fix bugs |
| `review` | Quality assurance | Code review, security audit |
| `test` | Validation | Write tests, run test suites |
| `research` | Discovery | Search codebase, read docs |

### Flags

| Flag | Available On | Effect |
|------|--------------|--------|
| `--log=summary` | `plan`, `run` | Enable basic execution logging |
| `--log=detailed` | `plan`, `run` | Enable verbose logging with prompts/outputs |
| `--dry-run` | `run` | Preview execution without dispatching |
| `--tool="..."` | `challenge` | Specify challenger tool |
| `--all` | `challenge` | Use all available tools as challengers |
| `--auto` | `review` | Auto-accept if review passes |
| `--json` | `status`, `report` | Output as JSON |
| `--output=path` | `report` | Write report to file |

### Task Status Flow

```
pending ──► running ──► done
                   └──► failed ──► (retry) ──► running
                   └──► blocked ──► (user action) ──► pending
```
