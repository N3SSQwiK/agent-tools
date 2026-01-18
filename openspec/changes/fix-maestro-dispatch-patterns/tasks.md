# Tasks: Fix Maestro Dispatch Patterns

## 1. Update Claude Code Command Files

- [x] 1.1 Update `features/maestro/claude/commands/maestro-run.md` — Add `--dangerously-skip-permissions` to Claude dispatch pattern (line 73)
- [x] 1.2 Update `features/maestro/claude/commands/maestro-run.md` — Add IMPORTANT callouts to all dispatch patterns
- [x] 1.3 Update `features/maestro/claude/commands/maestro-plan.md` — Add interactive logging level selection after plan approval

## 2. Update Codex Prompt Files

- [x] 2.1 Update `features/maestro/codex/prompts/maestro-run.md` — Add `--dangerously-skip-permissions` to Claude dispatch pattern
- [x] 2.2 Update `features/maestro/codex/prompts/maestro-run.md` — Add IMPORTANT callouts to all dispatch patterns
- [x] 2.3 Update `features/maestro/codex/prompts/maestro-plan.md` — Add interactive logging level selection

## 3. Update Gemini Extension Files

- [x] 3.1 Update `features/maestro/gemini/extensions/maestro/commands/maestro-run.toml` — Add `--dangerously-skip-permissions` to Claude dispatch pattern
- [x] 3.2 Update `features/maestro/gemini/extensions/maestro/commands/maestro-run.toml` — Add IMPORTANT callouts to all dispatch patterns
- [x] 3.3 Update `features/maestro/gemini/extensions/maestro/commands/maestro-plan.toml` — Add interactive logging level selection

## 4. Update Documentation

- [x] 4.1 Update `features/maestro/docs/SPOKE-CONTRACT.md` — Add `--dangerously-skip-permissions` to Claude pattern with security note
- [x] 4.2 Update `features/maestro/docs/SPOKE-CONTRACT.md` — Add IMPORTANT callouts to all dispatch patterns
- [x] 4.3 Update `features/maestro/docs/USER-GUIDE.md` — Update Claude dispatch pattern
- [x] 4.4 Update `features/maestro/docs/USER-GUIDE.md` — Document interactive logging selection

## 5. Update Assessment Documentation

- [ ] 5.1 Update `docs/maestro-testing/ASSESSMENT.md` — Mark issues as resolved with links to this change

## 6. Validation

- [ ] 6.1 Verify all command files have consistent dispatch patterns
- [ ] 6.2 Review security note wording is appropriate
- [ ] 6.3 Test interactive logging menu flow (manual verification)

## Dependencies

- Tasks 1.x, 2.x, 3.x can be done in parallel
- Task 4.x depends on 1.x being finalized (use as reference)
- Task 5.x depends on 4.x
- Task 6.x is final validation
