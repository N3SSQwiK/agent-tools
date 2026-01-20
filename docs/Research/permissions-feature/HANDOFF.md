# Handoff: Permissions Feature Implementation

## Context

You are implementing a **Permissions** feature for Nexus-AI that provides configurable trust levels across Claude Code, Codex CLI, and Gemini CLI.

**Important:** The original specification was reviewed and significantly revised. Read `DECISION.md` first — it supersedes much of the original spec.

## What Changed

The original proposal was a full translation layer (unified schema → generate native configs). After design review, this was rejected in favor of a lighter approach:

| Original | Revised |
|----------|---------|
| Unified `.ai/permissions.yaml` schema | No unified schema |
| Translation layer generates configs | Presets write directly to native configs |
| 6-9 weeks effort | 4-6 weeks effort |
| Users learn unified + native formats | Users learn native format only |

**Core insight:** Users should learn their tool's native config format. Nexus provides good starting points (presets), not an abstraction layer.

## Files in This Folder

| File | Purpose | Read Order |
|------|---------|------------|
| `DECISION.md` | Final decisions and rationale | **1st** |
| `TASKS.md` | Implementation checklist by phase | **2nd** |
| `permission-equivalence-guide.md` | Cross-tool permission mapping (Phase 1 deliverable) | Reference |
| `templates/` | Pre-built config templates (Phase 1 deliverable) | Reference |
| `Unified-Permission-System-Rebuttal-Response.md` | Full design review with inline responses | Deep context |
| `Unified-Permission-System-Spec.docx` | Original spec (partially superseded) | Historical |

## Implementation Phases

| Phase | Status | Deliverable |
|-------|--------|-------------|
| 1 | **~80% Complete** | Docs + templates (in this folder) |
| 2 | Not started | Lightweight audit logging |
| 3 | Not started | User survey (informed by audit data) |
| 4 | Not started | Preset commands (`/permissions preset balanced`) |

## Your Task

Review the documents and complete implementation according to `TASKS.md`.

**Immediate priorities:**
1. Review Phase 1 deliverables for completeness
2. Integrate templates into the Nexus-AI installer structure
3. Begin Phase 2: Audit logging system

## Key Design Decisions (Non-Negotiable)

These were agreed after design review — do not revisit:

1. **No translation layer** — presets write directly to native configs
2. **Safety flags required** — `--merge`, `--dry-run`, `diff` on all preset commands
3. **Audit before survey** — learn from real usage, then validate assumptions
4. **Native format only** — users learn Claude/Codex/Gemini config, not a Nexus abstraction

## Command Spec

```
/permissions preset <name>           # Apply preset (replace)
/permissions preset <name> --merge   # Merge with existing rules
/permissions preset <name> --dry-run # Preview changes
/permissions show                    # Show current effective permissions
/permissions diff                    # Deviation from closest preset
/permissions diff <name>             # Deviation from specific preset
/permissions export                  # Dump current config
/permissions reset                   # Remove Nexus-added rules
/permissions audit                   # Show recent permission events
/permissions audit --stats           # Permission fatigue analysis
```

## Questions?

If design questions arise, check `Unified-Permission-System-Rebuttal-Response.md` first — most edge cases were discussed there.
