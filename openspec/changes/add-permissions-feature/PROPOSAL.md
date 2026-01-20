# Change: Add Permissions Feature

## Why

Users of multiple AI CLI tools (Claude Code, Codex CLI, Gemini CLI) face permission configuration challenges:

1. **Fragmented configs** — Each tool uses different formats, locations, and syntax
2. **No visibility** — Users can't see what permissions were granted/denied across tools
3. **No starting points** — New users must read extensive docs to configure basic trust levels

After design review, a **unified permission schema** was rejected in favor of a **preset-based approach**:

| Rejected | Accepted |
|----------|----------|
| Unified `.ai/permissions.yaml` | No abstraction layer |
| Translation layer → native configs | Presets write directly to native configs |
| Users learn 2 systems | Users learn native format only |

**Core insight:** Users should learn their tool's native config format. Nexus provides good starting points (presets) and visibility (audit logs), not an abstraction that hides native formats.

## What Changes

### Phase 1: Documentation + Templates

1. **Permission Equivalence Guide** — Cross-tool mapping showing how to achieve same trust levels
2. **Config Templates** — Pre-built presets (conservative, balanced, autonomous) for each tool
3. **Snippet Library** — Copy-paste configs for common scenarios

### Phase 2: Lightweight Audit Logging

1. **Cross-tool audit log** — Unified `.ai/permissions.log` capturing permission events from all tools
2. **Claude Code audit hooks** — PreToolUse/PostToolUse hooks that log permission checks
3. **Audit analysis commands** — `/permissions audit` to view and analyze permission events

## What This Proposal Does NOT Include

Phase 3 (User Survey) and Phase 4 (Preset Commands) are **deferred** to a follow-up proposal after audit data informs the design.

## Impact

- **Affected specs**: `installer` (new feature structure)
- **New files**:
  - `installer/python/features/permissions/` — Feature directory
  - `docs/PERMISSION-EQUIVALENCE.md` — Reference guide
  - `docs/PERMISSION-SNIPPETS.md` — Copy-paste snippets
- **New capability**: Cross-tool permission visibility via audit logging

## Relationship to Other Work

- **Independent** of Maestro changes (no dependency)
- **Uses** existing installer feature structure pattern
- **Extends** Claude Code hooks pattern (like continuity-hooks proposal)

## Non-Negotiables

These were agreed after design review — do not revisit:

1. **No translation layer** — presets write directly to native configs
2. **Safety flags required** — `--merge`, `--dry-run`, `diff` on all preset commands (Phase 4)
3. **Audit before survey** — learn from real usage, then validate assumptions
4. **Native format only** — users learn Claude/Codex/Gemini config, not a Nexus abstraction

## Success Criteria

| Phase | Metric |
|-------|--------|
| Phase 1 | Templates installable via TUI; docs discoverable |
| Phase 2 | Audit log captures Claude Code permission events; analysis commands work |

## References

- `docs/Research/permissions-feature/DECISION.md` — Final design decisions
- `docs/Research/permissions-feature/HANDOFF.md` — Implementation context
- `docs/Research/permissions-feature/TASKS.md` — Original task breakdown
- `docs/Research/permissions-feature/permission-equivalence-guide.md` — Phase 1 deliverable (draft)
