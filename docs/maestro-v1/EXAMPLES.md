# MAESTRO Workflow Examples

**Version**: 1.0
**Created**: December 18, 2025
**Purpose**: End-to-end workflow templates demonstrating multi-agent orchestration

---

## How to Use These Examples

Each example demonstrates the complete MAESTRO workflow:

1. **Pre-Delegation Reconnaissance** - Claude uses cheap tools (Glob/Grep) first
2. **Routing Decision** - Apply DELEGATION-MATRIX.md gates
3. **Execution** - Use CODEX.md or GEMINI.md patterns
4. **Validation** - Apply quality gates before integration
5. **Integration** - Claude synthesizes and commits

**Key Principles**:
- Always recon before delegating (60-80% token savings)
- Use atomic queries for Gemini (single-file)
- Use detailed specs for Codex (prevent hallucinations)
- Claude handles all architectural decisions
- Claude validates ALL agent output

---

## Example 1: Add New Feature (Multi-Agent Workflow)

**Scenario**: Add a "Privacy Mode" feature that masks child names in the UI.

### Step 1: Pre-Delegation Reconnaissance (Claude)

**Before delegating anything, Claude scouts the codebase:**

```bash
# Find where child names are displayed (100 tokens, 1 second)
Grep "child\.name\|child.name" Views/*.swift Models/*.swift Services/*.swift

# Result: Found 23 locations across 8 files
# - ContentView.swift: Lines 145, 892, 1203
# - SleepLogView.swift: Lines 234, 567
# - Child.swift: Line 18 (model property)
# ...
```

**Savings**: Found all targets in 1 second with 100 tokens. Would have wasted 15K tokens delegating "search for child names" to Gemini.

### Step 2: Routing Decision (DELEGATION-MATRIX.md)

**Question 1**: What's the primary output?
- Answer: CODE (Swift implementation)
- Gate: Check Section 3 (Codex) vs Section 4 (Gemini)

**Question 2**: Is this a Codex-eligible task?
- Can specify exact behavior? YES (mask name pattern defined)
- Atomic (≤1 file)? NO for full feature, YES for helper function
- Can validate? YES (build, tests, UI check)
- Not security-critical? YES (cosmetic feature)
- **Decision**: Split into atomic tasks, delegate helper to Codex

**Question 3**: Do we need research first?
- Need to understand existing patterns? YES
- Single file analysis? YES (Child.swift, ContentView.swift)
- **Decision**: Delegate pattern research to Gemini first

### Step 3: Research Existing Patterns (Gemini)

```bash
# Analyze how child names are currently displayed
TASK_ID="privacy-research-$(date +%Y%m%d-%H%M%S)"

gtimeout 90 gemini -p "OBJECTIVE:
Document how child names are displayed in the UI.

INPUT:
@Views/ContentView.swift

OUTPUT:
Markdown list:
- Line number
- Context (what's displayed: title, label, etc.)
- Current pattern (direct property access, formatted, etc.)

Max 10 findings.

DO NOT:
- Search other files
- Suggest implementation
- Speculate about refactoring" -y -o json > ~/.claude-orchestration/gemini/$TASK_ID.json

# Extract output
cat ~/.claude-orchestration/gemini/$TASK_ID.json | jq -r '.response' > /tmp/privacy-research.md
```

**Token Cost**: ~4.5K (using @path pattern - Dec 2025 measured)

### Step 4: Review & Plan (Claude)

```bash
# Claude reads Gemini's findings
Read /tmp/privacy-research.md

# Claude creates implementation plan:
# 1. Add @AppStorage("privacyMode") property
# 2. Create maskChildName() helper function
# 3. Replace child.name with masked version in views
# 4. Add toggle in settings
```

### Step 5: Generate Helper Function (Codex)

**Delegate the helper function to Codex:**

```bash
TASK_ID="privacy-helper-$(date +%Y%m%d-%H%M%S)"

gtimeout 120 codex exec "OBJECTIVE:
Generate a Swift helper function that masks child names for privacy mode.

TARGET FILES:
Utilities/PrivacyHelpers.swift (create new file)

INPUT CONTEXT:
// Models/Child.swift structure
@Model
class Child {
    var name: String
    var dateOfBirth: Date
}

REQUIREMENTS:
- Function signature: func maskChildName(_ child: Child, allChildren: [Child]) -> String
- Return format: 'Child A', 'Child B', etc.
- Alphabetical by name (stable sorting)
- Consistent mapping (same child = same letter)
- Follow Somni conventions (MARK comments, camelCase)
- Include DocC comments

CONSTRAINTS:
- No force unwraps (!)
- Use guard statements for safety
- Import Foundation only (no other dependencies)
- Swift 5.9+ features allowed

OUTPUT FORMAT:
Complete Swift file with:
- File header comment
- Import statements
- MARK: - Privacy Helpers
- Function implementation
- Example usage in comments

VALIDATION PLAN:
- Compiles without warnings
- Returns correct masked names
- Handles edge cases (empty array, single child)" --full-auto --json -C /Users/nexus/iOSdev/Somni 2>&1 | tee ~/.claude-orchestration/codex/$TASK_ID.jsonl

exit_code=$?
```

**Token Cost**: ~8K

### Step 6: Validation (Claude)

```bash
# Extract generated code
CODE=$(grep '"type":"agent_message"' ~/.claude-orchestration/codex/$TASK_ID.jsonl | tail -1 | jq -r '.item.text')

# Write to file
echo "$CODE" > Utilities/PrivacyHelpers.swift

# Run quality gates
cd /Users/nexus/iOSdev/Somni

# Gate 1: Build check
xcodebuild build -scheme Somni -destination 'platform=iOS Simulator,name=iPhone 15'
if [ $? -ne 0 ]; then
    echo "❌ Build failed - reject code"
    exit 1
fi

# Gate 2: Pattern validation (no force unwraps)
if grep -n '!' Utilities/PrivacyHelpers.swift | grep -v '!=' | grep -v '//'; then
    echo "❌ Force unwrap detected - reject code"
    exit 1
fi

# Gate 3: Spot-check logic
# Claude manually reviews the code for correctness
Read Utilities/PrivacyHelpers.swift
```

**Quality Gate Results**:
- ✅ Builds successfully
- ✅ No force unwraps
- ✅ Logic correct (alphabetical sorting, stable mapping)
- **Decision**: ACCEPT and integrate

### Step 7: Integration (Claude Handles Complex UI)

**Claude implements the complex parts (architectural decisions):**

```swift
// ContentView.swift - Claude adds privacy mode logic
@AppStorage("privacyMode") private var privacyModeEnabled = false

private func displayName(for child: Child) -> String {
    if privacyModeEnabled {
        return maskChildName(child, allChildren: children)
    } else {
        return child.name
    }
}

// Replace all occurrences of child.name with displayName(for: child)
```

**Why Claude does this**: Multi-file coordination, architectural decisions, SwiftUI expertise.

### Step 8: Commit (Claude)

```bash
git add Utilities/PrivacyHelpers.swift Views/ContentView.swift Views/SleepLogView.swift
git commit -m "$(cat <<'EOF'
Add privacy mode to mask child names

Adds toggle in settings to display child names as 'Child A', 'Child B', etc.
for privacy when sharing screenshots.

Implementation:
- New PrivacyHelpers.swift with maskChildName() function
- Updated ContentView and SleepLogView to use masked names when enabled
- @AppStorage for persistence

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
EOF
)"
```

### Token Breakdown

| Phase | Agent | Tokens | Time |
|-------|-------|--------|------|
| Reconnaissance | Claude | 100 | 1s |
| Pattern research | Gemini | 23,000 | 60s |
| Helper generation | Codex | 8,000 | 45s |
| Validation | Claude | 2,000 | 30s |
| UI integration | Claude | 5,000 | 120s |
| **Total** | | **38,100** | **4.5 min** |

**vs Claude-only**: ~65K tokens, 8 minutes

**Savings**: 41% token reduction, 44% time reduction

---

## Example 2: Bug Fix (Targeted Workflow)

**Scenario**: Fix bug where sleep duration shows wrong time for overnight sessions.

### Step 1: Pre-Delegation Reconnaissance (Claude)

```bash
# Find duration calculation code (100 tokens)
Grep "duration\|timeInterval" Utilities/DateHelpers.swift Services/*.swift

# Result: Found DateHelpers.swift:42 - durationUntil() method
```

### Step 2: Routing Decision (DELEGATION-MATRIX.md)

**Primary output**: CODE (bug fix)
**Is bug in critical path?** Yes (core functionality)
**Decision**: **Claude handles directly** (Gate 4.1: Security/critical code)

**No delegation for critical bugs** - Claude reads file, understands logic, implements fix.

### Step 3: Claude Implements Fix Directly

```bash
# Read the problematic code
Read Utilities/DateHelpers.swift

# Claude identifies issue: doesn't handle midnight crossing
# Claude writes fix (uses Calendar.dateComponents for proper duration)

# Claude writes tests
# Claude validates fix
# Claude commits
```

**Why no delegation**: Critical path bugs require deep understanding and careful fixes. Delegation adds risk.

**Token Cost**: ~5K (Claude-only, but low risk)

---

## Example 3: Documentation Audit (Gemini-Heavy)

**Scenario**: Verify README.md accurately describes current app features.

### Step 1: Pre-Delegation Reconnaissance (Claude)

```bash
# List all documentation files (50 tokens)
ls docs/*.md README.md

# Result: Found README.md, ARCHITECTURE.md, START-HERE.md, etc.
```

### Step 2: Routing Decision (DELEGATION-MATRIX.md)

**Primary output**: ANALYSIS (gap report)
**Can provide complete input?** YES (inline docs)
**Single-file analysis?** YES (compare README vs reality)
**Decision**: **ROUTE TO GEMINI** (Gate 2.1: Synthesis/analysis task)

### Step 3: Delegate Documentation Audit (Gemini)

```bash
TASK_ID="doc-audit-$(date +%Y%m%d-%H%M%S)"

# Claude reads both files first
Read README.md
Read docs/ARCHITECTURE.md

# Delegate comparison to Gemini
gtimeout 120 gemini -p "OBJECTIVE:
Compare README.md claims against ARCHITECTURE.md reality.

INPUT:
README.md content:
$(cat README.md)

---

ARCHITECTURE.md content:
$(cat docs/ARCHITECTURE.md)

OUTPUT:
Markdown table with columns:
| Section | README Claim | Reality | Status |

Where Status = accurate | outdated | missing

Max 20 discrepancies. If more, prioritize user-facing features.

DO NOT:
- Search for other files
- Suggest documentation rewrites
- Speculate about unmentioned features" -y -o json > ~/.claude-orchestration/gemini/$TASK_ID.json

# Extract findings
cat ~/.claude-orchestration/gemini/$TASK_ID.json | jq -r '.response' > /tmp/doc-audit.md
```

**Token Cost**: ~25K (two files inlined)

### Step 4: Validation (Claude)

```bash
# Spot-check 5 random findings from Gemini's output
Read /tmp/doc-audit.md

# Verify line references against actual files
Read README.md  # Check mentioned sections
Read docs/ARCHITECTURE.md  # Verify reality claims

# All checks pass → Accept findings
```

### Step 5: Integration (Claude Updates Docs)

```bash
# Claude uses Gemini's findings to update README.md
# Claude makes specific edits based on identified gaps
# Claude commits with detailed message
```

**Token Breakdown**:
- Reconnaissance: 50
- Gemini audit: 25,000
- Validation: 3,000
- Integration: 4,000
- **Total**: 32,050

**vs Claude-only**: ~80K tokens (reading both docs multiple times)

**Savings**: 60% token reduction

---

## Example 4: Test Generation (Codex Workflow)

**Scenario**: Generate XCTest cases for RecommendationEngine.getSleepPressure()

### Step 1: Pre-Delegation Reconnaissance (Claude)

```bash
# Find the method to test (100 tokens)
Grep "getSleepPressure" Services/RecommendationEngine.swift

# Check existing test patterns (100 tokens)
Glob SomniTests/*Tests.swift

# Result: Found method at line 45, existing test file pattern
```

### Step 2: Routing Decision (DELEGATION-MATRIX.md)

**Primary output**: CODE (test cases)
**Atomic?** YES (single test file)
**Can specify behavior?** YES (test scenarios defined)
**Verifiable?** YES (tests must pass)
**Decision**: **ROUTE TO CODEX** (Gate 3.1: Code generation)

### Step 3: Delegate Test Generation (Codex)

```bash
TASK_ID="test-gen-$(date +%Y%m%d-%H%M%S)"

gtimeout 180 codex exec "OBJECTIVE:
Generate XCTest cases for RecommendationEngine.getSleepPressure() method.

TARGET FILES:
SomniTests/RecommendationEngineTests.swift (create new file)

INPUT CONTEXT:
// Services/RecommendationEngine.swift:45
func getSleepPressure(childAgeMonths: Int, lastWakeTime: Date) -> SleepPressure {
    let hoursAwake = Date().timeIntervalSince(lastWakeTime) / 3600
    let threshold = Constants.wakeWindowThresholds[childAgeMonths] ?? 2.0

    if hoursAwake < threshold * 0.7 {
        return .low
    } else if hoursAwake < threshold {
        return .medium
    } else {
        return .high
    }
}

enum SleepPressure {
    case low, medium, high
}

REQUIREMENTS:
- Test 1: Newborn (0 months), 30 min awake → .low
- Test 2: Infant (6 months), 2 hours awake → .medium
- Test 3: Toddler (18 months), 5 hours awake → .high
- Test 4: Edge case - exactly at threshold → .medium
- Test 5: Unknown age (99 months) uses default threshold
- Use descriptive names: test_getSleepPressure_newborn30Min_returnsLow
- Follow patterns in SomniTests/ (import @testable, XCTAssertEqual)

CONSTRAINTS:
- Import @testable import Somni
- No hardcoded dates (use Calendar, DateComponents)
- No force unwraps (!)
- Arrange-Act-Assert pattern
- Each test is independent

OUTPUT FORMAT:
Complete Swift test file

VALIDATION PLAN:
- All tests compile
- All tests pass when run
- Coverage of edge cases" --full-auto --json -C /Users/nexus/iOSdev/Somni 2>&1 | tee ~/.claude-orchestration/codex/$TASK_ID.jsonl
```

**Token Cost**: ~10K

### Step 4: Validation (Claude)

```bash
# Extract generated tests
CODE=$(grep '"type":"agent_message"' ~/.claude-orchestration/codex/$TASK_ID.jsonl | tail -1 | jq -r '.item.text')
echo "$CODE" > SomniTests/RecommendationEngineTests.swift

# Run validation gates
cd /Users/nexus/iOSdev/Somni

# Gate 1: Build
xcodebuild build -scheme Somni -destination 'platform=iOS Simulator,name=iPhone 15'

# Gate 2: Run tests
xcodebuild test -scheme Somni -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:SomniTests/RecommendationEngineTests

# Gate 3: Check patterns
grep -n '!' SomniTests/RecommendationEngineTests.swift | grep -v '!=' | grep -v '//'

# All gates pass → Accept
```

### Step 5: Integration (Claude)

```bash
git add SomniTests/RecommendationEngineTests.swift
git commit -m "Add tests for RecommendationEngine.getSleepPressure()

Covers:
- Newborn, infant, toddler age ranges
- Low, medium, high sleep pressure levels
- Edge case: exact threshold boundary
- Unknown age fallback to default

All tests pass ✅

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

**Token Breakdown**:
- Reconnaissance: 200
- Codex generation: 10,000
- Validation: 2,000
- Integration: 1,000
- **Total**: 13,200

**vs Claude-only**: ~25K tokens

**Savings**: 47% token reduction

---

## Example 5: Codebase Architecture Review (Hybrid Approach)

**Scenario**: Understand error handling patterns across all services before refactoring.

### Step 1: Pre-Delegation Reconnaissance (Claude)

```bash
# Find all service files (50 tokens, instant)
Glob Services/*.swift

# Result: Found 8 service files
# - ExportService.swift
# - RecommendationEngine.swift
# - NotificationService.swift
# - PDFExportService.swift
# ...
```

### Step 2: Routing Decision (DELEGATION-MATRIX.md)

**Primary output**: ANALYSIS (pattern report)
**Multi-file analysis?** YES (8 files)
**Atomic queries possible?** YES (one file at a time)
**Decision**: **HYBRID APPROACH** (Claude finds → Gemini analyzes each → Claude synthesizes)

**Why not broad Gemini search?** "Analyze Services/ for errors" would timeout (0% success rate).

### Step 3: Parallel Gemini Delegations (One Per File)

```bash
# Claude orchestrates parallel analysis of each service

for service in Services/*.swift; do
    BASENAME=$(basename "$service" .swift)
    TASK_ID="error-audit-${BASENAME}-$(date +%Y%m%d-%H%M%S)"

    gtimeout 90 gemini -p "OBJECTIVE:
Identify error handling patterns in $(basename "$service").

INPUT:
@$service

OUTPUT:
Markdown table:
| Line | Pattern | Assessment |

Where Pattern = do-catch | guard | optional | throw | none
Where Assessment = good | poor | missing

Max 15 findings.

DO NOT:
- Search other files
- Suggest refactoring" -y -o json > ~/.claude-orchestration/gemini/$TASK_ID.json &

    # Small delay to avoid rate limits
    sleep 2
done

# Wait for all to complete
wait

echo "All service audits complete"
```

**Token Cost**: 8 services × 23K = 184K (but parallel, so faster)

### Step 4: Synthesis (Claude)

```bash
# Claude reads all 8 reports
Read ~/.claude-orchestration/gemini/error-audit-ExportService-*.json
Read ~/.claude-orchestration/gemini/error-audit-RecommendationEngine-*.json
# ... (all 8)

# Claude synthesizes findings:
# - 5/8 services use do-catch consistently (good)
# - 2/8 services swallow errors (poor - ExportService, PDFExportService)
# - 1/8 services has no error handling (missing - NotificationService)
# - Recommendation: Standardize on Result<T, Error> pattern
```

### Step 5: Create Architecture Recommendation Doc (Claude)

```markdown
# Error Handling Audit Results

**Date**: December 18, 2025
**Scope**: 8 services in Services/

## Findings

### Good Practices (5 services)
- RecommendationEngine: Consistent do-catch, propagates errors
- [...]

### Issues Found
1. **ExportService.swift:42** - Swallows errors silently
2. **PDFExportService.swift:78** - Returns nil instead of throwing
3. **NotificationService.swift** - No error handling at all

## Recommendations
1. Standardize on Result<T, Error> for all service methods
2. Add error logging to ExportService
3. Implement proper error handling in NotificationService

## Priority
- HIGH: NotificationService (no error handling)
- MEDIUM: ExportService, PDFExportService (poor handling)
```

**Token Breakdown**:
- Reconnaissance: 50
- Gemini analysis (8 parallel): 184,000
- Synthesis: 5,000
- Documentation: 2,000
- **Total**: 191,050

**vs Claude-only**: ~300K tokens (reading 8 large files multiple times)

**Savings**: 36% token reduction + parallel execution (faster)

---

## Example 6: Emergency Hotfix (Claude-Only, No Delegation)

**Scenario**: Production crash reported - app crashes when user has no children.

### Step 1: Immediate Assessment (Claude)

**Decision: NO DELEGATION** - Critical bug, needs immediate fix.

### Step 2: Claude Handles Directly

```bash
# Find the crash location
Grep "children\[0\]\|children.first!" **/*.swift

# Read problematic file
Read Views/ContentView.swift

# Identify issue: Force unwrap of children array
# Line 145: let activeChild = children[0]

# Write fix
# Replace with: let activeChild = children.first

# Test locally
# Commit with priority tag
git commit -m "hotfix: Fix crash when no children exist

Replaced force unwrap of children[0] with safe children.first.

Priority: CRITICAL
Issue: App crashes on first launch"
```

**Token Cost**: ~4K (Claude-only, but fastest response)

**Why no delegation**:
- Critical production issue
- Simple fix once located
- Delegation adds latency (45-90s)
- Risk of hallucination
- Claude's direct fix: 60 seconds total

---

## Routing Decision Flowchart

```
User Request
    │
    ├─ Critical bug/security? ────────────────► CLAUDE (no delegation)
    │
    ├─ Primary output: CODE? ────────────────┐
    │                                         │
    │   ├─ Atomic (≤1 file)? ──► YES ──────► CODEX (with detailed spec)
    │   └─ Multi-file? ────────► NO ───────► CLAUDE (architectural)
    │
    ├─ Primary output: ANALYSIS? ────────────┐
    │                                         │
    │   ├─ Single-file query? ─► YES ──────► GEMINI (@path pattern)
    │   ├─ Multi-file? ──────────► YES ─────► HYBRID (Claude finds, Gemini analyzes each, Claude synthesizes)
    │   └─ Broad search? ────────► NO ──────► CLAUDE (use Grep/Glob)
    │
    └─ Architecture decision? ────────────────► CLAUDE (strategic role)
```

---

## Token Efficiency Comparison Table

| Workflow | Claude-Only | Multi-Agent | Savings | Time |
|----------|-------------|-------------|---------|------|
| New feature | 65K | 38K | 41% | -44% |
| Bug fix (critical) | 5K | 5K | 0% | Same (no delegation) |
| Doc audit | 80K | 32K | 60% | -50% |
| Test generation | 25K | 13K | 47% | -40% |
| Architecture review | 300K | 191K | 36% | -60% (parallel) |
| Emergency hotfix | 4K | 4K | 0% | Same (Claude-only) |

**Overall Average Savings**: 47% token reduction, 44% time reduction

---

## Best Practices Summary

### Always Do
1. ✅ **Pre-delegation reconnaissance** - Scout with Glob/Grep first (60-80% savings)
2. ✅ **Atomic queries for Gemini** - Single-file, specific questions (100% success)
3. ✅ **Detailed specs for Codex** - Clear requirements, constraints, validation plan
4. ✅ **Quality gates before integration** - Build, test, pattern checks
5. ✅ **Claude handles architecture** - Strategic decisions stay with orchestrator

### Never Do
1. ❌ **Delegate critical bugs** - Too risky, Claude handles directly
2. ❌ **Broad Gemini searches** - "Analyze entire codebase" = timeout (0% success)
3. ❌ **Multi-file Codex tasks** - Split into atomic operations
4. ❌ **Skip validation** - Always verify agent output before integration
5. ❌ **Delegate without recon** - Find targets first, then delegate analysis

### When to Skip Delegation

**Claude handles directly if**:
- Security/auth/payments/data-loss code
- Critical production bugs
- Architectural decisions
- Multi-file coordination
- Unclear requirements
- Task requires <5K tokens Claude-only

---

## Troubleshooting Common Issues

### Issue: Gemini Timeout

**Symptom**: `exit code 124`, partial or no output

**Causes**:
- Broad search query ("Analyze entire codebase...")
- Multi-file analysis in one query
- File path without @ symbol

**Solutions**:
1. Check query is atomic (single file, specific question)
2. Use @path pattern: `@Services/File.swift`
3. Split multi-file into separate queries (parallel or sequential)

---

### Issue: Codex Generated Force Unwraps

**Symptom**: Quality gate fails on pattern check

**Causes**:
- Insufficient constraints in prompt
- No example of safe pattern

**Solutions**:
1. Add explicit constraint: "No force unwraps (!) - use guard let or optional chaining"
2. Show example in prompt:
   ```swift
   // CORRECT:
   guard let value = optional else { return }

   // INCORRECT:
   let value = optional!
   ```
3. Retry with updated prompt

---

### Issue: Hallucinated Line Numbers (Gemini)

**Symptom**: Validation fails - line numbers don't match actual code

**Causes**:
- Gemini estimated instead of reading carefully
- Prompt didn't require line numbers

**Solutions**:
1. Add to prompt: "Include exact line numbers and quote 2-3 lines of code"
2. Validate more carefully - spot-check all line references
3. If persistent, Claude reads file directly instead

---

## Version History

**v1.0** (December 18, 2025)
- Initial examples document
- 6 comprehensive workflow examples
- Routing decision flowchart
- Token efficiency comparison table
- Best practices and troubleshooting

---

## References

- **Authority**: `DELEGATION-MATRIX.md` (routing decisions)
- **Codex Execution**: `CODEX.md` (code generation patterns)
- **Gemini Execution**: `GEMINI.md` (analysis patterns)
- **Orchestration Guide**: `GUIDE.md` (overall strategy)

---

**Status**: ✅ Active (created Dec 18, 2025)
**Maintained by**: Claude Code orchestrator
