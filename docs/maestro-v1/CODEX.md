# CODEX - Code Generation Execution Contract

**Version**: 1.1
**Created**: December 18, 2025
**Updated**: December 18, 2025
**Status**: Active
**Authority**: DELEGATION-MATRIX.md governs WHETHER to delegate. This document governs HOW.

---

## Purpose

Defines the execution contract for Codex CLI: invocation patterns, formats, validation gates, retry logic, and constraints when delegation is approved by DELEGATION-MATRIX.md.

**Codex Role**: Code writer/transformer - Produces code artifacts (diffs, single files, test files, transformations).

---

## 1. Non-Interactive Invocation Pattern

### Required Command Structure

```bash
gtimeout <seconds> codex exec "<prompt>" --full-auto --json -C <repo-path> 2>&1 | tee ~/.claude-orchestration/codex/<task-id>.jsonl
```

**Components**:
- `gtimeout <seconds>`: Mandatory timeout wrapper (see Timeout Guidelines)
- `codex exec`: Non-interactive execution mode
- `"<prompt>"`: Structured prompt (see Prompt Contract)
- `--full-auto`: Auto-approve sandbox operations (workspace-write mode)
- `--json`: Structured JSONL output
- `-C <repo-path>`: Absolute path to repository working directory
- `2>&1 | tee <output>`: Capture stdout+stderr, save for validation

### Flags Reference (Verified)

| Flag | Purpose | Required | Notes |
|------|---------|----------|-------|
| `exec` | Non-interactive mode | YES | Headless execution |
| `--full-auto` | Auto-approve | YES | Sets `-a on-request --sandbox workspace-write` |
| `--json` | JSONL output | YES | Structured event stream |
| `-C / --cd` | Working directory | YES | Absolute path |
| `-m / --model` | Model selection | NO | Omit for default (recommended) |
| `-o / --output-last-message` | Save final message | NO | Debugging only |

**Source**: `~/.maestro/verification/codex-verification-report.md` (Task 1.1, verified Dec 17, 2025)

---

## 2. Prompt Contract (Mandatory Structure)

### Prompt Format Requirements (CRITICAL)

**Single-line prompts ONLY** - Multiline heredocs cause shell errors:
```bash
# ❌ WRONG: Multiline heredoc (fails with "unknown file attribute")
codex exec "$(cat <<'EOF'
OBJECTIVE: Generate...
TARGET FILES: ...
EOF
)" --full-auto

# ✅ CORRECT: Single-line with inline sections
codex exec "OBJECTIVE: Generate... TARGET FILES: ... REQUIREMENTS: 1) X, 2) Y" --full-auto
```

**Source**: Task 3.1 testing (Dec 18, 2025) - Multiline prompts failed with shell evaluation errors

Every Codex prompt MUST include these sections:

```markdown
OBJECTIVE:
<One-sentence: What artifact will exist after completion>

TARGET FILES:
<Absolute or repo-relative paths where code will be written>

INPUT CONTEXT:
<Minimal code excerpts - only required context>

REQUIREMENTS:
- <Specific requirement 1>
- <Specific requirement 2>
- <Pattern or convention to follow>

CONSTRAINTS:
- <Banned patterns (e.g., force unwraps, deprecated APIs)>
- <Safety requirements>
- <Format requirements>

OUTPUT FORMAT:
<Unified diff (preferred) | Single file | Specific structure>

VALIDATION PLAN:
<How Claude will verify: build, tests, grep checks>
```

### Output Format Requirements

**Preferred**: Unified diff format
```diff
--- a/path/to/file.swift
+++ b/path/to/file.swift
@@ -10,3 +10,5 @@
 existing code
+new line 1
+new line 2
```

**Acceptable**: Single file replacement (explicit only)
```swift
// Full file content
```

**Forbidden**: Multi-file modifications, exploratory output, open-ended narratives

### Example Prompt (Test Generation)

```bash
gtimeout 180 codex exec "OBJECTIVE:
Generate XCTest cases for overnight sleep duration calculation.

TARGET FILES:
SomniTests/DateHelpersTests.swift (append to existing file)

INPUT CONTEXT:
// Utilities/DateHelpers.swift:42
func durationUntil(_ endDate: Date) -> TimeInterval {
    return endDate.timeIntervalSince(self)
}

REQUIREMENTS:
- Test 1: 8 PM to 6 AM → 10 hours
- Test 2: 11 PM to 1 AM → 2 hours
- Test 3: 7 PM yesterday to 7 AM today → 12 hours
- Use descriptive test names: test_durationUntil_overnightSession_returns10Hours
- Follow existing patterns in SomniTests/

CONSTRAINTS:
- No force unwraps (!)
- No hardcoded dates (use DateComponents)
- Arrange-Act-Assert pattern

OUTPUT FORMAT:
Unified diff for SomniTests/DateHelpersTests.swift

VALIDATION PLAN:
- Build succeeds (Cmd+B)
- Tests pass (Cmd+U)
- Grep check: no force unwraps
" --full-auto --json -C /Users/nexus/iOSdev/Somni 2>&1 | tee ~/.claude-orchestration/codex/test-gen-20251218-143052.jsonl
```

---

## 3. JSONL Event Structure

### Output Stream Format

Codex outputs events as JSON lines (one JSON object per line):

```jsonl
{"type":"thread.started","thread_id":"<uuid>"}
{"type":"turn.started"}
{"type":"item.completed","item":{"id":"item_0","type":"agent_message","text":"<generated code>"}}
{"type":"turn.completed","usage":{"input_tokens":7357,"cached_input_tokens":6144,"output_tokens":150}}
```

### Event Types

| Type | Purpose | Key Fields |
|------|---------|------------|
| `thread.started` | Thread init | `thread_id` |
| `turn.started` | Turn begins | None |
| `item.completed` | Agent output | `item.type`, `item.text` |
| `turn.completed` | Turn ends | `usage` (tokens) |

### Success Detection

**Primary**: Shell exit code
```bash
codex exec "..." --full-auto --json > output.jsonl
exit_code=$?

if [ $exit_code -eq 0 ]; then
    echo "SUCCESS"
elif [ $exit_code -eq 124 ]; then
    echo "TIMEOUT"
else
    echo "FAILURE: $exit_code"
fi
```

**Secondary**: Check for `turn.completed` event
```bash
if grep -q '"type":"turn.completed"' output.jsonl; then
    echo "Turn completed successfully"
fi
```

**Extract Output**:
```bash
# Get final message
grep '"type":"agent_message"' output.jsonl | tail -1 | jq -r '.item.text'

# Get token usage
grep '"usage":' output.jsonl | tail -1 | jq '.usage'
```

**Source**: ChatGPT claimed `exit_code` in JSONL. Reality: Use shell `$?`. (Non-breaking difference)

---

## 3.1. Token Efficiency & Caching (December 2025)

### Measured Performance

**Test Case**: Generate relativeTimeString() helper function (Task 3.1, Dec 18, 2025)

```json
{
  "usage": {
    "input_tokens": 35523,
    "cached_input_tokens": 29568,
    "output_tokens": 2117
  }
}
```

**Cache Hit Rate**: **83%** (29,568 cached / 35,523 total)
- **Effective cost**: 5,955 new tokens + 2,117 output = 8,072 tokens
- **Savings**: 29,568 tokens saved via caching (83% reduction in input costs)

### Implications

1. **Codex is highly cache-efficient** for repeated delegations
2. **Subsequent tasks cost ~8K tokens** (vs 38K first time)
3. **Delegation becomes MORE cost-effective over time**

### Cost Estimation

**First delegation**: 35K input + 2K output = ~37K tokens (~$0.74 at $0.02/1K)
**Subsequent delegations**: 6K input + 2K output = ~8K tokens (~$0.16)

**Recommendation**: Leverage caching by batching similar tasks (e.g., generate multiple helper functions in same session)

---

## 4. Timeout Guidelines

| Task Type | Timeout | Abort Threshold |
|-----------|---------|-----------------|
| Simple function | 120s | 180s |
| Test generation (5-10) | 180s | 300s |
| Boilerplate (models) | 180s | 300s |
| Complex transformation | 300s | 480s |
| **Hard limit** | 600s | N/A (abort) |

**Exit code 124**: Timeout triggered by `gtimeout`

### Critical Timeout Behavior (Dec 18, 2025)

**Timeouts may occur AFTER work completes** - Codex can finish file changes but timeout during validation.

**Detection pattern** (check JSONL for completion):
```bash
# On timeout (exit 124), check if work completed
if grep -q '"status":"completed"' ~/.claude-orchestration/codex/$TASK_ID.jsonl; then
    echo "SOFT SUCCESS: Work completed before timeout"
    # Extract and validate output normally
else
    echo "HARD FAILURE: Work incomplete"
fi
```

**Source**: Task 3.1 testing (Dec 18, 2025) - Test 2 timed out at 121s but file changes completed at 89s

**On timeout**:
1. **First**: Check JSONL for `"status":"completed"` (may be soft success)
2. If incomplete: Check if prompt is too broad → Reduce scope
3. If incomplete: Increase timeout (max 600s)
4. If timeout persists → Handle directly (do not delegate)

---

## 5. Validation Gates (Mandatory Before Integration)

Claude MUST validate all Codex output before integration.

### Build Validation

```bash
# Apply diff or write file
# Then build
cd /Users/nexus/iOSdev/Somni
xcodebuild build -scheme Somni -destination 'platform=iOS Simulator,name=iPhone 15'

# Exit code 0 = build success
if [ $? -ne 0 ]; then
    echo "BUILD FAILED - Reject output"
fi
```

### Test Validation

```bash
# Run relevant tests
xcodebuild test -scheme Somni -destination 'platform=iOS Simulator,name=iPhone 15'

# Exit code 0 = tests pass
if [ $? -ne 0 ]; then
    echo "TESTS FAILED - Reject output"
fi
```

### Pattern Validation (Banned Constructs)

```bash
# Check for force unwraps (Swift)
if grep -r '!' <changed-files> | grep -v '!=' | grep -v '//'; then
    echo "FORCE UNWRAP DETECTED - Reject output"
fi

# Check for deprecated APIs (Swift)
if grep -r '@available.*deprecated' <changed-files>; then
    echo "DEPRECATED API - Reject output"
fi

# Check for hardcoded secrets
if grep -r 'api_key\|password\|secret' <changed-files> | grep -v 'keychain'; then
    echo "POTENTIAL SECRET - Review required"
fi
```

### Spot-Check Validation

- [ ] Code follows project conventions (MARK comments, naming)
- [ ] Target files are correct (no modifications to wrong files)
- [ ] Required functionality implemented
- [ ] No obvious logic errors
- [ ] Accessibility labels present (if UI code)
- [ ] Error handling appropriate

**Rejection Criteria** (DO NOT INTEGRATE):
- Build fails
- Tests fail
- Force unwraps in production code
- Missing error handling for failable operations
- Deprecated API usage
- Modifies wrong files
- Introduces security vulnerabilities

---

## 6. Retry Ladder (On Failure)

### Retry Strategy

**Identical retries are FORBIDDEN.** Each retry MUST modify the prompt based on failure.

```
Attempt 1: Original prompt
  ↓ (FAILURE)
Attempt 2: Add error-specific constraint
  ↓ (FAILURE)
Attempt 3: Reduce scope (if timeout) OR Provide concrete example (if quality issue)
  ↓ (FAILURE)
ABORT: Handle directly (do not delegate)
```

### Failure-Driven Correction Patterns

#### Failure: Force unwraps detected

**Retry Prompt Addition**:
```markdown
CONSTRAINTS (UPDATED):
- No force unwraps (!) - use guard let, if let, or optional chaining
- Example correct pattern:
  guard let value = optional else { return }
  // use value safely
```

#### Failure: Build error (undefined symbol)

**Retry Prompt Addition**:
```markdown
INPUT CONTEXT (UPDATED):
// Add missing import or type definition
import Foundation

struct MissingType {
    // definition
}
```

#### Failure: Timeout

**Retry Prompt Modification**:
- Reduce scope: Generate only 3 tests instead of 10
- Simplify requirements: Remove edge cases from first pass
- Increase timeout: 180s → 300s (max 600s)

#### Failure: Wrong file modified

**Retry Prompt Addition**:
```markdown
TARGET FILES (CLARIFIED):
/Users/nexus/iOSdev/Somni/Models/Child.swift (ABSOLUTE PATH)
NOT: Models/ChildView.swift
NOT: Any other file
```

### Maximum Retries

**Hard limit**: 2 retries (3 total attempts)

After 2 failures:
- **ABORT delegation**
- Claude implements directly
- Log failure reason in `~/.claude-orchestration/learnings.md`

---

## 7. Model Selection

### Recommended Models (December 2025)

| Model | Use Case | Timeout | Cost |
|-------|----------|---------|------|
| `gpt-5.1-codex-max` ⭐ | Complex implementations, multi-step | 180-300s | Higher |
| `gpt-5.1-codex-mini` | Simple helpers, boilerplate | 120-180s | Lower |
| **Default (omit -m)** | General code generation | 180s | Optimized |

**Recommendation**: Omit `-m` flag for most tasks. Codex default is optimized.

**Source**: https://developers.openai.com/codex/models (verified Dec 17, 2025)

### Model Selection Override

```bash
# Use specific model (optional)
codex exec "..." -m gpt-5.1-codex-max --full-auto --json

# Use default (recommended)
codex exec "..." --full-auto --json
```

---

## 8. Concurrency Safety

### Rule: One Active Codex Task Per File Set

**Problem**: Multiple Codex tasks modifying the same files cause conflicts.

**Solutions**:
1. **Sequential execution**: Wait for Task A to complete before starting Task B
2. **File set isolation**: Ensure Task A and Task B modify disjoint file sets
3. **Branch isolation**: Run Task A on branch-A, Task B on branch-B

### Enforcement Pattern

```bash
# Check no active tasks on file
ACTIVE_TASKS=$(ps aux | grep "codex exec" | grep -v grep)
if [ -n "$ACTIVE_TASKS" ]; then
    echo "WARNING: Active Codex task detected - wait or verify isolation"
fi
```

### Example: Safe Parallel

```bash
# Task A: Modify Models/Child.swift
gtimeout 180 codex exec "..." -C /Users/nexus/iOSdev/Somni &

# Task B: Modify Services/ExportService.swift (disjoint file set)
gtimeout 180 codex exec "..." -C /Users/nexus/iOSdev/Somni &

# Wait for both
wait
```

### Example: Unsafe Parallel (FORBIDDEN)

```bash
# Task A: Modify Models/Child.swift
gtimeout 180 codex exec "..." &

# Task B: ALSO modify Models/Child.swift ❌ CONFLICT
gtimeout 180 codex exec "..." &
```

---

## 9. Abort Conditions (Do Not Delegate)

Claude MUST abort delegation and handle directly if:

- [ ] Task cannot be made atomic (requires multi-file coordination)
- [ ] Acceptance criteria are unclear or ambiguous
- [ ] Task is security/auth/payments/data-loss critical
- [ ] Cannot run validation gates (no build/test environment)
- [ ] Cannot produce complete Delegation Audit Record
- [ ] Task requires architectural decisions
- [ ] Task requires exploring codebase for context
- [ ] File discovery required before implementation

**Rationale**: Codex is a writer, not a thinker. Use only for well-defined bounded tasks.

---

## 10. Output Discipline

### Allowed Outputs

1. **Unified diff** (preferred):
   ```diff
   --- a/file.swift
   +++ b/file.swift
   @@ -10,3 +10,5 @@
   ```

2. **Single file** (explicit only):
   ```swift
   // Complete file content
   ```

3. **Test file** (bounded):
   ```swift
   // XCTest file with 5-10 test methods
   ```

### Forbidden Outputs

- ❌ Multi-file feature implementations
- ❌ Exploratory analysis or documentation
- ❌ "Best effort" with unspecified gaps
- ❌ Open-ended narratives
- ❌ Code without explicit target files

### Size Caps

| Output Type | Max Size | Enforcement |
|-------------|----------|-------------|
| Unified diff | 500 lines | Prompt constraint |
| Single file | 300 lines | Prompt constraint |
| Test file | 15 test methods | Prompt constraint |

**Example Constraint**:
```markdown
OUTPUT FORMAT:
Unified diff (max 500 lines - split into multiple tasks if needed)
```

---

## 11. Delegation Audit Record (Mandatory)

Before invoking Codex, Claude MUST emit this record in conversation:

```markdown
## DELEGATION AUDIT
Task ID: test-gen-20251218-143052
Primary Output: CODE (XCTest cases)
Routing Decision: CODEX
Matrix Gate Status: PASS
  - Gate 1.1: Task is atomic (single test file) ✅
  - Gate 1.2: Acceptance criteria clear (3 test cases specified) ✅
  - Gate 1.3: Not security critical ✅
  - Gate 2.1: Can validate (build + run tests) ✅
Inputs:
  - Utilities/DateHelpers.swift:42 (func durationUntil)
  - Existing test patterns from SomniTests/DateHelpersTests.swift
Expected Output:
  - Format: Unified diff
  - Size cap: 200 lines (3 test methods)
Validation Plan:
  - Build check (xcodebuild build)
  - Test run (xcodebuild test)
  - Grep check (no force unwraps)
Timeout: 180s
Retry Ladder:
  1. Original prompt
  2. If force unwraps → Add explicit constraint + example
  3. If timeout → Reduce to 2 tests
```

---

## 12. Authentication & Session Management

**Type**: Session-based OAuth (not API keys)

### Check Session Status

```bash
codex exec "What is 2+2?" --full-auto --json 2>&1 | grep -i "login"
# If output contains "please login", session expired
```

### Re-authenticate

```bash
codex login
# Opens browser for OAuth flow
```

### Session Expiry Handling

1. Claude detects "login required" error
2. Inform user: "Codex session expired - run `codex login`"
3. User re-authenticates
4. Claude retries delegation

**Proactive**: Run `codex login` weekly to refresh session

---

## 13. File Management

### Output File Naming

**Use timestamped unique IDs** to prevent concurrent access conflicts:

```bash
TASK_ID="$(date +%Y%m%d-%H%M%S)"
gtimeout 180 codex exec "..." 2>&1 | tee ~/.claude-orchestration/codex/task-$TASK_ID.jsonl
```

### Directory Structure

```
~/.claude-orchestration/codex/
├── test-gen-20251218-143052.jsonl
├── helper-func-20251218-150210.jsonl
└── ... (timestamped outputs)
```

### Cleanup

```bash
# Delete outputs older than 30 days
find ~/.claude-orchestration/codex/ -name "*.jsonl" -mtime +30 -delete
```

---

## 14. Examples

### Example 1: Helper Function (Simple)

```bash
TASK_ID="helper-$(date +%Y%m%d-%H%M%S)"

gtimeout 120 codex exec "OBJECTIVE:
Generate Swift extension for relative time formatting.

TARGET FILES:
Utilities/DateHelpers.swift (append extension)

INPUT CONTEXT:
// Existing DateHelpers.swift structure
extension Date {
    // Other methods...
}

REQUIREMENTS:
- Method: func relativeTimeString() -> String
- Examples: '2 hours ago', 'yesterday', 'just now'
- Use RelativeDateTimeFormatter
- Follow Somni conventions (MARK comments)

CONSTRAINTS:
- No force unwraps
- Use guard statements

OUTPUT FORMAT:
Unified diff (max 100 lines)

VALIDATION PLAN:
- Build check
- Manual test with Date().relativeTimeString()
" --full-auto --json -C /Users/nexus/iOSdev/Somni 2>&1 | tee ~/.claude-orchestration/codex/$TASK_ID.jsonl

# Validate output
cat ~/.claude-orchestration/codex/$TASK_ID.jsonl | grep '"type":"agent_message"' | tail -1 | jq -r '.item.text'
```

### Example 2: Test Generation (Medium Complexity)

```bash
TASK_ID="test-gen-$(date +%Y%m%d-%H%M%S)"

gtimeout 180 codex exec "OBJECTIVE:
Generate XCTest cases for RecommendationEngine.getSleepPressure().

TARGET FILES:
SomniTests/RecommendationEngineTests.swift (create new file)

INPUT CONTEXT:
func getSleepPressure(childAgeMonths: Int, lastWakeTime: Date) -> SleepPressure {
    let hoursAwake = Date().timeIntervalSince(lastWakeTime) / 3600
    let threshold = Constants.wakeWindowThresholds[childAgeMonths] ?? 2.0
    if hoursAwake < threshold * 0.7 { return .low }
    else if hoursAwake < threshold { return .medium }
    else { return .high }
}

REQUIREMENTS:
- Test 1: Newborn (0 months), 30 min awake → .low
- Test 2: Infant (6 months), 2 hrs awake → .medium
- Test 3: Toddler (18 months), 5 hrs awake → .high
- Test 4: Edge case - exact threshold → .medium
- Descriptive names: test_getSleepPressure_newborn30Min_returnsLow

CONSTRAINTS:
- Import @testable import Somni
- No hardcoded dates (use DateComponents)
- Arrange-Act-Assert pattern

OUTPUT FORMAT:
Single file (max 300 lines, ~5 test methods)

VALIDATION PLAN:
- Build succeeds
- All tests pass (Cmd+U)
- No force unwraps (grep check)
" --full-auto --json -C /Users/nexus/iOSdev/Somni 2>&1 | tee ~/.claude-orchestration/codex/$TASK_ID.jsonl

# Validate
exit_code=$?
if [ $exit_code -eq 0 ]; then
    # Extract output
    CODE=$(cat ~/.claude-orchestration/codex/$TASK_ID.jsonl | grep '"type":"agent_message"' | tail -1 | jq -r '.item.text')

    # Write to file
    echo "$CODE" > SomniTests/RecommendationEngineTests.swift

    # Build and test
    xcodebuild build test -scheme Somni -destination 'platform=iOS Simulator,name=iPhone 15'

    if [ $? -eq 0 ]; then
        echo "✅ Tests pass - integration approved"
    else
        echo "❌ Tests fail - reject output, retry or handle directly"
    fi
fi
```

---

## 15. Logging (Optional)

After each delegation, append to orchestration log:

```bash
cat >> ~/.claude-orchestration/orchestration-log.md <<EOF
### $(date +%Y-%m-%d\ %H:%M:%S) | $TASK_ID
Agent: CODEX
Inputs: Utilities/DateHelpers.swift:42
Command: codex exec "..." --full-auto --json
Exit: $exit_code
Result: ACCEPTED | REJECTED | PARTIAL
Notes: Generated 3 test cases, all passing
EOF
```

---

## 16. Version History

**v1.1** (December 18, 2025)
- Added prompt format requirements (single-line only, no multiline heredocs)
- Added timeout behavior guidance (soft success detection pattern)
- Added token efficiency data (83% cache hit rate measured)
- Based on Task 3.1 testing (codex-test-results.md, Dec 18, 2025)

**v1.0** (December 18, 2025)
- Initial execution contract
- Based on Task 1.1 verification (codex-verification-report.md)
- Follows Claude_System_Instruction_Block.md template structure
- Includes current model names (gpt-5.1-codex-max, gpt-5.1-codex-mini)

---

## References

- **Authority**: `DELEGATION-MATRIX.md` (delegation routing)
- **Verification**: `~/.maestro/verification/codex-verification-report.md`
- **Models**: `~/.maestro/verification/model-names.md`
- **Template**: `docs/maestro/To-Assess/Claude_System_Instruction_Block.md`
- **Official Docs**: https://developers.openai.com/codex/

---

**Status**: ✅ Active (created Dec 18, 2025)
**Next Review**: March 2026 (quarterly model updates)
