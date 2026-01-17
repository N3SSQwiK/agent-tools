# Distribution Specification Delta

## ADDED Requirements

### Requirement: CLI Entry Point
The tool MUST provide a command-line entry point named `nexus-ai`.

#### Scenario: Command invocation
- **Given** the package is installed
- **When** user runs `nexus-ai` in terminal
- **Then** the TUI installer launches

#### Scenario: Help flag
- **Given** the package is installed
- **When** user runs `nexus-ai --help`
- **Then** usage information is displayed

### Requirement: Python Package Structure
The tool MUST be installable as a Python package via pip.

#### Scenario: Editable install
- **Given** user is in the project root
- **When** user runs `pip install -e .`
- **Then** the package installs with `nexus-ai` command available

#### Scenario: Package metadata
- **Given** `pyproject.toml` exists
- **When** pip reads package metadata
- **Then** name, version, and dependencies are correctly defined

### Requirement: Homebrew Formula
The tool MUST provide a Homebrew formula for macOS/Linux installation.

#### Scenario: Formula validation
- **Given** `Formula/nexus-ai.rb` exists
- **When** running `brew audit --strict Formula/nexus-ai.rb`
- **Then** no errors are reported

#### Scenario: Local build installation
- **Given** user has Homebrew installed
- **When** running `brew install --build-from-source ./Formula/nexus-ai.rb`
- **Then** `nexus-ai` command becomes available system-wide

#### Scenario: Formula dependencies
- **Given** formula specifies `depends_on "python@3.11"`
- **When** installing on a fresh system
- **Then** Python is installed automatically

### Requirement: Semantic Versioning
The tool MUST follow semantic versioning (MAJOR.MINOR.PATCH).

#### Scenario: Version format
- **Given** a release tag
- **When** the tag is created
- **Then** it follows the format `vX.Y.Z` (e.g., `v1.0.0`)

#### Scenario: Version in package
- **Given** `pyproject.toml` defines version
- **When** user runs `nexus-ai --version`
- **Then** the version matches the package metadata

### Requirement: Release Automation
Releases MUST be automated via GitHub Actions on tag push.

#### Scenario: Tag trigger
- **Given** `.github/workflows/release.yml` exists
- **When** a tag matching `v*` is pushed
- **Then** the release workflow executes

#### Scenario: Release assets
- **Given** the release workflow completes successfully
- **When** viewing the GitHub release
- **Then** source tarball and SHA256 checksum are attached
