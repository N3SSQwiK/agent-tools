# MAESTRO Failure Mode Runbook
**Operational Troubleshooting Guide**

**Version**: 1.0
**Created**: December 18, 2025
**Status**: Production
**Purpose**: Diagnose and resolve common MAESTRO delegation failures

---

## Quick Reference Card

```
┌─────────────────────────────────────────────────┐
│ FAILURE MODE DIAGNOSIS                          │
├─────────────────────────────────────────────────┤
│                                                 │
│ 1. Timeout (exit 124)                          │
│    ├─ Gemini → Validate output first (may be   │
│    │           complete despite timeout)       │
│    ├─ If valid → Accept as soft success        │
│    └─ If invalid → Query too broad, use atomic │
│                                                 │
│ 2. High Token Usage (>30K Gemini)              │
│    ├─ Using $(cat)? → Switch to @path          │
│    └─ Model router? → Disable in settings.json │
│                                                 │
│ 3. Hallucinations                               │
│    ├─ Gemini → Line numbers wrong, add quotes  │
│    └─ Codex → Force unwraps, add constraints   │
│                                                 │
│ 4. Session Expired                              │
│    └─ Run `gemini login` or `codex login`      │
│                                                 │
│ 5. Build/Test Failures                          │
│    ├─ Codex output → Reject, retry with error  │
│    └─ Missing context → Add to INPUT CONTEXT   │
│                                                 │
└─────────────────────────────────────────────────┘
```

---

## 1. Gemini Failures

### 1.1 Timeout (Exit Code 124)

**Symptom**:
```bash
gtimeout 90 gemini -p "Analyze..." -y -o json
# Exit code: 124
# Output: May be empty OR may contain complete valid output
```

**Root Causes**:
| Cause | Detection | Solution |
|-------|-----------|----------|
| **Broad query** | Prompt asks "search all files" | Use atomic query (single file) |
| **Multi-file pattern** | `@Services/*.swift` in prompt | Delegate one file at a time |
| **Network latency** | Occasional, not consistent | Increase timeout to 120s |
| **Model router enabled** | Check settings.json | Disable `useModelRouter: false` |
| **Session cleanup delay** | Output complete but timeout during cleanup | Validate output before rejecting |

**IMPORTANT - Timeout Output Validation Pattern**:

Exit code 124 does NOT always mean failure. Gemini may complete generation before timeout during session cleanup.

**Detection Protocol**:
```bash
# 1. Capture both exit code AND output
OUTPUT=$(gtimeout 90 gemini -p "Generate test function testFoo" -y -o text 2>&1)
EXIT_CODE=$?

# 2. If timeout (124), validate output
if [ $EXIT_CODE -eq 124 ]; then
    # Check if expected output exists and is valid
    if echo "$OUTPUT" | grep -q "func testFoo"; then
        # SUCCESS: Complete output captured before timeout
        echo "✅ Soft success: Output complete despite timeout"
    else
        # FAILURE: Incomplete or missing output
        echo "❌ Hard failure: Timeout with incomplete output"
    fi
fi
```

**For File Generation Tasks**:
```bash
# After timeout, check if file was modified
if [ $EXIT_CODE -eq 124 ]; then
    # File may have been written despite timeout
    if [ -f target-file.swift ] && grep -q "expected pattern" target-file.swift; then
        echo "✅ Soft success: File written before timeout"
    else
        echo "❌ Hard failure: File not written or incomplete"
    fi
fi
```

**Resolution Steps**:
1. **Check prompt scope** - Is it atomic (single file, specific question)?
2. **Validate output** - Check if expected output exists despite timeout
3. **If output valid** → Accept as soft success (output was complete before timeout)
4. **If output invalid** → Narrow query, reduce to single file analysis
5. **Increase timeout** - Try 120s (max) if consistently timing out on valid queries
6. **If persistent with invalid output** → Claude handles directly (do not delegate)

**Example Fix**:
```bash
# ❌ BAD: Broad query
gemini -p "Find all error handling patterns across Services/"

# ✅ GOOD: Atomic query
gemini -p "Analyze @Services/ExportService.swift for error handling patterns. List line numbers."
```

**Evidence**:
- Source: Phase 2 Task 19 completion (Dec 23, 2025)
- Gemini generated complete test functions despite exit code 124
- Tests appeared in files via Xcode auto-save/file watching
- All 4 generated tests compiled and were valid Swift code

---

### 1.2 Token Overhead (>30K tokens for single file)

**Symptom**:
```json
{
  "tokens": {
    "prompt": 41295,  // Expected: 4,468
    "candidates": 258
  }
}
```

**Root Causes**:
| Cause | Detection | Impact | Solution |
|-------|-----------|--------|----------|
| **Using $(cat)** | Command uses `$(cat file)` | 9.2x token waste | Switch to @path |
| **stdin piping** | Command uses `cat file \|` | 9.0x token waste | Switch to @path |
| **Model router** | `useModelRouter: true` | 2-3 models run | Disable in settings.json |
| **ImportProcessor** | Warnings in output | Non-functional overhead | Add to .geminiignore |

**Resolution Steps**:
1. **Check command pattern** - Using @path or $(cat)?
2. **Verify settings.json** - Is `useModelRouter: false`?
3. **Check .geminiignore** - Is `docs/maestro/**` excluded?
4. **Measure improvement** - Re-run with fixes, compare tokens

**Evidence-Based Fix**:
```bash
# ❌ BAD: $(cat) pattern (41,295 tokens)
gemini -p "Analyze: $(cat Services/File.swift)"

# ✅ GOOD: @path pattern (4,468 tokens)
gemini -p "Analyze @Services/File.swift"

# Token savings: 36,827 tokens (892% reduction)
# Cost savings: $0.74 per delegation
```

**Production Configuration**:
```json
// ~/.gemini/settings.json
{
  "context": {
    "loadFromIncludeDirectories": false,
    "fileFiltering": {
      "enableRecursiveFileSearch": false
    }
  },
  "experimental": {
    "useModelRouter": false
  }
}
```

```
// .geminiignore (repo root)
docs/maestro/**
```

---

### 1.3 Hallucinated Line Numbers

**Symptom**:
- Gemini claims "line 42 has error handling"
- Actual line 42 is empty or different code

**Root Cause**: Gemini estimated locations instead of reading carefully

**Resolution**:
```markdown
## Retry Prompt (Updated)

OBJECTIVE: [same as before]

INPUT: @Services/File.swift

OUTPUT:
- Include EXACT line numbers
- Quote 2-3 lines of actual code for each finding
- If location unclear, say "Location unclear" (do not guess)

Format:
| Line | Code Quote | Pattern |
|------|------------|---------|
| 42   | `if error != nil {` | guard pattern |
```

**Validation**:
1. Spot-check 5 random line numbers
2. Read source file, verify quotes match
3. Reject if >50% inaccurate

---

### 1.4 Session Expired

**Symptom**:
```
Error: Please log in using 'gemini login'
```

**Resolution**:
```bash
# Re-authenticate
gemini login
# Opens browser for OAuth flow

# Retry delegation
gtimeout 90 gemini -p "..." -y -o json
```

**Prevention**: Run `gemini login` weekly to refresh session

---

## 2. Codex Failures

### 2.1 Timeout After Completion (Soft Success)

**Symptom**:
```bash
codex exec "..." --full-auto --json
# Exit code: 124 (timeout)
# But file changes already written
```

**Root Cause**: Codex completed work but timed out during post-validation

**Detection**:
```bash
# Check JSONL for completion status
grep '"status":"completed"' ~/.maestro/codex/$TASK_ID.jsonl

# If found → SOFT SUCCESS (work completed)
# If not found → HARD FAILURE (work incomplete)
```

**Resolution**:
```bash
# Extract output despite timeout
cat $TASK_ID.jsonl | grep '"type":"agent_message"' | tail -1 | jq -r '.item.text'

# Validate normally (build, tests, grep checks)
# If valid → Accept
# If invalid → Retry with narrower scope
```

**Source**: Task 3.1 testing (Dec 18, 2025) - Test 2 timed out at 121s but completed work at 89s

---

### 2.2 Force Unwraps Detected

**Symptom**:
```bash
# Grep validation fails
grep '!' generated-code.swift | grep -v '!=' | grep -v '//'
# Output: entry.child!.name (force unwrap found)
```

**Resolution**:
```markdown
## Retry Prompt (Updated Constraints)

CONSTRAINTS:
- NO force unwraps (!) - use guard let, if let, or optional chaining
- Example CORRECT pattern:
  ```swift
  guard let value = optional else { return }
  // use value safely
  ```
- Example INCORRECT pattern:
  ```swift
  let value = optional!  // ❌ FORBIDDEN
  ```
```

**Validation Gate**:
```bash
# After generation
if grep -r '!' <changed-files> | grep -v '!=' | grep -v '//'; then
    echo "❌ REJECT: Force unwrap detected"
    # Retry with updated constraints
fi
```

---

### 2.3 Build Failures (Missing Imports)

**Symptom**:
```bash
xcodebuild build
# Error: Use of unresolved identifier 'MissingType'
```

**Resolution**:
```markdown
## Retry Prompt (Updated Input Context)

INPUT CONTEXT (UPDATED):
```swift
// Add missing import
import Foundation

// Add type definition
struct MissingType {
    var property: String
}

// Existing code...
```
```

---

### 2.4 Multiline Prompt Failures

**Symptom**:
```bash
codex exec "$(cat <<'EOF'
OBJECTIVE: ...
EOF
)" --full-auto
# Error: unknown file attribute
```

**Root Cause**: Shell heredocs not supported in Codex prompts

**Resolution**:
```bash
# ✅ CORRECT: Single-line prompt with inline sections
codex exec "OBJECTIVE: Generate... TARGET FILES: file.swift REQUIREMENTS: 1) X, 2) Y" --full-auto
```

**Source**: Task 3.1 testing (Dec 18, 2025) - Multiline heredocs fail with shell errors

---

### 2.5 Session Expired

**Symptom**:
```
Error: Please log in using 'codex login'
```

**Resolution**:
```bash
codex login
# Opens browser for OAuth

# Retry delegation
codex exec "..." --full-auto --json
```

---

## 3. Integration Failures

### 3.1 Concurrent File Access Conflicts

**Symptom**:
- Two Codex tasks modifying same file
- Output overwrites, data loss

**Prevention**:
```bash
# ✅ SAFE: Sequential execution
codex exec "Task A on file1" --full-auto && \
codex exec "Task B on file1" --full-auto

# ✅ SAFE: Parallel with file isolation
codex exec "Task A on file1" --full-auto &
codex exec "Task B on file2" --full-auto &
wait

# ❌ UNSAFE: Parallel on same file
codex exec "Task A on file1" --full-auto &
codex exec "Task B on file1" --full-auto &  # CONFLICT
```

**Detection**:
```bash
# Check for active Codex tasks before starting
ps aux | grep "codex exec" | grep -v grep
# If output → Wait or verify file isolation
```

---

### 3.2 Silent Over-Analysis (Gemini)

**Symptom**:
- Prompt asks for "top 10 findings"
- Gemini returns 50 findings

**Prevention**:
```markdown
SIZE CONSTRAINT (HARD LIMIT):
- Maximum 10 findings
- Count your findings and STOP at exactly 10
- If more than 10 exist, select the 10 most critical only
```

**Validation**:
```bash
# Count findings before accepting
wc -l < output.md
# If >10 → Reject, retry with stricter constraint
```

---

### 3.3 Cache Bleed (Gemini)

**Symptom**:
- Token usage increases over time
- Cache growing unbounded

**Resolution**:
```bash
# Clear cache
mv ~/.gemini/tmp ~/.gemini/tmp-backup-$(date +%s)

# Verify improvement
gtimeout 90 gemini -p "Test query" -y -o json
# Check token count in output
```

**Prevention**: Clear cache monthly or after major config changes

---

## 4. Emergency Procedures

### 4.1 Total Delegation Failure

**When to abort delegation**:
- 3+ retry attempts failed
- Timeout persists despite scope reduction
- Hallucinations persist despite constraints
- Build/test failures not resolvable

**Abort Protocol**:
1. **Stop delegation** - Do not retry further
2. **Claude handles directly** - Read files, analyze manually
3. **Log failure** - Document in `~/.maestro/workflows/failure-$(date +%s).md`
4. **Update learnings** - Add to `~/.maestro/learnings.md` for future prevention

**Failure Log Template**:
```markdown
# Delegation Failure: [Task Name]
**Date**: [timestamp]
**Agent**: Gemini | Codex
**Attempts**: 3

## Failure Symptoms
- [List observed symptoms]

## Attempts
1. Attempt 1: [What was tried, what failed]
2. Attempt 2: [What was changed, still failed]
3. Attempt 3: [Final attempt, abort]

## Root Cause (Best Guess)
[Hypothesis about why delegation failed]

## Claude Direct Implementation
[How Claude handled it instead]

## Prevention for Future
[What to avoid or do differently]
```

---

### 4.2 Workspace Corruption

**Symptom**:
- Codex output corrupted files
- Build completely broken
- Git shows massive unexpected diffs

**Recovery**:
```bash
# 1. Immediate rollback
git status
git diff  # Review changes
git restore <corrupted-files>

# 2. Verify recovery
xcodebuild build
# Should succeed

# 3. Document incident
echo "$(date): Workspace corruption from Codex task [ID]" >> ~/.maestro/incidents.log

# 4. Retry task with validation gates
# Add explicit OUTPUT FORMAT constraints
```

**Prevention**:
- Always commit before delegating
- Use `--json` flag for structured output parsing
- Validate before integration (build + tests)

---

## 5. Production Monitoring

### 5.1 Token Budget Overruns

**Detection**:
```bash
# Review token log
cat ~/.maestro/token-log.md

# Check if exceeding budget
# Expected: ~27K/delegation for Gemini
# Expected: ~8K/delegation for Codex (with caching)

# If consistently >30K for Gemini → Investigate
```

**Response**:
1. Check if using @path pattern (not $(cat))
2. Verify `useModelRouter: false` in settings
3. Clear cache if bloated
4. Review prompts for unnecessary verbosity

---

### 5.2 Success Rate Degradation

**Monitoring**:
```bash
# Track acceptance rate in learnings.md
# Expected: >90% acceptance rate

# If dropping below 80%:
# - Review recent failures
# - Check for prompt template drift
# - Verify validation gates still running
```

---

## 6. Diagnostic Commands

### 6.1 Gemini Health Check

```bash
# Test basic query
gtimeout 60 gemini -p "What is 2+2?" -y -o json > /tmp/gemini-health.json

# Check tokens (should be ~200-500)
cat /tmp/gemini-health.json | grep -o '"prompt":[0-9]*'

# Check session
gemini -p "test" -y -o json 2>&1 | grep -i "login"
# If "login" found → Session expired
```

### 6.2 Codex Health Check

```bash
# Test basic execution
codex exec "What is 2+2?" --full-auto --json > /tmp/codex-health.jsonl

# Check exit code
echo $?
# 0 = success, 1 = failure, 124 = timeout

# Extract response
cat /tmp/codex-health.jsonl | grep '"type":"agent_message"' | tail -1
```

### 6.3 Token Efficiency Audit

```bash
# Compare @path vs $(cat) on same file
FILE="Services/ExportService.swift"

# Test 1: @path pattern
gtimeout 90 gemini -p "Analyze @$FILE briefly" -y -o json > /tmp/test-atpath.json
TOKENS_ATPATH=$(cat /tmp/test-atpath.json | grep -o '"prompt":[0-9]*' | cut -d: -f2)

# Test 2: $(cat) pattern
gtimeout 90 gemini -p "Analyze: $(cat $FILE)" -y -o json > /tmp/test-cat.json
TOKENS_CAT=$(cat /tmp/test-cat.json | grep -o '"prompt":[0-9]*' | cut -d: -f2)

# Compare
echo "@path tokens: $TOKENS_ATPATH"
echo "\$(cat) tokens: $TOKENS_CAT"
echo "Overhead: $((TOKENS_CAT - TOKENS_ATPATH)) tokens"
```

---

## 7. Escalation Matrix

| Severity | Response Time | Action |
|----------|---------------|--------|
| **P1: Workspace corruption** | Immediate | Git rollback, abort all delegations |
| **P2: 100% delegation failure** | 5 minutes | Switch to Claude direct implementation |
| **P3: >3x token budget** | 15 minutes | Audit configuration, disable delegation temporarily |
| **P4: Session expired** | On-demand | User runs `gemini login` / `codex login` |
| **P5: Occasional timeout** | Next session | Adjust timeouts, narrow prompts |

---

## 8. Version History

**v1.1** (December 23, 2025)
- **Added**: Gemini timeout output validation pattern (Section 1.1)
- **Discovery**: Exit code 124 ≠ automatic failure; validate output first
- **Evidence**: Phase 2 Task 19 - 4 complete test functions generated despite timeouts
- **Impact**: Reduced false-negative delegation failures

**v1.0** (December 18, 2025)
- Initial production runbook
- Based on Phase 3 testing (Dec 17-18, 2025)
- Incorporates ChatGPT peer review feedback
- Includes evidence-based fixes (token counts, exit codes)

---

## References

- **Authority**: `DELEGATION-MATRIX.md` (routing rules)
- **Execution**: `GEMINI.md`, `CODEX.md` (contracts)
- **Evidence**: `docs/maestro/To-Assess/validation/` (test results)
- **Learnings**: `~/.maestro/learnings.md` (persistent patterns)

---

**Status**: ✅ Production (v1.1 - Dec 23, 2025)
**Next Review**: Quarterly (March 2026) or after 5+ P1 incidents
