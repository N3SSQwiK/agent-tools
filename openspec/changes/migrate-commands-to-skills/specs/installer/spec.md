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
- **Then** it uses glob pattern `features/<feature>/skills/*/SKILL.md`
- **And** treats each parent directory as a skill bundle

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

#### Scenario: SKILL.md validation
- **Given** a skill directory with SKILL.md
- **When** the installer processes the skill
- **Then** it validates the file exists
- **And** validates YAML frontmatter is parseable (if present)
- **And** validates `name` field contains only lowercase letters, numbers, and hyphens (if present)

#### Scenario: SKILL.md without frontmatter
- **Given** a skill directory with SKILL.md that has no YAML frontmatter
- **When** the installer processes the skill
- **Then** it proceeds with installation (frontmatter is optional)
- **And** the tool uses the directory name as the skill name

#### Scenario: Hook script validation
- **Given** a skill with files in `hooks/` directory
- **When** the installer copies the skill
- **Then** it verifies hook scripts have execute permissions
- **And** it sets execute permissions if missing (`chmod +x`)
- **And** it verifies each script starts with a shebang line (`#!`)
- **And** it logs a warning for scripts missing a shebang

### Requirement: Gemini Skills Enablement
The installer MUST verify Gemini CLI is functional before installing skills.

#### Scenario: Gemini binary not found
- **Given** the user selected Gemini CLI
- **When** the installer checks for `gemini` binary in PATH
- **And** the binary is not found
- **Then** the installer displays a warning that Gemini CLI must be installed separately
- **And** skips Gemini skill installation
- **And** proceeds with other selected tools

#### Scenario: Gemini skills list check
- **Given** the user selected Gemini CLI
- **And** `gemini` binary exists in PATH
- **When** the installer runs `gemini skills list`
- **And** the command succeeds (exit code 0)
- **Then** the installer proceeds with skill installation

#### Scenario: Gemini skills list fails
- **Given** the user selected Gemini CLI
- **When** the installer runs `gemini skills list`
- **And** the command fails (non-zero exit code)
- **Then** the installer displays a warning about Gemini configuration
- **And** attempts skill installation anyway (skills may still work)

#### Scenario: First-time Gemini skills user
- **Given** the user selected Gemini CLI
- **And** `~/.gemini/skills/` directory does not exist
- **When** proceeding to installation
- **Then** the installer creates the skills directory
- **And** displays an informational message about Gemini skill usage

#### Scenario: Gemini skills confirmation screen
- **Given** the user selected Gemini CLI and features with skills
- **When** progressing past feature selection
- **Then** the installer displays a confirmation screen explaining:
  - What skills are and how they work in Gemini
  - That skills will be installed to `~/.gemini/skills/`
  - How to invoke skills (`/skill-name` or via auto-activation)
- **And** user can proceed or skip Gemini installation

#### Scenario: User confirms Gemini installation
- **Given** the user is on the Gemini skills confirmation screen
- **When** the user confirms
- **Then** the installer proceeds with Gemini skill installation

#### Scenario: User skips Gemini
- **Given** the user is on the Gemini skills confirmation screen
- **When** the user declines
- **Then** the installer skips Gemini skill installation
- **And** proceeds with other selected tools

#### Scenario: Gemini not selected
- **Given** the user did not select Gemini CLI
- **When** running the installer
- **Then** the installer skips the Gemini skills enablement screen

### Requirement: Legacy Installation Cleanup
The installer MUST detect and automatically clean up previous Nexus-AI installations.

#### Scenario: No legacy files detected
- **Given** no Nexus-AI files exist at deprecated locations
- **When** running the installer
- **Then** the installer proceeds normally without cleanup

#### Scenario: Legacy Claude commands detected
- **Given** files exist at `~/.claude/commands/maestro-*.md` or `continuity.md`
- **When** the installer scans for legacy installations
- **Then** it identifies these as Nexus-AI v1.x files
- **And** removes them automatically during installation

#### Scenario: Legacy Gemini extensions detected
- **Given** directories exist at `~/.gemini/extensions/maestro/` or `continuity/`
- **When** the installer scans for legacy installations
- **Then** it identifies these as Nexus-AI v1.x extensions
- **And** removes them automatically during installation

#### Scenario: Legacy Codex prompts detected
- **Given** files exist at `~/.codex/prompts/maestro-*.md` or `continuity.md`
- **When** the installer scans for legacy installations
- **Then** it identifies these as Nexus-AI v1.x files
- **And** removes them automatically during installation

#### Scenario: Cleanup summary
- **Given** legacy files were detected and removed
- **When** cleanup completes
- **Then** the installer displays a summary of removed files
- **And** proceeds with skills installation

#### Scenario: Cleanup failure
- **Given** the installer attempts to remove a legacy file
- **When** removal fails (permissions, etc.)
- **Then** the installer logs a warning
- **And** continues with remaining cleanup
- **And** proceeds with skills installation

#### Scenario: Custom files preserved
- **Given** user has custom files at `~/.claude/commands/my-custom-command.md`
- **When** the installer scans for legacy installations
- **Then** it does NOT remove custom files
- **And** only removes known Nexus-AI patterns

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
