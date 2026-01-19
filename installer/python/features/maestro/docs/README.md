# Maestro v2

**Multi-Agent Execution Strategy for Task Routing & Orchestration**

Maestro is a tool-agnostic hub-spoke orchestration system that enables any AI tool (Claude Code, Gemini CLI, Codex CLI) to coordinate multiple agents for complex tasks.

## Quick Start

### 1. Plan

Decompose a goal into atomic tasks:

```
/maestro plan "add user authentication with JWT"
```

This will:
- Analyze your codebase
- Create a task breakdown with specialists and tools
- Present a structured approval menu:
  ```
  Ready to proceed with this plan?

  1. Approve — Accept the plan and continue
  2. Modify — Adjust tasks, tools, or dependencies
  3. Reject — Discard this plan and start over
  ```

### 2. Select Logging Level

After approving the plan, you'll be prompted to select a logging level:

```
Select logging level for this orchestration:

1. None (default) — No execution log created
2. Summary — Log actions, outcomes, token counts to .ai/MAESTRO-LOG.md
3. Detailed — Log full prompts and outputs (useful for debugging)
```

You can skip this by passing `--log=summary` or `--log=detailed` with the plan command.

### 3. Challenge (Optional)

Have a different AI tool challenge the plan:

```
/maestro challenge
```

Review feedback and choose:
```
How would you like to proceed?

1. Revise — Incorporate feedback and update the plan
2. Proceed — Continue with current plan despite concerns
3. Reject — Discard this plan and start over
4. Other — Type a different response
```

### 4. Run

Execute the approved plan:

```
/maestro run
```

Or run a specific task:

```
/maestro run 3
```

### 5. Review (Optional)

Have another tool review completed work:

```
/maestro review
```

### 6. Monitor

Check orchestration status:

```
/maestro status
```

Generate an execution report (requires logging):

```
/maestro report
```

## Commands

| Command | Purpose |
|---------|---------|
| `/maestro plan <goal>` | Decompose goal into tasks |
| `/maestro challenge` | Have spokes challenge the plan |
| `/maestro run [task-id]` | Execute plan or specific task |
| `/maestro review [task-id]` | Cross-tool review of completed work |
| `/maestro status` | Display current state |
| `/maestro report` | Generate execution walkthrough |

## Key Concepts

### Hub and Spoke

- **Hub**: The AI tool coordinating the work (can be any tool)
- **Spoke**: AI tool executing a delegated task

### Specialists

| Specialist | Role |
|------------|------|
| `code` | Write code, refactor, fix bugs |
| `review` | Code review, security audit |
| `test` | Write tests, verify behavior |
| `research` | Search codebase, read docs |

### State Files

- `.ai/MAESTRO.md` - Orchestration state (tasks, status)
- `.ai/MAESTRO-LOG.md` - Execution log (opt-in)

## User Interaction

All decision points use structured numbered menus for consistency:

| Decision Point | Options |
|----------------|---------|
| Plan approval | Approve, Modify, Reject |
| Logging level | None, Summary, Detailed |
| Challenge response | Revise, Proceed, Reject, Other |
| Review response | Accept, Revise, Flag, Other |

The "Other" option allows free-text input for custom responses.

## Spoke Guardrails

When tasks are dispatched to spokes, they include strict guardrails:

1. **ONLY modify files explicitly listed**
2. **ONLY run commands required for THIS task**
3. **DO NOT install dependencies** unless explicitly requested
4. **DO NOT expand scope**
5. **STOP if blocked** — report blockers instead of improvising

These guardrails prevent scope creep and ensure predictable execution.

## CLI Dispatch Patterns

The hub uses these patterns when dispatching to spokes:

| Tool | Command Pattern |
|------|-----------------|
| Claude Code | `claude -p "..." --output-format json --dangerously-skip-permissions` |
| Gemini CLI | `gemini -p "..." -y -o json` |
| Codex CLI | `codex exec "..." --full-auto --json` |

All flags are required for proper file write permissions.

## Documentation

- [User Guide](USER-GUIDE.md) - Detailed usage instructions
- [Troubleshooting](TROUBLESHOOTING.md) - Common issues and fixes
- [State File Spec](STATE-FILE-SPEC.md) - State file format
- [Spoke Contract](SPOKE-CONTRACT.md) - Task handoff protocol
