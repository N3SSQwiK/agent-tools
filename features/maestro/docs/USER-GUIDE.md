# Maestro User Guide

## Prerequisites

Before using Maestro, ensure you have:

1. **Authenticated CLI tools** - Each tool you want to use as a spoke must be configured
   - Claude Code: Anthropic API key
   - Gemini CLI: Google account
   - Codex CLI: OpenAI API key

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

### Token Budgets

| Tool | Budget | Abort Threshold |
|------|--------|-----------------|
| Gemini CLI | 30,000 | 50,000 |
| Codex CLI | 40,000 | 60,000 |

If a spoke exceeds the abort threshold, the hub handles the task directly.
