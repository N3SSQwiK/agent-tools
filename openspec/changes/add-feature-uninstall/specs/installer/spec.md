# installer Specification Delta

## ADDED Requirements

### Requirement: Feature Detection
The installer MUST detect which features are currently installed by checking the filesystem.

#### Scenario: Detect Claude Code installation
- **Given** the feature `continuity` was previously installed for Claude Code
- **When** the installer scans for installed features
- **Then** it checks for files matching `~/.claude/commands/continuity*.md`
- **And** reports `continuity` as installed for Claude Code if files exist

#### Scenario: Detect Gemini CLI installation
- **Given** the feature `maestro` was previously installed for Gemini CLI
- **When** the installer scans for installed features
- **Then** it checks for directory `~/.gemini/extensions/maestro/`
- **And** reports `maestro` as installed for Gemini CLI if directory exists

#### Scenario: Detect Codex CLI installation
- **Given** the feature `continuity` was previously installed for Codex CLI
- **When** the installer scans for installed features
- **Then** it checks for files matching `~/.codex/prompts/continuity*.md`
- **And** reports `continuity` as installed for Codex CLI if files exist

#### Scenario: No features installed
- **Given** no Nexus-AI features have been installed
- **When** the installer scans for installed features
- **Then** it returns an empty result
- **And** the uninstall flow shows "No features installed" message

### Requirement: Uninstall Mode Selection
The installer MUST allow users to choose between install and uninstall modes on the welcome screen.

#### Scenario: Mode selection on welcome
- **Given** user launches the installer
- **When** the welcome screen displays
- **Then** it shows two options: "Install features" and "Uninstall features"
- **And** user can navigate between options and select one

#### Scenario: Install mode selected
- **Given** user is on the welcome screen
- **When** user selects "Install features" and presses enter
- **Then** the installer proceeds to the existing ToolsScreen

#### Scenario: Uninstall mode selected
- **Given** user is on the welcome screen
- **When** user selects "Uninstall features" and presses enter
- **Then** the installer proceeds to the UninstallFeatureScreen

### Requirement: Uninstall Feature Selection
The installer MUST allow users to select which feature to uninstall from a list of detected installed features.

#### Scenario: Feature list display
- **Given** features `continuity` and `maestro` are installed
- **When** the UninstallFeatureScreen displays
- **Then** it shows both features with indication of which tools have them installed
- **And** user can navigate and select a single feature

#### Scenario: Feature selection
- **Given** user is on UninstallFeatureScreen with `continuity` highlighted
- **When** user presses enter
- **Then** the installer proceeds to UninstallToolsScreen for `continuity`

#### Scenario: No features to uninstall
- **Given** no features are detected as installed
- **When** the UninstallFeatureScreen displays
- **Then** it shows a message "No features installed"
- **And** only allows user to go back

### Requirement: Uninstall Tool Selection
The installer MUST allow users to select which tools to uninstall a feature from.

#### Scenario: Tool list display
- **Given** feature `continuity` is installed for Claude Code and Gemini CLI but not Codex CLI
- **When** the UninstallToolsScreen displays for `continuity`
- **Then** it shows all three tools
- **And** Claude Code and Gemini CLI are checkable (pre-selected)
- **And** Codex CLI is shown as "not installed" and not checkable

#### Scenario: Selective tool uninstall
- **Given** user is on UninstallToolsScreen for `continuity`
- **And** Claude Code and Gemini CLI are selected
- **When** user unchecks Gemini CLI and presses enter
- **Then** the uninstall queue contains only `continuity` for Claude Code

#### Scenario: Add another feature
- **Given** user is on UninstallToolsScreen
- **When** user presses the "Add another feature" action
- **Then** the current selection is added to the uninstall queue
- **And** user returns to UninstallFeatureScreen to select another feature

### Requirement: Uninstall Confirmation
The installer MUST show a confirmation screen before executing uninstalls.

#### Scenario: Confirmation display
- **Given** the uninstall queue contains `continuity` for Claude Code and `maestro` for Gemini CLI
- **When** the UninstallConfirmScreen displays
- **Then** it lists all pending uninstalls with specific file paths
- **And** shows a warning about CLI tools that should not be running

#### Scenario: Confirm uninstall
- **Given** user is on UninstallConfirmScreen
- **When** user presses enter to confirm
- **Then** the installer proceeds to UninstallingScreen

#### Scenario: Cancel uninstall
- **Given** user is on UninstallConfirmScreen
- **When** user presses escape to cancel
- **Then** no files are deleted
- **And** user returns to the previous screen

### Requirement: Claude Code Uninstallation
The installer MUST remove Claude Code feature files and update configuration on uninstall.

#### Scenario: Command file removal
- **Given** feature `maestro` is being uninstalled from Claude Code
- **And** files `maestro-plan.md`, `maestro-run.md` exist in `~/.claude/commands/`
- **When** uninstall executes
- **Then** all files matching `maestro*.md` in `~/.claude/commands/` are deleted

#### Scenario: Missing command files
- **Given** feature `continuity` is being uninstalled from Claude Code
- **And** the file `~/.claude/commands/continuity.md` does not exist
- **When** uninstall executes
- **Then** uninstall completes without error (silent skip)

#### Scenario: Config rebuild after uninstall
- **Given** `continuity` is uninstalled from Claude Code
- **And** `maestro` remains installed for Claude Code
- **When** uninstall completes
- **Then** `~/.claude/CLAUDE.md` managed block is rebuilt with only `maestro` content

### Requirement: Gemini CLI Uninstallation
The installer MUST remove Gemini CLI extensions and update configuration on uninstall.

#### Scenario: Extension directory removal
- **Given** feature `continuity` is being uninstalled from Gemini CLI
- **And** directory `~/.gemini/extensions/continuity/` exists
- **When** uninstall executes
- **Then** the entire `~/.gemini/extensions/continuity/` directory is deleted

#### Scenario: Extension enablement update
- **Given** feature `continuity` is being uninstalled from Gemini CLI
- **And** `extension-enablement.json` contains `{"continuity": true, "maestro": true}`
- **When** uninstall executes
- **Then** `extension-enablement.json` is updated to `{"maestro": true}`

#### Scenario: Config rebuild after uninstall
- **Given** `continuity` is uninstalled from Gemini CLI
- **When** uninstall completes
- **Then** `~/.gemini/GEMINI.md` managed block is rebuilt without `continuity` content

### Requirement: Codex CLI Uninstallation
The installer MUST remove Codex CLI prompt files and update configuration on uninstall.

#### Scenario: Prompt file removal
- **Given** feature `maestro` is being uninstalled from Codex CLI
- **And** files exist matching `~/.codex/prompts/maestro*.md`
- **When** uninstall executes
- **Then** all matching files are deleted

#### Scenario: Config rebuild after uninstall
- **Given** `maestro` is uninstalled from Codex CLI
- **When** uninstall completes
- **Then** `~/.codex/AGENTS.md` managed block is rebuilt without `maestro` content

### Requirement: Uninstall Progress Display
The installer MUST show progress during uninstallation.

#### Scenario: Progress indication
- **Given** multiple features are queued for uninstall
- **When** the UninstallingScreen displays
- **Then** it shows each uninstall step with status (pending, active, done)
- **And** updates in real-time as each step completes

#### Scenario: Completion transition
- **Given** all uninstall steps have completed
- **When** the final step finishes
- **Then** the installer automatically transitions to UninstallDoneScreen

### Requirement: Uninstall Completion
The installer MUST show a summary of completed uninstalls.

#### Scenario: Done screen display
- **Given** `continuity` was uninstalled from Claude Code and Gemini CLI
- **And** `maestro` was uninstalled from Codex CLI
- **When** the UninstallDoneScreen displays
- **Then** it shows a summary of all removed features and tools
- **And** user can exit by pressing enter or q

### Requirement: Convention-Based Uninstall
The installer MUST support uninstalling any feature that follows the standard naming conventions without requiring feature-specific uninstall logic.

#### Scenario: New feature uninstall without custom code
- **Given** a new feature `codesearch` is added to the FEATURES list
- **And** it follows the naming convention with files like `codesearch.md`, `codesearch-index.md`
- **When** the feature is installed and later uninstalled
- **Then** uninstall works automatically using the generic `{feature_id}*.md` pattern
- **And** no feature-specific uninstall code is required

#### Scenario: Multi-command feature detection
- **Given** feature `maestro` has multiple commands: `maestro-plan.md`, `maestro-run.md`, `maestro-status.md`
- **When** the installer detects installed features
- **Then** it finds `maestro` by matching the `maestro*.md` glob pattern
- **And** uninstall removes all matching files

#### Scenario: Convention enforcement
- **Given** a feature's command files do not follow the `{feature_id}*.md` naming convention
- **When** attempting to uninstall
- **Then** only files matching the convention are detected and removed
- **And** non-conforming files are the user's responsibility to manage

## MODIFIED Requirements

### Requirement: TUI Installation Flow (MODIFIED)
The installer MUST guide users through a multi-screen wizard flow. **The flow now branches based on install/uninstall mode selection.**

#### Scenario: Screen progression for install
- **Given** user launches the installer
- **And** selects "Install features" on the welcome screen
- **When** progressing through the wizard
- **Then** screens appear in order: Welcome → Tools → Features → Installing → Done

#### Scenario: Screen progression for uninstall
- **Given** user launches the installer
- **And** selects "Uninstall features" on the welcome screen
- **When** progressing through the wizard
- **Then** screens appear in order: Welcome → UninstallFeature → UninstallTools → UninstallConfirm → Uninstalling → UninstallDone
