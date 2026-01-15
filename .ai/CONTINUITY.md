# Continuity

## Summary
Nexus-AI is a TUI installer for configuring AI assistant CLI tools (Claude Code, Gemini CLI, Codex CLI) with shared features. Currently implementing unified session continuity to eliminate context loss when switching between tools.

## Completed
- Fixed banner red border colors, removed Go installer
- Added `.gitignore` and `requirements.txt` for Python venv
- Renamed `installer.py` to `nexus.py`, streamlined startup
- Updated statusline to show `model.id` and `cost.total_cost_usd`
- Created OpenSpec proposal for unified continuity (`openspec/changes/unify-continuity-file/`)
- Implemented unified continuity feature on `feat/unify-continuity-file` branch:
  - Updated global instructions (3 files) to reference `.ai/CONTINUITY.md`
  - Updated slash commands (3 files) with expanded ~500 token format
  - Added migration logic for legacy per-tool files

## In Progress
- Testing and committing the unified continuity implementation
- Migrating legacy `.claude/CONTINUITY.md` to unified location (this file)

## Blocked
None

## Key Files
- `features/continuity/claude/commands/continuity.md` - Claude slash command
- `features/continuity/gemini/extensions/continuity/commands/continuity.toml` - Gemini extension
- `features/continuity/codex/prompts/continuity.md` - Codex prompt
- `openspec/changes/unify-continuity-file/` - Proposal with design.md, tasks.md, spec.md

## Context
- User is on Claude Pro/Max subscription, added API cost estimate to statusline for plan comparison
- All three AI tools use additive config loading (global + project files concatenated)
- Feature branch `feat/unify-continuity-file` has uncommitted implementation changes

## Suggested Prompt
> Commit the unified continuity implementation on `feat/unify-continuity-file` branch.
> Then reinstall the continuity feature (`./install.sh`) to deploy the updated
> commands to `~/.claude/commands/`. After verifying the migration worked,
> delete the legacy file at `.claude/CONTINUITY.md`.

## Source
Claude Code | 2026-01-15 20:34 UTC
