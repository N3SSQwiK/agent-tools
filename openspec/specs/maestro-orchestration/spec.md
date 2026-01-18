# maestro-orchestration Specification

## Purpose
Maestro is a hub-and-spoke multi-agent orchestration system that enables coordinated work across multiple AI CLI tools (Claude Code, Gemini CLI, Codex CLI). It provides planning, challenge, execution, review, and reporting phases with quality gates and failure handling.
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
- **THEN** the hub dispatches the task to the assigned specialist using the correct CLI dispatch pattern with all required flags

#### Scenario: Precondition validation
- **WHEN** delegating a task
- **THEN** the hub validates AAVSR preconditions (Atomic, Authority, Verifiable, Scope, Risk)

#### Scenario: Result collection
- **WHEN** a specialist completes a task
- **THEN** the hub collects, normalizes, and records the result in `.ai/MAESTRO.md`

#### Scenario: Specific task execution
- **WHEN** user invokes `/maestro run <task-id>`
- **THEN** the hub executes only the specified task

#### Scenario: Permission recovery
- **WHEN** a spoke returns a `permission_denials` response
- **THEN** the hub MAY use the provided file paths and content to complete the write operation directly

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

### Requirement: CLI Dispatch Patterns
The system SHALL use specific CLI dispatch patterns with required flags for each spoke tool.

#### Scenario: Claude Code dispatch
- **WHEN** hub dispatches a task to Claude Code
- **THEN** the command SHALL include `--output-format json` and `--dangerously-skip-permissions` flags

#### Scenario: Gemini CLI dispatch
- **WHEN** hub dispatches a task to Gemini CLI
- **THEN** the command SHALL include `-y` and `-o json` flags

#### Scenario: Codex CLI dispatch
- **WHEN** hub dispatches a task to Codex CLI
- **THEN** the command SHALL include `--full-auto` and `--json` flags

#### Scenario: Dispatch pattern visibility
- **WHEN** dispatch patterns are documented in command files
- **THEN** they SHALL be marked with prominent callouts indicating all flags are required

### Requirement: Interactive Logging Selection
The system SHALL provide interactive logging level selection during plan approval.

#### Scenario: Logging menu presentation
- **WHEN** user approves a plan via `/maestro plan`
- **THEN** the hub presents a logging level menu with options: None, Summary, Detailed

#### Scenario: Logging level application
- **WHEN** user selects a logging level
- **THEN** the hub applies that level to the orchestration (creating `.ai/MAESTRO-LOG.md` if not None)

#### Scenario: Default logging behavior
- **WHEN** user dismisses or skips the logging menu
- **THEN** the hub defaults to no logging (current behavior preserved)

### Requirement: Structured User Decision Menus
The system SHALL present all user decision points as structured numbered menus for UX consistency.

#### Scenario: Plan approval menu
- **WHEN** hub presents a plan for user approval
- **THEN** the hub displays a numbered menu with options: Approve, Modify, Reject

#### Scenario: Challenge response menu
- **WHEN** hub presents challenge feedback to user
- **THEN** the hub displays a numbered menu with options: Revise, Proceed, Reject, Other

#### Scenario: Review response menu
- **WHEN** hub presents review feedback to user
- **THEN** the hub displays a numbered menu with options: Accept, Revise, Flag, Other

#### Scenario: Menu format consistency
- **WHEN** any decision menu is presented
- **THEN** each option SHALL include a short description of its effect

#### Scenario: Other option behavior
- **WHEN** user selects "Other" from a menu that includes it
- **THEN** the hub accepts free-text input for custom responses

### Requirement: Spoke Guardrails
The system SHALL include guardrails in task handoff prompts to constrain spoke behavior.

#### Scenario: Guardrails in handoff
- **WHEN** hub builds a task handoff for a spoke
- **THEN** the handoff SHALL include a Guardrails section with strict rules

#### Scenario: Guardrail content
- **WHEN** guardrails are included in handoff
- **THEN** they SHALL prohibit: modifying unlisted files, running exploratory commands, installing dependencies without request, expanding scope, and improvising when blocked

