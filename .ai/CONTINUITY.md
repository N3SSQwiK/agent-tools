# Continuity

## Summary
Nexus-AI is a TUI installer for AI assistant CLI tools (Claude Code, Gemini CLI, Codex CLI). Distributed via Homebrew with automated release pipeline. Now licensed under AGPL-3.0-or-later.

## Completed
- Changed license from MIT to AGPL-3.0-or-later (main repo + Homebrew tap)
- Scaffolded `add-permissions-feature` OpenSpec proposal (Phases 1-2 only)
- Homebrew distribution working with tap repo (`N3SSQwiK/homebrew-nexus-ai`)
- Release automation: tag push triggers GitHub Release + tap formula auto-update
- Documented Homebrew learnings in `CLAUDE.md`

## In Progress
None — ready to begin implementation of any pending proposal.

## Research Ready
- **Maestro Hooks** (`docs/Research/maestro-hooks/`) - Self-enforcing hooks for Maestro commands: scope enforcement, CLI dispatch validation, auto-logging, state integrity, safety rails. Architecture designed, awaiting implementation.

## Pending OpenSpec Changes (Recommended Order)

| # | Change | Status | Rationale |
|---|--------|--------|-----------|
| 1 | `maestro-spoke-availability` | Pending | Foundation — detect available tools before planning |
| 2 | `add-hub-task-classification` | Pending | Classify tasks before dispatch |
| 3 | `add-delegation-method` | Pending | Complete dispatch logic (Task tool vs CLI spawn) |
| 4 | `add-continuity-hooks` | Pending | Event-driven triggers for continuity |
| 5 | `add-feature-uninstall` | Pending | TUI flow to remove features |
| 6 | `add-permissions-feature` | **New** | Docs + templates + audit logging (Phases 1-2) |

## Blocked
None

## Key Files
- `pyproject.toml` - Package config (now AGPL-3.0-or-later)
- `LICENSE` - Full AGPL v3 text (new)
- `openspec/changes/add-permissions-feature/` - New proposal (untracked)
- `docs/Research/permissions-feature/` - Research docs with templates

## Context
- v1.0.0 released; license change will ship with next release
- Permissions feature uses preset-based approach (no translation layer)
- Research folder has Phase 1 templates ready to integrate

## Suggested Prompt
> Three paths forward:
> 1. **Maestro hooks** — Implement self-enforcing hooks from `docs/Research/maestro-hooks/`.
>    Adds scope enforcement, CLI validation, auto-logging, and safety rails.
> 2. **Permissions feature** — Run `openspec apply add-permissions-feature` to begin
>    integrating templates into installer and building audit logging.
> 3. **Maestro spoke detection** — Run `openspec apply maestro-spoke-availability` to
>    start the foundation for tool availability detection.
> The permissions proposal is untracked — commit it first if you want to preserve it.

## Source
Claude Code | 2026-01-21 02:15 UTC
