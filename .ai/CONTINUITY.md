# Continuity

## Summary
Nexus-AI is a TUI installer for AI assistant CLI tools (Claude Code, Gemini CLI, Codex CLI). Distributed via Homebrew with automated release pipeline. Licensed under AGPL-3.0-or-later.

## Completed
- **Peer reviewed `migrate-commands-to-skills` proposal** — 3 critical issues identified, draft revisions created
- Created proposal with 35 tasks across 7 phases for Agent Skills migration
- v1.0.1 released on Homebrew
- Documented Maestro hooks research (`docs/Research/maestro-hooks/`)

## In Progress
Apply revisions to `migrate-commands-to-skills` proposal to address peer review feedback.

## Blocked
None

## Key Files
- `docs/Research/migrate-commands-to-skills-review/` — **Start here**: Peer review + draft revisions
- `openspec/changes/migrate-commands-to-skills/` — Proposal files to update
- `docs/Research/migrate-commands-to-skills-review/revisions/` — Three revision docs ready to apply

## Context
- Proposal peer review verdict: **REQUEST CHANGES** (~2-3 hours revision effort)
- Critical issues to address:
  1. Missing SKILL.md format spec → `revisions/skill-format-spec.md`
  2. Gemini enablement underspecified → `revisions/gemini-enablement-spec.md`
  3. No migration path for v1.x users → `revisions/migration-path-spec.md`
- Official docs fetched: Claude skills, Gemini CLI skills (used in revisions)

## Suggested Prompt
> Apply the peer review revisions to the `migrate-commands-to-skills` proposal:
> 1. Read `docs/Research/migrate-commands-to-skills-review/README.md` for full context
> 2. Apply `revisions/skill-format-spec.md` to `proposal.md` and `spec.md`
> 3. Apply `revisions/gemini-enablement-spec.md` to `spec.md` and `tasks.md`
> 4. Apply `revisions/migration-path-spec.md` to all three proposal files
> 5. After applying, re-run peer review to verify critical issues resolved

## Source
Claude Code | 2026-01-21 15:18 UTC
