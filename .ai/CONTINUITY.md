# Continuity

## Summary
Nexus-AI is a TUI installer for configuring AI assistant CLI tools (Claude Code, Gemini CLI, Codex CLI) with shared features. Maestro v2 multi-agent orchestration is production-ready with robust dispatch patterns, guardrails, and standardized UX.

## Completed
- Applied and archived `fix-maestro-dispatch-patterns` OpenSpec change
- Added spoke guardrails (5 strict rules) to all task handoff prompts
- Standardized all user decision points to structured numbered menus
- Added "Other" option to challenge/review menus for free-text input
- Updated main spec with CLI Dispatch Patterns, Structured Menus, Guardrails
- Updated all Maestro documentation (README, TROUBLESHOOTING, STATE-FILE-SPEC)
- Validated fixes with cross-tool testing (Claude, Gemini, Codex spokes)

## In Progress
None

## Blocked
None

## Key Files
- `openspec/specs/maestro-orchestration/spec.md` - Main Maestro specification (19 requirements)
- `features/maestro/claude/commands/maestro-*.md` - Claude slash commands with menus
- `features/maestro/docs/TROUBLESHOOTING.md` - New sections for permissions, guardrails, tokens
- `openspec/changes/archive/2026-01-17-fix-maestro-dispatch-patterns/` - Archived change

## Context
- All work committed and pushed to `main` branch
- No active OpenSpec changes (clean slate)
- Known limitation: global instructions can override spoke guardrails
- Future optimizations identified: hub file injection for Codex/Claude spokes

## Suggested Prompt
> Consider creating an OpenSpec change for hub file injection optimization -
> pre-injecting file contents for Codex/Claude spokes like Gemini's `@path` syntax.
> Alternatively, explore global instruction isolation for spoke sessions to prevent
> guardrail conflicts. Review `docs/FUTURE.md` and findings in archived assessment
> at `openspec/changes/archive/2026-01-17-fix-maestro-dispatch-patterns/`.

## Source
Claude Code | 2026-01-18 06:29 UTC
