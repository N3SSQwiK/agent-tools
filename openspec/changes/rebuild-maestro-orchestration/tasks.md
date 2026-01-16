# Tasks: Rebuild Maestro Multi-Agent Orchestration

## Phase 0: Archive & Prepare

### 0.1 Archive v1 documentation
- [x] Move `docs/maestro/*` to `docs/maestro-v1/`
- [x] Update any internal links in archived docs
- [x] Add deprecation notice to `docs/maestro-v1/README.md`
- **Verification:** v1 docs preserved in archive location

### 0.2 Create v2 documentation structure
- [x] Create `features/maestro/docs/` directory (changed from `docs/maestro/` per design)
- [x] Create documentation files for v2
- **Verification:** Clean directory ready for v2 documentation

## Phase 1: Core Infrastructure

### 1.1 Create state file schema
- [x] Define `.ai/MAESTRO.md` format specification (`STATE-FILE-SPEC.md`)
- [x] Document execution log format (`.ai/MAESTRO-LOG.md`)
- **Verification:** State file format is documented and consistent

### 1.2 Implement Task Handoff template
- [x] Define handoff schema (task, context, criteria, constraints, output format)
- [x] Document in `SPOKE-CONTRACT.md`
- **Verification:** Handoffs are properly structured and documented

### 1.3 Implement Result Submission template
- [x] Define result schema (status, summary, changes, verification, issues)
- [x] Document in `SPOKE-CONTRACT.md`
- **Verification:** Results format is normalized and documented

## Phase 2: Slash Commands (Claude)

### 2.1 Create `/maestro plan` command
- [x] Create `features/maestro/claude/commands/maestro-plan.md`
- [x] Implement goal decomposition logic
- [x] Add task dependency analysis
- [x] Implement user approval checkpoint
- [x] Write plan to `.ai/MAESTRO.md` on approval
- **Verification:** User can decompose goal, approve plan, and see it persisted

### 2.2 Create `/maestro challenge` command
- [x] Create `features/maestro/claude/commands/maestro-challenge.md`
- [x] Implement plan dispatch to spokes
- [x] Add challenge collection and parsing
- [x] Implement plan revision based on feedback
- **Verification:** Hub can dispatch plan, collect challenges, and revise before user approval

### 2.3 Create `/maestro run` command
- [x] Create `features/maestro/claude/commands/maestro-run.md`
- [x] Implement plan loading from state file
- [x] Add AAVSR precondition checks
- [x] Implement specialist dispatch (to Gemini/Codex CLI)
- [x] Add result collection and normalization
- [x] Implement state file updates during execution
- **Verification:** Tasks execute, results return, state updates correctly

### 2.4 Create `/maestro review` command
- [x] Create `features/maestro/claude/commands/maestro-review.md`
- [x] Implement result dispatch to different spoke
- [x] Add review collection and parsing
- [x] Implement accept/revise/escalate decision logic
- **Verification:** Hub can dispatch result for review and act on feedback

### 2.5 Create `/maestro status` command
- [x] Create `features/maestro/claude/commands/maestro-status.md`
- [x] Implement state file reading and display
- [x] Add progress visualization
- [x] Show blocking issues and suggested actions
- **Verification:** Status accurately reflects orchestration state

### 2.6 Create `/maestro report` command
- [x] Create `features/maestro/claude/commands/maestro-report.md`
- [x] Implement log file parsing
- [x] Generate walkthrough narrative from execution log
- [x] Add token usage breakdown and timing analysis
- **Verification:** Report accurately summarizes orchestration session

## Phase 3: Slash Commands (Gemini)

### 3.1 Create `/maestro plan` command
- [x] Create `features/maestro/gemini/extensions/maestro/commands/maestro-plan.toml`
- [x] Port decomposition logic from Claude version
- [x] Adapt for Gemini's TOML prompt format
- **Verification:** Same plan quality as Claude version

### 3.2 Create `/maestro challenge` command
- [x] Create `features/maestro/gemini/extensions/maestro/commands/maestro-challenge.toml`
- [x] Port challenge logic from Claude version
- **Verification:** Cross-tool plan challenge works with Gemini as hub

### 3.3 Create `/maestro run` command
- [x] Create `features/maestro/gemini/extensions/maestro/commands/maestro-run.toml`
- [x] Port execution logic from Claude version
- [x] Use `@path` syntax for token efficiency
- [x] Adapt CLI invocation for Claude/Codex dispatch
- **Verification:** Cross-tool execution works with Gemini as hub

### 3.4 Create `/maestro review` command
- [x] Create `features/maestro/gemini/extensions/maestro/commands/maestro-review.toml`
- [x] Port review logic from Claude version
- **Verification:** Cross-tool work review works with Gemini as hub

### 3.5 Create `/maestro status` command
- [x] Create `features/maestro/gemini/extensions/maestro/commands/maestro-status.toml`
- [x] Port status display from Claude version
- **Verification:** Consistent status output across tools

### 3.6 Create `/maestro report` command
- [x] Create `features/maestro/gemini/extensions/maestro/commands/maestro-report.toml`
- [x] Port report logic from Claude version
- **Verification:** Report generation works with Gemini as hub

## Phase 4: Slash Commands (Codex)

### 4.1 Create `/maestro plan` command
- [x] Create `features/maestro/codex/prompts/maestro-plan.md`
- [x] Port decomposition logic from Claude version
- [x] Adapt for Codex's markdown prompt format
- **Verification:** Same plan quality as Claude version

### 4.2 Create `/maestro challenge` command
- [x] Create `features/maestro/codex/prompts/maestro-challenge.md`
- [x] Port challenge logic from Claude version
- **Verification:** Cross-tool plan challenge works with Codex as hub

### 4.3 Create `/maestro run` command
- [x] Create `features/maestro/codex/prompts/maestro-run.md`
- [x] Port execution logic from Claude version
- [x] Adapt CLI invocation for Claude/Gemini dispatch
- **Verification:** Cross-tool execution works with Codex as hub

### 4.4 Create `/maestro review` command
- [x] Create `features/maestro/codex/prompts/maestro-review.md`
- [x] Port review logic from Claude version
- **Verification:** Cross-tool work review works with Codex as hub

### 4.5 Create `/maestro status` command
- [x] Create `features/maestro/codex/prompts/maestro-status.md`
- [x] Port status display from Claude version
- **Verification:** Consistent status output across tools

### 4.6 Create `/maestro report` command
- [x] Create `features/maestro/codex/prompts/maestro-report.md`
- [x] Port report logic from Claude version
- **Verification:** Report generation works with Codex as hub

## Phase 5: Specialist Definitions

### 5.1 Define `code` specialist
- [x] Document role and capabilities in `SPOKE-CONTRACT.md`
- [x] Define typical task patterns
- [x] Add tool-specific invocation templates
- **Verification:** Code tasks delegate and return correctly

### 5.2 Define `review` specialist
- [x] Document role and capabilities in `SPOKE-CONTRACT.md`
- [x] Define typical task patterns (code review, security audit)
- [x] Add tool-specific invocation templates
- **Verification:** Review tasks produce actionable feedback

### 5.3 Define `test` specialist
- [x] Document role and capabilities in `SPOKE-CONTRACT.md`
- [x] Define typical task patterns (write tests, run suites)
- [x] Add tool-specific invocation templates
- **Verification:** Test tasks validate implementation correctly

### 5.4 Define `research` specialist
- [x] Document role and capabilities in `SPOKE-CONTRACT.md`
- [x] Define typical task patterns (search, read, answer)
- [x] Add tool-specific invocation templates
- **Verification:** Research tasks return accurate information

## Phase 6: Failure Handling

### 6.1 Implement retry ladder
- [x] Add immediate retry for transient failures (embedded in `/maestro run`)
- [x] Implement context expansion retry
- [x] Add task decomposition retry
- [x] Implement user escalation
- **Verification:** Failures escalate appropriately through ladder

### 6.2 Implement quality gates
- [x] Add format compliance validation (embedded in `/maestro run`)
- [x] Add criteria satisfaction check
- [x] Add scope adherence validation
- **Verification:** Invalid results are caught and retried

## Phase 7: Integration & Testing

### 7.1 Add Maestro to installer
- [x] Add `maestro` feature to `features/` directory structure
- [x] Update `installer/python/nexus.py` to recognize Maestro feature
- [x] Test installation verification (feature appears in list)
- **Verification:** Maestro commands install correctly via TUI

### 7.2 Cross-tool integration testing
- [ ] Test Claude as Hub → Gemini as Spoke
- [ ] Test Claude as Hub → Codex as Spoke
- [ ] Test Gemini as Hub → Claude as Spoke
- [ ] Test Gemini as Hub → Codex as Spoke
- [ ] Test Codex as Hub → Claude as Spoke
- [ ] Test Codex as Hub → Gemini as Spoke
- **Verification:** All hub-spoke combinations work correctly

### 7.3 Documentation
- [x] Write `features/maestro/docs/README.md` - Overview, quick start, prerequisites
- [x] Write `features/maestro/docs/USER-GUIDE.md` - Detailed usage for all commands
- [x] Write `features/maestro/docs/TROUBLESHOOTING.md` - Common issues, failure modes, solutions
- [x] Write `features/maestro/docs/SPOKE-CONTRACT.md` - Tool-agnostic spoke execution contract
- [x] Write `features/maestro/docs/STATE-FILE-SPEC.md` - `.ai/MAESTRO.md` format specification
- [ ] Update project README with Maestro feature description
- **Verification:** Users can understand and use Maestro effectively

## Dependencies

```
Phase 0 (Archive) ─── Phase 1 (Infrastructure) ──┬── Phase 2 (Claude) ──┐
                                                  ├── Phase 3 (Gemini) ──┼── Phase 5 (Specialists)
                                                  └── Phase 4 (Codex) ───┘
                                                                          │
                                                           Phase 6 (Failure Handling)
                                                                          │
                                                           Phase 7 (Integration)
```

## Parallelization Opportunities

- Phases 2, 3, 4 can run in parallel (one per tool)
- Specialist definitions (5.1-5.4) can run in parallel
- Phase 6 can start after any one tool's commands are complete

## Completion Summary

| Phase | Status |
|-------|--------|
| Phase 0: Archive | Complete |
| Phase 1: Infrastructure | Complete |
| Phase 2: Claude Commands | Complete |
| Phase 3: Gemini Commands | Complete |
| Phase 4: Codex Commands | Complete |
| Phase 5: Specialists | Complete |
| Phase 6: Failure Handling | Complete |
| Phase 7.1: Installer | Complete |
| Phase 7.2: Cross-tool Testing | Pending (requires runtime testing) |
| Phase 7.3: Documentation | Mostly complete (project README pending) |
