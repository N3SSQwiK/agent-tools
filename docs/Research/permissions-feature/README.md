# Permissions Feature - Implementation Package

This folder contains all artifacts for the Nexus-AI Unified Permission System feature.

## Context

This feature provides configurable trust levels across Claude Code, Codex CLI, and Gemini CLI. After design review and rebuttal, the scope was refined from a full translation layer to a lighter, data-driven approach.

## Documents

| File | Description |
|------|-------------|
| `Unified-Permission-System-Spec.docx` | Original full specification (for reference, partially superseded) |
| `Unified-Permission-System-Rebuttal-Response.md` | Design review with inline responses - **read this first** |
| `DECISION.md` | Final decisions and rationale |
| `TASKS.md` | Implementation tasks by phase |
| `permission-equivalence-guide.md` | Phase 1 deliverable: Cross-tool permission mapping |
| `templates/` | Phase 1 deliverable: Pre-built config templates |

## Key Decisions

1. **No translation layer** - Users learn native config formats; Nexus provides starting points
2. **Presets write directly to native configs** - No intermediate unified schema
3. **Audit logging before survey** - Learn from real usage, then validate assumptions
4. **Safety flags required** - `--merge`, `--dry-run`, `diff` prevent accidental overwrites

## Implementation Phases

| Phase | Deliverable | Effort | Status |
|-------|-------------|--------|--------|
| 1 | Documentation + templates | 2-3 days | Not started |
| 2 | Lightweight audit logging | 1-2 weeks | Not started |
| 3 | Survey (informed by audit data) | 1 week | Not started |
| 4 | Preset commands with safety flags | 1-2 weeks | Not started |
| Deferred | Full translation layer | — | Only if data proves need |

## Getting Started

1. Read `Unified-Permission-System-Rebuttal-Response.md` for context and decisions
2. Review `DECISION.md` for the final agreed approach
3. Follow `TASKS.md` for implementation steps
