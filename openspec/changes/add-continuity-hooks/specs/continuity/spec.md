# continuity Specification Delta

## ADDED Requirements

### Requirement: Session Start Hook (Claude Code & Gemini CLI)
When a session starts, the tool MUST automatically check for `.ai/CONTINUITY.md` and present its contents to the user via a hook mechanism.

#### Scenario: Session start with continuity file present
- **Given** a project with `.ai/CONTINUITY.md` containing previous session state
- **And** the `SessionStart` hook is configured
- **When** Claude Code or Gemini CLI starts a new session
- **Then** the hook reads `.ai/CONTINUITY.md`
- **And** injects the contents into the AI's context via `additionalContext`
- **And** prompts the user to proceed with the suggested prompt or work on something else

#### Scenario: Session start without continuity file
- **Given** a project without `.ai/CONTINUITY.md`
- **When** Claude Code or Gemini CLI starts a new session
- **Then** the hook exits silently without injecting any context

#### Scenario: Hook matcher targets startup only
- **Given** the `SessionStart` hook configuration
- **When** a session resumes (not fresh start)
- **Then** the hook does not fire (context already loaded)

### Requirement: Milestone Detection Hook (Claude Code & Gemini CLI)
After executing shell commands that indicate milestone completion, the tool MUST suggest updating the continuity file via a hook mechanism.

#### Scenario: PR merge detected
- **Given** a `PostToolUse` hook configured for Bash/Shell commands
- **When** the user executes `gh pr merge <number>`
- **Then** the hook detects the milestone pattern
- **And** injects a suggestion to run `/continuity`

#### Scenario: PR creation detected
- **Given** a `PostToolUse` hook configured for Bash/Shell commands
- **When** the user executes `gh pr create`
- **Then** the hook detects the milestone pattern
- **And** injects a suggestion to run `/continuity`

#### Scenario: Push to main branch detected
- **Given** a `PostToolUse` hook configured for Bash/Shell commands
- **When** the user executes `git push origin main` or `git push origin master`
- **Then** the hook detects the milestone pattern
- **And** injects a suggestion to run `/continuity`

#### Scenario: Non-milestone command ignored
- **Given** a `PostToolUse` hook configured for Bash/Shell commands
- **When** the user executes a non-milestone command like `ls` or `git status`
- **Then** the hook does not inject any suggestion

### Requirement: Turn-Based Reminder (Codex CLI)
Codex CLI MUST remind users to update continuity after extended work sessions using the notify mechanism.

#### Scenario: Turn threshold reached
- **Given** the Codex notify script is configured
- **And** the user has completed 100 agent turns in a session
- **When** the 100th `agent-turn-complete` event fires
- **Then** a desktop notification appears: "You've been working a while. Consider running /continuity to save context."
- **And** the turn counter resets to 0

#### Scenario: Turn count persists within session
- **Given** the Codex notify script is configured
- **And** the user has completed 50 agent turns
- **When** the session continues
- **Then** the turn count continues from 50 (not reset)

#### Scenario: Turn count resets on new session
- **Given** the Codex notify script is configured
- **And** a previous session reached 80 turns
- **When** a new session starts
- **Then** the turn count resets to 0

### Requirement: Git Hook Milestone Detection (Codex CLI)
The installer MUST provide git hooks that detect semantic milestones and remind users to update continuity when manually installed.

#### Scenario: Post-merge notification
- **Given** the git `post-merge` hook is installed
- **When** a branch merge completes
- **Then** a desktop notification appears suggesting to run `/continuity`

#### Scenario: Git hooks are optional
- **Given** a user has not installed the git hooks
- **When** they complete a merge or push
- **Then** no notification appears (hooks are opt-in)

## MODIFIED Requirements

### Requirement: Cross-Tool Continuity (MODIFIED)
Session state written by one tool MUST be readable by all other supported tools. **Additionally, tools with hook support MUST automatically present continuity state at session start.**

#### Scenario: Claude reads Gemini-created continuity automatically
- **Given** Gemini CLI created `.ai/CONTINUITY.md` with Source "Gemini CLI"
- **And** Claude Code's `SessionStart` hook is configured
- **When** Claude Code starts a session in the same project
- **Then** Claude automatically presents the continuity state via the hook
- **And** the user is prompted to proceed or adjust
