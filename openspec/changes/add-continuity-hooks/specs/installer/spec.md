# installer Specification Delta

## ADDED Requirements

### Requirement: Claude Code Hook Installation
The installer MUST deploy Claude Code hooks from feature directories to the user's Claude configuration.

#### Scenario: Hook directory detected
- **Given** a feature with `features/<feature>/claude/hooks/` directory
- **When** installing for Claude Code
- **Then** the installer processes the hooks directory

#### Scenario: Hook scripts copied
- **Given** a feature with hook scripts in `features/<feature>/claude/hooks/*.sh`
- **When** installing for Claude Code
- **Then** the installer copies scripts to `~/.claude/hooks/<feature>/`
- **And** makes the scripts executable (chmod +x)

#### Scenario: Hook configuration merged
- **Given** a feature with `features/<feature>/claude/hooks/hooks.json`
- **When** installing for Claude Code
- **Then** the installer merges the hook configuration into `~/.claude/settings.json`
- **And** updates script paths to reference `~/.claude/hooks/<feature>/`

#### Scenario: Multiple features with hooks
- **Given** multiple features each with hooks
- **When** installing for Claude Code
- **Then** all hook configurations are merged into `~/.claude/settings.json`
- **And** hooks from different features do not conflict

### Requirement: Gemini CLI Hook Installation
The installer MUST deploy Gemini CLI hooks as part of extension installation.

#### Scenario: Extension hooks directory detected
- **Given** a feature with `features/<feature>/gemini/extensions/<feature>/hooks/` directory
- **When** installing for Gemini CLI
- **Then** the installer copies the entire hooks directory to the extension location

#### Scenario: Hook scripts in extension
- **Given** a feature with hook scripts in the extension's hooks directory
- **When** installing for Gemini CLI
- **Then** the scripts are copied to `~/.gemini/extensions/<feature>/hooks/`
- **And** the scripts are made executable

#### Scenario: Extension hooks.json preserved
- **Given** a feature with `hooks/hooks.json` in the extension
- **When** installing for Gemini CLI
- **Then** the `hooks.json` is copied alongside the scripts
- **And** Gemini CLI automatically discovers extension hooks

### Requirement: Codex CLI Notify Script Installation
The installer MUST deploy Codex notify scripts and update the Codex configuration.

#### Scenario: Notify directory detected
- **Given** a feature with `features/<feature>/codex/notify/` directory
- **When** installing for Codex CLI
- **Then** the installer processes the notify directory

#### Scenario: Notify script copied
- **Given** a feature with `features/<feature>/codex/notify/<script>.sh`
- **When** installing for Codex CLI
- **Then** the installer copies the script to `~/.codex/scripts/<feature>/`
- **And** makes the script executable

#### Scenario: Codex config updated
- **Given** a notify script being installed
- **When** installation completes
- **Then** the installer updates `~/.codex/config.json` to set `notify` to the script path
- **And** preserves other existing config values

#### Scenario: Single notify script limit
- **Given** Codex only supports one notify script
- **And** multiple features provide notify scripts
- **When** installing for Codex CLI
- **Then** the installer creates a wrapper script that calls all feature scripts
- **Or** warns the user about the conflict

### Requirement: Codex CLI Git Hooks (Optional)
The installer MUST provide git hooks for Codex but NOT auto-install them.

#### Scenario: Git hooks directory detected
- **Given** a feature with `features/<feature>/codex/git-hooks/` directory
- **When** installing for Codex CLI
- **Then** the installer copies hooks to `~/.codex/git-hooks/<feature>/`

#### Scenario: Git hooks not auto-installed
- **Given** git hooks copied to `~/.codex/git-hooks/`
- **When** installation completes
- **Then** the installer does NOT modify `.git/hooks/`
- **And** displays instructions for manual installation

#### Scenario: Git hook installation instructions
- **Given** git hooks were copied
- **When** the Done screen displays
- **Then** it includes: "To enable Codex git hooks, copy from ~/.codex/git-hooks/ to your project's .git/hooks/"

## MODIFIED Requirements

### Requirement: Feature Directory Structure (MODIFIED)
Each feature MUST follow a standard directory structure under `features/<feature>/`. **Features MAY include hooks, notify scripts, and git-hooks directories.**

#### Scenario: Valid feature structure with hooks
- **Given** a feature named `<feature>` with hook support
- **When** the installer scans for features
- **Then** it expects the following extended structure:
  ```
  features/<feature>/
  ├── claude/
  │   ├── CLAUDE.md
  │   ├── commands/<feature>[-*].md
  │   └── hooks/                      # NEW
  │       ├── hooks.json
  │       └── *.sh
  ├── gemini/
  │   ├── GEMINI.md
  │   └── extensions/<feature>/
  │       ├── gemini-extension.json
  │       ├── commands/<feature>[-*].toml
  │       └── hooks/                  # NEW
  │           ├── hooks.json
  │           └── *.sh
  └── codex/
      ├── AGENTS.md
      ├── prompts/<feature>[-*].md
      ├── notify/                     # NEW
      │   └── *.sh
      └── git-hooks/                  # NEW
          ├── post-merge
          └── post-push
  ```

#### Scenario: Feature without hooks
- **Given** a feature without any hooks directories
- **When** the installer processes the feature
- **Then** installation proceeds normally for commands and config only
