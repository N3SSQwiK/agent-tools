# Continuity Feature Spec Delta

## ADDED Requirements

### Requirement: Unified Continuity File Location
All AI tools (Claude Code, Gemini CLI, Codex CLI) MUST read and write session continuity state to a single shared file at `.ai/CONTINUITY.md` in the project root.

#### Scenario: Session start with unified file
- **Given** a project with `.ai/CONTINUITY.md` containing previous session state
- **When** any supported AI tool starts a session in that project
- **Then** the tool reads and displays the continuity state from `.ai/CONTINUITY.md`

#### Scenario: Continuity update writes to unified location
- **Given** a user runs the `/continuity` command in any supported tool
- **When** the user confirms they want to update the continuity
- **Then** the tool writes the new state to `.ai/CONTINUITY.md`
- **And** the Source field includes the tool name that made the update

### Requirement: Legacy File Migration
When the unified file does not exist but a legacy per-tool file does, the tool MUST offer to migrate the content.

#### Scenario: Migration from Claude legacy path
- **Given** `.ai/CONTINUITY.md` does not exist
- **And** `.claude/CONTINUITY.md` exists with content
- **When** Claude Code starts a session
- **Then** it displays the legacy content and asks "Migrate to unified location?"
- **And** if user confirms, copies content to `.ai/CONTINUITY.md`

#### Scenario: Migration from Gemini legacy path
- **Given** `.ai/CONTINUITY.md` does not exist
- **And** `.gemini/CONTINUITY.md` exists with content
- **When** Gemini CLI starts a session
- **Then** it displays the legacy content and asks "Migrate to unified location?"
- **And** if user confirms, copies content to `.ai/CONTINUITY.md`

#### Scenario: Migration from Codex legacy path
- **Given** `.ai/CONTINUITY.md` does not exist
- **And** `.codex/CONTINUITY.md` exists with content
- **When** Codex CLI starts a session
- **Then** it displays the legacy content and asks "Migrate to unified location?"
- **And** if user confirms, copies content to `.ai/CONTINUITY.md`

### Requirement: Cross-Tool Continuity
Session state written by one tool MUST be readable by all other supported tools.

#### Scenario: Claude reads Gemini-created continuity
- **Given** Gemini CLI created `.ai/CONTINUITY.md` with Source "Gemini CLI"
- **When** Claude Code starts a session in the same project
- **Then** Claude displays the continuity state including the Gemini source attribution

#### Scenario: Tool switching preserves context
- **Given** a user completes work using Claude Code and updates continuity
- **When** the user starts a new session using Codex CLI
- **Then** Codex displays the work completed in the Claude session
- **And** the user can continue from where Claude left off

### Requirement: Expanded Format Structure
The continuity file MUST use an expanded format (~500 tokens) with the following sections: Summary, Completed, In Progress, Blocked, Key Files, Context, Suggested Prompt, and Source.

#### Scenario: Full format structure on update
- **Given** a user runs `/continuity` and confirms an update
- **When** the tool writes the continuity file
- **Then** the file includes all required sections:
  - Summary (project-level context)
  - Completed (finished work items)
  - In Progress (active work)
  - Blocked (impediments or "None")
  - Key Files (relevant file paths)
  - Context (session-specific state)
  - Suggested Prompt (actionable continuation)
  - Source (tool name and UTC timestamp)

#### Scenario: Token budget allocation
- **Given** the tool is generating continuity content
- **When** it writes the file
- **Then** the total content is approximately 500 tokens
- **And** the Suggested Prompt section receives priority allocation (~120 tokens)

### Requirement: Suggested Prompt for Session Handoff
The continuity file MUST include an actionable Suggested Prompt that enables seamless session continuation.

#### Scenario: Suggested Prompt is actionable
- **Given** a continuity file with a Suggested Prompt section
- **When** a user starts a new session and views the continuity
- **Then** the Suggested Prompt contains specific next steps
- **And** the prompt can be copy-pasted to continue work immediately

#### Scenario: Suggested Prompt includes pending decisions
- **Given** work was paused with unresolved decisions
- **When** the tool writes the continuity file
- **Then** the Suggested Prompt explicitly mentions pending decisions
- **And** provides options or context needed to make the decision
