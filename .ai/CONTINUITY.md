# Continuity

## Summary
Nexus-AI is a TUI installer for AI assistant CLI tools (Claude Code, Gemini CLI, Codex CLI). Distributed via Homebrew, licensed AGPL-3.0-or-later. Currently preparing v2.0.0 migration from commands/extensions/prompts to unified Agent Skills.

## Completed
- Applied all peer review revisions to `migrate-commands-to-skills` proposal (C1-C3, M1-M3, m1-m3 resolved)
- Peer re-review verdict: **APPROVE** (95/100 confidence)
- Maestro plan created: 16 tasks across implementation, migration, and testing phases
- 3 cross-tool challenge rounds completed (Claude self-challenge, Gemini CLI, Codex CLI)
- Key challenge fixes: `rmtree`+`copytree` (not merge), no `gemini skills enable --global`, frontmatter validation for Codex, hooks deferred

## In Progress
- Maestro orchestration plan ready for execution (`/maestro run`)

## Blocked
None

## Key Files
- `.ai/MAESTRO.md` — **Start here**: 16-task orchestration plan with implementation notes
- `.ai/MAESTRO-LOG.md` — Detailed execution log (3 challenge rounds logged)
- `openspec/changes/migrate-commands-to-skills/proposal.md` — Approved proposal with SKILL.md spec, Gemini detection, migration path
- `openspec/changes/migrate-commands-to-skills/tasks.md` — 49 granular implementation tasks
- `installer/python/nexus.py` — Primary file to modify (827 lines, 3 install methods to replace)

## Context
- On `main` branch, 1 commit ahead of origin (proposal revisions committed as `c1be0c8`)
- Maestro plan uses verification split: Claude Code implements, Gemini/Codex verify their own skills
- Hooks deferred to follow-up PR (research exists, no production scripts)
- Codex requires restart after skill install; Gemini auto-discovers

## Suggested Prompt
> Run `/maestro run` to begin implementing the migrate-commands-to-skills plan. Start with Task 1 (create feature branch `feat/migrate-commands-to-skills`), then Task 2 (add `install_skills()` with `rmtree`+`copytree` to `nexus.py`). The full plan is in `.ai/MAESTRO.md` with 16 tasks and detailed implementation notes. All 3 challenge rounds are complete — plan is approved for execution.

## Source
Claude Code | 2026-01-29 02:35 UTC
