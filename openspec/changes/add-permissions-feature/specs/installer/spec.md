# installer Specification Delta

## ADDED Requirements

### Requirement: Hook File Installation
The installer MUST support deploying hook scripts for features that include them.

#### Scenario: Claude Code hook installation
- **Given** a feature with `features/<feature>/claude/hooks/*.sh`
- **When** installing for Claude Code
- **Then** the installer copies hook scripts to `~/.claude/hooks/`
- **And** sets executable permissions (755) on hook files

#### Scenario: Hook directory creation
- **Given** `~/.claude/hooks/` does not exist
- **When** installing hooks for Claude Code
- **Then** the installer creates the directory with appropriate permissions

#### Scenario: Hook naming convention
- **Given** hook files named `<feature>-<event>.sh` (e.g., `permissions-audit-pre.sh`)
- **When** the installer processes hooks
- **Then** it preserves the naming convention in the destination directory

### Requirement: Template File Installation
The installer MUST support deploying reference templates to a Nexus-managed location.

#### Scenario: Template directory setup
- **Given** a feature with `features/<feature>/templates/`
- **When** installing the feature
- **Then** the installer copies templates to `~/.nexus/<feature>/templates/`

#### Scenario: Template preservation
- **Given** templates are copied to `~/.nexus/<feature>/templates/`
- **When** user modifies templates in that location
- **Then** re-running the installer overwrites with current versions
- **And** user is expected to copy templates elsewhere before customizing

#### Scenario: Nexus directory creation
- **Given** `~/.nexus/` does not exist
- **When** installing templates
- **Then** the installer creates `~/.nexus/` with appropriate permissions

### Requirement: Feature Documentation Installation
The installer MUST support deploying feature-specific documentation.

#### Scenario: Docs copied to central location
- **Given** a feature with `features/<feature>/docs/`
- **When** installing the feature
- **Then** the installer copies documentation to `~/.nexus/<feature>/docs/`

#### Scenario: Docs accessible to users
- **Given** documentation installed to `~/.nexus/<feature>/docs/`
- **When** user looks for feature documentation
- **Then** they can find it without navigating the installer's internal structure

## MODIFIED Requirements

### Requirement: Feature Directory Structure
Each feature MUST follow a standard directory structure under `features/<feature>/`.

#### Scenario: Valid feature structure (extended)
- **Given** a feature named `<feature>`
- **When** the installer scans for features
- **Then** it expects the following structure:
  ```
  features/<feature>/
  ├── claude/
  │   ├── CLAUDE.md              # Global instructions (optional)
  │   ├── commands/
  │   │   └── <feature>[-*].md   # Slash command(s)
  │   └── hooks/                 # NEW: Hook scripts (optional)
  │       └── <feature>-*.sh
  ├── gemini/
  │   ├── GEMINI.md              # Global instructions (optional)
  │   └── extensions/<feature>/
  │       ├── gemini-extension.json
  │       └── commands/
  │           └── <feature>[-*].toml
  ├── codex/
  │   ├── AGENTS.md              # Global instructions (optional)
  │   └── prompts/
  │       └── <feature>[-*].md   # Slash command(s)
  ├── templates/                 # NEW: Reference templates (optional)
  │   └── <tool>/*.{json,toml}
  └── docs/                      # NEW: Feature documentation (optional)
      └── *.md
  ```
