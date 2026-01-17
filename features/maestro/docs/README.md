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
- Create a task breakdown
- Assign specialists and tools
- Present for your approval

### 2. Run

Execute the approved plan:

```
/maestro run
```

Or run a specific task:

```
/maestro run 3
```

### 3. Monitor

Check orchestration status:

```
/maestro status
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

## Execution Logging

Enable logging to track token usage and debug issues:

```
/maestro plan "goal" --log=summary
/maestro run --log=detailed
/maestro report
```

## Documentation

- [User Guide](USER-GUIDE.md) - Detailed usage instructions
- [Troubleshooting](TROUBLESHOOTING.md) - Common issues and fixes
- [State File Spec](STATE-FILE-SPEC.md) - State file format
- [Spoke Contract](SPOKE-CONTRACT.md) - Task handoff protocol
