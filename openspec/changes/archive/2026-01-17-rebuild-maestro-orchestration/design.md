# Design: Rebuild Maestro Multi-Agent Orchestration

## Token Efficiency

### Design Principle: Minimal Global Footprint

The Maestro protocol MUST NOT bloat the user's context window at session start. Full protocol details load on-demand when slash commands are invoked.

### Token Budget

| Component | Location | Tokens | When Loaded |
|-----------|----------|--------|-------------|
| Trigger phrase | Global instructions | ~50 | Session start |
| `/maestro plan` | Slash command | ~800 | On invoke |
| `/maestro challenge` | Slash command | ~400 | On invoke |
| `/maestro run` | Slash command | ~500 | On invoke |
| `/maestro review` | Slash command | ~300 | On invoke |
| `/maestro status` | Slash command | ~200 | On invoke |
| `/maestro report` | Slash command | ~300 | On invoke |
| State file | `.ai/MAESTRO.md` | Variable | On invoke |

### Global Instruction Content (~50 tokens)

Each tool's global instructions (CLAUDE.md, GEMINI.md, AGENTS.md) include only:

```markdown
## Maestro Orchestration
Multi-agent orchestration via `/maestro plan`, `/maestro challenge`, `/maestro run`, `/maestro review`, `/maestro status`, `/maestro report`.
State: `.ai/MAESTRO.md` | Log: `.ai/MAESTRO-LOG.md`
```

### What Lives in Slash Commands (Not Global)

- Hub behavior and decision logic
- Specialist definitions and routing
- Task Handoff / Result Submission schemas
- AAVSR precondition checks
- Retry ladder and failure handling
- Quality gate validation

This ensures users pay zero token cost for Maestro unless they actively use it.

## Native Subagent Integration

### Design Principle: Cheap Recon, Expensive Dispatch

Native subagents handle internal "cheap" work (recon, validation) while external tool dispatch handles "expensive" work (implementation). This maximizes token efficiency by avoiding CLI overhead for exploratory tasks.

### Hub Subagent Roles

| Subagent | Phase | Purpose |
|----------|-------|---------|
| `Explore` | Pre-plan | Understand codebase patterns before decomposing goals |
| `Plan` | Pre-dispatch | Validate task feasibility and identify blockers |
| `code-reviewer` | Post-dispatch | Quality gate for code-type spoke results |
| `Bash` | Dispatch | Execute CLI commands to spawn Gemini/Codex |

### Hub Workflow with Subagents

```
/maestro plan "add authentication"
        │
        ▼
┌─────────────────────────────────┐
│  Explore subagent               │  ← Cheap: internal recon
│  - Find existing auth patterns  │
│  - Identify relevant files      │
│  - Understand current approach  │
└─────────────────────────────────┘
        │
        ▼
┌─────────────────────────────────┐
│  Hub decomposes goal            │
│  - Informed by recon results    │
│  - Creates atomic task list     │
│  - Assigns specialists          │
└─────────────────────────────────┘
        │
        ▼
/maestro challenge (optional)
        │
        ▼
┌─────────────────────────────────┐
│  Bash subagent                  │  ← Cross-tool: plan challenge
│  - Dispatch plan to spoke(s)    │
│  - Collect assumption issues    │
│  - Hub revises plan             │
└─────────────────────────────────┘
        │
        ▼
    User approves
        │
        ▼
/maestro run
        │
        ▼
┌─────────────────────────────────┐
│  Plan subagent (per task)       │  ← Cheap: feasibility check
│  - Validate preconditions       │
│  - Identify missing context     │
│  - Flag potential blockers      │
└─────────────────────────────────┘
        │
        ▼
┌─────────────────────────────────┐
│  Bash subagent                  │  ← Expensive: external dispatch
│  - gemini -p "..." -y -o json   │
│  - codex exec "..." --full-auto │
└─────────────────────────────────┘
        │
        ▼
/maestro review (optional)
        │
        ▼
┌─────────────────────────────────┐
│  Bash subagent                  │  ← Cross-tool: work review
│  - Dispatch result to Spoke B   │
│  - Collect review feedback      │
│  - Hub decides: accept/revise   │
└─────────────────────────────────┘
        │
        ▼
┌─────────────────────────────────┐
│  code-reviewer subagent         │  ← Cheap: final validation
│  - Check against criteria       │
│  - Verify no scope creep        │
│  - Assess code quality          │
└─────────────────────────────────┘
```

### Subagent Availability by Tool

| Tool | Explore | Plan | Code Review | Bash |
|------|---------|------|-------------|------|
| Claude Code | ✓ Task tool | ✓ Task tool | ✓ Task tool | ✓ Native |
| Gemini CLI | TBD | TBD | TBD | ✓ Native |
| Codex CLI | TBD | TBD | TBD | ✓ Native |

**Note:** Gemini CLI and Codex CLI agent capabilities need verification. All tools support Bash for external dispatch. Internal recon/validation patterns may differ by tool.

### Skills for Maestro Execution

On-demand skills encapsulate complex decision logic without bloating slash commands:

| Skill | Purpose | Trigger |
|-------|---------|---------|
| `maestro-decompose` | Goal → atomic tasks breakdown | During `/maestro plan` |
| `maestro-validate-result` | Check spoke output against criteria | After spoke returns |
| `maestro-route` | Match task to optimal specialist/tool | Before dispatch |
| `maestro-recover` | Failure diagnosis and retry strategy | On task failure |

Skills are invoked on-demand, maintaining the minimal global footprint design.

## Architecture Overview

Maestro v2 uses a **Hub-and-Spoke** architecture where any AI tool (Claude Code, Gemini CLI, Codex CLI) can act as the central orchestrator (Hub), delegating atomic tasks to specialist workers (Spokes).

```
                    ┌─────────────┐
                    │    User     │
                    └──────┬──────┘
                           │
                    ┌──────▼──────┐
                    │     Hub     │  ← Any tool can be Hub
                    │  (Claude/   │
                    │  Gemini/    │
                    │  Codex)     │
                    └──────┬──────┘
                           │
         ┌─────────────────┼─────────────────┐
         │                 │                 │
    ┌────▼────┐      ┌────▼────┐      ┌────▼────┐
    │ Spoke 1 │      │ Spoke 2 │      │ Spoke 3 │
    │ (code)  │      │ (review)│      │ (test)  │
    └─────────┘      └─────────┘      └─────────┘
```

## Decision Records

### DR-1: Hub-and-Spoke vs Alternatives

**Options Considered:**
1. **Parent-Child** - Fixed hierarchy, one tool always orchestrates
2. **Peer-to-Peer** - Tools communicate directly without coordinator
3. **Hub-and-Spoke** - Central coordinator, but any tool can be hub

**Decision:** Hub-and-Spoke

**Rationale:**
- Maintains single point of normalization (hub handles output format differences)
- Allows user to choose preferred tool as orchestrator
- Simpler state management than peer-to-peer
- More flexible than parent-child

### DR-2: Context Injection Strategy

**Options Considered:**
1. **Spoke pulls context** - Each spoke reads state file directly
2. **Hub injects context** - Hub includes only relevant context in handoff
3. **Shared context pool** - All context available to all spokes

**Decision:** Hub injects context

**Rationale:**
- Most token-efficient (9.2x savings observed with Gemini's @path syntax)
- Hub can tailor context per specialist role
- Prevents context pollution between unrelated tasks
- Enables pre-delegation reconnaissance (cheap checks before expensive delegation)

### DR-3: Specialist Definition Strategy

**Options Considered:**
1. **Predefined only** - Ship fixed specialist roles
2. **Custom only** - User defines all specialists
3. **Hybrid** - Predefined roles + extensible custom definitions

**Decision:** Hybrid (predefined + extensible)

**Rationale:**
- Predefined roles cover 80% of use cases (code, review, test, research)
- Custom specialists enable domain-specific workflows
- Lower barrier to entry, higher ceiling for power users
- Custom definitions deferred to future enhancement

### DR-4: Persistence Model

**Options Considered:**
1. **Ephemeral** - State lives only in session memory
2. **Persistent** - Always write state to disk
3. **Hybrid** - Stateful within session, optional persistence

**Decision:** Hybrid persistence

**Rationale:**
- Avoids cluttering project with state files for quick tasks
- Supports long-running orchestrations that span sessions
- User controls when to persist via explicit commands
- State file only created when user runs `/maestro plan` or `/maestro status --save`

### DR-5: Authentication Handling

**Options Considered:**
1. **Maestro manages auth** - Orchestrator handles credentials for all tools
2. **Pre-authenticated tools** - Assume user has already set up auth per tool
3. **Credential sharing** - Pass auth tokens between tools

**Decision:** Pre-authenticated tools

**Rationale:**
- Each CLI tool has its own auth mechanism (Anthropic API, Google account, OpenAI API)
- No secure way to share credentials across tools
- Simpler prerequisite: user sets up each tool once
- Aligns with "API key-based orchestration" being out of scope

**Prerequisite:** User must have authenticated each CLI tool they want to use as a spoke before running Maestro orchestration.

### DR-6: Spoke Selection Strategy

**Options Considered:**
1. **User specifies** - User assigns tool per task manually
2. **Hub decides** - Automatic routing based on task type
3. **Configurable defaults** - User sets preferences, Hub follows
4. **Explicit in plan** - Hub proposes specialist + tool, user approves/modifies

**Decision:** Explicit in plan

**Rationale:**
- Transparency: user sees exactly which tool will handle each task
- Control: user can override Hub's suggestions before execution
- Flexibility: no hardcoded routing rules
- Fits existing approval checkpoint pattern

**Plan output format:**
```
Task 1: Implement auth middleware
  Specialist: code
  Tool: Gemini CLI  ← User can modify before approval

Task 2: Review implementation
  Specialist: review
  Tool: Codex CLI   ← User can modify before approval
```

## Slash Command Design

### `/maestro plan <goal>`

**Purpose:** Decompose a high-level goal into atomic tasks.

**Flow:**
1. Hub analyzes goal and codebase context
2. Hub generates task decomposition
3. Hub presents plan to user for approval
4. User approves, modifies, or rejects
5. If approved, plan written to `.ai/MAESTRO.md`

**Output:** Structured plan with:
- Goal statement
- Task list with dependencies
- Specialist assignments
- Estimated parallelization opportunities

### `/maestro challenge`

**Purpose:** Have spokes challenge the hub's plan before execution.

**When:** After `/maestro plan`, before user approval.

**Flow:**
1. Hub dispatches plan summary to one or more spokes
2. Spokes analyze plan against codebase reality
3. Spokes return challenges (flawed assumptions, missing dependencies, better approaches)
4. Hub incorporates feedback and revises plan
5. Revised plan presented to user for approval

**Challenge Output:**
- Assumption issues (e.g., "Plan assumes JWT but codebase uses session cookies")
- Missing dependencies (e.g., "Task 2 requires middleware that doesn't exist")
- Scope concerns (e.g., "Task 3 is too large, should be split")
- Alternative approaches (e.g., "Existing auth util could be extended instead")

**Value:** Catches plan flaws before expensive execution. Different models have different blind spots—cross-tool challenge leverages this diversity.

### `/maestro run [task-id]`

**Purpose:** Execute approved plan or specific task.

**Flow:**
1. Load plan from `.ai/MAESTRO.md`
2. Identify next runnable task(s) (dependencies satisfied)
3. For each task:
   - Perform pre-delegation reconnaissance
   - Validate preconditions (AAVSR checks)
   - Dispatch to appropriate specialist
   - Collect and normalize result
   - Update state file
4. Continue until plan complete or blocked

**Precondition Checks (AAVSR):**
- **A**tomic - Single responsibility, one clear outcome
- **A**uthority - Specialist has capability to complete
- **V**erifiable - Success criteria are testable
- **S**cope - Fits within task boundaries
- **R**isk - Acceptable failure impact

### `/maestro review`

**Purpose:** Have a different spoke review work before hub accepts it.

**When:** After spoke completes a task, before hub marks it done.

**Flow:**
1. Spoke A completes task and submits result
2. Hub dispatches result to Spoke B for review
3. Spoke B analyzes against success criteria and codebase standards
4. Spoke B returns review (approve, request changes, flag issues)
5. Hub decides: accept result, request revision, or escalate to user

**Review Output:**
- Approval with notes
- Requested changes (specific, actionable)
- Flagged issues (bugs, security concerns, scope creep)
- Quality assessment (meets criteria? follows patterns?)

**Value:** Cross-tool review catches issues the original spoke missed. Mirrors human code review—author ≠ reviewer.

### `/maestro status`

**Purpose:** Display current orchestration state.

**Output:**
- Active goal
- Task completion status (pending/running/done/failed)
- Blocking issues
- Suggested next actions

## State File Format

Location: `.ai/MAESTRO.md`

```markdown
# Maestro Orchestration

## Goal
[High-level objective from /maestro plan]

## Tasks

### Task 1: [description]
- **Status:** pending | running | done | failed | blocked
- **Specialist:** code | review | test | research
- **Depends:** [task IDs]
- **Assigned:** [tool name if running]
- **Result:** [outcome summary if done]

### Task 2: [description]
...

## Execution Log
| Time | Task | Tool | Action | Outcome |
|------|------|------|--------|---------|
| ... | ... | ... | ... | ... |

## Source
[Hub Tool] | [YYYY-MM-DD HH:MM UTC]
```

## Structured I/O Schemas

### Task Handoff Template

Hub sends to Spoke:

```markdown
## Task
[Clear, atomic task description]

## Context
[Relevant files, decisions, constraints - injected by hub]

## Success Criteria
- [ ] [Testable criterion 1]
- [ ] [Testable criterion 2]

## Constraints
- [Scope boundary 1]
- [Scope boundary 2]

## Output Format
[Expected structure of result]
```

### Result Submission Template

Spoke returns to Hub:

```markdown
## Status
success | partial | failed | blocked

## Summary
[1-2 sentence outcome description]

## Changes
- [File/action 1]
- [File/action 2]

## Verification
- [x] [Criterion 1 - how verified]
- [ ] [Criterion 2 - why not met]

## Issues
[Blockers, concerns, or recommendations - or "None"]
```

## CLI Invocation Patterns

### Gemini CLI (Headless)

```bash
gemini -p "<prompt>" -y -o json
```

**Token Efficiency:** Use `@path/to/file` for file references (9.2x more efficient than inline content).

### Codex CLI (Headless)

```bash
codex exec "<prompt>" --full-auto --json
```

**Note:** Codex operates in full-auto mode, suitable for well-defined atomic tasks.

### Claude Code (Headless)

```bash
claude -p "<prompt>" --output-format json
```

**Useful flags:**
- `--max-turns N` - Limit agentic turns
- `--dangerously-skip-permissions` - Full automation in trusted environments
- `--no-session-persistence` - Stateless execution

**Note:** When Claude is the Hub, it delegates to Gemini/Codex via CLI. When Claude is a Spoke, it is invoked via the CLI pattern above.

## Predefined Specialists

| Specialist | Role | Typical Tasks |
|------------|------|---------------|
| `code` | Implementation | Write code, refactor, fix bugs |
| `review` | Quality assurance | Code review, security audit, style check |
| `test` | Validation | Write tests, run test suites, verify behavior |
| `research` | Discovery | Search codebase, read docs, answer questions |

## Failure Handling

### Retry Ladder

1. **Immediate retry** - Transient failures (network, rate limit)
2. **Context expansion** - Add more context and retry
3. **Task decomposition** - Break into smaller subtasks
4. **Escalate to user** - Request human intervention

### User Prompts on Failure

When a task fails after retries:

```
Task "Implement auth middleware" failed.

Error: Could not determine session storage approach.

Options:
1. Provide clarification and retry
2. Reassign to different specialist
3. Mark as blocked and continue
4. Abort orchestration
```

## Quality Gates

Before accepting Spoke results, Hub validates:

1. **Format compliance** - Result matches expected schema
2. **Criteria satisfaction** - Success criteria met
3. **Scope adherence** - No out-of-scope changes
4. **Integration check** - Changes don't break existing functionality

Failed gates trigger retry ladder or user escalation.

## Token Budget & Cost Guardrails

### Per-Delegation Limits

| Tool | Budget | Abort Threshold | Rationale |
|------|--------|-----------------|-----------|
| Gemini CLI | 30,000 tokens | 50,000 tokens | Based on v1 baseline (~27K typical) |
| Codex CLI | 40,000 tokens | 60,000 tokens | Based on v1 baseline (~8K cached) |

**Enforcement:**
- If delegation exceeds budget → Hub logs warning, investigates root cause
- If exceeds abort threshold → Hub aborts delegation, handles task directly

### Cost Tracking

Hub logs each delegation to `.ai/MAESTRO.md` execution log:

```
| Time | Task | Tool | Tokens | Cost | Status |
|------|------|------|--------|------|--------|
| 14:32 | Implement auth | Gemini | 27,316 | $0.55 | ✅ Budget |
| 14:35 | Write tests | Codex | 8,072 | $0.16 | ✅ Budget |
| 14:41 | Analyze deps | Gemini | 52,000 | $1.04 | ⚠️ Over |
```

### Anomaly Detection

| Alert Level | Gemini Threshold | Codex Threshold | Action |
|-------------|------------------|-----------------|--------|
| Yellow | >35K tokens | >45K tokens | Investigate, log warning |
| Red | >50K tokens | >60K tokens | Abort, Hub handles directly |

## Timeout Handling

### Exit Code 124 (Soft Success Pattern)

CLI timeout does NOT always mean failure. Output may be complete before session cleanup times out.

**Detection Protocol:**
```bash
OUTPUT=$(gtimeout 90 gemini -p "..." -y -o json 2>&1)
EXIT_CODE=$?

if [ $EXIT_CODE -eq 124 ]; then
    # Validate output before rejecting
    if [output contains expected structure]; then
        # SUCCESS: Complete output captured before timeout
        accept as soft success
    else
        # FAILURE: Incomplete output
        trigger retry ladder
    fi
fi
```

**Hub behavior on timeout:**
1. Check if output is structurally complete
2. If complete → Accept as soft success, log timeout warning
3. If incomplete → Trigger retry ladder with narrower scope

## Execution Logging & Walkthrough

### Design Principle: Opt-in Observability

Logging is off by default to keep orchestration fast and lean. Users who want refinement data or debugging capability opt in.

### Verbosity Levels

| Level | What's Logged | Use Case |
|-------|---------------|----------|
| `off` | Nothing (default) | Quick tasks, minimal overhead |
| `summary` | Actions, outcomes, token counts, timing | Protocol refinement, cost tracking |
| `detailed` | Full prompts and outputs | Debugging, deep analysis |

### File Separation

| File | Purpose | Behavior |
|------|---------|----------|
| `.ai/MAESTRO.md` | State only | Current plan, task status |
| `.ai/MAESTRO-LOG.md` | Execution log | Append-only during run |

### Log Format (Table)

```markdown
# Maestro Execution Log

## Session: 2026-01-16 14:30 UTC
**Goal:** Add user authentication

| Time | Actor | Action | Target | Tokens | Duration | Outcome | Notes |
|------|-------|--------|--------|--------|----------|---------|-------|
| 14:30:15 | Hub | Recon | Explore subagent | 1,247 | 12s | ✅ | Found auth patterns |
| 14:31:02 | Hub | Dispatch | Gemini (code) | 27,316 | 45s | ✅ | Task 1 complete |
| 14:32:15 | Hub | Dispatch | Codex (test) | 8,072 | 23s | ❌ | Missing context |
| 14:33:40 | Hub | Retry | Codex (test) | 12,105 | 31s | ✅ | Context expanded |
| 14:34:20 | Hub | Review | Gemini (review) | 15,230 | 28s | ✅ | Approved |
| 14:35:00 | Hub | Complete | - | - | - | ✅ | All tasks done |

## Totals
| Tool | Dispatches | Tokens | Failures | Retries |
|------|------------|--------|----------|---------|
| Gemini CLI | 2 | 42,546 | 0 | 0 |
| Codex CLI | 2 | 20,177 | 1 | 1 |
| Subagents | 1 | 1,247 | 0 | 0 |
| **Total** | **5** | **63,970** | **1** | **1** |
```

### Toggle Mechanism

```bash
# Enable during plan
/maestro plan "goal" --log=summary

# Enable during run
/maestro run --log=detailed

# Generate walkthrough after completion
/maestro report
```

### `/maestro report` Command

Generates a human-readable walkthrough from the execution log:

**Output includes:**
- Goal and plan summary
- Step-by-step execution narrative
- Token usage breakdown by tool/task
- Failures and how they were resolved
- Timing analysis
- Recommendations for protocol refinement

**Output location:** stdout or `--output=path/to/report.md`

## V2 Documentation Structure

### Feature Docs (installed via nexus-ai)

| Document | Purpose |
|----------|---------|
| `features/maestro/docs/README.md` | Overview, quick start |
| `features/maestro/docs/USER-GUIDE.md` | Detailed usage guide |
| `features/maestro/docs/TROUBLESHOOTING.md` | Common issues and fixes |
| `features/maestro/docs/SPOKE-CONTRACT.md` | Tool-agnostic spoke execution contract |
| `features/maestro/docs/STATE-FILE-SPEC.md` | `.ai/MAESTRO.md` format specification |

### Archived

| Location | Contents |
|----------|----------|
| `docs/maestro-v1/` | All v1 documentation (historical reference) |
