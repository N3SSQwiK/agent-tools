# Change: Add Spoke Availability Detection to Maestro

## Why

Maestro currently assumes all three tools (Claude Code, Gemini CLI, Codex CLI) are available, but users may only have one or two installed. This leads to:
- Plans assigning tasks to unavailable tools
- Challenge/review commands offering tools that don't exist
- Failed dispatches when spokes aren't installed or authenticated

Additionally, the `--tool` flags for `/maestro challenge` and `/maestro review` are not discoverable — users must read documentation to find them.

## What Changes

### 1. Spoke Availability Detection (New)
- `/maestro plan` detects which CLI tools are installed at orchestration start
- Hub is automatically identified (the tool running the command)
- User confirms available spokes before plan creation
- Availability stored in `.ai/MAESTRO.md` for use by other commands

### 2. Interactive Tool Selection Menus
- `/maestro challenge` shows menu for selecting challenger tool (step 2)
- `/maestro review` shows menu for selecting reviewer tool (step 4)
- Menus only show tools confirmed as available
- Flags (`--tool`, `--all`) bypass menus for power users

### 3. Task Assignment Validation
- Plan command only assigns tasks to confirmed available tools
- Validation prevents assigning work to unavailable spokes

## Impact

- **Affected specs**: `maestro-orchestration` (Plan Command, Challenge Command, Review Command)
- **Affected files**:
  - `installer/python/features/maestro/claude/commands/maestro-plan.md`
  - `installer/python/features/maestro/claude/commands/maestro-challenge.md`
  - `installer/python/features/maestro/claude/commands/maestro-review.md`
  - `installer/python/features/maestro/codex/prompts/maestro-plan.md`
  - `installer/python/features/maestro/codex/prompts/maestro-challenge.md`
  - `installer/python/features/maestro/codex/prompts/maestro-review.md`
  - `installer/python/features/maestro/gemini/extensions/maestro/commands/maestro-plan.toml`
  - `installer/python/features/maestro/gemini/extensions/maestro/commands/maestro-challenge.toml`
  - `installer/python/features/maestro/gemini/extensions/maestro/commands/maestro-review.toml`
  - `installer/python/features/maestro/docs/USER-GUIDE.md`
  - `installer/python/features/maestro/docs/STATE-FILE-SPEC.md`
