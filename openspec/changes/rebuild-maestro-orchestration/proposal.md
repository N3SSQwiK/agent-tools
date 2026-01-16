# Proposal: Rebuild Maestro Multi-Agent Orchestration

## Problem Statement

Maestro v1 was a multi-agent orchestration system where Claude Code acted as the orchestrator, delegating work to Gemini CLI and Codex CLI to reduce token usage and maximize parallel work.

**V1 Issues:**
1. **Claude-only orchestrator** - Hardcoded assumption limits flexibility
2. **No slash commands** - Protocol was documentation-based, leading to inconsistent usage
3. **Protocol drift** - Agent frequently defaulted to internal logic instead of following the orchestration protocol
4. **Hardcoded paths** - Tied to specific project directories
5. **Manual state management** - No automated tracking of orchestration state

## Proposed Solution

Rebuild Maestro as a **tool-agnostic Hub-and-Spoke orchestration system** with:

1. **Any tool as Hub** - Claude, Gemini, or Codex can orchestrate
2. **Granular slash commands** - `/maestro plan`, `/maestro challenge`, `/maestro run`, `/maestro review`, `/maestro status`, `/maestro report`
3. **Structured I/O schemas** - Enforce protocol via required input/output formats
4. **Atomic task design** - Small, well-defined, independent tasks
5. **Central state file** - `.ai/MAESTRO.md` for orchestration tracking
6. **Hybrid persistence** - Stateful within session, optional persistence across sessions

### Key Design Decisions

1. **Hub-and-Spoke model** - Central hub dispatches to specialists, handles normalization
2. **Atomic tasks** - Single responsibility, testable, parallelizable
3. **Hub injects context** - Most token-efficient approach
4. **User approval checkpoint** - Hub proposes decomposition, user approves before execution
5. **Hybrid specialists** - Ship predefined roles, allow custom definitions

### Retained from V1

- Structured templates (Task Handoff, Result Submission)
- Pre-delegation reconnaissance pattern
- Precondition checks (Atomic, Authority, Verifiable, Scope, Risk)
- Token efficiency patterns (@path for Gemini)
- Quality gates and retry ladders
- Failure runbook approach
- Token budget ceilings and cost tracking
- Timeout soft-success pattern (exit 124 handling)

## Scope

### In Scope
- Slash commands for all three tools: `/maestro plan`, `/maestro challenge`, `/maestro run`, `/maestro review`, `/maestro status`, `/maestro report`
- Opt-in execution logging with verbosity levels (off/summary/detailed)
- Global instructions for hub behavior
- Structured input/output schemas
- Central state file (`.ai/MAESTRO.md`)
- Predefined specialists (code, review, test, research)
- Cross-tool orchestration (any tool can spawn any other)
- Failure handling with user prompts
- Token budget enforcement and cost tracking
- V2 documentation (README, user guide, troubleshooting, spoke contract)
- Archive v1 documentation to `docs/maestro-v1/`

### Out of Scope
- Custom specialist definitions (future enhancement)
- API key-based orchestration (session-based only)
- Multi-user coordination
- Distributed orchestration across machines

## Success Criteria

1. Any tool can act as orchestrator using the same protocol
2. Slash commands enforce consistent protocol usage
3. Atomic tasks execute reliably across tool boundaries
4. State persists correctly in `.ai/MAESTRO.md`
5. User approval checkpoint prevents runaway token spend
6. Normalized outputs regardless of which tool executes
