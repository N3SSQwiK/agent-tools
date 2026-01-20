# maestro-orchestration Specification Delta

## ADDED Requirements

### Requirement: Spoke Availability Detection
The system SHALL detect and confirm available spoke tools before creating an orchestration plan.

#### Scenario: Hub identification
- **WHEN** user invokes `/maestro plan`
- **THEN** the system identifies the current tool as the hub

#### Scenario: Spoke detection
- **WHEN** the plan command starts
- **THEN** the system detects which other CLI tools are installed (via `which` or equivalent)

#### Scenario: Availability confirmation
- **WHEN** spokes are detected
- **THEN** the system presents a confirmation menu showing detected tools and allowing user adjustment

#### Scenario: Availability storage
- **WHEN** user confirms available tools
- **THEN** the system stores the hub and spoke list in `.ai/MAESTRO.md` under "Available Tools" section

#### Scenario: Tool not detected
- **WHEN** a tool is not detected but user selects it anyway
- **THEN** the system allows the selection with a warning that dispatch may fail

## MODIFIED Requirements

### Requirement: Plan Command
The system SHALL provide a `/maestro plan` command that decomposes a high-level goal into atomic tasks.

#### Scenario: Spoke detection at start
- **WHEN** user invokes `/maestro plan <goal>`
- **THEN** the hub first detects and confirms available spoke tools before proceeding

#### Scenario: Goal decomposition
- **WHEN** available tools are confirmed
- **THEN** the hub analyzes the goal and generates a task decomposition with dependencies and specialist assignments

#### Scenario: Task assignment constraint
- **WHEN** assigning tools to tasks
- **THEN** the hub only assigns tasks to confirmed available tools

#### Scenario: User approval checkpoint
- **WHEN** the plan is generated
- **THEN** the hub presents the plan to the user for approval before execution

#### Scenario: Plan persistence
- **WHEN** user approves the plan
- **THEN** the hub writes the plan to `.ai/MAESTRO.md` including the Available Tools section

### Requirement: Challenge Command
The system SHALL provide a `/maestro challenge` command that has spokes challenge the hub's plan before execution.

#### Scenario: Interactive tool selection
- **WHEN** user invokes `/maestro challenge` without `--tool` or `--all` flags
- **THEN** the hub presents an interactive menu for selecting the challenger tool

#### Scenario: Menu shows available tools only
- **WHEN** the tool selection menu is displayed
- **THEN** it shows only tools listed in the Available Tools section of `.ai/MAESTRO.md`

#### Scenario: Flag bypass for challenge
- **WHEN** user invokes `/maestro challenge` with `--tool=<name>` or `--all` flag
- **THEN** the interactive menu is skipped and the specified tool(s) are used

#### Scenario: Plan dispatch for challenge
- **WHEN** user selects a challenger tool (via menu or flag)
- **THEN** the hub dispatches the plan summary to the selected spoke(s) for analysis

#### Scenario: Challenge collection
- **WHEN** spokes analyze the plan
- **THEN** they return challenges including assumption issues, missing dependencies, scope concerns, and alternative approaches

#### Scenario: Plan revision
- **WHEN** hub receives challenges
- **THEN** the hub incorporates feedback and revises the plan before user approval

### Requirement: Review Command
The system SHALL provide a `/maestro review` command that has a different spoke review work before the hub accepts it.

#### Scenario: Interactive reviewer selection
- **WHEN** user invokes `/maestro review` without `--tool` flag
- **THEN** the hub presents an interactive menu for selecting the reviewer tool

#### Scenario: Menu shows available tools only
- **WHEN** the reviewer selection menu is displayed
- **THEN** it shows only tools listed in the Available Tools section of `.ai/MAESTRO.md`

#### Scenario: Flag bypass for review
- **WHEN** user invokes `/maestro review` with `--tool=<name>` flag
- **THEN** the interactive menu is skipped and the specified tool is used

#### Scenario: Result dispatch for review
- **WHEN** user selects a reviewer tool (via menu or flag)
- **THEN** the hub dispatches the result to the selected spoke for review

#### Scenario: Review collection
- **WHEN** reviewing spoke analyzes the result
- **THEN** they return a review including approval status, requested changes, flagged issues, and quality assessment

#### Scenario: Review decision
- **WHEN** hub receives the review
- **THEN** the hub decides to accept the result, request revision from the original spoke, or escalate to user
