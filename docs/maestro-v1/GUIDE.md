# Multi-Agent Orchestration Plan
**Claude Code as Orchestrator**

**Version**: 1.1
**Created**: December 15, 2025
**Updated**: December 17, 2025
**Status**: Active
**Purpose**: Maximize token efficiency by distributing work across Claude, Gemini, and Codex

---

## Executive Summary

**Goal**: Use Claude Code (Sonnet 4.5) as the strategic "brain" that coordinates work across multiple AI agents, offloading token-intensive tasks to Gemini and Codex while maintaining quality and coherence.

**Key Principle**: **Right task, right model** - Match task characteristics to model strengths while Claude maintains overall context and decision-making authority.

**Expected Impact**:
- 60-70% reduction in Claude token usage for routine tasks
- Parallel execution of independent work streams
- Maintained quality through Claude's oversight and integration
- Cost optimization across AI service tiers

**Delegation Rules**: See [DELEGATION-MATRIX.md](DELEGATION-MATRIX.md) for authoritative routing policy.

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│                    CLAUDE CODE (Brain)                  │
│  • Strategic decisions                                  │
│  • Architecture & design                                │
│  • Task decomposition & routing                         │
│  • Quality control & integration                        │
│  • Final code review & merge                            │
└──────────────┬──────────────────────────┬───────────────┘
               │                          │
       ┌───────▼────────┐        ┌────────▼───────┐
       │  GEMINI Agent  │        │  CODEX Agent   │
       │  (Worker)      │        │  (Worker)      │
       └───────┬────────┘        └───────┬────────┘
               │                         │
               └──────────┬──────────────┘
                          │
                ┌─────────▼─────────┐
                │  Shared Context   │
                │  • Task queue     │
                │  • Results cache  │
                │  • Code artifacts │
                └───────────────────┘
```

---

## Agent Capabilities Matrix

### Claude Code (Orchestrator/Brain)
**Strengths**:
- Complex architectural decisions
- Multi-file refactoring with deep context
- OpenSpec proposal creation and validation
- Strategic planning and task decomposition
- Code review and quality gates
- SwiftUI/SwiftData expertise
- Integration and conflict resolution

**Token Priority**: HIGH (preserve for strategic work)

**Ideal Tasks**:
- Creating implementation plans
- OpenSpec proposals and specs
- Architectural design decisions
- Complex refactoring (3+ files)
- Final code review before commit
- Debugging complex state/logic issues
- User-facing communication

---

### Gemini Agent (Research & Analysis)
**Strengths**:
- Large context window (2M tokens in Gemini 1.5 Pro)
- Fast processing of large codebases
- Pattern recognition across files
- Documentation generation
- Test case generation from specs
- Data analysis and reporting
- Research and information gathering

**Token Priority**: MEDIUM (abundant capacity)

**Ideal Tasks**:
- Codebase exploration and mapping
- Documentation audits and updates
- Test coverage analysis
- Dependency analysis
- Finding all usages of a pattern
- Generating test fixtures/mock data
- Writing repetitive boilerplate code
- Markdown documentation generation
- Analyzing OpenSpec specs for completeness

**NOT Suitable For**:
- Final production code (quality concerns)
- Complex SwiftUI view composition
- Critical business logic
- Anything requiring Claude Code tool access

---

### Codex Agent (Code Generation)
**Strengths**:
- Fast code generation
- Excellent at completing patterns
- Function implementation from signatures
- Unit test generation
- Code translation/conversion
- Implementing well-defined algorithms
- Boilerplate reduction

**Token Priority**: MEDIUM (cost-effective for code tasks)

**Ideal Tasks**:
- Implementing functions from detailed specs
- Writing unit tests from test plans
- Generating SwiftUI previews
- Creating model boilerplate (@Model classes)
- Implementing helper functions
- Writing Constants.swift entries
- Code formatting and style fixes
- Generating mock/test data structures

**NOT Suitable For**:
- Unclear requirements (will hallucinate)
- Complex architectural decisions
- Multi-file coordination
- Novel algorithms without clear spec

---

## Task Routing Decision Tree

```
User Request
    │
    ├─ Strategic/Architectural? ────────► CLAUDE (direct)
    │
    ├─ Research/Exploration? ───────────► GEMINI
    │   │                                    ↓
    │   └─ Results ─────────────────────► CLAUDE (review & integrate)
    │
    ├─ Code Generation (well-defined)? ──► CODEX
    │   │                                    ↓
    │   └─ Results ─────────────────────► CLAUDE (review & validate)
    │
    └─ Complex Implementation? ─────────► CLAUDE (decompose)
        │                                    ↓
        ├─ Sub-task 1 ──────────────────► GEMINI or CODEX
        ├─ Sub-task 2 ──────────────────► GEMINI or CODEX
        └─ Sub-task 3 ──────────────────► GEMINI or CODEX
            ↓
        CLAUDE (integrate & commit)
```

---

## Pre-Delegation Reconnaissance (Critical)

**Always do cheap reconnaissance BEFORE expensive delegation!**

### The Problem
Delegating research without first checking what exists wastes tokens and time.

**Example**: Delegating "search for PDF export" to Gemini without first checking if `PDFExportService.swift` exists.
- **Cost**: 3 failed attempts, ~15K tokens, 10 minutes wasted
- **Should have been**: `ls Services/` (100 tokens, 1 second)

### The Pattern

```bash
# Step 1: Quick Recon (100-200 tokens, <1 second)
ls Services/                    # List directory
Glob Services/*.swift           # Find Swift files
Grep "PDFExport" **/*.swift     # Search for pattern

# Step 2: Assess
# - Found target? → Read it directly (2-3K tokens)
# - Complex analysis needed? → Delegate to Gemini
# - Simple info? → Handle with Claude tools

# Step 3: Delegate ONLY if needed
gemini -p "Analyze [specific file] for [specific aspect]" -y -o json
```

### Token Impact

| Approach | Tokens | Time | Success Rate |
|----------|--------|------|--------------|
| ❌ Delegate blindly (no recon) | 15K+ | 10 min | 50% (timeouts) |
| ✅ Recon → Read directly | 3.1K | 1 min | 100% |
| ✅ Recon → Delegate (@path) | 4.6K | 2 min | 100% |

**Savings**: 69-79% token reduction (vs blind delegation) + higher reliability

### When to Use
**ALWAYS** before delegating research tasks. No exceptions.

---

## Workflow Patterns

### Pattern 1: Research → Design → Implement

**Use Case**: "Add new feature to the app"

**Flow**:
1. **CLAUDE**: Understand requirements, decompose task
2. **GEMINI**: Research existing patterns in codebase
   - Find similar features
   - Map affected files
   - Identify integration points
   - Generate file list and change estimates
3. **CLAUDE**: Review research, create implementation plan
4. **CODEX**: Generate boilerplate code from plan
   - Models, services, helpers
   - Unit test shells
5. **CLAUDE**: Review generated code, implement complex logic, integrate, commit

**Token Savings**: ~65% (research + boilerplate offloaded)

---

### Pattern 2: Parallel Exploration

**Use Case**: "Understand how authentication works across the app"

**Flow**:
1. **CLAUDE**: Define exploration goals, partition search space
2. **GEMINI (parallel instances)**:
   - Instance 1: Search Models/ and Services/
   - Instance 2: Search Views/ for auth UI
   - Instance 3: Search Tests/ for auth test patterns
3. **CLAUDE**: Synthesize findings, create architecture diagram

**Token Savings**: ~70% (parallel exploration + synthesis only)

---

### Pattern 3: Test Generation Pipeline

**Use Case**: "Add tests for new RecommendationEngine methods"

**Flow**:
1. **CLAUDE**: Review code, define test strategy
2. **GEMINI**: Analyze code to extract test cases
   - Edge cases
   - Happy paths
   - Error conditions
   - Generate test plan document
3. **CLAUDE**: Review and approve test plan
4. **CODEX**: Generate test code from approved plan
5. **CLAUDE**: Review tests, run and verify, commit

**Token Savings**: ~60% (test planning + generation offloaded)

---

### Pattern 4: Documentation Sync

**Use Case**: "Update all docs after major refactor"

**Flow**:
1. **CLAUDE**: Identify changed files and impacts
2. **GEMINI**: Audit all documentation
   - Find outdated references
   - Generate line-number-specific change list
   - Draft updated documentation
3. **CLAUDE**: Review changes, approve, commit

**Token Savings**: ~75% (doc reading + drafting offloaded)

---

### Pattern 5: Spec Validation

**Use Case**: "Verify all OpenSpec scenarios have test coverage"

**Flow**:
1. **CLAUDE**: Define validation criteria
2. **GEMINI**: Cross-reference specs with tests
   - Parse all spec scenarios (WHEN/THEN)
   - Find matching test methods
   - Generate coverage report
   - List untested scenarios
3. **CLAUDE**: Review gaps, prioritize
4. **CODEX**: Generate missing tests
5. **CLAUDE**: Review and commit

**Token Savings**: ~70% (analysis + test generation offloaded)

---

### Pattern 6: Pre-Plan Delegation (Recommended Best Practice)

**Use Case**: "Create OpenSpec proposal for new feature" or "Plan large refactoring"

**Problem**: Plan Mode's internal Explore agents consume 15-20K tokens during planning phase, representing the largest token usage in the workflow.

**Solution**: Delegate codebase research to Gemini CLI BEFORE entering Plan Mode, then read outputs during planning.

**Flow**:
1. **CLAUDE (Pre-Planning Phase)**: Define research questions
   - What patterns exist?
   - What files are affected?
   - What integration points matter?
2. **GEMINI**: Conduct codebase research
   ```bash
   # IMPORTANT: Use -p flag explicitly for headless mode
   gtimeout 120 gemini -p "Analyze [specific file] for X patterns. Focus on:
   - Existing implementations of Y
   - Error handling approach
   - Integration points" -y -o json > ~/.claude-orchestration/gemini/pre-plan-research.json

   # Note: Use ATOMIC queries (single-file), not broad searches
   # Bad: "Search entire codebase..." (will timeout)
   # Good: "Read Services/X.swift and analyze..."
   ```
3. **CLAUDE (Plan Mode)**: Enter Plan Mode with pre-loaded research
   - Read Gemini research output
   - Skip internal Explore agents (already have data)
   - Use Plan agents only for design decisions
   - Create comprehensive implementation plan
4. **CLAUDE (Implementation Phase)**: Execute plan
   - Delegate boilerplate to Codex as usual
   - Handle complex logic and integration
   - Review and commit

**Token Savings**: ~57% reduction in planning phase
- Planning without delegation: ~30K tokens
- Planning with pre-plan delegation: ~13K tokens
- **Savings: ~17K tokens per planning session**

**When to Use**:
- Any OpenSpec proposal planning
- Large refactoring efforts requiring codebase understanding
- New feature architectural planning
- Any task where you'd normally say "Let me explore the codebase..."

**Critical Insight**: This pattern separates RESEARCH (Gemini's strength) from DESIGN (Claude's strength), allowing each agent to operate in its optimal domain. The result is both faster execution and dramatically reduced token usage.

---

## Communication Protocols

### Task Handoff Format

**When delegating to Gemini/Codex**:

```markdown
## TASK FOR [AGENT NAME]

**Objective**: [One-sentence goal]

**Context**:
- Current state: [What exists now]
- Goal state: [What should exist after]
- Constraints: [Any limitations or requirements]

**Input Artifacts**:
- File: /path/to/file.swift
- Spec: openspec/specs/feature/spec.md
- Related: [Links to related work]

**Expected Output**:
- Format: [Markdown report / Swift code / Test file]
- Deliverables:
  1. [Specific item 1]
  2. [Specific item 2]
- Quality Criteria: [How to validate success]

**Do NOT**:
- [Specific things to avoid]
- [Out of scope items]

**Estimated Complexity**: [Low/Medium/High]
**Deadline**: [If applicable]
```

---

### Result Submission Format

**When agents return results**:

```markdown
## TASK RESULT: [Task Name]

**Status**: ✅ Complete / ⚠️ Partial / ❌ Blocked

**Summary**: [2-3 sentence overview]

**Deliverables**:
1. [Item 1]: [Status and location]
2. [Item 2]: [Status and location]

**Key Findings** (if research task):
- Finding 1: [Description]
- Finding 2: [Description]

**Code Artifacts** (if code task):
```swift
// Generated code here
```

**Assumptions Made**:
- [List any assumptions]

**Questions/Blockers**:
- [Anything unclear or blocking]

**Next Steps Recommendation**:
- [What should happen next]

**Quality Self-Check**:
- [ ] Meets stated criteria
- [ ] No obvious errors
- [ ] Follows project conventions
```

---

## Integration Requirements

### Technical Setup

**Prerequisites** (✅ Already installed on your Mac):
- `gemini-cli` - https://github.com/google-gemini/gemini-cli
- `codex` - https://github.com/openai/codex

**Verification**:
```bash
which gemini  # Should show installed path
which codex   # Should show installed path
```

**Working Directory Setup**:
```bash
# Create results cache for agent outputs
mkdir -p ~/.claude-orchestration/{gemini,codex,artifacts}
```

---

### Direct CLI Integration (Simplified Approach)

> [!IMPORTANT]
> **Verified December 2025**: Both CLIs work for non-interactive delegation!
> - **Gemini CLI**: Requires VS Code "Gemini CLI Companion" extension installed and connected first
> - **Codex CLI**: Works via `codex exec` command

**Setup Requirement**: Install "Gemini CLI Companion" from VS Code marketplace, then run `/ide enable` in an interactive Gemini session once.

**Codex Pattern**: Claude delegates → `codex exec` → Review result → Integrate
**Gemini Pattern**: Claude delegates → `gemini -y "prompt" -o text` → Review result → Integrate

---

### Practical Integration Examples

#### Example 1: Delegate Research to Gemini

**Claude Code action** (MANDATORY @path pattern):
```bash
# Step 1: Use Claude tools to find target files (cheap & fast)
Grep "child.name" Views/*.swift Models/*.swift Services/*.swift

# Step 2: Use @path syntax (MANDATORY - 9.2x more efficient)
gtimeout 90 gemini -p "Find all locations where child.name is displayed in @Views/ContentView.swift and list with line numbers" -y -o json > ~/.maestro/gemini/child-name-usage.json

# Step 3: Claude reads result
cat ~/.maestro/gemini/child-name-usage.json
```

#### Example 2: Delegate Code Generation to Codex

**Claude Code action** (✅ Verified working):
```bash
# Invoke Codex in non-interactive mode with auto-approval
cd /Users/nexus/iOSdev/Somni

codex exec "Generate a Swift function that masks a child's name for privacy mode.
Requirements:
- Input: Child name (String)
- Output: Masked name (e.g., 'Emma' -> 'Child A')
- Use alphabetical assignment (sorted by name)
- Follow Somni code conventions (MARK comments, camelCase)" \
  --full-auto --json 2>&1 | tee ~/.claude-orchestration/codex/privacy-masking-function.json

# Claude reviews generated code from JSON output
cat ~/.claude-orchestration/codex/privacy-masking-function.json
```

#### Example 3: Multi-File Analysis with Gemini

**Claude Code action** (Hybrid approach with @path ONLY):
```bash
cd /Users/nexus/iOSdev/Somni

# Step 1: Claude finds relevant files cheaply (100 tokens, <1 second)
Grep "profilePhotoData\|photoPosition" Views/*.swift

# Step 2: Gemini analyzes specific file (@path MANDATORY)
gtimeout 90 gemini -p "Analyze @Views/ContentView.swift for profile photo display. Does it display child profile photos? How?" -y -o json > ~/.maestro/gemini/photo-display-analysis.json
```

#### Example 4: Test Generation with Codex

**Claude Code action**:
```bash
# Pass existing code + test plan to Codex
cat Services/RecommendationEngine.swift > /tmp/codex-context.txt
cat <<'EOF' >> /tmp/codex-context.txt

Generate XCTest test cases for the getSleepPressure() method:
- Test newborn (0-2 months) with no prior sleep
- Test infant (6 months) with recent nap
- Test toddler (18 months) with long wake window
- Follow existing test patterns in SomniTests/
EOF

codex "$(cat /tmp/codex-context.txt)" \
  --language swift \
  > ~/.claude-orchestration/codex/recommendation-engine-tests.swift
```

---

### Claude Code Integration Workflow

**Step-by-step for delegation**:

1. **Claude identifies task suitable for delegation**
   - Research → Gemini
   - Code generation → Codex
   - Complex logic → Keep with Claude

2. **Claude uses Bash tool to invoke CLI**
   ```bash
   # Use @path syntax (MANDATORY - 9.2x more efficient)
   gtimeout 90 gemini -p "Your prompt here with @file1.swift reference" -y -o json > output.json
   ```

3. **Claude uses Read tool to review result**
   ```bash
   Read ~/.claude-orchestration/gemini/output.md
   ```

4. **Claude validates quality**
   - Check for hallucinations
   - Verify file paths exist
   - Ensure conventions followed

5. **Claude integrates or iterates**
   - If good: integrate into codebase
   - If needs work: refine and re-delegate
   - If unsuitable: handle directly

---

### Gemini CLI Usage Patterns

> [!IMPORTANT]
> **December 2025 Discovery**: Token efficiency varies 9.2x between patterns!
> - **@path** syntax: **4,468 tokens** (9.2x more efficient, **MANDATORY**)
> - **$(cat)** inline: **41,295 tokens** (works but 824% MORE expensive)
> - **stdin piping**: **~40,000 tokens** (works but 796% MORE expensive)

**Recommended Headless Patterns** (ordered by token efficiency):

**Pattern 1: @path Syntax** ⭐ **MANDATORY** (9.2x More Efficient)
```bash
cd /Users/nexus/iOSdev/Somni

# Use @path (9.2x more efficient than $(cat))
gtimeout 90 gemini -p "Analyze @Services/ExportService.swift for error handling" -y -o json > output.json
# Tokens: 4,468 (for 48KB Swift file)
```

**Pattern 2: $(cat) Inline** ⚠️ **AVOID** (Works but Expensive)
```bash
cd /Users/nexus/iOSdev/Somni

# Inline with $(cat) - works but 9.2x MORE expensive than @path
gtimeout 90 gemini -p "Analyze: $(cat Services/ExportService.swift)" -y -o json > output.json
# Tokens: 41,295 (for 48KB Swift file) - **824% MORE than @path**

# ONLY use when preprocessing absolutely required:
gtimeout 90 gemini -p "Analyze: $(head -100 Services/LargeFile.swift)" -y -o json
```

**Pattern 3: stdin Piping** ⚠️ **AVOID** (Works but Expensive)
```bash
# Officially documented but uses 796% MORE tokens than @path
cat Services/ExportService.swift | gtimeout 90 gemini -p "Analyze" -y -o json
# Tokens: ~40,000 (for 48KB Swift file) - **9.0x MORE than @path**
```

**What Works** ✅:
- **@path syntax**: `@Services/File.swift` (**4.5K tokens**, most efficient - **USE THIS**)
- **$(cat) inline**: `$(cat file.swift)` (**41K tokens**, works but 9.2x more expensive)
- **stdin piping**: `cat file | gemini -p` (**~40K tokens**, works but impractical)

**What Fails** ❌:
- **--files flag**: Doesn't exist
- **Plain file paths**: "Read Services/X.swift" (timeouts)
- **@{path} braces**: Custom commands only (timeouts in headless)

**Token Efficiency** (48KB Swift file, Dec 18, 2025):
- @path: **4,468 tokens** ← **MANDATORY** (9.2x cheaper)
- $(cat): **41,295 tokens** ← Avoid (9.2x more expensive)
- stdin: **~40,000 tokens** ← Avoid (9.0x more expensive)

**Solution**: Use **hybrid approach** with **@path only**
- Claude finds: Glob/Grep (100 tokens)
- Gemini analyzes: **@path** (4.5K tokens - MANDATORY)
- Single file at a time (atomic queries)
- **Never use $(cat) or stdin** (9.2x token waste)

**Available options**:
- `-p` / `--prompt`: Prompt for headless mode **(REQUIRED for automation)**
- `-y` / `--yolo`: Auto-approve all tool calls
- `-o` / `--output-format`: Output format (text, json, stream-json) - **json recommended**
- `-m` / `--model`: Specify model (gemini-1.5-pro, gemini-1.5-flash)
- `-r` / `--resume`: Resume a previous session

---

### Codex CLI Usage Patterns

> [!TIP]
> Use `codex exec` for non-interactive execution. This is the verified working pattern.

**Non-interactive code generation** (✅ verified):
```bash
cd /Users/nexus/iOSdev/Somni

# Basic delegation with full-auto mode
codex exec "Generate a Swift extension for relative time formatting" --full-auto

# With JSON output for structured parsing
codex exec "Generate XCTest cases for DateHelpers" --full-auto --json

# Save output to file
codex exec "Analyze code quality" --full-auto --json 2>&1 | tee output.json
```

**Available options**:
- `--full-auto`: Auto-approve sandbox operations (workspace-write + on-request approval)
- `--json`: Output events as JSON lines (structured output)
- `-m` / `--model`: Specify model
- `-C` / `--cd`: Set working directory
- `-o` / `--output-last-message`: Save final message to file

**Code review**:
```bash
codex exec review  # Non-interactive code review
```

---

## Quality Control Gates

### Before Accepting Agent Work

**Gemini Results**:
- [ ] Research is comprehensive (checked multiple locations)
- [ ] File paths are correct and exist
- [ ] Findings are relevant to task
- [ ] No hallucinated code examples (if included)
- [ ] Recommendations are actionable

**Codex Results**:
- [ ] Code compiles (if Swift)
- [ ] Follows project conventions (MARK comments, naming)
- [ ] No force unwraps or unsafe patterns
- [ ] Includes error handling where needed
- [ ] Tests pass (if test code)
- [ ] Accessibility labels present (if UI code)

**Always Required**:
- [ ] Claude reviews ALL code before commit
- [ ] Claude writes final commit messages
- [ ] Claude handles git operations
- [ ] Claude maintains conversation context with user

---

## Token Budget Allocation

**Target Distribution** (for a typical feature implementation):

| Phase | Claude | Gemini | Codex | Total |
|-------|--------|--------|-------|-------|
| Understanding & Planning | 80% | 10% | 10% | ~5K tokens |
| Research & Exploration | 20% | 70% | 10% | ~15K tokens |
| Code Generation | 30% | 10% | 60% | ~20K tokens |
| Review & Integration | 90% | 5% | 5% | ~8K tokens |
| Testing & Validation | 40% | 30% | 30% | ~10K tokens |

**Total Feature**: ~58K tokens
**Claude Usage**: ~23K tokens (40% of total)
**Savings vs Claude-only**: ~35K tokens (60% reduction)

---

## Example Workflows

### Workflow 1: Add Privacy Mode Feature

**User Request**: "Implement privacy mode that masks child names"

**Claude orchestration** (actual CLI commands):

```bash
# Step 1: Claude understands requirements, creates OpenSpec proposal (keeps this)

# Step 2: Use Claude tools for multi-file search (cheap & fast)
Grep "child\.name" Views/*.swift Models/*.swift Services/*.swift

# Step 3: For detailed analysis, delegate to Gemini (@path MANDATORY)
gtimeout 90 gemini -p "Analyze @Views/ContentView.swift for child.name usage. List all locations with line numbers and context." -y -o json \
  > ~/.claude-orchestration/gemini/child-name-usage-report.json

# Step 3: Claude reads and reviews findings
# (Uses Read tool on child-name-usage-report.json)

# Step 4: Claude creates implementation plan based on findings

# Step 5: Delegate boilerplate generation to Codex
cat > /tmp/privacy-toggle-spec.txt <<'EOF'
Generate Swift code for privacy mode toggle:
- @AppStorage property wrapper for persistence
- Observable property in settings view model
- Follow Somni conventions (MARK comments)
EOF

codex "$(cat /tmp/privacy-toggle-spec.txt)" \
  --language swift \
  > ~/.claude-orchestration/codex/privacy-toggle.swift

# Step 6: Delegate masking helper to Codex
cat > /tmp/masking-helper-spec.txt <<'EOF'
Generate Swift function: maskChildName(children: [Child], targetChild: Child) -> String
- Returns "Child A", "Child B", etc.
- Alphabetical by child name
- Consistent mapping
- Include unit test examples
EOF

codex "$(cat /tmp/masking-helper-spec.txt)" \
  --language swift \
  > ~/.claude-orchestration/codex/masking-helper.swift

# Step 7: Claude reviews generated code (Read tool)
# Step 8: Claude implements complex UI integration manually
# Step 9: Claude integrates all pieces, handles edge cases
# Step 10: Claude commits with proper message
```

**Token Breakdown**:
- Claude: 12K (planning + integration + complex UI logic + review)
- Gemini: 8K (codebase search across 20+ files)
- Codex: 6K (boilerplate + helper functions)
- **Total**: 26K tokens, **54% Claude savings**

---

### Workflow 2: Fix Reported Bug

**User Request**: "Sleep timer shows wrong duration for overnight sessions"

**Claude orchestration**:

```bash
# Step 1: Claude understands bug report

# Step 2: Use Claude tools to find relevant code
Grep "duration\|midnight\|Date" Services/*.swift Utilities/DateHelpers.swift

# Step 3: Delegate detailed analysis to Gemini (@path MANDATORY)
gtimeout 90 gemini -p "Analyze @Utilities/DateHelpers.swift for duration calculation bugs. Focus on midnight crossing edge cases." -y -o json \
  > ~/.claude-orchestration/gemini/duration-calc-analysis.json

# Step 3: Claude reviews findings, identifies root cause
# (e.g., discovers DateHelpers.swift line 42 doesn't handle midnight crossing)

# Step 4: Claude writes fix directly (critical business logic)

# Step 5: Delegate test generation to Codex
cat > /tmp/test-spec.txt <<'EOF'
Generate XCTest cases for overnight sleep duration calculation:
- Test 1: Sleep at 8 PM, wake at 6 AM (10 hours)
- Test 2: Sleep at 11 PM, wake at 1 AM (2 hours)
- Test 3: Sleep at 7 PM yesterday, wake at 7 AM today (12 hours)
Follow existing test patterns in SomniTests/DateHelpersTests.swift
EOF

codex "$(cat /tmp/test-spec.txt)" --language swift \
  > ~/.claude-orchestration/codex/overnight-duration-tests.swift

# Step 6: Claude reviews tests, integrates, runs suite
# Step 7: Claude commits with detailed bug fix message
```

**Token Breakdown**:
- Claude: 6K (diagnosis + fix implementation + test review)
- Gemini: 4K (comprehensive code search)
- Codex: 3K (test generation)
- **Total**: 13K tokens, **54% Claude savings**

---

### Workflow 3: Documentation Update

**User Request**: "Update all docs to reflect new onboarding flow"

**Claude orchestration**:

```bash
# Step 1: Claude identifies what changed in onboarding

# Step 2: Use Claude tools for multi-file search (fast!)
Grep -i "onboarding|getting started|first launch|initial setup" docs/*.md docs/guides/*.md openspec/specs/**/*.md

# Step 3: For each doc file found, delegate update drafting to Gemini (@path MANDATORY)
gtimeout 90 gemini -p "Update onboarding references in @docs/START-HERE.md.
Old flow: Single-step quick start
New flow: 1) Welcome screen with app intro, 2) Add first child profile, 3) Start first sleep session
Draft updated text maintaining existing tone." -y -o json \
  > ~/.claude-orchestration/gemini/doc-updates-draft.json

# Step 4: Claude reviews drafts (quick scan - 2K tokens instead of 15K)
# Step 5: Claude applies approved changes and commits
```

**Token Breakdown**:
- Claude: 3K (coordination + quick review + edits)
- Gemini: 12K (reading 15 doc files + drafting updates)
- **Total**: 15K tokens, **80% Claude savings**

---

## Monitoring & Metrics

**See also**: [COST-GUARDRAILS.md](COST-GUARDRAILS.md) for budget enforcement and cost optimization

### Track These Metrics

**Efficiency**:
- Claude token usage per task type
- Total tokens saved via delegation
- Time to completion (parallel vs sequential)
- Cost per feature (across all models)

**Quality**:
- Code review rejection rate by agent
- Bug introduction rate by agent
- Test coverage achieved
- Documentation accuracy

**Process**:
- Task handoff clarity (rework rate)
- Integration complexity (merge conflicts)
- User satisfaction (blocking questions)

**Cost Management**:
- Token budget adherence ([COST-GUARDRAILS.md § 2](COST-GUARDRAILS.md#2-cost-anomaly-detection))
- Monthly cost trending ([COST-GUARDRAILS.md § 8](COST-GUARDRAILS.md#8-production-metrics-dashboard))
- ROI validation ([COST-GUARDRAILS.md § 4](COST-GUARDRAILS.md#4-economic-justification-matrix))

### Simple Token Tracking

**Create a log file**: `~/.claude-orchestration/token-log.md`

```markdown
# Multi-Agent Token Log

## Week 1: Dec 15-21, 2025

### Tasks Completed
1. **Privacy mode research** (Dec 16)
   - Gemini: Codebase search (estimated 8K tokens)
   - Claude: Review + planning (3K tokens)
   - Savings: ~60% (would have been 20K Claude-only)

2. **Bug fix: Overnight duration** (Dec 17)
   - Gemini: Code search (4K tokens)
   - Codex: Test generation (3K tokens)
   - Claude: Diagnosis + fix + review (6K tokens)
   - Savings: ~54% (would have been 28K Claude-only)

3. **Doc update: Onboarding flow** (Dec 18)
   - Gemini: Audit + drafting (12K tokens)
   - Claude: Quick review + apply (3K tokens)
   - Savings: ~80% (would have been 75K Claude-only)

### Weekly Summary
- **Claude tokens used**: 12K
- **Claude tokens saved**: ~93K (estimated)
- **Delegation rate**: 88%
- **Quality issues**: 1 (Codex force unwrap, caught in review)
- **Time saved**: ~2 hours (parallel execution)

### Learnings
- Gemini excellent for doc audits (2M context window)
- Codex needs detailed specs for quality
- Always review generated code for Swift safety patterns
```

**Update weekly**: Track actual usage vs. estimates, refine delegation strategy.

---

### Dashboard (Simple Markdown)

**Optional detailed tracking** (if you want more metrics):

```markdown
# Orchestration Metrics - Week of Dec 15

## Token Usage
- Claude: 12K (target: <20K) ✅ **40% reduction**
- Gemini: 24K (quota: 2M) ✅
- Codex: 9K (quota: unlimited) ✅

## Task Distribution
- Total tasks: 3
  - Claude only: 0 (0%)
  - Gemini delegated: 3 (100%)
  - Codex delegated: 2 (67%)
  - Multi-agent: 2 (67%)

## Quality
- Code reviews passed first time: 2/2 (100%) ✅
- Gemini research accuracy: 3/3 (100%) ✅
- Codex code quality: 1/2 (50%) ⚠️

## Efficiency
- Avg Claude tokens saved per delegation: ~31K
- Parallel execution speedup: Not measured yet
- Estimated cost reduction: ~$15/week

## Issues
- Codex generated force unwrap (caught in review, fixed)
- Gemini occasionally over-explains (acceptable)

## Next Week Goals
- Delegate 5+ tasks
- Measure actual token usage (vs estimates)
- Refine Codex prompts for better quality
```

---

## Risk Mitigation

**See also**: [FAILURE-RUNBOOK.md](FAILURE-RUNBOOK.md) for detailed troubleshooting procedures

### Risk 1: Agent Hallucination
**Mitigation**:
- Claude ALWAYS reviews agent output
- Verify file paths exist before accepting
- Run tests on all generated code
- Never deploy agent code without human review

**If hallucinations persist**: See [FAILURE-RUNBOOK.md § 1.3](FAILURE-RUNBOOK.md#13-hallucinated-line-numbers) for retry strategies

### Risk 2: Context Loss
**Mitigation**:
- Claude maintains master context
- Task results include full context
- Use task dependencies to sequence work
- Regular context sync (every 5 tasks)

### Risk 3: Quality Degradation
**Mitigation**:
- Quality gates before accepting work
- Style guide enforcement
- Automated tests required
- User-facing code always gets Claude review

**If quality issues arise**: See [FAILURE-RUNBOOK.md § 2.2](FAILURE-RUNBOOK.md#22-force-unwraps-detected) for validation patterns

### Risk 4: Over-Delegation
**Mitigation**:
- Claude makes all architectural decisions
- Complex logic stays with Claude
- User communication stays with Claude
- Git operations stay with Claude

**Economic check**: See [COST-GUARDRAILS.md § 4.2](COST-GUARDRAILS.md#42-break-even-thresholds) for ROI thresholds

---

## Success Criteria

**After 2 Weeks**:
- [ ] 50%+ reduction in Claude token usage
- [ ] 90%+ agent work acceptance rate
- [ ] Zero bugs introduced by agents
- [ ] 2x faster feature completion (via parallelization)
- [ ] User satisfaction maintained

**After 1 Month**:
- [ ] 60%+ reduction in Claude token usage
- [ ] Established patterns for common tasks
- [ ] Metrics dashboard automated
- [ ] Clear ROI demonstrated
- [ ] Workflow refined based on learnings

---

## Quick Start (15 Minutes)

**Since you already have gemini-cli and codex installed, you can start immediately!**

> [!IMPORTANT]
> **December 2025 Update**: Gemini CLI requires an interactive terminal. Codex CLI works non-interactively via `codex exec`.

### Step 1: Create working directories (30 seconds)
```bash
mkdir -p ~/.claude-orchestration/{gemini,codex,artifacts}
```

### Step 2: Test Codex (2 minutes) ✅ Delegatable
```bash
cd /Users/nexus/iOSdev/Somni

# Non-interactive test: Generate a helper function
codex exec "Generate a Swift extension on Date that returns a human-readable relative time string.
Examples: '2 hours ago', 'yesterday', 'last week'
Follow iOS conventions." --full-auto --json 2>&1 | tee ~/.claude-orchestration/codex/test-date-extension.json

# View the output
cat ~/.claude-orchestration/codex/test-date-extension.json | grep -A5 '"type":"agent_message"'
```

### Step 3: Test Gemini (2 minutes) ⚠️ Interactive Only
```bash
cd /Users/nexus/iOSdev/Somni

# Run interactively (requires terminal)
gemini -y "Find all TODO comments in Swift files. List file paths and TODO text."

# User manually copies results to share with Claude
```

### Step 4: Test integrated workflow (5 minutes)

**Scenario**: Code generation with Codex + manual Gemini research

```bash
# Step 1: User runs Gemini interactively for research
gemini -y "Search for force unwraps (!) in accessibility-related code in Views/"

# Step 2: Claude delegates fix generation to Codex
codex exec "Convert this Swift code to use safe optional binding:
.accessibilityLabel(entry.child != nil ? entry.child!.name : 'Session')
Use .map { } ?? pattern instead of force unwrap." --full-auto --json

# Claude reviews Codex output and integrates
```

**If Codex tests pass**: You're ready for code generation delegation!

---

## Next Steps

### Immediate (Today)
1. ✅ Test setup complete (Quick Start above)
2. Try first real delegation during next feature
3. Track which tasks you delegate vs handle directly
4. Note any CLI flag adjustments needed

### This Week
1. Delegate 3-5 research tasks to Gemini
2. Delegate 3-5 code generation tasks to Codex
3. Keep simple log of token savings (estimate)
4. Refine prompts based on quality of results
5. Identify which workflows save most tokens

### This Month
1. Establish patterns for common task types
2. Create prompt templates for frequent delegations
3. Measure actual token reduction (vs estimates)
4. Optimize CLI flags (model selection, temperature)
5. Document learnings in this file

---

## Claude's Delegation Decision Protocol

**When Claude Code should proactively suggest delegation during conversation:**

### Delegation Triggers

**Automatic Gemini delegation** (Claude does without asking):
- Large codebase searches (>10 files)
- Documentation audits (>5 doc files)
- Pattern finding across entire project
- Test coverage analysis
- Dependency mapping

**Automatic Codex delegation** (Claude does without asking):
- Boilerplate generation (models, previews)
- Test case generation from specs
- Helper function implementation
- Constants/enum definitions

**Ask user first** (for significant work):
- Complex feature implementation (multi-agent)
- Unclear requirements (research needed first)
- User preference matters (multiple approaches)

### Conversation Patterns

**Pattern 1: Proactive Delegation**
```
User: "Find all places where we display child names"

Claude: "I'll delegate this codebase search to Gemini for faster results.

[Uses Bash tool to invoke gemini CLI]

Gemini found 23 locations across 8 files. Here are the key findings:
- ContentView.swift: Lines 145, 892, 1203
- SleepLogView.swift: Lines 234, 567
...

Based on this, I recommend...
```

**Pattern 2: Transparent Multi-Agent**
```
User: "Add a privacy mode toggle"

Claude: "I'll orchestrate this across multiple agents:

1. **Gemini**: Research existing privacy patterns in codebase
2. **Codex**: Generate @AppStorage boilerplate
3. **Claude** (me): Design UI integration and implement

Starting with Gemini research...

[Delegates and shows results]

Now delegating boilerplate to Codex...

[Generates and reviews]

Now I'll implement the UI integration myself...

[Implements complex logic]
```

**Pattern 3: Quality Gate Transparency**
```
Claude: "Codex generated the helper function. Let me review before integrating...

✅ Follows naming conventions
✅ No force unwraps
⚠️ Missing error handling - I'll add that
❌ Uses deprecated API - I'll update this

Here's the refined version I'm integrating:
[Shows corrected code]
```

### User Control Signals

**User can request specific agent**:
- "Use Gemini to search for..."
- "Have Codex generate..."
- "You handle this directly" (skip delegation)

**User can adjust delegation**:
- "Do this yourself" → Claude handles directly
- "Speed this up" → Delegate more aggressively
- "I want to see the prompts" → Show exact CLI commands

---

## Appendix: Task Type Catalog

### High-Value Gemini Tasks
- Codebase exploration ("map authentication flow")
- Documentation audits ("find outdated version numbers")
- Test coverage analysis ("which specs lack tests?")
- Dependency analysis ("what depends on this model?")
- Pattern finding ("all force unwraps in accessibility code")
- Large file reading (specs, logs, reports)

### High-Value Codex Tasks
- Boilerplate generation (models, services)
- Test case generation from specs
- Preview generation for SwiftUI
- Helper function implementation
- Constants/enum definitions
- Mock data generation
- Code formatting fixes

### Must-Stay-With-Claude
- Architecture decisions
- OpenSpec proposals
- Complex refactoring
- User communication
- Git commits
- Final code review
- Debugging complex issues
- Integration work

---

---

## Critical Implementation Considerations

### Authentication Model

**Session-Based (OAuth)**: This workflow uses OAuth/account-based authentication, NOT API keys.

```bash
# Check session status
gemini "test" 2>&1 | grep -i "login"  # If prompts to login, session expired
codex "test" 2>&1 | grep -i "login"   # If prompts to login, session expired

# Re-authenticate if session expired
gemini login
codex login
```

**Session expiry handling**:
- Sessions can expire during long work periods
- I will detect "please login" errors and inform you
- Quick fix: Run `gemini login` or `codex login` and retry delegation
- Proactive: Run login weekly to refresh sessions

---

### Error Handling & Fallback Strategy

**Robust delegation with fallback**:

```bash
# Safe delegation pattern with timeout and fallback
if ! timeout 60 gemini "task" > ~/.claude-orchestration/gemini/output-$(date +%s).md 2>&1; then
    echo "Gemini failed or timed out - Claude handling directly" >&2
    # I analyze the task myself instead of delegating
fi
```

**Common failure modes**:
1. **Session expired** → Inform user, they run `gemini login`
2. **Network timeout** → Retry with longer timeout or handle directly
3. **Interactive prompt** → Use `timeout` command to prevent hangs
4. **Rate limited** → Wait 60 seconds, retry, or handle directly
5. **Model deprecated** → Use CLI default (omit --model flag)

---

### Output File Management

**Prevent concurrent access conflicts** with timestamped filenames:

```bash
# Bad (race condition possible):
gemini "task" > ~/.claude-orchestration/gemini/output.md

# Good (unique per delegation):
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
gemini "task" > ~/.claude-orchestration/gemini/search-$TIMESTAMP.md
```

**Output size limits**:
- Large outputs (>100KB) risk exceeding my context window
- Use `| head -5000` to truncate if expecting large results
- For massive analysis, use summary prompts: "Provide top 10 findings only"

---

### Quality Metrics Tracking

**Track delegation effectiveness** in `~/.claude-orchestration/quality-log.md`:

```markdown
## Delegation Quality Log

### 2025-12-15
- **Gemini codebase search**: ✅ Accepted (accurate, all files found)
- **Codex test generation**: ❌ Rejected (generated force unwraps)
- **Codex test generation v2**: ✅ Accepted (after refining prompt)

### Running Stats
- Gemini acceptance rate: 5/5 (100%)
- Codex acceptance rate: 8/10 (80%)
- Most common Codex issue: Force unwraps in Swift
- Best Gemini use case: Multi-file searches
```

---

### Cost Tracking (Optional)

**Track actual costs** (not just token estimates):

```bash
# After each delegation
echo "$(date),gemini,codebase-search,est-8K-tokens,est-$0.12" >> ~/.claude-orchestration/costs.csv

# Monthly summary
awk -F, '{sum+=$5} END {print "Total: $" sum}' ~/.claude-orchestration/costs.csv
```

---

### Pre-Use Checklist

**Before first delegation**, run workspace audit:

```bash
bash ~/.claude-orchestration/WORKSPACE-AUDIT.md
```

**Verify**:
- [ ] CLIs installed (`which gemini` / `which codex`)
- [ ] Sessions active (test queries succeed)
- [ ] Directories exist (`~/.claude-orchestration/`)
- [ ] Network connectivity (can reach APIs)
- [ ] Disk space available (>1GB free)
- [ ] No interactive prompts (test with small task)

---

### Known Blind Spots & Mitigations

| Blind Spot | Risk | Mitigation |
|-----------|------|------------|
| **Session expiration** | High | Check before delegation, inform user if expired |
| **Interactive prompts** | High | Use `timeout` command wrapper (60s default) |
| **Output size explosion** | Medium | Truncate with `head` or request summaries |
| **Concurrent file conflicts** | Low | Use timestamped filenames |
| **Rate limiting** | Medium | Add `sleep 5` between rapid delegations |
| **Model deprecation** | Low | Use CLI defaults (no --model flag) |
| **Network failures** | Medium | Timeout + fallback to Claude |
| **Cost overruns** | Low | Track in costs.csv, review weekly |

---

### Emergency Procedures

**If delegation hangs**:
1. Wait 60 seconds (timeout should kill)
2. If still hung, user presses Ctrl+C
3. I handle task directly
4. Update learnings.md with issue

**If session expired mid-work**:
1. I detect "login required" error
2. Inform user: "Gemini session expired - run `gemini login`"
3. User re-authenticates
4. I retry delegation
5. Continue work seamlessly

**If output is unusable**:
1. Check quality gates (hallucinations, wrong format)
2. Refine prompt and re-delegate
3. If still bad, handle directly
4. Log issue in learnings.md with better prompt template

---

### Integration with Claude Code Permissions

**Pre-approved commands** (from CLAUDE.md):
- `gemini * > ~/.claude-orchestration/gemini/*`
- `codex * > ~/.claude-orchestration/codex/*`
- `timeout * gemini *`
- `timeout * codex *`

**These run automatically without user approval**, enabling seamless delegation.

**Security**: Outputs confined to `~/.claude-orchestration/` directory only. I review all outputs before integrating into codebase.

---

## Workflow Evolution & Learning

**After each delegation**, update `~/.claude-orchestration/learnings.md`:

1. **What worked**: Successful prompts → save as templates
2. **What failed**: Quality issues → document avoidance patterns
3. **Prompt refinements**: Better wording → update examples
4. **CLI discoveries**: New flags → document in usage patterns

**Monthly review**:
- Analyze quality-log.md for trends
- Update delegation triggers (when to use which agent)
- Refine quality gates based on rejection patterns
- Optimize prompt templates for common tasks

---

**End of Plan**

*This is a living document. Update based on real-world experience and evolving capabilities.*

**Critical files**:
- `~/.maestro/learnings.md` - Prompt patterns & quality issues (survives compaction)
- `~/.maestro/token-log.md` - Usage tracking
- `docs/maestro/WORKSPACE-AUDIT.md` - Pre-use verification
- `docs/maestro/FAILURE-RUNBOOK.md` - Operational troubleshooting
- `docs/maestro/COST-GUARDRAILS.md` - Budget enforcement

**Operational Guides**:
- **DELEGATION-MATRIX.md** - Strict routing rules (authoritative)
- **GEMINI.md** - Gemini execution contract
- **CODEX.md** - Codex execution contract
- **FAILURE-RUNBOOK.md** - Symptom → Cause → Fix workflows
- **COST-GUARDRAILS.md** - Token budgets and economic viability
