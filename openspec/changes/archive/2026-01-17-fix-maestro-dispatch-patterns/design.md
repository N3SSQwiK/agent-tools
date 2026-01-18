# Design: Fix Maestro Dispatch Patterns

## Context

Maestro is a hub-and-spoke multi-agent orchestration system. The hub (any of Claude Code, Gemini CLI, or Codex CLI) dispatches tasks to spokes using CLI commands. During testing, we discovered:

1. **Claude Code sub-agents couldn't write files** — the dispatch pattern lacks `--dangerously-skip-permissions`
2. **Gemini CLI couldn't write files** — the hub forgot to include `-y -o json` flags despite documentation
3. **Codex CLI worked** — the hub correctly included `--full-auto`

The logging flag (`--log=detailed`) is also underutilized because users forget the syntax.

## Goals / Non-Goals

**Goals:**
- Ensure all three tools can write files when dispatched as spokes
- Make dispatch patterns impossible to forget (prominent formatting)
- Improve logging UX with interactive selection during plan phase

**Non-Goals:**
- Changing the underlying permission models of the CLI tools
- Adding new logging levels beyond none/summary/detailed
- Implementing plan-derived permission manifests (future enhancement)

## Decisions

### Decision 1: Add `--dangerously-skip-permissions` to Claude Code Pattern

**What**: Change the default Claude Code dispatch pattern from:
```bash
claude -p "<prompt>" --output-format json
```
To:
```bash
claude -p "<prompt>" --output-format json --dangerously-skip-permissions
```

**Why**: Without this flag, Claude Code sub-agents cannot write files in non-interactive mode. The `permission_denials` array provides recovery data, but it's inefficient (extra round-trips, hub must parse and write).

**Security Note**: This grants broad permissions to sub-agents. We'll add a prominent warning and note that this is for trusted orchestration contexts.

**Alternatives Considered**:
- Hub-writes pattern (formalize current fallback) — Rejected: Defeats parallelization benefit
- Workspace-scoped permissions — Rejected: Requires new CLI feature
- Permission manifests — Rejected: Too complex for this fix

### Decision 2: Add IMPORTANT Callouts to Dispatch Patterns

**What**: Wrap dispatch patterns in prominent callout blocks:

```markdown
> **IMPORTANT: Include ALL flags exactly as shown**
> ```bash
> gemini -p "<handoff prompt>" -y -o json
> ```
> Missing `-y` will cause file write failures.
```

**Why**: The hub (an AI model following instructions) forgot Gemini's flags during testing. Making patterns more visually prominent and adding explicit warnings should improve adherence.

### Decision 3: Interactive Logging Selection in /maestro-plan

**What**: After user approves the plan, present a logging level menu:

```
Select logging level for this orchestration:

1. None (default) - No execution log
2. Summary - Log actions, outcomes, token counts
3. Detailed - Log full prompts and outputs

>
```

**Why**: Users don't remember `--log=detailed` syntax. Interactive selection during the natural plan approval flow is more discoverable.

**Implementation**: Use AskUserQuestion tool pattern with 3 options.

## Risks / Trade-offs

| Risk | Mitigation |
|------|------------|
| `--dangerously-skip-permissions` is security-sensitive | Add prominent warning; note it's for trusted orchestration |
| Hub might still forget flags despite callouts | Consider future enhancement: dispatch template function |
| Interactive menu adds friction to plan flow | Keep it brief; default to "None" if user dismisses |

## Migration Plan

1. Update all command files (claude, gemini, codex variants)
2. Update SPOKE-CONTRACT.md and USER-GUIDE.md
3. No data migration needed — changes are to instruction files only
4. Backward compatible — existing orchestrations continue to work

## Open Questions

None — ready for implementation.
