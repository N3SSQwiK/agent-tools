## ADDED Requirements

### Requirement: Hub Task Classification

The system SHALL classify tasks as hub-only or delegatable before dispatch to ensure interactive tasks remain at the hub where user input is available.

#### Scenario: Interactive command detection

- **WHEN** hub evaluates a task for dispatch
- **AND** the task involves commands known to require interactive input (e.g., `npm create`, `npm init`, `yarn create`, `npx create-*`, `git rebase -i`)
- **THEN** the hub SHALL classify the task as hub-only

#### Scenario: Dependency installation detection

- **WHEN** hub evaluates a task for dispatch
- **AND** the task involves installing packages or dependencies that the user has not pre-approved
- **THEN** the hub SHALL classify the task as hub-only

#### Scenario: Credential or sensitive input detection

- **WHEN** hub evaluates a task for dispatch
- **AND** the task may require credentials, API keys, or other sensitive user input
- **THEN** the hub SHALL classify the task as hub-only

#### Scenario: Hub-only task execution

- **WHEN** a task is classified as hub-only
- **THEN** the hub SHALL execute the task directly with user interaction available
- **AND** the hub SHALL NOT dispatch the task to a spoke

#### Scenario: Delegatable task dispatch

- **WHEN** a task is classified as delegatable
- **AND** the task is non-interactive, well-scoped, and verifiable
- **THEN** the hub MAY dispatch the task to an appropriate spoke

#### Scenario: Classification visibility in plan

- **WHEN** hub generates or displays a plan
- **THEN** each task SHALL indicate its classification (hub-only or delegatable)
- **AND** hub-only tasks SHALL be visually distinguished (e.g., `[HUB]` marker)

#### Scenario: User override for classification

- **WHEN** user explicitly requests a hub-only task be delegated
- **THEN** the hub SHALL warn the user about potential interactive blocking
- **AND** the hub MAY proceed with delegation if user confirms

## MODIFIED Requirements

### Requirement: Challenge Command

The system SHALL provide a `/maestro challenge` command that has spokes challenge the hub's plan before execution.

#### Scenario: Plan dispatch for challenge

- **WHEN** user invokes `/maestro challenge`
- **THEN** the hub dispatches the plan summary to one or more spokes for analysis

#### Scenario: Challenge collection

- **WHEN** spokes analyze the plan
- **THEN** they return challenges including assumption issues, missing dependencies, scope concerns, alternative approaches, and task classification issues (tasks marked delegatable that should be hub-only)

#### Scenario: Plan revision

- **WHEN** hub receives challenges
- **THEN** the hub incorporates feedback and revises the plan before user approval
