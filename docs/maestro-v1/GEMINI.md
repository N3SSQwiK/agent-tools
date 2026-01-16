# GEMINI - Large Context Analysis Execution Contract

**Version**: 1.0
**Created**: December 18, 2025
**Status**: Active
**Authority**: DELEGATION-MATRIX.md governs WHETHER to delegate. This document governs HOW.

---

## Purpose

Defines the execution contract for Gemini CLI: invocation patterns, file access methods, validation gates, retry logic, and constraints when delegation is approved by DELEGATION-MATRIX.md.

**Gemini Role**: Reader/synthesizer - Analyzes provided content, recognizes patterns, generates documentation drafts, creates test plans, summarizes material.

**NOT for**: File discovery, code modification, broad codebase searches.

---

## 1. File Access Patterns (Token Efficiency Critical)

**⚠️ Updated Dec 18, 2025**: Clean-room testing revealed dramatic efficiency differences. Previous token counts were incorrect.

### Three Working Patterns (Clean-Room Verified)

**Pattern 1: @path syntax** ⭐ **MANDATORY** (9.2x More Efficient)
```bash
gtimeout 90 gemini -p "Analyze @Services/File.swift for error handling" -y -o json
```
- **Tokens**: **4,468** (for 48KB Swift file)
- **Cost**: $0.09 per delegation (at $0.02/1K tokens)
- **Use when**: ALL file analysis tasks (unless preprocessing required)
- **Status**: Undocumented but empirically validated
- **Reliability**: 100% success rate
- **Why mandatory**: 9.2x cheaper than alternatives

**Pattern 2: $(cat) inline** ⚠️ **AVOID** (Works but Expensive)
```bash
gtimeout 90 gemini -p "Analyze this code:

$(cat Services/File.swift)

Does it have error handling?" -y -o json
```
- **Tokens**: **41,295** (for 48KB Swift file) - **824% MORE than @path**
- **Cost**: $0.83 per delegation (9.2x more expensive)
- **Use when**: ONLY when file preprocessing absolutely required (grep, sed, head filters)
- **Status**: Works perfectly but token-inefficient
- **Example preprocessing**: `$(head -100 file.swift | grep -v "test")` (filter before sending)

**Pattern 3: stdin piping** ⚠️ **AVOID** (Works but Impractical)
```bash
cat Services/File.swift | gtimeout 90 gemini -p "Analyze for error handling" -y -o json
```
- **Tokens**: ~40,000 (estimated, similar to $(cat))
- **Cost**: $0.80 per delegation
- **Use when**: AVOID - use @path instead
- **Status**: Officially documented but token-inefficient
- **Note**: Requires local file copy from clean directory to work reliably

### What DOESN'T Work ❌

- `--files` flag (doesn't exist in CLI)
- `@{path}` with braces (custom commands only, not for file refs)
- Plain file paths without @ (Gemini can't interpret: "Read Services/File.swift")
- Multiple files in one invocation (use separate delegations)

### Token Efficiency Comparison (48KB Swift File)

| Pattern | Prompt Tokens | Cost per Delegation | Efficiency vs @path |
|---------|--------------|---------------------|---------------------|
| ✅ **@path** | **4,468** | **$0.09** | **Baseline (1.0x)** |
| ❌ $(cat) inline | 41,295 | $0.83 | **9.2x MORE expensive** |
| ❌ stdin | ~40,000 | $0.80 | **9.0x MORE expensive** |

**Cost Impact**: Using $(cat) instead of @path wastes $0.74 per delegation. At 10 delegations/day, that's **$7.40/day or $2,701/year in wasted tokens**.

### Corrected Decision Tree

```
Need to analyze a file?
│
├─ No preprocessing? → ✅ Use @path (MANDATORY - 9.2x cheaper)
│
├─ Need grep/sed/head? → ⚠️ Use $(cat) with filters (expensive but justified)
│
└─ Everything else? → ✅ Use @path (don't use stdin)
```

**Evidence**: `~/.maestro/validation/gemini-clean-room-results.md` (Dec 18, 2025)
**Previous (incorrect) claim**: "@path: 22,922 tokens" - **This was contaminated by .gemini/ config**
**Clean-room reality**: "@path: 4,468 tokens" - **81% reduction from claimed value**

---

## 2. Non-Interactive Invocation Pattern

### Required Command Structure

```bash
gtimeout <seconds> gemini -p "<prompt>" -y -o json > ~/.claude-orchestration/gemini/<task-id>.json 2>&1
```

**Components**:
- `gtimeout <seconds>`: Mandatory timeout wrapper (see Timeout Guidelines)
- `gemini`: Gemini CLI executable
- `-p "<prompt>"` or `--prompt "<prompt>"`: REQUIRED for headless mode
- `-y` or `--yolo`: Auto-approve all tool calls (prevents hanging)
- `-o json` or `--output-format json`: Structured JSON output
- `> <output>`: Save for validation
- `2>&1`: Capture stderr with stdout

### Flags Reference (Verified)

| Flag | Purpose | Required | Notes |
|------|---------|----------|-------|
| `-p / --prompt` | Explicit prompt text | YES | Required for headless mode |
| `-y / --yolo` | Auto-approve tool calls | YES | Prevents interactive prompts |
| `-o / --output-format` | Output format | YES | Use `json` for structured data |
| `-m / --model` | Model selection | NO | Omit for auto-selection (recommended) |
| `-r / --resume` | Resume session | NO | Avoid in headless (use fresh sessions) |

### Timeout Guidelines

| Task Type | Timeout | Rationale |
|-----------|---------|-----------|
| Simple query | 60s | "What is 2+2?" completes in 30s |
| Single-file analysis | 90s | @path pattern, focused question |
| Complex synthesis | 120s | Multiple questions, detailed output |
| **Hard limit** | 120s | Abort - task too broad, needs chunking |

**Exit code on timeout**: `124` (indicates `gtimeout` killed the process)

---

## 3. Pre-Delegation Reconnaissance (MANDATORY)

**ALWAYS scout before delegating!** This is the most critical pattern for token efficiency.

### The Problem

Delegating search/discovery to Gemini without knowing what exists wastes tokens and time:
- **Bad approach**: "Search for PDF export" → 15K tokens, 3 failures, 10 minutes
- **Good approach**: `ls Services/` → 100 tokens, 1 second, found target

### The Pattern

```bash
# Step 1: Quick recon (100-200 tokens, <1 second)
ls Services/                          # Directory listing
Glob Services/*.swift                 # Find Swift files
Grep "PDFExport" Services/*.swift     # Search for pattern

# Step 2: Assess - do we need delegation?
# - Found target? → Read it directly with Claude tools (2-3K tokens)
# - Complex analysis needed? → Delegate to Gemini
# - Simple info? → Handle with Claude

# Step 3: Delegate ONLY if needed
gtimeout 90 gemini -p "Analyze @Services/PDFExportService.swift..." -y -o json
```

### Token Impact (Updated Dec 18, 2025)

| Approach | Tokens | Time | Success Rate |
|----------|--------|------|--------------|
| ❌ Delegate first (blind, $(cat)) | 41K | 10 min | 50% (timeouts) |
| ✅ Recon → Read directly | 3.1K | 1 min | 100% |
| ✅ Recon → Delegate (@path) | 4.6K | 2 min | 100% |

**Savings**: **92% token reduction** (vs blind $(cat) delegation) + 100% reliability

**Breakdown**:
- Blind delegation with $(cat): 41,295 tokens (expensive, often fails)
- Recon (100 tokens) → Read directly (3,000 tokens): 3,100 tokens total
- Recon (100 tokens) → @path delegation (4,468 tokens): 4,568 tokens total

**When to Use**: ALWAYS before delegating research tasks. No exceptions.

**Evidence**: `~/.maestro/validation/gemini-clean-room-results.md` (Dec 18, 2025)

---

## 4. Atomic Query Pattern (Required for Reliability)

**Discovery**: Gemini works GREAT with atomic queries, FAILS with broad searches.

### What Works ✅

**Single-file analysis**:
```bash
gemini -p "Analyze @Services/ExportService.swift and summarize error handling" -y -o json
gemini -p "Does @Models/Child.swift use @Transient properties?" -y -o json
```

**Simple questions**:
```bash
gemini -p "What is 2+2?" -y -o json
```

**Synthesis of provided material**:
```bash
gemini -p "Summarize these three approaches:

$(cat approach1.txt)
$(cat approach2.txt)
$(cat approach3.txt)

Which is best for iOS 17?" -y -o json
```

**Characteristics**:
- **Scope**: Single file or simple question
- **Timeout**: 60-90s sufficient
- **Completion**: Fast, reliable (30-60s typical)
- **Output**: Clean, focused, accurate
- **Success Rate**: 100%

### What Fails ❌

**Broad codebase searches**:
```bash
gemini -p "Search entire codebase for PDF export patterns" -y -o json
gemini -p "List all services and what they do" -y -o json
gemini -p "Find all retry mechanisms across the project" -y -o json
```

**Multi-file analysis**:
```bash
gemini -p "Analyze @Services/*.swift for common patterns" -y -o json
```

**Characteristics**:
- **Scope**: Multi-file, exploratory
- **Timeout**: >180s, often exceeds limit
- **Completion**: Hangs, returns startup logs only, or empty output
- **Output**: Incomplete or missing
- **Success Rate**: 0%

### Solution: Use Atomic Queries Only

- ✅ "What does THIS file do?"
- ✅ "Does THIS file have feature X?"
- ❌ "Which files have feature X?" (use Claude tools instead)

**Source**: `~/.maestro/learnings.md` Atomic Query Pattern (verified Dec 17, 2025)

---

## 5. Hybrid Approach (Recommended Pattern)

**Workflow**:
1. **Claude** finds targets (Glob/Grep - cheap, fast, 100 tokens)
2. **Claude** reads files if simple info needed (Read tool, 2-3K tokens)
3. **Claude** delegates analysis to Gemini ONLY if complex (using @path or inline)
4. **Gemini** analyzes provided content (single file at a time)
5. **Claude** synthesizes results from multiple delegations

**Why This Works**:
| Agent | Strength | Use Case |
|-------|----------|----------|
| **Gemini** | Focused analysis | "What does THIS file do?" |
| **Claude tools** | Fast searches | "Which files exist?" |
| **Best together** | Efficiency + Reliability | Claude finds → Gemini analyzes |

### Example: Multi-File Error Handling Audit

```bash
# Step 1: Claude finds all services (100 tokens, 1 second)
Glob Services/*.swift
# Result: ServiceA.swift, ServiceB.swift, ServiceC.swift

# Step 2: Claude delegates analysis of each (in parallel if possible)
# 2a: Analyze ServiceA
gtimeout 90 gemini -p "Analyze @Services/ServiceA.swift

Focus on error handling:
- Does it use do-catch blocks?
- Are errors propagated or swallowed?
- What error types are used?

Provide:
1. Line numbers for each error handling block
2. Assessment (good/poor/missing)
3. Recommendations (max 3)" -y -o json > ~/.claude-orchestration/gemini/audit-serviceA.json

# 2b: Analyze ServiceB (same pattern)
gtimeout 90 gemini -p "Analyze @Services/ServiceB.swift..." -y -o json > ~/.claude-orchestration/gemini/audit-serviceB.json

# 2c: Analyze ServiceC (same pattern)
gtimeout 90 gemini -p "Analyze @Services/ServiceC.swift..." -y -o json > ~/.claude-orchestration/gemini/audit-serviceC.json

# Step 3: Claude reads results and synthesizes
Read ~/.claude-orchestration/gemini/audit-serviceA.json
Read ~/.claude-orchestration/gemini/audit-serviceB.json
Read ~/.claude-orchestration/gemini/audit-serviceC.json

# Claude creates summary report
```

**Token Comparison**:
- ❌ Gemini broad search: "Analyze all services" → 15K tokens, fails
- ✅ Hybrid approach: 100 (Glob) + 3×3K (targeted) = 9.1K tokens, succeeds
- **Savings**: ~40% + 100% reliability

---

## 6. Prompt Contract (Mandatory Structure)

Every Gemini prompt MUST include these sections:

```markdown
OBJECTIVE:
<Single, explicit goal - what question are you answering?>

INPUT:
<Description of content being provided (via @path, inline, or stdin)>
<Specify file paths explicitly>

OUTPUT:
<Required format: markdown table, JSON, bullet list, etc.>
<Size constraints: "top 10 findings only", "max 500 words", etc.>

DO NOT:
- Search for other files beyond what's provided
- Speculate about code you haven't seen
- Make assumptions about missing context
```

### Example Prompt (Single-File Analysis)

```bash
gtimeout 90 gemini -p "OBJECTIVE:
Identify all error handling patterns in the ExportService.

INPUT:
@Services/ExportService.swift (Swift service class)

OUTPUT:
Markdown table with columns:
- Line Number
- Error Handling Pattern (do-catch, guard, optional, throw)
- Assessment (good/poor/missing)

Max 20 findings. If more, prioritize critical paths.

DO NOT:
- Search for other files
- Suggest refactoring (just document current state)
- Speculate about methods not present in the file" -y -o json > ~/.claude-orchestration/gemini/export-error-audit.json
```

---

## 7. Model Selection

### Recommended Models (December 2025)

| Model | Use Case | Speed | Context | Cost |
|-------|----------|-------|---------|------|
| **Auto (default)** ⭐ | General use | Balanced | Auto | Optimized |
| `gemini-2.5-pro` | Complex reasoning | Slower | 2M tokens | Higher |
| `gemini-2.5-flash` | Simple queries | Faster | 1M tokens | Lower |
| `gemini-3-*-preview` | Latest features | Variable | Variable | Experimental |

**Recommendation**: **Omit `-m` flag** for most tasks. Gemini auto-selects the optimal model.

### When to Override

```bash
# Large context (multiple files inlined)
gemini -p "..." -m gemini-2.5-pro -y -o json

# Speed-critical (simple query)
gemini -p "..." -m gemini-2.5-flash -y -o json

# Experimental (if available)
gemini -p "..." -m gemini-3-flash-preview -y -o json
```

**Source**: `~/.maestro/verification/model-names.md` (verified Dec 17, 2025)

---

## 8. Validation Gates (Mandatory Before Accepting)

Claude MUST validate all Gemini output before integration.

### Spot-Check Validation

```bash
# Read Gemini output
cat ~/.claude-orchestration/gemini/analysis.json

# Verify claims
Read Services/ExportService.swift

# Check line numbers mentioned by Gemini
# Are they accurate? Does the code match the description?
```

**Checklist**:
- [ ] Line numbers accurate (spot-check 3-5 references)
- [ ] Code snippets match actual file content
- [ ] No hallucinated file paths (all files mentioned exist)
- [ ] No hallucinated APIs or methods (grep to verify)
- [ ] Output format matches contract
- [ ] Size constraints respected (e.g., "top 10" = exactly 10, not 50)
- [ ] No speculation beyond provided input

### Hallucination Detection

**Common hallucinations**:
- References to files that don't exist
- Method names not in the provided code
- Line numbers off by >5 lines
- Invented patterns or conventions

**Detection pattern**:
```bash
# Gemini claims: "ErrorHandler.swift line 42 has retry logic"

# Verify file exists
ls Services/ErrorHandler.swift

# Verify line 42 content
Read Services/ErrorHandler.swift
# Check line 42 manually

# If doesn't match → REJECT output
```

### Rejection Criteria (DO NOT INTEGRATE)

- Line numbers inaccurate (>50% off)
- References non-existent files
- Output exceeds size constraints
- Speculation beyond provided material
- Format doesn't match contract

---

## 9. Retry Ladder (On Failure)

**Identical retries are FORBIDDEN.** Each retry MUST modify the prompt based on failure.

```
Attempt 1: Normal atomic prompt with @path
  ↓ (FAILURE: timeout, hallucinations, or format issues)
Attempt 2: Narrower scope + stricter output constraints
  ↓ (FAILURE: still issues)
Attempt 3: Fallback to stdin pattern (official method)
  ↓ (FAILURE: persistent)
ABORT: Claude handles directly (read file, analyze manually)
```

### Failure-Driven Correction Patterns

#### Failure: Timeout (exit code 124)

**Cause**: Query too broad, multiple files, or exploratory

**Retry Prompt Modification**:
```bash
# Original (broad)
gemini -p "Analyze Services/ for patterns" -y -o json

# Retry 1: Narrow to single file
gemini -p "Analyze @Services/ServiceA.swift only" -y -o json

# Retry 2: Increase timeout + explicit scope
gtimeout 120 gemini -p "Analyze @Services/ServiceA.swift

Focus ONLY on error handling (ignore other aspects)
Max 10 findings" -y -o json
```

#### Failure: Hallucinated line numbers

**Cause**: Gemini inferred locations instead of reading carefully

**Retry Prompt Addition**:
```markdown
OUTPUT CONSTRAINTS (UPDATED):
- Include exact line numbers from the file
- Quote 2-3 lines of actual code for each finding
- If unsure about location, say "Location unclear" instead of guessing
```

#### Failure: Format mismatch

**Cause**: Output was prose instead of requested table/JSON

**Retry Prompt Addition**:
```markdown
OUTPUT FORMAT (STRICT):
Markdown table with these EXACT columns:
| Line | Pattern | Assessment |

NO prose before or after table.
NO explanatory paragraphs.
ONLY the table.
```

#### Failure: Output size exceeded

**Cause**: "Top 10" request returned 50 findings

**Retry Prompt Addition**:
```markdown
SIZE CONSTRAINT (HARD LIMIT):
Maximum 10 findings. If more exist, select the 10 most critical only.
Count your findings and STOP at 10.
```

### Maximum Retries

**Hard limit**: 2 retries (3 total attempts)

After 2 failures:
- **ABORT delegation**
- Claude handles directly (read file, manual analysis)
- Log failure in `~/.claude-orchestration/learnings.md`

---

## 10. Output Discipline

### Allowed Outputs

1. **Markdown report** (structured):
   ```markdown
   ## Findings
   - Finding 1: [description]
   - Finding 2: [description]
   ```

2. **Markdown table**:
   ```markdown
   | Column 1 | Column 2 | Column 3 |
   |----------|----------|----------|
   | Data     | Data     | Data     |
   ```

3. **JSON structured data** (if explicitly requested):
   ```json
   {
     "findings": [
       {"line": 42, "pattern": "do-catch", "assessment": "good"}
     ]
   }
   ```

### Forbidden Outputs

- ❌ Code modifications or diffs
- ❌ Multi-file implementations
- ❌ Exploratory "best effort" with unspecified gaps
- ❌ Open-ended narratives without structure
- ❌ Output without explicit size limits

### Size Caps

| Output Type | Max Size | Enforcement |
|-------------|----------|-------------|
| Markdown report | 1000 words | Prompt constraint |
| Table | 20 rows | Prompt constraint ("top 20") |
| JSON array | 50 items | Prompt constraint |
| Summary | 500 words | Prompt constraint |

**Example Constraint**:
```markdown
OUTPUT:
Markdown table (max 20 rows - if more findings exist, select top 20 by criticality)
```

---

## 11. Delegation Audit Record (Mandatory)

Before invoking Gemini, Claude MUST emit this record in conversation:

```markdown
## DELEGATION AUDIT
Task ID: error-audit-20251218-143052
Primary Output: ANALYSIS (error handling patterns)
Routing Decision: GEMINI
Matrix Gate Status: PASS
  - Gate 2.1: Task is synthesis/analysis (not code modification) ✅
  - Gate 2.2: Acceptance criteria clear (table with line numbers) ✅
  - Gate 2.3: Can provide content via @path (single file) ✅
  - Gate 2.4: Can validate (spot-check line numbers) ✅
Inputs:
  - Services/ExportService.swift (via @path pattern)
Expected Output:
  - Format: Markdown table
  - Columns: Line Number, Pattern, Assessment
  - Size cap: 20 findings max
Validation Plan:
  - Spot-check 5 random line numbers against actual file
  - Verify no hallucinated methods
  - Confirm size constraint (≤20 rows)
Timeout: 90s
Retry Ladder:
  1. Original atomic prompt with @path
  2. If timeout → Reduce scope (error handling only, ignore other aspects)
  3. If hallucinations → Add "include code quotes" constraint
  4. If persistent → Claude handles directly
```

---

## 12. Authentication & Session Management

**Type**: Session-based OAuth (not API keys)

### Check Session Status

```bash
gemini -p "test" -y -o json 2>&1 | grep -i "login\|auth"
# If output contains "please login" or "unauthorized", session expired
```

### Re-authenticate

```bash
gemini login
# Opens browser for OAuth flow
# Follow prompts to authenticate with Google account
```

### Session Expiry Handling

1. Claude detects "login required" error in output
2. Inform user: "Gemini session expired - run `gemini login`"
3. User re-authenticates
4. Claude retries delegation

**Proactive**: Run `gemini login` weekly to refresh session

---

## 13. Concurrency Safety

### Rule: Multiple Parallel Gemini Tasks Allowed

**Unlike Codex**, Gemini read-only operations are safe to run in parallel:

```bash
# Safe: Parallel analysis of different files
gtimeout 90 gemini -p "Analyze @Services/ServiceA.swift..." -y -o json > output-A.json &
gtimeout 90 gemini -p "Analyze @Services/ServiceB.swift..." -y -o json > output-B.json &
gtimeout 90 gemini -p "Analyze @Services/ServiceC.swift..." -y -o json > output-C.json &

# Wait for all to complete
wait
```

**Requirement**: Use unique output filenames (timestamped task IDs)

### Unsafe Pattern (Avoid)

```bash
# Unsafe: Same output file (race condition)
gemini -p "..." -y -o json > output.json &
gemini -p "..." -y -o json > output.json &  # ❌ OVERWRITES
```

---

## 14. Abort Conditions (Do Not Delegate)

Claude MUST abort delegation and handle directly if:

- [ ] Task requires file discovery ("Find all files with X")
- [ ] Task requires code modification
- [ ] Acceptance criteria are unclear
- [ ] Cannot provide content via @path, inline, or stdin
- [ ] Cannot run validation gates (no source files to verify)
- [ ] Cannot produce complete Delegation Audit Record
- [ ] Task is exploratory without specific question
- [ ] Query is broad/multi-file (use Claude tools instead)

**Rationale**: Gemini is a reader/synthesizer, not a codebase explorer or code writer.

---

## 15. Examples

### Example 1: Single-File Error Handling Audit

**Task**: Analyze error handling in ExportService

**Invocation**:
```bash
TASK_ID="error-audit-$(date +%Y%m%d-%H%M%S)"

gtimeout 90 gemini -p "OBJECTIVE:
Identify all error handling patterns in ExportService.swift.

INPUT:
@Services/ExportService.swift

OUTPUT:
Markdown table with columns:
- Line Number (exact)
- Error Handling Pattern (do-catch | guard | optional | throw)
- Assessment (good | poor | missing)
- Brief Note (1 sentence)

Max 20 findings. If more, prioritize main code paths.

DO NOT:
- Search other files
- Suggest refactoring
- Speculate about missing methods" -y -o json > ~/.claude-orchestration/gemini/$TASK_ID.json

# Validate
cat ~/.claude-orchestration/gemini/$TASK_ID.json | jq -r '.response' > /tmp/gemini-output.md

# Spot-check line numbers
Read Services/ExportService.swift
# Manually verify 5 random line numbers from output
```

---

### Example 2: Documentation Audit (Multiple Files)

**Task**: Check if README accurately describes current architecture

**Invocation (Hybrid Approach)**:
```bash
# Step 1: Claude reads both files
Read README.md
Read docs/ARCHITECTURE.md

# Step 2: Delegate comparison to Gemini
TASK_ID="doc-audit-$(date +%Y%m%d-%H%M%S)"

gtimeout 120 gemini -p "OBJECTIVE:
Compare README.md claims against ARCHITECTURE.md reality. Find discrepancies.

INPUT:
README.md content:
$(cat README.md)

---

ARCHITECTURE.md content:
$(cat docs/ARCHITECTURE.md)

OUTPUT:
Markdown table:
- Section (from README)
- Claim (what README says)
- Reality (what ARCHITECTURE says)
- Status (accurate | outdated | missing)

Max 15 discrepancies.

DO NOT:
- Search for other files
- Recommend documentation changes (just identify gaps)" -y -o json > ~/.claude-orchestration/gemini/$TASK_ID.json

# Validate
cat ~/.claude-orchestration/gemini/$TASK_ID.json | jq -r '.response' > /tmp/doc-audit.md

# Review findings
Read /tmp/doc-audit.md
```

---

### Example 3: Test Coverage Gap Analysis

**Task**: Identify Swift methods in a service that lack test coverage

**Invocation**:
```bash
# Step 1: Claude reads both files
Read Services/RecommendationEngine.swift
Read SomniTests/RecommendationEngineTests.swift

# Step 2: Delegate gap analysis to Gemini
TASK_ID="coverage-gaps-$(date +%Y%m%d-%H%M%S)"

gtimeout 90 gemini -p "OBJECTIVE:
Find methods in RecommendationEngine.swift that lack tests in RecommendationEngineTests.swift.

INPUT:
Production code:
$(cat Services/RecommendationEngine.swift)

---

Test file:
$(cat SomniTests/RecommendationEngineTests.swift)

OUTPUT:
Markdown table:
- Method Name (from production file)
- Line Number (in RecommendationEngine.swift)
- Test Status (tested | untested | partial)
- Notes (if partial, what's missing)

Max 20 methods.

DO NOT:
- Generate test code
- Search for other test files
- Make assumptions about private helper methods" -y -o json > ~/.claude-orchestration/gemini/$TASK_ID.json

# Validate
cat ~/.claude-orchestration/gemini/$TASK_ID.json | jq -r '.response'
```

---

## 16. Logging (Optional)

After each delegation, append to orchestration log:

```bash
TASK_ID="error-audit-$(date +%Y%m%d-%H%M%S)"

# After delegation completes
cat >> ~/.claude-orchestration/orchestration-log.md <<EOF
### $(date +%Y-%m-%d\ %H:%M:%S) | $TASK_ID
Agent: GEMINI
Inputs: Services/ExportService.swift (via @path)
Command: gemini -p "..." -y -o json
Exit: $exit_code
Result: ACCEPTED | REJECTED | PARTIAL
Notes: Found 15 error handling patterns, all line numbers verified
EOF
```

---

## 17. Troubleshooting

### Issue: Timeout (exit code 124)

**Cause**: Query too broad, multi-file, or exploratory
**Resolution**:
1. Verify query is atomic (single file, specific question)
2. Reduce scope (e.g., "error handling only" instead of "analyze everything")
3. Increase timeout (90s → 120s max)
4. If persistent → Claude handles directly

---

### Issue: Hallucinated line numbers

**Cause**: Gemini estimated locations instead of reading carefully
**Resolution**:
1. Add to prompt: "Include exact line numbers and quote 2-3 lines of code for each finding"
2. Retry with stricter output constraints
3. Validate output more carefully (spot-check all line numbers)
4. If persistent → Claude reads file and analyzes manually

---

### Issue: Output exceeds size limit

**Cause**: Gemini ignored "top 10" constraint
**Resolution**:
1. Make constraint more explicit: "Count your findings and STOP at exactly 10"
2. Add: "If more than 10 exist, select the 10 most critical only"
3. Validate output size before accepting
4. Reject and retry if exceeded

---

### Issue: Format mismatch (prose instead of table)

**Cause**: Prompt format section unclear
**Resolution**:
1. Simplify format instruction: "ONLY a markdown table, NO prose"
2. Show example format in prompt
3. Add: "NO explanatory paragraphs before or after the table"
4. Retry with stricter constraints

---

### Issue: "Not logged in" or "unauthorized"

**Cause**: Session expired
**Resolution**:
1. User runs `gemini login`
2. Retry delegation after authentication
3. Proactive: Run `gemini login` weekly

---

## 18. Version History

**v1.0** (December 18, 2025)
- Initial execution contract
- Based on Task 1.2 validation and learnings.md patterns
- Includes verified file access patterns (@path, $(cat), stdin)
- Current model names (gemini-2.5-pro, gemini-2.5-flash, gemini-3-*-preview)
- Pre-delegation reconnaissance requirement
- Atomic query pattern (no broad searches)
- Hybrid approach (Claude finds → Gemini analyzes)

---

## 18. Troubleshooting

### ImportProcessor Warnings (Non-Fatal)

**Symptom**: When running Gemini from project directory, you see errors like:
```
[ERROR] [ImportProcessor] Failed to import path: ENOENT: no such file or directory
```

**Root Cause**: Project has `.gemini/` configuration directory. ImportProcessor scans prompts for @path references and finds false positives.

**Impact**: **COSMETIC ONLY** - warnings don't prevent execution. Tasks complete successfully.

**Solutions**:
1. **Ignore warnings** (recommended) - non-fatal, functionality unaffected
2. **Run from clean directory**: `cd /tmp && gemini -p "..." -y -o json`

### Token Costs Higher Than Expected

**Check**: Are you using @path (4.5K) or $(cat) (41K)? Using $(cat) wastes 37K tokens per delegation.

### Timeouts (Exit 124)

**Common causes**: Broad queries, multiple files, network latency.

**Solutions**: Use atomic queries, pre-delegation recon, increase timeout to 120s.

---

## References

- **Authority**: `DELEGATION-MATRIX.md` (delegation routing)
- **Validation**: `~/.maestro/validation/gemini-clean-room-results.md` (Dec 18, 2025)
- **Models**: `~/.maestro/verification/model-names.md`
- **Template**: `docs/maestro/To-Assess/Claude_System_Instruction_Block.md`
- **Official Docs**: https://github.com/google-gemini/gemini-cli

---

**Status**: ✅ Active (v1.1 - Dec 18, 2025)
**Next Review**: March 2026 (quarterly model updates)

**Changelog**:
- **v1.1** (Dec 18, 2025): Corrected token counts from clean-room testing (@path: 4,468 not 22,922), added troubleshooting
- **v1.0** (Dec 18, 2025): Initial execution contract
