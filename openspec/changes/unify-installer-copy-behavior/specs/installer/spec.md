# Installer Specification Delta

## MODIFIED Requirements

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
