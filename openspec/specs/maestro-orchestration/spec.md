# maestro-orchestration Specification

## Purpose
TBD - created by archiving change rebuild-maestro-orchestration. Update Purpose after archive.
## Requirements
### Requirement: Plan Command
The system SHALL provide a `/maestro plan` command that decomposes a high-level goal into atomic tasks.

#### Scenario: Goal decomposition
- **WHEN** user invokes `/maestro plan <goal>`
- **THEN** the hub analyzes the goal and generates a task decomposition with dependencies and specialist assignments

#### Scenario: User approval checkpoint
- **WHEN** the plan is generated
- **THEN** the hub presents the plan to the user for approval before execution

#### Scenario: Plan persistence
- **WHEN** user approves the plan
- **THEN** the hub writes the plan to `.ai/MAESTRO.md`

### Requirement: Challenge Command
The system SHALL provide a `/maestro challenge` command that has spokes challenge the hub's plan before execution.

#### Scenario: Plan dispatch for challenge
- **WHEN** user invokes `/maestro challenge`
- **THEN** the hub dispatches the plan summary to one or more spokes for analysis

#### Scenario: Challenge collection
- **WHEN** spokes analyze the plan
- **THEN** they return challenges including assumption issues, missing dependencies, scope concerns, and alternative approaches

#### Scenario: Plan revision
- **WHEN** hub receives challenges
- **THEN** the hub incorporates feedback and revises the plan before user approval

### Requirement: Run Command
The system SHALL provide a `/maestro run` command that executes approved plans.

#### Scenario: Plan loading
- **WHEN** user invokes `/maestro run`
- **THEN** the hub loads the plan from `.ai/MAESTRO.md`

#### Scenario: Task execution
- **WHEN** a task's dependencies are satisfied
- **THEN** the hub dispatches the task to the assigned specialist

#### Scenario: Precondition validation
- **WHEN** delegating a task
- **THEN** the hub validates AAVSR preconditions (Atomic, Authority, Verifiable, Scope, Risk)

#### Scenario: Result collection
- **WHEN** a specialist completes a task
- **THEN** the hub collects, normalizes, and records the result in `.ai/MAESTRO.md`

#### Scenario: Specific task execution
- **WHEN** user invokes `/maestro run <task-id>`
- **THEN** the hub executes only the specified task

### Requirement: Review Command
The system SHALL provide a `/maestro review` command that has a different spoke review work before the hub accepts it.

#### Scenario: Result dispatch for review
- **WHEN** user invokes `/maestro review` after a spoke completes a task
- **THEN** the hub dispatches the result to a different spoke for review

#### Scenario: Review collection
- **WHEN** reviewing spoke analyzes the result
- **THEN** they return a review including approval status, requested changes, flagged issues, and quality assessment

#### Scenario: Review decision
- **WHEN** hub receives the review
- **THEN** the hub decides to accept the result, request revision from the original spoke, or escalate to user

### Requirement: Status Command
The system SHALL provide a `/maestro status` command that displays orchestration state.

#### Scenario: Status display
- **WHEN** user invokes `/maestro status`
- **THEN** the hub displays the current goal, task statuses, blocking issues, and suggested actions

### Requirement: Report Command
The system SHALL provide a `/maestro report` command that generates a walkthrough from the execution log.

#### Scenario: Report generation
- **WHEN** user invokes `/maestro report` after orchestration completes
- **THEN** the hub generates a human-readable walkthrough from `.ai/MAESTRO-LOG.md`

#### Scenario: Report contents
- **WHEN** report is generated
- **THEN** it includes goal summary, step-by-step narrative, token usage breakdown, failure analysis, and timing

### Requirement: Execution Logging
The system SHALL support opt-in execution logging with configurable verbosity.

#### Scenario: Logging disabled by default
- **WHEN** user runs orchestration without `--log` flag
- **THEN** no execution log is created

#### Scenario: Summary logging
- **WHEN** user runs with `--log=summary`
- **THEN** hub logs actions, outcomes, token counts, and timing to `.ai/MAESTRO-LOG.md`

#### Scenario: Detailed logging
- **WHEN** user runs with `--log=detailed`
- **THEN** hub logs full prompts and outputs in addition to summary data

### Requirement: Hub-and-Spoke Architecture
The system SHALL support any AI tool (Claude Code, Gemini CLI, Codex CLI) as the orchestrating hub.

#### Scenario: Claude as hub
- **WHEN** user invokes `/maestro` commands in Claude Code
- **THEN** Claude acts as hub and can dispatch to Gemini CLI or Codex CLI

#### Scenario: Gemini as hub
- **WHEN** user invokes `/maestro` commands in Gemini CLI
- **THEN** Gemini acts as hub and can dispatch to Claude Code or Codex CLI

#### Scenario: Codex as hub
- **WHEN** user invokes `/maestro` commands in Codex CLI
- **THEN** Codex acts as hub and can dispatch to Claude Code or Gemini CLI

### Requirement: State File Management
The system SHALL maintain orchestration state in `.ai/MAESTRO.md`.

#### Scenario: State file creation
- **WHEN** user approves a plan via `/maestro plan`
- **THEN** the system creates or updates `.ai/MAESTRO.md` with the plan

#### Scenario: State file updates
- **WHEN** a task status changes during execution
- **THEN** the system updates `.ai/MAESTRO.md` to reflect current state

#### Scenario: Execution logging
- **WHEN** tasks are executed
- **THEN** the system appends to the execution log in `.ai/MAESTRO.md`

### Requirement: Structured Task Handoff
The system SHALL use a structured template for hub-to-spoke task delegation.

#### Scenario: Handoff format
- **WHEN** hub delegates a task to a spoke
- **THEN** the handoff includes: task description, context, success criteria, constraints, and expected output format

### Requirement: Structured Result Submission
The system SHALL use a structured template for spoke-to-hub result reporting.

#### Scenario: Result format
- **WHEN** spoke completes a task
- **THEN** the result includes: status, summary, changes made, verification outcomes, and any issues

### Requirement: Predefined Specialists
The system SHALL provide predefined specialist roles for common task types.

#### Scenario: Code specialist
- **WHEN** a task requires implementation, refactoring, or bug fixing
- **THEN** it can be assigned to the `code` specialist

#### Scenario: Review specialist
- **WHEN** a task requires code review, security audit, or style check
- **THEN** it can be assigned to the `review` specialist

#### Scenario: Test specialist
- **WHEN** a task requires writing tests, running test suites, or verification
- **THEN** it can be assigned to the `test` specialist

#### Scenario: Research specialist
- **WHEN** a task requires codebase search, documentation reading, or question answering
- **THEN** it can be assigned to the `research` specialist

### Requirement: Failure Handling
The system SHALL implement a retry ladder for failed tasks.

#### Scenario: Immediate retry
- **WHEN** a task fails due to transient error
- **THEN** the system retries immediately

#### Scenario: Context expansion retry
- **WHEN** immediate retry fails
- **THEN** the system adds more context and retries

#### Scenario: Task decomposition
- **WHEN** context expansion fails
- **THEN** the system attempts to break the task into smaller subtasks

#### Scenario: User escalation
- **WHEN** all retries fail
- **THEN** the system presents options to the user (clarify, reassign, mark blocked, abort)

### Requirement: Quality Gates
The system SHALL validate spoke results before accepting them.

#### Scenario: Format validation
- **WHEN** spoke returns a result
- **THEN** hub validates the result matches the expected schema

#### Scenario: Criteria validation
- **WHEN** result format is valid
- **THEN** hub validates success criteria are satisfied

#### Scenario: Scope validation
- **WHEN** criteria are met
- **THEN** hub validates no out-of-scope changes were made

#### Scenario: Gate failure handling
- **WHEN** quality gate fails
- **THEN** hub triggers retry ladder

