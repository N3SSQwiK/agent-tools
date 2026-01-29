# installer Specification

## Purpose
Define the installation behavior for Nexus-AI features across Claude Code, Gemini CLI, and Codex CLI tools.
## Requirements
### Requirement: Feature Directory Structure
Each feature MUST follow a standard directory structure under `features/<feature>/`.

#### Scenario: Valid feature structure
- **Given** a feature named `<feature>`
- **When** the installer scans for features
- **Then** it expects the following structure:
  ```
  features/<feature>/
  ├── claude/
  │   └── CLAUDE.md              # Global instructions (optional)
  ├── gemini/
  │   └── GEMINI.md              # Global instructions (optional)
  ├── codex/
  │   └── AGENTS.md              # Global instructions (optional)
  └── skills/                    # Unified skills (all tools)
      └── <skill-name>/
          ├── SKILL.md           # Skill with YAML frontmatter
          └── templates/         # Optional supporting files
  ```

#### Scenario: Feature with single skill
- **Given** a feature with one skill directory
- **When** the installer processes the feature
- **Then** it finds `skills/<skill-name>/SKILL.md`

#### Scenario: Feature with multiple skills
- **Given** a feature with multiple skill directories (e.g., `maestro-plan`, `maestro-run`)
- **When** the installer processes the feature
- **Then** it finds all directories under `skills/` and installs each one

### Requirement: Skill Installation
The installer MUST install skills using clean directory replacement.

#### Scenario: Skill installation for any tool
- **Given** a feature with skills in `features/<feature>/skills/<skill-name>/`
- **When** installing for any tool
- **Then** the installer copies the entire skill directory to `~/.<tool>/skills/<skill-name>/`
- **And** uses `rmtree` + `copytree` for clean replacement (no ghost files)

#### Scenario: Skill directory creation
- **Given** `~/.<tool>/skills/` does not exist
- **When** installing skills
- **Then** the installer creates the directory with `mkdir(parents=True, exist_ok=True)`

#### Scenario: Skill already installed
- **Given** a skill directory already exists at the destination
- **When** re-running installation
- **Then** the installer removes the existing directory completely before copying

#### Scenario: Empty skills directory
- **Given** a feature with no skill directories in `skills/`
- **When** the installer processes that feature
- **Then** it skips skill installation without error

### Requirement: SKILL.md Validation
The installer MUST validate SKILL.md frontmatter before installation.

#### Scenario: Valid frontmatter
- **Given** a SKILL.md with YAML frontmatter containing `name` and `description`
- **When** the installer validates the skill
- **Then** validation passes with no warnings

#### Scenario: Missing SKILL.md
- **Given** a skill directory without a SKILL.md file
- **When** the installer validates the skill
- **Then** it logs a warning but still installs the directory

#### Scenario: Invalid name format
- **Given** a SKILL.md with `name` that is not kebab-case or exceeds 64 characters
- **When** the installer validates the skill
- **Then** it logs a warning (Codex silently skips skills with invalid frontmatter)

#### Scenario: Multi-line description
- **Given** a SKILL.md with a multi-line `description`
- **When** the installer validates the skill
- **Then** it logs a warning

#### Scenario: Missing frontmatter
- **Given** a SKILL.md without `---` delimited YAML frontmatter
- **When** the installer validates the skill
- **Then** it logs a warning

### Requirement: Legacy Installation Cleanup
The installer MUST detect and remove known Nexus-AI v1.x files during installation.

#### Scenario: No legacy files
- **Given** no v1.x files exist for a tool
- **When** running the installer
- **Then** cleanup completes with no removals

#### Scenario: Claude legacy files detected
- **Given** files matching known patterns exist in `~/.claude/commands/` (e.g., `continuity.md`, `maestro-plan.md`)
- **When** running the installer
- **Then** the installer removes all matching files

#### Scenario: Gemini legacy files detected
- **Given** directories matching known patterns exist in `~/.gemini/extensions/` (e.g., `continuity/`, `maestro/`)
- **When** running the installer
- **Then** the installer removes all matching directories and `extension-enablement.json`

#### Scenario: Codex legacy files detected
- **Given** files matching known patterns exist in `~/.codex/prompts/` (e.g., `continuity.md`, `maestro-run.md`)
- **When** running the installer
- **Then** the installer removes all matching files

#### Scenario: Cleanup summary
- **Given** legacy files were found and removed
- **When** cleanup completes
- **Then** the installer logs the count of removed files

#### Scenario: Permission error during cleanup
- **Given** a legacy file cannot be removed due to permissions
- **When** cleanup encounters the error
- **Then** the installer logs a warning and continues with remaining files

#### Scenario: Custom user files preserved
- **Given** a user has custom files in `~/.claude/commands/` that don't match known Nexus-AI patterns
- **When** running the installer
- **Then** those custom files are NOT removed

### Requirement: Managed Config Block Rebuild
The installer MUST rebuild the managed block from all selected features on each run, replacing any existing managed content.

#### Scenario: First installation
- **Given** the destination config file does not exist
- **When** installing selected features
- **Then** the installer creates the file with all feature configs in one block:
  ```markdown
  <!-- Nexus-AI:START -->
  [feature-a content]

  [feature-b content]
  <!-- Nexus-AI:END -->
  ```

#### Scenario: Re-installation replaces content
- **Given** the config file contains a managed block with old feature content
- **When** re-running the installer with updated feature configs
- **Then** the installer replaces the entire managed block with current content
- **And** stale content from previous versions is removed

#### Scenario: Feature removal
- **Given** a feature was previously installed
- **When** re-running the installer without that feature selected
- **Then** the feature's content is removed from the managed block

#### Scenario: Preserve user content
- **Given** the config file contains user content outside the managed block
- **When** running the installer
- **Then** the user content before and after the managed block is preserved

#### Scenario: Empty feature selection
- **Given** no features are selected for a tool
- **When** running the installer
- **Then** no managed block is written for that tool

#### Scenario: Tool directory does not exist
- **Given** the tool's config directory (e.g., `~/.claude`) does not exist
- **When** running the installer with that tool selected
- **Then** the installer creates the directory
- **And** proceeds with config and skill installation

### Requirement: Post-Install Notices
The installer MUST display tool-specific post-install guidance on the Done screen.

#### Scenario: Codex selected
- **Given** the user selected Codex CLI
- **When** installation completes
- **Then** the Done screen shows: "Codex CLI: Restart to discover new skills"

#### Scenario: Gemini selected
- **Given** the user selected Gemini CLI
- **When** installation completes
- **Then** the Done screen shows: "Gemini CLI: Skills auto-discovered on next invocation"

### Requirement: Feature Registration
Features MUST be registered in the installer's FEATURES list to be available for selection.

#### Scenario: Feature appears in TUI
- **Given** a feature registered with name, directory, description, and default state
- **When** user reaches the feature selection screen
- **Then** the feature appears with its description and selection state

#### Scenario: Feature default enabled
- **Given** a feature registered with `default=True`
- **When** user reaches the feature selection screen
- **Then** the feature is pre-selected

#### Scenario: Feature default disabled
- **Given** a feature registered with `default=False`
- **When** user reaches the feature selection screen
- **Then** the feature is not pre-selected

### Requirement: TUI Installation Flow
The installer MUST guide users through a multi-screen wizard flow.

#### Scenario: Screen progression
- **Given** user launches the installer
- **When** progressing through the wizard
- **Then** screens appear in order: Welcome → Tools → Features → Installing → Done

#### Scenario: Tool selection filters installation
- **Given** user selects specific tools on the Tools screen
- **When** installation runs
- **Then** only selected tools receive feature installations

#### Scenario: Feature selection filters installation
- **Given** user selects specific features on the Features screen
- **When** installation runs
- **Then** only selected features are installed

### Requirement: Installation Idempotency
Re-running the installer MUST be safe and produce consistent results.

#### Scenario: Skill already installed
- **Given** a skill directory already exists at the destination
- **When** re-running installation
- **Then** the installer removes and replaces the directory with current content

#### Scenario: Config already merged
- **Given** a feature's config is already in the managed block
- **When** re-running installation
- **Then** the content is not duplicated

#### Scenario: Directory already exists
- **Given** destination directories already exist
- **When** running installation
- **Then** the installer proceeds without error
