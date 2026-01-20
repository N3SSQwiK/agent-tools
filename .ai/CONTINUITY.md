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
None

## Blocked
None

## Key Files
- `pyproject.toml` - Python package configuration with entry point
- `installer/python/nexus.py` - TUI with `get_features_path()` for dual-mode operation
- `.github/workflows/release.yml` - Release automation with retry loop and tap dispatch
- `CLAUDE.md` - Comprehensive Homebrew distribution guide (new section)
- `homebrew-nexus-ai/Formula/nexus-ai.rb` - Homebrew formula (separate repo)

## Context
- v1.0.0 released and available via Homebrew
- All work committed to `main`, tap repo also up to date
- One pending OpenSpec change: `add-hub-task-classification` (0/13 tasks)
- Known formula pattern: use `python -m pip install` not `venv.pip_install` (--no-deps issue)

## Suggested Prompt
> The `add-hub-task-classification` OpenSpec change is pending (0/13 tasks).
> This addresses interactive task dispatch to spokes - hub should handle tasks
> requiring user input (like `npm create vite`) instead of delegating to spokes
> running with `-y` flags. Run `openspec show add-hub-task-classification` to
> review the proposal and `openspec apply add-hub-task-classification` to start.

## Source
Claude Code | 2026-01-19 03:38 UTC
