# maestro-orchestration Specification Delta

## ADDED Requirements

### Requirement: Task Delegation Method
The system SHALL select the appropriate delegation mechanism based on hub and spoke tool capabilities.

#### Scenario: Claude Code self-delegation
- **WHEN** Claude Code is the hub and the assigned spoke is Claude Code
- **THEN** the hub SHALL use the Task tool for delegation

#### Scenario: Claude Code cross-tool delegation
- **WHEN** Claude Code is the hub and the assigned spoke is Gemini CLI or Codex CLI
- **THEN** the hub SHALL use CLI spawn for delegation

#### Scenario: Gemini CLI delegation
- **WHEN** Gemini CLI is the hub
- **THEN** all task delegation SHALL use CLI spawn regardless of the assigned spoke

#### Scenario: Codex CLI delegation
- **WHEN** Codex CLI is the hub
- **THEN** all task delegation SHALL use CLI spawn regardless of the assigned spoke

#### Scenario: Task tool guardrails
- **WHEN** using Task tool for delegation
- **THEN** the subagent SHALL receive the same guardrails prompt as CLI-spawned spokes
