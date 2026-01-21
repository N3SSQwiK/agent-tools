# Installer Specification Delta

## REMOVED Requirements

### Requirement: Multi-Command File Installation
**Reason**: Replaced by unified skill installation
**Migration**: Skills provide same functionality with additional features

### Requirement: Claude Code Installation (command scenarios)
**Reason**: Commands deprecated in favor of skills
**Migration**: Use skill installation instead

### Requirement: Gemini CLI Installation (extension scenarios)
**Reason**: Extensions deprecated in favor of skills
**Migration**: Use skill installation instead

### Requirement: Codex CLI Installation (prompt scenarios)
**Reason**: Prompts deprecated in favor of skills
**Migration**: Use skill installation instead

## MODIFIED Requirements

### Requirement: Feature Directory Structure
Each feature MUST follow a standard directory structure under `features/<feature>/`.

#### Scenario: Valid feature structure
- **Given** a feature named `<feature>`
- **When** the installer scans for features
- **Then** it expects the following structure:
  ```
  features/<feature>/
  ├── skills/                        # Unified skills (all tools)
  │   └── <skill-name>/
  │       ├── SKILL.md               # Required: Instructions + frontmatter
  │       ├── hooks/                 # Optional: Hook scripts
  │       ├── templates/             # Optional: Output templates
  │       └── scripts/               # Optional: Helper scripts
  ├── claude/
  │   └── CLAUDE.md                  # Global instructions (optional)
  ├── gemini/
  │   └── GEMINI.md                  # Global instructions (optional)
  └── codex/
      └── AGENTS.md                  # Global instructions (optional)
  ```

#### Scenario: Feature with single skill
- **Given** a feature with one skill
- **When** the installer processes the feature
- **Then** it finds a directory at `skills/<skill-name>/` containing `SKILL.md`

#### Scenario: Feature with multiple skills
- **Given** a feature with multiple skills (e.g., `maestro-plan`, `maestro-run`)
- **When** the installer processes the feature
- **Then** it finds all directories under `skills/` containing `SKILL.md`

#### Scenario: Empty skills directory
- **Given** a feature with no skill directories
- **When** the installer processes that feature
- **Then** it skips skill installation for that feature without error

## ADDED Requirements

### Requirement: Skill Installation
The installer MUST install skills by copying skill directories to tool-specific locations.

#### Scenario: Skill directory copy
- **Given** a feature with skills in `features/<feature>/skills/<skill-name>/`
- **When** installing for any supported tool
- **Then** the installer copies the entire skill directory preserving structure

#### Scenario: Claude skill installation
- **Given** a feature with skills
- **When** installing for Claude Code
- **Then** the installer copies skill directories to `~/.claude/skills/<skill-name>/`

#### Scenario: Gemini skill installation
- **Given** a feature with skills
- **When** installing for Gemini CLI
- **Then** the installer copies skill directories to `~/.gemini/skills/<skill-name>/`

#### Scenario: Codex skill installation
- **Given** a feature with skills
- **When** installing for Codex CLI
- **Then** the installer copies skill directories to `~/.codex/skills/<skill-name>/`

#### Scenario: Skill directory creation
- **Given** the tool's skills directory does not exist
- **When** installing skills
- **Then** the installer creates the directory with appropriate permissions

#### Scenario: Existing skill replacement
- **Given** a skill directory already exists at the destination
- **When** re-running the installer
- **Then** the installer overwrites the skill directory with current content

#### Scenario: Skill supporting files
- **Given** a skill with supporting directories (`hooks/`, `templates/`, `scripts/`)
- **When** installing the skill
- **Then** all supporting directories and files are copied preserving structure

### Requirement: Gemini Skills Enablement
The installer MUST prompt users to enable Gemini CLI skills when Gemini is selected.

#### Scenario: Gemini selected with skills
- **Given** the user selected Gemini CLI and features with skills
- **When** reaching the installation phase
- **Then** the installer displays a confirmation screen for skills enablement

#### Scenario: User confirms enablement
- **Given** the user is on the Gemini skills confirmation screen
- **When** the user confirms enablement
- **Then** the installer runs `gemini skills enable --global`
- **And** proceeds with installation

#### Scenario: User declines enablement
- **Given** the user is on the Gemini skills confirmation screen
- **When** the user declines enablement
- **Then** the installer proceeds with installation without enabling skills
- **And** notifies user that skills may not auto-activate

#### Scenario: Skills already enabled
- **Given** Gemini CLI skills are already enabled globally
- **When** running the installer with Gemini selected
- **Then** the installer skips the enablement confirmation screen

#### Scenario: Enablement failure
- **Given** the user confirms skills enablement
- **When** the `gemini skills enable --global` command fails
- **Then** the installer displays a warning notification
- **And** proceeds with installation

#### Scenario: Gemini not selected
- **Given** the user did not select Gemini CLI
- **When** running the installer
- **Then** the installer skips the Gemini skills enablement screen

### Requirement: TUI Installation Flow
The installer MUST guide users through a multi-screen wizard flow.

#### Scenario: Screen progression
- **Given** user launches the installer
- **When** progressing through the wizard
- **Then** screens appear in order: Welcome → Tools → Features → Gemini Skills (conditional) → Installing → Done

#### Scenario: Gemini skills screen conditional
- **Given** user selected Gemini CLI and features with skills
- **When** progressing past feature selection
- **Then** the Gemini Skills enablement screen appears before Installing
