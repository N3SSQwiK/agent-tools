# Multi-Agent Orchestration Plan (Token-Efficient)
**Claude Code as Orchestrator**  
**Version**: 1.1 (condensed)  
**Created**: 2025-12-15 • **Updated**: 2025-12-17 • **Status**: Active  
**Purpose**: Reduce *Claude* token spend by routing token-heavy work to Gemini/Codex while keeping quality via Claude review + integration.

**Authoritative routing policy**: `DELEGATION-MATRIX.md` (source of truth).  
**Related ops guides**: `FAILURE-RUNBOOK.md`, `COST-GUARDRAILS.md`, `WORKSPACE-AUDIT.md`, `GEMINI.md`, `CODEX.md`.

---

## 1) Executive Summary
**Goal**: Claude Code (Sonnet 4.5) acts as the strategic brain: decomposes tasks, routes to workers, reviews outputs, integrates, commits.  
**Key principle**: *Right task, right model* (match task characteristics to model strengths).  
**Expected impact** (target): 60–70% reduction in Claude tokens on routine work; parallelization of independent streams; cost optimization across tiers.

---

## 2) Architecture
Claude coordinates Gemini + Codex through a shared workspace (task queue, results cache, code artifacts).

**Core invariant**: *No agent output is accepted into prod without Claude review.*

---

## 3) Agents: Definitions, Strengths, Constraints
### 3.1 Claude Code (Orchestrator / Brain)
**Strengths**: architecture/design, task decomposition, complex refactors (3+ files), OpenSpec proposals, conflict resolution, SwiftUI/SwiftData decisions, deep debugging, final review/merge, user-facing comms.  
**Token priority**: **HIGH** (reserve for strategic + integration).  
**Must-own tasks**:
- Architecture decisions + OpenSpec proposals
- Integration work (multi-file coordination)
- Final code review before commit
- Git operations + commit messages
- Any complex logic / state-heavy debugging
- Maintaining conversation context with user

### 3.2 Gemini (Research & Analysis Worker)
**Strengths**: large-context analysis, codebase mapping, cross-file pattern finding, doc audits, test coverage analysis, dependency mapping, data/reporting, research.  
**Token priority**: MEDIUM (capacity abundant).  
**Ideal tasks**:
- “Find all usages of X” across repo
- Read/scan many files; produce line-numbered reports
- Draft/update Markdown documentation
- Spec completeness checks; coverage reports
**Not suitable**:
- Final production code (quality risk)
- Critical business logic, complex SwiftUI composition
- Anything requiring Claude Code tool access

### 3.3 Codex (Code Generation Worker)
**Strengths**: fast implementation from clear specs, pattern completion, boilerplate, unit tests from approved plans, translations/conversions, helpers/constants.  
**Token priority**: MEDIUM (cost-effective for code).  
**Ideal tasks**:
- Implement functions from detailed specs
- Generate unit tests from an approved test plan
- Boilerplate (`@Model`, previews, enums/constants)
- Formatting/style fixes
**Not suitable**:
- Unclear requirements (hallucination risk)
- Architectural decisions
- Multi-file coordination without explicit plan

---

## 4) Task Routing Decision Tree (Minimal)
1) **Strategic / Architectural / Integration-heavy** → **Claude**  
2) **Research / Exploration / Cross-file pattern finding** → **Gemini** → Claude review/integrate  
3) **Well-defined code generation** → **Codex** → Claude review/validate  
4) **Complex implementation** → Claude decomposes → delegate atomic subtasks → Claude integrates/commits

---

## 5) Pre-Delegation Reconnaissance (Critical Rule)
**Rule**: Do *cheap recon* before expensive delegation.  
**Why**: Prevents token waste + timeouts from blind “search everything” prompts.

**Recon tools (cheap)**:
```bash
ls <dir>
Glob <pattern>
Grep "<pattern>" **/*.swift
```

**Then decide**:
- Found target → read directly (small context)  
- Needs deeper analysis → delegate *atomic* file analysis to Gemini/Codex

**Observed example impact**:
- Blind delegation: ~15K+ tokens, low reliability  
- Recon → direct read: ~3K tokens, high reliability  
- Recon → @path delegation: ~4–5K tokens, high reliability

---

## 6) Delegation Patterns (Canonical Workflows)
### A) Research → Design → Implement (default)
1. Claude: clarify reqs + decompose  
2. Gemini: map patterns/files/impacts  
3. Claude: plan + quality gates  
4. Codex: boilerplate/tests/helpers per plan  
5. Claude: integrate + complex logic + commit

### B) Parallel Exploration
Claude defines partitions → Gemini runs parallel targeted searches → Claude synthesizes (diagram/report).

### C) Test Generation Pipeline
Claude sets strategy → Gemini drafts test plan (edge/happy/error) → Claude approves plan → Codex generates tests → Claude verifies + runs suite.

### D) Documentation Sync
Claude identifies change surface → Gemini audits + drafts updates (line-specific) → Claude reviews + applies.

### E) Spec Validation
Claude defines criteria → Gemini cross-references specs ↔ tests → Claude prioritizes gaps → Codex generates missing tests → Claude reviews/commits.

### F) Pre-Plan Delegation (high ROI)
**Problem**: Planning “Explore agents” can consume 15–20K tokens.  
**Solution**: Do Gemini research *before* Plan Mode; load outputs during planning; use Plan Mode for design only.

**Target savings**: planning ~30K → ~13K (≈57% reduction).

---

## 7) Communication Protocols (Required Formats)
### 7.1 Task Handoff Template (to Gemini/Codex)
```markdown
## TASK FOR [AGENT]

**Objective**: <one sentence>

**Context**
- Current state:
- Goal state:
- Constraints:

**Inputs**
- Files: <@path list or explicit paths>
- Spec/docs:

**Expected Output**
- Format: <md/json/code>
- Deliverables: <numbered>
- Quality criteria: <acceptance checks>

**Do NOT**
- <explicit out-of-scope / avoid>

**Complexity**: Low/Med/High
```

### 7.2 Result Submission Template (from agents)
```markdown
## TASK RESULT: <name>

**Status**: ✅ Complete / ⚠️ Partial / ❌ Blocked
**Summary**: <2–3 sentences>

**Deliverables**
1) <item + location>

**Key Findings** (research):
- <bullets>

**Assumptions**
- <bullets>

**Questions/Blockers**
- <bullets>

**Next Steps**
- <bullets>

**Quality Self-Check**
- [ ] Meets criteria
- [ ] No obvious errors
- [ ] Follows conventions
```

---

## 8) CLI Integration (Operational Contract)
### 8.1 Working directories
```bash
mkdir -p ~/.claude-orchestration/{gemini,codex,artifacts}
```

### 8.2 Output file naming (avoid collisions)
```bash
TS=$(date +%Y%m%d-%H%M%S)
# write outputs to unique files per run
```

### 8.3 Gemini CLI: Token-Efficient Headless Pattern
**Rule**: Use `-p` for headless mode. Prefer **@path** references. Use atomic (single-file) prompts.  
**Avoid**: broad “search entire codebase”, `$(cat file)` inline, or stdin piping unless unavoidable.

**Observed efficiency (48KB Swift file, from project directory)**:
- `@path`: ~21,457 tokens (best)
- `$(cat)`: ~41,295 tokens (~2× worse)
- stdin: ~40,000 tokens (~2× worse)

**Recommended** (Execute from project directory):
```bash
cd /Users/nexus/iOSdev/Somni
gtimeout 90 gemini -p "Analyze @Services/ExportService.swift for error handling patterns. Output JSON with line references." -y -o json \
  > ~/.claude-orchestration/gemini/exportservice-errors-$TS.json
```

### 8.4 Codex CLI: Non-Interactive Pattern
Use `codex exec` with `--full-auto` and `--json` when structured parsing is needed.
```bash
codex exec "Implement <well-defined spec>." --full-auto --json \
  2>&1 | tee ~/.claude-orchestration/codex/task-$TS.json
```

---

## 9) Quality Control Gates (Acceptance Criteria)
### 9.1 Before accepting Gemini output
- [ ] File paths exist and are correct  
- [ ] Coverage is comprehensive for scope (multiple likely locations checked)  
- [ ] Line numbers/context are plausible  
- [ ] No invented APIs/files/patterns  
- [ ] Recommendations are actionable

### 9.2 Before accepting Codex output
- [ ] Code compiles (Swift)  
- [ ] Project conventions: naming, `MARK`, structure  
- [ ] No force unwraps / unsafe patterns unless explicitly justified  
- [ ] Error handling present where needed  
- [ ] Tests pass (if applicable)  
- [ ] Accessibility labels for UI (when relevant)

### 9.3 Always required
- Claude reviews *all* code before commit  
- Claude owns git operations + final commit messages  
- Claude maintains master context for the user

---

## 10) Token Budgeting (Targets)
**Typical feature distribution (illustrative target)**:
- Understanding/Planning: Claude-heavy  
- Research/Exploration: Gemini-heavy  
- Code Generation: Codex-heavy  
- Review/Integration: Claude-heavy  
- Testing/Validation: shared

**Headline target**: ~60% Claude token reduction vs Claude-only by offloading research + boilerplate.

---

## 11) Monitoring & Metrics (Minimum Viable)
### 11.1 Track
**Efficiency**: Claude tokens/task, tokens saved, time-to-complete, cost/feature  
**Quality**: rejection rate by agent, bug intro rate, coverage achieved, doc accuracy  
**Process**: rework rate, integration complexity, user blocking questions  
**Cost**: budget adherence, monthly trend, ROI check

### 11.2 Simple logs
- `~/.claude-orchestration/token-log.md` (weekly summaries)  
- `~/.claude-orchestration/quality-log.md` (accept/reject + failure patterns)  
- `~/.claude-orchestration/costs.csv` (optional: actual spend)

---

## 12) Risks & Mitigations
1) **Hallucination** → Claude review; verify paths; run tests; reject if uncertain  
2) **Context loss** → Claude is master; structured handoffs + results include assumptions  
3) **Quality degradation** → enforce gates; tighten specs; add tests; iterate prompts  
4) **Over-delegation** → keep architecture/complex logic/user comms/git with Claude  
5) **Session expiry / interactive prompts** → detect “login required”; use timeout wrappers; retry or fallback

---

## 13) Authentication (Session-Based, not API keys)
```bash
gemini "test" 2>&1 | grep -i "login" || true
codex  "test" 2>&1 | grep -i "login" || true
# If expired:
gemini login
codex login
```

---

## 14) Error Handling & Fallback (Robust Delegation)
```bash
TS=$(date +%Y%m%d-%H%M%S)
OUT=~/.claude-orchestration/gemini/out-$TS.md

# Execute from project directory
cd /Users/nexus/iOSdev/Somni

if ! timeout 60 gemini -p "Analyze @Services/File.swift for <x>." -y -o text > "$OUT" 2>&1; then
  echo "Delegation failed/timeout → Claude handles directly" >&2
fi
```

Common failures: session expired, network timeout, interactive prompt, rate limits, model deprecation.

---

## 15) Quick Start (Minimal)
1) Create directories:
```bash
mkdir -p ~/.claude-orchestration/{gemini,codex,artifacts}
```
2) Verify binaries:
```bash
which gemini
which codex
```
3) Run one Codex smoke test:
```bash
TS=$(date +%Y%m%d-%H%M%S)
codex exec "Generate a Swift Date extension for relative time strings." --full-auto --json \
  2>&1 | tee ~/.claude-orchestration/codex/smoke-$TS.json
```
4) Run one Gemini atomic analysis from project directory:
```bash
TS=$(date +%Y%m%d-%H%M%S)
cd /Users/nexus/iOSdev/Somni
gtimeout 90 gemini -p "Summarize responsibilities + error handling in @Services/ExportService.swift. Output JSON." -y -o json \
  > ~/.claude-orchestration/gemini/smoke-$TS.json
```

---

## 16) Success Criteria
**After 2 weeks**
- [ ] ≥50% reduction in Claude tokens  
- [ ] ≥90% acceptance rate for delegated work (after Claude review)  
- [ ] 0 agent-introduced bugs reaching main  
- [ ] measurable speedup from parallelization  
- [ ] user experience maintained

**After 1 month**
- [ ] ≥60% Claude token reduction  
- [ ] stable patterns for common tasks  
- [ ] metrics logging automated  
- [ ] ROI demonstrated; guardrails refined

---

## 17) Operational File Map (Critical)
- `~/.maestro/learnings.md` — prompt patterns + quality issues (survives compaction)  
- `~/.maestro/token-log.md` — usage tracking  
- `docs/maestro/WORKSPACE-AUDIT.md` — pre-use verification  
- `docs/maestro/FAILURE-RUNBOOK.md` — symptom→cause→fix  
- `docs/maestro/COST-GUARDRAILS.md` — budget enforcement  
- `DELEGATION-MATRIX.md` — strict routing rules (authoritative)

---

**End of condensed plan.**
