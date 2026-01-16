# Claude Action Checklist (MAESTRO)
**Version**: 1.3 (Corrected based on live testing)
**Date**: December 19, 2025
**Status**: MANDATORY for all delegations

This checklist defines **mandatory actions Claude Code must perform** before, during, and after delegating to Gemini CLI or Codex CLI.
Failure to complete a REQUIRED item is grounds to abort delegation.

---

## 1. Pre-Delegation Gate (REQUIRED)

- [ ] Confirm delegation eligibility via `DELEGATION-MATRIX.md`
- [ ] Identify execution contract (`GEMINI.md` or `CODEX.md`)
- [ ] Log delegation intent (objective, agent, contract reference)

---

## 2. Gemini Delegation Checklist

### 2.1 Environment Requirements (REQUIRED)
- [ ] **Mandatory**: Execute from project directory (where files are accessible)
- [ ] Use relative paths with `@path` syntax (e.g., `@Services/File.swift`)
- [ ] Be aware of `.gemini/` configuration if present (causes non-fatal ImportProcessor warnings)
- [ ] Accept ImportProcessor warnings as cosmetic (do not abort on warnings alone)

**Rationale** (Updated Dec 19, 2025 - Live Testing):
- **Clean directory execution FAILS**: Gemini's `read_file` tool is sandboxed to workspace directories
- **@path triggers read_file tool**: Cannot access files outside execution directory
- **Project directory execution WORKS**: Files are within workspace, `read_file` succeeds
- **Trade-off**: Accept cosmetic ImportProcessor warnings for functional file access
- **Finding**: v1.2's clean directory requirement was incompatible with @path file access mechanism

### 2.2 Prompt Construction (REQUIRED)
- [ ] **Mandatory**: Use only `@path` references for file access
- [ ] **Forbidden**: `$(cat)` inline or stdin piping (9.2x more expensive, not broken)
- [ ] Avoid ambiguous substrings in prompts if possible
- [ ] Explicitly state: objective, scope, constraints, output format

**Token Efficiency** (Updated Dec 19, 2025 - Live Testing):
- ✅ `@path`: ~21,457 tokens (48KB Swift file, from project directory)
- ❌ `$(cat) inline`: ~41,295 tokens (from clean-room tests)
- ❌ `stdin`: ~40K tokens (estimated)

**Why @path recommended**: Still more efficient than $(cat) inline (~2x better), and triggers Gemini's built-in file reading capability.

**Note**: Previous claim of 4,468 tokens was NOT reproduced in live testing. Actual @path usage shows ~21K tokens for same file size.

### 2.3 Execution (REQUIRED)
- [ ] Apply conservative timeout (90-120 seconds)
- [ ] Capture stdout and stderr to file
- [ ] Use JSON output format for token usage tracking

### 2.4 Output Validation (REQUIRED)
- [ ] Verify referenced files exist in filesystem
- [ ] Reject hallucinated paths or code symbols
- [ ] Confirm analysis scope matches request
- [ ] Check token usage in JSON output (validate efficiency)

---

## 3. Codex Delegation Checklist

### 3.1 Prompt Shape (REQUIRED)
- [ ] **Mandatory**: Single-line prompt only
- [ ] **Forbidden**: Heredocs or multiline bash formatting
- [ ] Use inline section delimiters if needed (e.g., "OBJECTIVE: X. REQUIREMENTS: Y.")

**Why single-line**: Multiline prompts cause "unknown file attribute" shell errors.

### 3.2 Mandatory Constraints Injection (REQUIRED)
- [ ] Inject all safety constraints from `CODEX.md` Section 2
- [ ] Specify target files explicitly (absolute or repo-relative paths)
- [ ] List banned patterns (e.g., "no force unwraps (!)")
- [ ] Define output format (unified diff | full file | test file)

### 3.3 Execution (REQUIRED)
- [ ] Enable JSONL output (`--json` flag)
- [ ] Apply timeout guard (120-180 seconds)
- [ ] Capture full event stream to file

### 3.4 Timeout Handling (CRITICAL)
- [ ] **On timeout (exit 124)**: Parse JSONL for `file_change` events
- [ ] Check if `file_change.status="completed"` exists
- [ ] **If found**: Treat as soft success (work completed before timeout)
- [ ] **If not found**: Treat as hard failure (incomplete work)

**Rationale**: Codex may run validation after file changes, causing timeout post-completion.

### 3.5 Output Validation (REQUIRED)
- [ ] Read all modified files from `file_change.changes` array
- [ ] Run grep for banned patterns (e.g., `grep '!' file | grep -v '!=' | grep -v '//'`)
- [ ] Attempt build if applicable (`xcodebuild`, `swift build`, etc.)
- [ ] Run affected tests if applicable
- [ ] **Reject on any violation** (revert changes, escalate to Claude)

---

## 4. Retry Ladder (REQUIRED)

**Max retries**: 2
**Rule**: Each retry MUST modify prompt structure (identical retries forbidden)

### Retry Protocol
1. **Attempt 1**: Normal prompt with full specification
2. **Failure**: Classify error type
   - Timeout? Check JSONL for completion
   - Validation failure? Extract error message
   - Hallucination? Narrow scope
3. **Attempt 2**: Modified prompt
   - Timeout → increase timeout OR narrow scope
   - Validation → include error message in prompt
   - Hallucination → add explicit constraints
4. **Failure 2**: Abort delegation
5. **Escalation**: Claude handles task directly

### Abort Conditions
- Two failures with different prompt structures
- Validation cannot be made deterministic
- Agent behavior deviates from documented patterns

---

## 5. Negative Test Enforcement

**Must pass before production use**:

### Gemini Negative Tests
- [ ] Broad codebase query aborts correctly (e.g., "search entire codebase for X")
- [ ] Multi-file analysis without @path references fails gracefully
- [ ] Invalid @path references return clear error

### Codex Negative Tests
- [ ] Invalid multiline prompt format rejected
- [ ] Prompt without target files rejected or flagged
- [ ] Unauthorized file access blocked or flagged

### Cross-Agent Tests
- [ ] Partial outputs from timeouts not leaked to next step
- [ ] Failed validation prevents merge/commit

**Status** (Dec 18, 2025): NOT TESTED - Priority 4 in action plan

---

## 6. End-to-End Workflow Discipline

**Until Task 3.3 complete**:
- [ ] Treat MAESTRO as **single-agent-at-a-time** only
- [ ] No multi-agent workflows (Claude → Gemini → Codex → Claude)
- [ ] Validate each agent's output before next step

**After Task 3.3 complete**:
- [ ] Multi-agent workflows allowed
- [ ] Validate all cross-agent handoffs
- [ ] Measure actual token savings vs estimates

---

## 7. Audit Record (REQUIRED)

**For every delegation**, log:
- **Task ID**: Unique identifier (timestamp or description)
- **Agent**: Gemini or Codex
- **Contract**: Which execution contract used (GEMINI.md v1.0, etc.)
- **Prompt Summary**: Condensed objective (1 sentence)
- **Outcome**: Success / Soft success (timeout + completion) / Failure
- **Validation**: What checks passed/failed
- **Intervention**: What Claude did with output (accepted / modified / rejected)

**Log location**: `~/.maestro/workflows/delegation-log-YYYY-MM-DD.md`

**Example entry**:
```markdown
## 2025-12-18 17:30 - Gemini Analysis

- **Task**: Analyze RecommendationEngine.swift error handling
- **Agent**: Gemini CLI
- **Contract**: GEMINI.md v1.1
- **Prompt**: "@path analysis, error handling patterns, max 300 words"
- **Outcome**: ✅ Success (4,468 tokens)
- **Validation**: ✅ All file refs exist, no hallucinations
- **Intervention**: Accepted analysis, used in planning
```

---

## 8. Abort Conditions (IMMEDIATE HALT)

**Abort delegation immediately if**:
- Execution contracts cannot be satisfied (missing tools, wrong versions)
- Environment contamination prevents clean execution
- Agent behavior deviates from documented patterns (unexpected errors, crashes)
- Validation cannot be made deterministic (no way to verify safety)
- Two retry attempts fail
- User safety at risk (secrets, destructive operations)

**On abort**:
1. Log failure reason in audit record
2. Escalate to Claude for direct handling
3. Inform user of issue and fallback plan

---

## 9. Clean-Room Testing Insights (Dec 18, 2025)

**Critical learnings from Priority 1 testing**:

### Gemini
- ✅ @path works from PROJECT DIRECTORY with relative paths
- ❌ @path FAILS from clean directory (workspace sandbox blocks external files)
- ✅ @path is ~2x more efficient than $(cat) inline (~21K vs ~41K tokens)
- ⚠️ **Critical finding**: Clean directory execution incompatible with @path file access
- ⚠️ **Token discrepancy**: Observed 21,457 tokens (not 4,468 as initially claimed)

### Codex
- ✅ Timeouts after file completion are common (check JSONL)
- ❌ Multiline prompts fail with shell errors
- ✅ Token caching is highly effective (83% cache hit rate)

### Methodology
- ✅ Always do clean-room validation before declaring patterns "broken"
- ✅ Measure token efficiency comparatively (not just absolute)
- ✅ Isolate variables (environment, file attributes, shell context)

---

## 10. Integration with Existing Docs

**This checklist references**:
- `DELEGATION-MATRIX.md` - Section 0 (Absolute Preconditions)
- `GEMINI.md` - Section 1 (File Access Patterns), Section 5 (Validation Gates)
- `CODEX.md` - Section 2 (Prompt Contract), Section 5 (Validation Gates)

**Where to use this checklist**:
- Before every delegation (Section 1: Pre-Delegation Gate)
- During delegation (Sections 2-3: Agent-specific checklists)
- After delegation (Section 7: Audit Record)
- On failure (Section 4: Retry Ladder, Section 8: Abort Conditions)

---

**Final Rule:**
**Claude retains accountability.** Delegation is a performance optimization, not a responsibility transfer. If unsure, Claude handles directly.

---

**Document Status**: ✅ ACTIVE
**Next Review**: After Task 3.3 (End-to-End Workflows) complete
**Changelog**:
- v1.0 (Dec 18, 2025) - Initial version from ChatGPT peer review
- v1.1 (Dec 18, 2025) - Updated with clean-room testing findings (Gemini patterns work, token efficiency data)
- v1.2 (Dec 19, 2025) - Mandated clean directory execution (predictability > convenience for orchestration)
- v1.3 (Dec 19, 2025) - **CORRECTED**: Reverted to project directory execution after live testing revealed clean directory incompatible with @path. Updated token efficiency expectations (21K actual vs 4K claimed).
