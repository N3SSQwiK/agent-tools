## ADDED Requirements

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

## MODIFIED Requirements

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
