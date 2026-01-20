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

### Requirement: Homebrew Tap
The tool MUST provide a Homebrew tap for standard installation UX.

#### Scenario: Tap repository structure
- **Given** a repository named `homebrew-nexus-ai` exists
- **When** it contains `Formula/nexus-ai.rb`
- **Then** it follows Homebrew tap naming conventions

#### Scenario: Tap addition
- **Given** user has Homebrew installed
- **When** running `brew tap N3SSQwiK/nexus-ai`
- **Then** the tap is added to Homebrew's formula sources

#### Scenario: Standard installation
- **Given** user has tapped the repository
- **When** running `brew install nexus-ai`
- **Then** `nexus-ai` command becomes available system-wide

#### Scenario: One-liner installation
- **Given** user has Homebrew installed
- **When** running `brew install N3SSQwiK/nexus-ai/nexus-ai`
- **Then** the tap is added and formula installed in one command

### Requirement: Homebrew Formula
The tool MUST provide a valid Homebrew formula in the tap repository.

#### Scenario: Formula validation
- **Given** `Formula/nexus-ai.rb` exists in the tap
- **When** running `brew audit --strict Formula/nexus-ai.rb`
- **Then** no errors are reported

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
- **Given** `.github/workflows/release.yml` exists in `agent-tools`
- **When** a tag matching `v*` is pushed
- **Then** the release workflow executes

#### Scenario: Release assets
- **Given** the release workflow completes successfully
- **When** viewing the GitHub release
- **Then** source tarball and SHA256 checksum are attached

#### Scenario: Cross-repo tap update
- **Given** the release workflow has access to the tap repository
- **When** a new release is published
- **Then** the workflow updates `Formula/nexus-ai.rb` in `homebrew-nexus-ai` with new URL and SHA256

### Requirement: Tarball Exclusions
Release tarballs MUST exclude non-essential files to minimize distribution size and protect internal documentation.

#### Scenario: Export-ignore configuration
- **Given** `.gitattributes` exists with export-ignore rules
- **When** GitHub generates a release tarball
- **Then** excluded directories (`.ai/`, `.github/`, `openspec/`, `docs/`) are NOT included

#### Scenario: Feature files included
- **Given** `.gitattributes` has exceptions for feature files
- **When** GitHub generates a release tarball
- **Then** all files in `installer/python/features/` ARE included

#### Scenario: Tarball verification
- **Given** a release tarball is downloaded
- **When** extracted and inspected
- **Then** it contains only files necessary for installation

### Requirement: Bundled Features
The installed package MUST include feature files that can be copied to user config directories.

#### Scenario: Features as package data
- **Given** `features/` is located at `installer/python/features/`
- **When** the package is installed via pip or Homebrew
- **Then** feature files are bundled and accessible at runtime

#### Scenario: Feature installation from package
- **Given** the package is installed (not cloned from repo)
- **When** user selects features in the TUI
- **Then** feature files are successfully copied to config directories

#### Scenario: Development mode compatibility
- **Given** developer runs `./install.sh` from repo checkout
- **When** features are installed
- **Then** the TUI correctly locates features in the repo structure
