# Continuity

## Summary
Nexus-AI is a TUI installer for AI assistant CLI tools (Claude Code, Gemini CLI, Codex CLI). Now distributed via Homebrew (`brew install N3SSQwiK/nexus-ai/nexus-ai`) with automated release pipeline.

## Completed
- Implemented Homebrew distribution with tap repo (`N3SSQwiK/homebrew-nexus-ai`)
- Python packaging: `pyproject.toml`, `__init__.py` files, `main()` entry point
- Release automation: tag push triggers GitHub Release + tap formula auto-update
- Fixed formula bugs: dependency resolution (`python -m pip`), trailing whitespace
- Verified end-to-end: `brew install` → TUI → features installed to all 3 CLI tools
- Documented all Homebrew learnings in `CLAUDE.md`
- Archived `add-homebrew-distribution` OpenSpec change, created `distribution` spec

## In Progress
Reviewed 5 pending OpenSpec proposals and established implementation order.

## Pending OpenSpec Changes (Recommended Order)

| # | Change | Status | Rationale |
|---|--------|--------|-----------|
| 1 | `maestro-spoke-availability` | Pending | Foundation — detect available tools before planning |
| 2 | `add-hub-task-classification` | Pending (0/13 tasks) | Build on availability; classify tasks before dispatch |
| 3 | `add-delegation-method` | Pending | Complete dispatch logic (Task tool vs CLI spawn) |
| 4 | `add-continuity-hooks` | Pending | Independent; event-driven triggers for continuity |
| 5 | `add-feature-uninstall` | Pending | Independent; depends on hooks for full implementation |

**Dependency chain**: availability → classification → delegation method

## Blocked
None

## Key Files
- `pyproject.toml` - Python package configuration with entry point
- `installer/python/nexus.py` - TUI with `get_features_path()` for dual-mode operation
- `.github/workflows/release.yml` - Release automation with retry loop and tap dispatch
- `CLAUDE.md` - Comprehensive Homebrew distribution guide
- `openspec/changes/` - Contains all 5 pending proposals

## Context
- v1.0.0 released and available via Homebrew
- All previous work committed to `main`, tap repo also up to date
- Case study (`CASE-STUDY-CHALLENGE.md`) documented the `npm create vite` dispatch issue that motivated `add-hub-task-classification`
- Known formula pattern: use `python -m pip install` not `venv.pip_install` (--no-deps issue)

## Suggested Prompt
> Start implementing the OpenSpec changes in order. Run `openspec apply maestro-spoke-availability`
> to begin with spoke availability detection, which is the foundation for the other Maestro improvements.

## Source
Claude Code | 2026-01-20 UTC
