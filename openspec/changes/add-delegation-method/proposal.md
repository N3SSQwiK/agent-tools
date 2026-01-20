# Change: Add Explicit Task Delegation Method to Maestro

## Why

Maestro currently specifies *what* to delegate (tasks with tool assignments) but not *how* to delegate. The execution mechanism differs based on tool capabilities:

- **Claude Code** has a native Task tool that spawns subagents within the same session (up to 7 parallel), providing isolation and guardrails without CLI process overhead
- **Gemini CLI** and **Codex CLI** lack within-session subagent support and must spawn separate CLI processes

Without explicit guidance, implementations may inconsistently choose delegation mechanisms, leading to:
- Unnecessary CLI spawn overhead when Claude Code delegates to itself
- Missed optimization opportunities
- Inconsistent behavior across hub configurations

## What Changes

### 1. Explicit Delegation Method Requirement (New)
- Define when to use Task tool (subagent) vs CLI spawn
- Claude Code self-delegation uses Task tool
- All other delegation uses CLI spawn

### 2. Update Run Command Documentation
- Document delegation method selection in `maestro-run.md` for each tool
- Update SPOKE-CONTRACT.md with delegation method guidance

## Relationship to Other Work

Builds on `maestro-spoke-availability` (approved, not yet implemented) which handles:
- Detecting which tools are available
- Storing availability in `.ai/MAESTRO.md`
- Constraining task assignment to available tools

This proposal addresses the *execution mechanism* after tool selection — a downstream concern.

## Impact

- **Affected specs**: `maestro-orchestration` (Run Command requirement)
- **Affected files**:
  - `installer/python/features/maestro/claude/commands/maestro-run.md`
  - `installer/python/features/maestro/codex/prompts/maestro-run.md`
  - `installer/python/features/maestro/gemini/extensions/maestro/commands/maestro-run.toml`
  - `installer/python/features/maestro/docs/SPOKE-CONTRACT.md`
