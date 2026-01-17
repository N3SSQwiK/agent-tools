# installer Specification

## Purpose
TBD - created by archiving change document-installer-spec. Update Purpose after archive.
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
  │   ├── CLAUDE.md              # Global instructions (optional)
  │   └── commands/
  │       └── <feature>[-*].md   # Slash command(s)
  ├── gemini/
  │   ├── GEMINI.md              # Global instructions (optional)
  │   └── extensions/<feature>/
  │       ├── gemini-extension.json
  │       └── commands/
  │           └── <feature>[-*].toml
  └── codex/
      ├── AGENTS.md              # Global instructions (optional)
      └── prompts/
          └── <feature>[-*].md   # Slash command(s)
  ```

#### Scenario: Feature with single command
- **Given** a feature with one command file per tool
- **When** the installer processes the feature
- **Then** it finds files named exactly `<feature>.md` or `<feature>.toml`

#### Scenario: Feature with multiple commands
- **Given** a feature with multiple command files (e.g., `<feature>-plan.md`, `<feature>-run.md`)
- **When** the installer processes the feature
- **Then** it finds all files matching `<feature>-*.md` or `<feature>-*.toml`

### Requirement: Multi-Command File Installation
The installer MUST support features with multiple command files using glob patterns.

#### Scenario: Claude multi-command installation
- **Given** a feature with commands: `<feature>-a.md`, `<feature>-b.md`, `<feature>-c.md`
- **When** installing for Claude Code
- **Then** the installer symlinks ALL files matching `features/<feature>/claude/commands/<feature>-*.md` to `~/.claude/commands/`

#### Scenario: Gemini multi-command installation
- **Given** a feature with commands: `<feature>-a.toml`, `<feature>-b.toml`
- **When** installing for Gemini CLI
- **Then** the installer copies ALL files matching the glob pattern to the extension's commands directory

#### Scenario: Codex multi-command installation
- **Given** a feature with prompts: `<feature>-a.md`, `<feature>-b.md`
- **When** installing for Codex CLI
- **Then** the installer symlinks ALL files matching `features/<feature>/codex/prompts/<feature>-*.md` to `~/.codex/prompts/`

#### Scenario: Empty command directory
- **Given** a feature with no command files in a tool directory
- **When** the installer processes that tool
- **Then** it skips command installation for that tool without error

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
- **Then** the installer skips the config write for that tool
- **And** notifies the user to install and run the CLI tool first

### Requirement: Claude Code Installation
The installer MUST install Claude Code features using file copies.

#### Scenario: Command file copy
- **Given** a feature with command files in `features/<feature>/claude/commands/`
- **When** installing for Claude Code
- **Then** the installer copies files from source to `~/.claude/commands/`

#### Scenario: Config installation
- **Given** a feature with `features/<feature>/claude/CLAUDE.md`
- **When** installing for Claude Code
- **Then** the installer merges content into `~/.claude/CLAUDE.md` managed block

#### Scenario: Directory creation
- **Given** `~/.claude/commands/` does not exist
- **When** installing for Claude Code
- **Then** the installer creates the directory with appropriate permissions

#### Scenario: Existing symlink replacement
- **Given** a symlink exists at the destination from a previous installation
- **When** re-running the installer
- **Then** the installer removes the symlink and creates a file copy

### Requirement: Gemini CLI Installation
The installer MUST install Gemini CLI features using file copies and extension enablement.

#### Scenario: Extension directory setup
- **Given** a feature with `features/<feature>/gemini/extensions/<feature>/`
- **When** installing for Gemini CLI
- **Then** the installer copies extension files to `~/.gemini/extensions/<feature>/`

#### Scenario: Extension manifest copy
- **Given** a feature with `gemini-extension.json`
- **When** installing for Gemini CLI
- **Then** the installer copies the manifest to the extension directory

#### Scenario: Extension enablement
- **Given** a feature being installed for Gemini CLI
- **When** installation completes
- **Then** the installer updates `~/.gemini/extensions/enabled.json` to include `"<feature>": true`

#### Scenario: Config installation
- **Given** a feature with `features/<feature>/gemini/GEMINI.md`
- **When** installing for Gemini CLI
- **Then** the installer merges content into `~/.gemini/GEMINI.md` managed block

### Requirement: Codex CLI Installation
The installer MUST install Codex CLI features using file copies.

#### Scenario: Prompt file copy
- **Given** a feature with prompt files in `features/<feature>/codex/prompts/`
- **When** installing for Codex CLI
- **Then** the installer copies files from source to `~/.codex/prompts/`

#### Scenario: Config installation
- **Given** a feature with `features/<feature>/codex/AGENTS.md`
- **When** installing for Codex CLI
- **Then** the installer merges content into `~/.codex/AGENTS.md` managed block

#### Scenario: Existing symlink replacement
- **Given** a symlink exists at the destination from a previous installation
- **When** re-running the installer
- **Then** the installer removes the symlink and creates a file copy

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

#### Scenario: File already exists
- **Given** a file already exists at the destination
- **When** re-running installation
- **Then** the installer overwrites the file with current content

#### Scenario: Symlink exists from previous version
- **Given** a symlink exists at the destination from a prior installation
- **When** re-running installation
- **Then** the installer removes the symlink and creates a file copy

#### Scenario: Config already merged
- **Given** a feature's config is already in the managed block
- **When** re-running installation
- **Then** the content is not duplicated

#### Scenario: Directory already exists
- **Given** destination directories already exist
- **When** running installation
- **Then** the installer proceeds without error

