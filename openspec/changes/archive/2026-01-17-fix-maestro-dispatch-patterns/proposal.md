# Change: Fix Maestro Dispatch Patterns and Improve Logging UX

## Why

During Maestro testing, we discovered two root causes for spoke file write failures:

1. **Documentation Gap**: Claude Code dispatch pattern missing `--dangerously-skip-permissions` flag, causing all Claude sub-agent file writes to fail with permission denial
2. **Execution Bug**: Hub forgot to include `-y -o json` flags when dispatching to Gemini CLI, despite these being documented in the pattern

Additionally, the `--log=detailed` flag is cumbersome to remember and invoke, reducing adoption of the valuable execution logging feature.

## What Changes

### Dispatch Pattern Fixes
- **Claude Code**: Add `--dangerously-skip-permissions` to the default dispatch pattern (with security note)
- **All Tools**: Add prominent `IMPORTANT` callouts to dispatch patterns to prevent hub from forgetting flags
- **Add dispatch pattern validation guidance** to help hub self-check command generation

### Logging UX Improvement
- **Add interactive logging menu** to `/maestro-plan` command
- User selects logging level (none/summary/detailed) during plan approval
- Eliminates need to remember `--log=detailed` flag syntax

## Impact

- **Affected specs**: `maestro-orchestration`
- **Affected code**:
  - `features/maestro/claude/commands/maestro-plan.md`
  - `features/maestro/claude/commands/maestro-run.md`
  - `features/maestro/codex/prompts/maestro-plan.md`
  - `features/maestro/codex/prompts/maestro-run.md`
  - `features/maestro/gemini/extensions/maestro/commands/maestro-plan.toml`
  - `features/maestro/gemini/extensions/maestro/commands/maestro-run.toml`
  - `features/maestro/docs/SPOKE-CONTRACT.md`
  - `features/maestro/docs/USER-GUIDE.md`
