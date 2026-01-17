# Spoke Contract

## Overview

This document defines the execution contract for Maestro spokes. A spoke is any AI tool (Claude Code, Gemini CLI, Codex CLI) receiving delegated work from a hub.

## Core Principles

1. **Atomic Tasks** - Each task has single responsibility, one clear outcome
2. **Hub Injects Context** - Spoke receives only what it needs, no state file access
3. **Structured I/O** - Handoff and result formats are enforced
4. **Tool-Agnostic** - Same contract applies regardless of which tool is the spoke

## Task Handoff Template

Hub sends this format when delegating work to a spoke:

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

### Field Requirements

| Field | Required | Description |
|-------|----------|-------------|
| Task | Yes | One sentence, imperative form (e.g., "Implement JWT token validation") |
| Context | Yes | Files, patterns, decisions relevant to this task only |
| Success Criteria | Yes | Minimum one testable criterion |
| Constraints | No | Scope boundaries (e.g., "Do not modify existing auth flow") |
| Output Format | No | Explicit structure if spoke should return specific format |

## Result Submission Template

Spoke returns this format after completing (or failing) a task:

```markdown
## Status
[success | partial | failed | blocked]

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

### Status Values

| Status | Meaning | Hub Action |
|--------|---------|------------|
| `success` | All criteria satisfied | Accept, mark task done |
| `partial` | Some criteria met, work incomplete | Evaluate, possibly retry |
| `failed` | Could not complete task | Trigger retry ladder |
| `blocked` | External dependency prevents progress | Escalate to user |

### Field Requirements

| Field | Required | Description |
|-------|----------|-------------|
| Status | Yes | One of the four status values |
| Summary | Yes | Brief outcome description |
| Changes | Yes | List of files created/modified or actions taken |
| Verification | Yes | Checklist mapping to success criteria |
| Issues | Yes | Blockers or "None" |

## Predefined Specialists

| Specialist | Role | Typical Tasks |
|------------|------|---------------|
| `code` | Implementation | Write code, refactor, fix bugs |
| `review` | Quality assurance | Code review, security audit, style check |
| `test` | Validation | Write tests, run test suites, verify behavior |
| `research` | Discovery | Search codebase, read docs, answer questions |

### Specialist Capabilities

#### `code` Specialist
- Write new code following existing patterns
- Refactor existing code
- Fix bugs with minimal changes
- Implement features based on specifications

**Not for:** Architectural decisions, security-critical logic, user-facing communication

#### `review` Specialist
- Code review for quality, bugs, style
- Security audit for vulnerabilities
- Pattern compliance checking
- Documentation review

**Not for:** Writing code, making changes (review only)

#### `test` Specialist
- Write unit tests
- Write integration tests
- Run test suites and report results
- Verify behavior against specifications

**Not for:** Implementation changes (tests only)

#### `research` Specialist
- Search codebase for patterns
- Read documentation
- Answer questions about existing code
- Identify relevant files and dependencies

**Not for:** Making changes (research only)

## Tool-Specific Invocation

### Gemini CLI

```bash
gemini -p "<handoff prompt>" -y -o json
```

**Token Efficiency:** Use `@path/to/file` for file references (9.2x more efficient than inline content).

**Example:**
```bash
gemini -p "## Task
Implement JWT token validation in @src/auth/jwt.ts

## Context
Existing auth patterns in @src/auth/session.ts

## Success Criteria
- [ ] Validates JWT signature
- [ ] Returns decoded payload on success
- [ ] Returns null on invalid token

## Output Format
Return result as markdown with Status, Summary, Changes, Verification, Issues sections" -y -o json
```

### Codex CLI

```bash
codex exec "<handoff prompt>" --full-auto --json
```

**Structured Output:**
```bash
codex exec "<handoff prompt>" --full-auto --output-schema ./result-schema.json
```

**Full Access (trusted environments only):**
```bash
codex exec "<handoff prompt>" --full-auto --json --sandbox danger-full-access
```

**Note:** Codex operates in full-auto mode, suitable for well-defined atomic tasks.

**Example:**
```bash
codex exec "## Task
Write unit tests for JWT validation

## Context
Implementation at src/auth/jwt.ts
Test patterns in tests/auth/session.test.ts

## Success Criteria
- [ ] Tests valid token case
- [ ] Tests expired token case
- [ ] Tests malformed token case

## Output Format
Return result as markdown with Status, Summary, Changes, Verification, Issues sections" --full-auto --json
```

### Claude Code

```bash
claude -p "<handoff prompt>" --output-format json
```

**Full Automation (trusted environments only):**
```bash
claude -p "<handoff prompt>" --output-format json --dangerously-skip-permissions
```

**Useful flags:**
- `--max-turns N` - Limit agentic turns
- `--max-budget-usd N` - Set cost ceiling
- `--no-session-persistence` - Stateless execution

**Example:**
```bash
claude -p "## Task
Review authentication implementation for security issues

## Context
Implementation at src/auth/jwt.ts
Session handling in src/auth/session.ts

## Success Criteria
- [ ] No hardcoded secrets
- [ ] Token expiration handled
- [ ] Input validation present

## Output Format
Return result as markdown with Status, Summary, Changes, Verification, Issues sections" --output-format json
```

## Precondition Checks (AAVSR)

Before dispatching, hub validates task against:

| Check | Question | Failure Action |
|-------|----------|----------------|
| **A**tomic | Single responsibility, one clear outcome? | Decompose further |
| **A**uthority | Specialist has capability to complete? | Reassign specialist |
| **V**erifiable | Success criteria are testable? | Add concrete criteria |
| **S**cope | Fits within task boundaries? | Add constraints |
| **R**isk | Acceptable failure impact? | Add safeguards |

## Quality Gates

Before accepting spoke results, hub validates:

1. **Format Compliance** - Result matches submission template
2. **Criteria Satisfaction** - All success criteria checked
3. **Scope Adherence** - No out-of-scope changes
4. **Integration Check** - Changes don't break existing functionality

Failed gates trigger retry ladder.

## Retry Ladder

When task fails, hub escalates through:

1. **Immediate Retry** - Transient failures (network, rate limit)
2. **Context Expansion** - Add more context and retry
3. **Task Decomposition** - Break into smaller subtasks
4. **User Escalation** - Request human intervention

## Cost Management

**User Responsibility:** Token and cost management is the user's responsibility. Each CLI tool has its own billing model (subscription or API-based), and users should configure limits appropriate to their setup.

**Available Controls:**
- **Claude Code:** `--max-turns N`, `--max-budget-usd N`
- **Gemini CLI:** Managed via Google Cloud billing
- **Codex CLI:** Managed via OpenAI billing settings

**Guidance for Complex Tasks:**
- Start with smaller tasks to calibrate cost expectations
- Use `/maestro plan` with `--log=summary` to track token usage patterns
- Review `.ai/MAESTRO-LOG.md` after orchestration to inform future budgeting

## Timeout Handling (Exit 124)

Timeout does not always mean failure. Hub checks output completeness:

1. If output structurally complete → Accept as soft success
2. If output incomplete → Trigger retry with narrower scope
