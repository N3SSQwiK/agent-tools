## 1. Documentation Updates

- [ ] 1.1 Update `features/maestro/docs/README.md` with Task Classification section
- [ ] 1.2 Update `features/maestro/docs/TROUBLESHOOTING.md` with "Task stuck on interactive input" guidance

## 2. Command Implementation

- [ ] 2.1 Update `/maestro plan` commands to classify tasks during plan generation
- [ ] 2.2 Add `[HUB]` / `[SPOKE]` markers to plan output format
- [ ] 2.3 Update `/maestro run` commands to check classification before dispatch
- [ ] 2.4 Implement hub-only task execution path (execute directly, not via spoke)

## 3. Classification Logic

- [ ] 3.1 Define interactive command patterns list (npm create, npm init, yarn create, npx create-*, git rebase -i, etc.)
- [ ] 3.2 Define dependency installation detection heuristics
- [ ] 3.3 Add user override flow with warning for forcing delegation

## 4. Challenge Command Update

- [ ] 4.1 Update `/maestro challenge` commands to instruct challengers to flag task classification issues
- [ ] 4.2 Add example challenge output for misclassified tasks

## 5. State File Updates

- [ ] 5.1 Update `.ai/MAESTRO.md` format to include task classification field
- [ ] 5.2 Update `STATE-FILE-SPEC.md` documentation
