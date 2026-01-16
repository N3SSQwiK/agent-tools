# Tasks: Rebuild Maestro Multi-Agent Orchestration

## Phase 0: Archive & Prepare

### 0.1 Archive v1 documentation
- [ ] Move `docs/maestro/*` to `docs/maestro-v1/`
- [ ] Update any internal links in archived docs
- [ ] Add deprecation notice to `docs/maestro-v1/README.md`
- **Verification:** v1 docs preserved in archive location

### 0.2 Create v2 documentation structure
- [ ] Create `docs/maestro/` directory
- [ ] Create placeholder files for v2 docs
- **Verification:** Clean directory ready for v2 documentation

## Phase 1: Core Infrastructure

### 1.1 Create state file schema
- [ ] Define `.ai/MAESTRO.md` format specification
- [ ] Create parser for reading/writing state file
- [ ] Add validation for state file integrity
- **Verification:** State file can be created, read, updated, and validated

### 1.2 Implement Task Handoff template
- [ ] Define handoff schema (task, context, criteria, constraints, output format)
- [ ] Create template generator for hub-to-spoke communication
- [ ] Add validation for handoff completeness
- **Verification:** Handoffs are properly structured and parseable by receiving tools

### 1.3 Implement Result Submission template
- [ ] Define result schema (status, summary, changes, verification, issues)
- [ ] Create template parser for spoke-to-hub responses
- [ ] Add validation for result completeness
- **Verification:** Results are normalized regardless of which tool produces them

## Phase 2: Slash Commands (Claude)

### 2.1 Create `/maestro plan` command
- [ ] Create `features/maestro/claude/commands/maestro-plan.md`
- [ ] Implement goal decomposition logic
- [ ] Add task dependency analysis
- [ ] Implement user approval checkpoint
- [ ] Write plan to `.ai/MAESTRO.md` on approval
- **Verification:** User can decompose goal, approve plan, and see it persisted

### 2.2 Create `/maestro challenge` command
- [ ] Create `features/maestro/claude/commands/maestro-challenge.md`
- [ ] Implement plan dispatch to spokes
- [ ] Add challenge collection and parsing
- [ ] Implement plan revision based on feedback
- **Verification:** Hub can dispatch plan, collect challenges, and revise before user approval

### 2.3 Create `/maestro run` command
- [ ] Create `features/maestro/claude/commands/maestro-run.md`
- [ ] Implement plan loading from state file
- [ ] Add AAVSR precondition checks
- [ ] Implement specialist dispatch (to Gemini/Codex CLI)
- [ ] Add result collection and normalization
- [ ] Implement state file updates during execution
- **Verification:** Tasks execute, results return, state updates correctly

### 2.4 Create `/maestro review` command
- [ ] Create `features/maestro/claude/commands/maestro-review.md`
- [ ] Implement result dispatch to different spoke
- [ ] Add review collection and parsing
- [ ] Implement accept/revise/escalate decision logic
- **Verification:** Hub can dispatch result for review and act on feedback

### 2.5 Create `/maestro status` command
- [ ] Create `features/maestro/claude/commands/maestro-status.md`
- [ ] Implement state file reading and display
- [ ] Add progress visualization
- [ ] Show blocking issues and suggested actions
- **Verification:** Status accurately reflects orchestration state

### 2.6 Create `/maestro report` command
- [ ] Create `features/maestro/claude/commands/maestro-report.md`
- [ ] Implement log file parsing
- [ ] Generate walkthrough narrative from execution log
- [ ] Add token usage breakdown and timing analysis
- **Verification:** Report accurately summarizes orchestration session

## Phase 3: Slash Commands (Gemini)

### 3.1 Create `/maestro plan` command
- [ ] Create `features/maestro/gemini/extensions/maestro/commands/maestro-plan.toml`
- [ ] Port decomposition logic from Claude version
- [ ] Adapt for Gemini's TOML prompt format
- **Verification:** Same plan quality as Claude version

### 3.2 Create `/maestro challenge` command
- [ ] Create `features/maestro/gemini/extensions/maestro/commands/maestro-challenge.toml`
- [ ] Port challenge logic from Claude version
- **Verification:** Cross-tool plan challenge works with Gemini as hub

### 3.3 Create `/maestro run` command
- [ ] Create `features/maestro/gemini/extensions/maestro/commands/maestro-run.toml`
- [ ] Port execution logic from Claude version
- [ ] Use `@path` syntax for token efficiency
- [ ] Adapt CLI invocation for Claude/Codex dispatch
- **Verification:** Cross-tool execution works with Gemini as hub

### 3.4 Create `/maestro review` command
- [ ] Create `features/maestro/gemini/extensions/maestro/commands/maestro-review.toml`
- [ ] Port review logic from Claude version
- **Verification:** Cross-tool work review works with Gemini as hub

### 3.5 Create `/maestro status` command
- [ ] Create `features/maestro/gemini/extensions/maestro/commands/maestro-status.toml`
- [ ] Port status display from Claude version
- **Verification:** Consistent status output across tools

### 3.6 Create `/maestro report` command
- [ ] Create `features/maestro/gemini/extensions/maestro/commands/maestro-report.toml`
- [ ] Port report logic from Claude version
- **Verification:** Report generation works with Gemini as hub

## Phase 4: Slash Commands (Codex)

### 4.1 Create `/maestro plan` command
- [ ] Create `features/maestro/codex/prompts/maestro-plan.md`
- [ ] Port decomposition logic from Claude version
- [ ] Adapt for Codex's markdown prompt format
- **Verification:** Same plan quality as Claude version

### 4.2 Create `/maestro challenge` command
- [ ] Create `features/maestro/codex/prompts/maestro-challenge.md`
- [ ] Port challenge logic from Claude version
- **Verification:** Cross-tool plan challenge works with Codex as hub

### 4.3 Create `/maestro run` command
- [ ] Create `features/maestro/codex/prompts/maestro-run.md`
- [ ] Port execution logic from Claude version
- [ ] Adapt CLI invocation for Claude/Gemini dispatch
- **Verification:** Cross-tool execution works with Codex as hub

### 4.4 Create `/maestro review` command
- [ ] Create `features/maestro/codex/prompts/maestro-review.md`
- [ ] Port review logic from Claude version
- **Verification:** Cross-tool work review works with Codex as hub

### 4.5 Create `/maestro status` command
- [ ] Create `features/maestro/codex/prompts/maestro-status.md`
- [ ] Port status display from Claude version
- **Verification:** Consistent status output across tools

### 4.6 Create `/maestro report` command
- [ ] Create `features/maestro/codex/prompts/maestro-report.md`
- [ ] Port report logic from Claude version
- **Verification:** Report generation works with Codex as hub

## Phase 5: Specialist Definitions

### 5.1 Define `code` specialist
- [ ] Document role and capabilities
- [ ] Define typical task patterns
- [ ] Add tool-specific invocation templates
- **Verification:** Code tasks delegate and return correctly

### 5.2 Define `review` specialist
- [ ] Document role and capabilities
- [ ] Define typical task patterns (code review, security audit)
- [ ] Add tool-specific invocation templates
- **Verification:** Review tasks produce actionable feedback

### 5.3 Define `test` specialist
- [ ] Document role and capabilities
- [ ] Define typical task patterns (write tests, run suites)
- [ ] Add tool-specific invocation templates
- **Verification:** Test tasks validate implementation correctly

### 5.4 Define `research` specialist
- [ ] Document role and capabilities
- [ ] Define typical task patterns (search, read, answer)
- [ ] Add tool-specific invocation templates
- **Verification:** Research tasks return accurate information

## Phase 6: Failure Handling

### 6.1 Implement retry ladder
- [ ] Add immediate retry for transient failures
- [ ] Implement context expansion retry
- [ ] Add task decomposition retry
- [ ] Implement user escalation
- **Verification:** Failures escalate appropriately through ladder

### 6.2 Implement quality gates
- [ ] Add format compliance validation
- [ ] Add criteria satisfaction check
- [ ] Add scope adherence validation
- [ ] Implement integration check hooks
- **Verification:** Invalid results are caught and retried

## Phase 7: Integration & Testing

### 7.1 Add Maestro to installer
- [ ] Add `maestro` feature to `features/` directory structure
- [ ] Update `installer/python/nexus.py` to recognize Maestro feature
- [ ] Test installation for each tool
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
- [ ] Write `features/maestro/docs/README.md` - Overview, quick start, prerequisites
- [ ] Write `features/maestro/docs/USER-GUIDE.md` - Detailed usage for all commands
- [ ] Write `features/maestro/docs/TROUBLESHOOTING.md` - Common issues, failure modes, solutions
- [ ] Write `features/maestro/docs/SPOKE-CONTRACT.md` - Tool-agnostic spoke execution contract
- [ ] Write `features/maestro/docs/STATE-FILE-SPEC.md` - `.ai/MAESTRO.md` format specification
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
