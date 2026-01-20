# Permissions Feature - Final Decisions

## Problem Statement

Developers using multiple AI CLI tools (Claude Code, Codex CLI, Gemini CLI) face:
- Configuration fragmentation (different formats, locations, syntax)
- Inconsistent behavior (similar concepts, different semantics)
- Maintenance burden (changes replicated across 3+ systems)

## Original Proposal

Build a unified permission schema (`.ai/permissions.yaml`) with a translation layer that generates native configs for each tool.

**Estimated effort:** 6-9 weeks

## Critique Summary

The original proposal was challenged on five points:

| Concern | Verdict |
|---------|---------|
| Translation is lossy (glob/regex/hooks not portable) | Valid |
| 4 configs instead of 3 (unified + 3 generated) | Valid |
| Abstraction leakage (users learn 2 systems) | Valid |
| Uncertain value proposition (multi-tool ≠ unified desire) | Partially valid |
| 6-9 week investment for uncertain adoption | Valid |

## Revised Approach

**Core insight:** Users should learn their tool's native config format. Nexus provides good starting points (presets), not an abstraction layer that hides the native format.

### What We Will Build

1. **Documentation + Templates** - Equivalence guide showing how to achieve same trust levels across tools, plus copy-paste config templates

2. **Lightweight Audit Logging** - Cross-tool visibility into permission events (`.ai/permissions.log`). This is instrumentation to inform future decisions, not just a user feature.

3. **Preset Commands** - `/permissions preset balanced` writes directly to native config. No intermediate schema.

### What We Will NOT Build (For Now)

- Unified permission schema (`.ai/permissions.yaml`)
- Translation layer that generates configs
- Cross-tool rule synchronization

### Why This Is Better

| Aspect | Original | Revised |
|--------|----------|---------|
| Configs to maintain | 4 (unified + 3 native) | 3 (native only) |
| Abstraction leakage | Yes (learn unified + native) | No (native only) |
| Power user support | Degraded (lowest common denominator) | Full (native features) |
| Effort | 6-9 weeks | 4-6 weeks |
| Risk | High (uncertain adoption) | Low (incremental, data-driven) |

## Command Design

The `/permissions` command will support:

```
/permissions preset balanced          # Apply preset (replace)
/permissions preset balanced --merge  # Merge with existing rules
/permissions preset balanced --dry-run # Show what would change
/permissions show                      # Show current effective permissions
/permissions diff                      # Show deviation from closest preset
/permissions diff balanced             # Deviation from specific preset
/permissions export                    # Dump current config (for backup/sharing)
/permissions reset                     # Remove Nexus-added rules, keep user rules
```

**Required safety flags:**
- `--dry-run` prevents accidental overwrites
- `--merge` preserves user customizations
- `reset` provides escape hatch

## Preset Definitions

Three presets, applied to native config format of each tool:

| Preset | file_read | file_write | shell_safe | shell_destructive | network |
|--------|-----------|------------|------------|-------------------|---------|
| conservative | auto | ask | ask | ask | deny |
| balanced | auto | ask | auto | ask | deny |
| autonomous | auto | auto | auto | ask | ask |

## Phasing Rationale

| Phase | Why This Order |
|-------|----------------|
| 1. Docs + Templates | Immediate value, zero risk, validates interest |
| 2. Audit Logging | Learn real patterns before designing presets |
| 3. Survey | "We observed X" > "We think Y" |
| 4. Preset Commands | Designed from actual usage data |

## Success Metrics

- Phase 1: Downloads/views of documentation
- Phase 2: Opt-in rate for audit logging
- Phase 3: Survey validates desire for unified permissions (>50%)
- Phase 4: Preset adoption rate, time saved vs manual config

## Open Questions (To Validate)

1. Do users want the *same* permissions across tools, or intentionally different?
2. What's the primary tool vs. secondary tools distribution?
3. What permission rules are approved 90%+ of the time? (candidates for auto-allow)

## References

- `Unified-Permission-System-Spec.docx` - Original specification (partially superseded)
- `Unified-Permission-System-Rebuttal-Response.md` - Full critique and responses
