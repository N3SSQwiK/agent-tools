# Change: Add Homebrew Distribution

## Why

The installer currently requires users to clone the repo and run `./install.sh`. This creates friction:

1. **Discovery:** Users can't find it via `brew search`
2. **Installation:** Multi-step process (git clone, cd, chmod, run)
3. **Updates:** Manual `git pull` required
4. **Portability:** Requires git and the full repo on disk

Homebrew distribution enables `brew install nexus-ai` for one-command installation with automatic updates via `brew upgrade`.

## What Changes

### New Files in `agent-tools` Repo

| File | Purpose |
|------|---------|
| `pyproject.toml` | Python package configuration with entry point and dependencies |
| `.gitattributes` | Export-ignore rules to exclude non-essential files from release tarballs |
| `.github/workflows/release.yml` | Automated release workflow triggered by git tags |

### Repository Restructuring

The `features/` directory must be moved inside the Python package so it can be bundled as package data:

```
BEFORE                              AFTER
──────                              ─────
agent-tools/                        agent-tools/
├── features/          →            ├── installer/
│   ├── continuity/                 │   └── python/
│   ├── maestro/                    │       ├── nexus.py
│   └── openspec/                   │       └── features/      ← Moved here
├── installer/                      │           ├── continuity/
│   └── python/                     │           ├── maestro/
│       └── nexus.py                │           └── openspec/
└── ...                             └── ...
```

**Why this move is necessary:** Python packages can only bundle data files that are *inside* a package directory. The `features/` directory contains the command files, config templates, and extensions that the TUI copies to user config directories. Without this restructuring, Homebrew-installed users would have no features to install.

### New Repository

| Repo | Purpose |
|------|---------|
| `N3SSQwiK/homebrew-nexus-ai` | Homebrew tap containing the formula |

This follows Homebrew's naming convention: when users run `brew tap N3SSQwiK/nexus-ai`, Homebrew looks for a repo named `homebrew-nexus-ai`.

## Proposed Solution

### 1. Python Packaging (`pyproject.toml`)

Defines the package metadata, dependencies, and entry point:

```toml
[build-system]
requires = ["setuptools>=61.0"]
build-backend = "setuptools.build_meta"

[project]
name = "nexus-ai"
version = "1.0.0"
description = "TUI installer for AI assistant CLI tools (Claude Code, Gemini CLI, Codex CLI)"
readme = "README.md"
requires-python = ">=3.9"
license = {text = "MIT"}
dependencies = [
    "textual>=0.50.0",
]

[project.scripts]
nexus-ai = "installer.python.nexus:main"

[tool.setuptools.packages.find]
where = ["."]
include = ["installer*"]

[tool.setuptools.package-data]
"installer.python" = ["features/**/*"]
```

**What this does:**
- Declares `nexus-ai` as the CLI command that runs `installer.python.nexus:main`
- Bundles everything in `installer/python/features/` as package data
- Specifies Textual as the only runtime dependency
- Requires Python 3.9+ (Textual's minimum requirement)

### 2. Tarball Exclusions (`.gitattributes`)

Excludes non-essential files from GitHub release tarballs:

```gitattributes
# Exclude from release tarballs (git archive / GitHub releases)
.ai/ export-ignore
.github/ export-ignore
openspec/ export-ignore
docs/ export-ignore
*.md export-ignore
!README.md
!installer/python/features/**/*.md
```

**What this does:**
- Release tarballs will NOT contain: `.ai/`, `.github/`, `openspec/`, `docs/`, or root-level markdown files
- Release tarballs WILL contain: `README.md` (needed for PyPI metadata) and all feature markdown files
- Your `openspec/` specs and internal documentation stay in the repo but don't ship to end users
- Anyone browsing GitHub still sees everything; only the downloadable tarball is trimmed

### 3. Homebrew Tap (`N3SSQwiK/homebrew-nexus-ai`)

A new public repository containing the Homebrew formula:

```
homebrew-nexus-ai/
├── README.md           # Tap usage instructions
└── Formula/
    └── nexus-ai.rb     # The formula
```

**Formula structure (`nexus-ai.rb`):**

```ruby
class NexusAi < Formula
  include Language::Python::Virtualenv

  desc "TUI installer for AI assistant CLI tools"
  homepage "https://github.com/N3SSQwiK/agent-tools"
  url "https://github.com/N3SSQwiK/agent-tools/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "abc123..."  # Auto-updated by release workflow
  license "MIT"

  depends_on "python@3.11"

  def install
    virtualenv_install_with_resources
  end

  test do
    assert_match "nexus-ai", shell_output("#{bin}/nexus-ai --help")
  end
end
```

**What this does:**
- Downloads the release tarball from GitHub
- Creates an isolated Python virtualenv in Homebrew's Cellar
- Installs the package and dependencies into that virtualenv
- Creates a wrapper script at `/opt/homebrew/bin/nexus-ai`

### 4. Release Automation (`.github/workflows/release.yml`)

Triggered when you push a version tag:

```yaml
name: Release

on:
  push:
    tags:
      - 'v*'

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Create GitHub Release
        uses: softprops/action-gh-release@v1
        with:
          generate_release_notes: true

      - name: Get release info
        id: release
        run: |
          # Get the tarball URL and compute SHA256
          VERSION=${GITHUB_REF#refs/tags/}
          TARBALL_URL="https://github.com/${{ github.repository }}/archive/refs/tags/${VERSION}.tar.gz"
          curl -sL "$TARBALL_URL" -o release.tar.gz
          SHA256=$(shasum -a 256 release.tar.gz | cut -d' ' -f1)
          echo "version=${VERSION}" >> $GITHUB_OUTPUT
          echo "sha256=${SHA256}" >> $GITHUB_OUTPUT

      - name: Update Homebrew tap
        uses: peter-evans/repository-dispatch@v2
        with:
          token: ${{ secrets.TAP_UPDATE_TOKEN }}
          repository: N3SSQwiK/homebrew-nexus-ai
          event-type: update-formula
          client-payload: |
            {
              "version": "${{ steps.release.outputs.version }}",
              "sha256": "${{ steps.release.outputs.sha256 }}"
            }
```

**What this does:**
1. Creates a GitHub Release with auto-generated release notes
2. Computes the SHA256 of the release tarball
3. Triggers a workflow in the tap repo to update the formula

**Tap repo workflow (`.github/workflows/update-formula.yml`):**

```yaml
name: Update Formula

on:
  repository_dispatch:
    types: [update-formula]

jobs:
  update:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Update formula
        run: |
          VERSION="${{ github.event.client_payload.version }}"
          SHA256="${{ github.event.client_payload.sha256 }}"

          sed -i "s|archive/refs/tags/v.*\.tar\.gz|archive/refs/tags/${VERSION}.tar.gz|" Formula/nexus-ai.rb
          sed -i "s|sha256 \".*\"|sha256 \"${SHA256}\"|" Formula/nexus-ai.rb

      - name: Commit and push
        run: |
          git config user.name "github-actions[bot]"
          git config user.email "github-actions[bot]@users.noreply.github.com"
          git add Formula/nexus-ai.rb
          git commit -m "Update nexus-ai to ${{ github.event.client_payload.version }}"
          git push
```

### 5. Code Changes (`nexus.py`)

Update the feature path resolution to work both in development (repo checkout) and when installed as a package:

```python
from importlib.resources import files, as_file
from pathlib import Path

def get_features_path() -> Path:
    """Get the path to features directory, works both in dev and installed."""
    # Try package resources first (installed via pip/brew)
    try:
        pkg_features = files("installer.python").joinpath("features")
        if pkg_features.is_dir():
            return Path(str(pkg_features))
    except (TypeError, FileNotFoundError):
        pass

    # Fall back to repo structure (development)
    repo = Path(__file__).parent.parent.parent
    if (repo / "features").exists():
        return repo / "features"

    raise FileNotFoundError("Could not locate features directory")
```

**What this does:**
- First tries to find features via Python's package resource system (for Homebrew installs)
- Falls back to looking in the repo structure (for development with `./install.sh`)
- Ensures the TUI works in both contexts

### 6. Local Development

Developers can still use the traditional flow or the new pip install:

```bash
# Option A: Traditional (still works)
./install.sh

# Option B: Editable pip install (new)
pip install -e .
nexus-ai
```

## User Experience

### Installation

```bash
# One-liner (tap + install combined)
brew install N3SSQwiK/nexus-ai/nexus-ai

# Or two steps
brew tap N3SSQwiK/nexus-ai
brew install nexus-ai
```

### Usage

```bash
# Launch the TUI
nexus-ai

# Get help
nexus-ai --help

# Check version
nexus-ai --version
```

### Updates

```bash
# Update to latest version
brew upgrade nexus-ai
```

## Scope

### In Scope

- Python packaging setup (`pyproject.toml`)
- Repository restructuring (move `features/` into package)
- Tarball exclusions (`.gitattributes`)
- Homebrew tap repository creation (`N3SSQwiK/homebrew-nexus-ai`)
- Homebrew formula with Python virtualenv
- GitHub Actions release workflow with cross-repo tap updates
- Code changes to support installed package context
- Local development setup preservation

### Out of Scope

- PyPI publishing (not needed while repo is public)
- Linux package managers (apt, dnf)
- Windows distribution (scoop, winget)
- Auto-update checks within the TUI

## Success Criteria

1. `pip install -e .` enables local `nexus-ai` command
2. `./install.sh` continues to work (backwards compatibility)
3. `brew tap N3SSQwiK/nexus-ai` adds the tap successfully
4. `brew install nexus-ai` installs and launches TUI
5. Installed TUI can successfully install features to `~/.claude/`, `~/.gemini/`, `~/.codex/`
6. Homebrew formula validates with `brew audit --strict`
7. Pushing tag `v1.0.0` triggers release workflow and auto-updates tap
8. Release tarball does NOT contain `openspec/`, `docs/`, `.ai/`

## Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Repo visibility | Public | Simplifies distribution; private would require PyPI |
| Python version | `python@3.11` | LTS until Oct 2027; Textual requires ≥3.9 |
| Initial version | `v1.0.0` | Production-ready release |
| Formula update | Full auto-update | Release workflow auto-commits SHA to tap repo |
| Distribution | Homebrew tap | Standard UX: `brew install nexus-ai` |
| Tarball contents | Minimal | `.gitattributes` export-ignore excludes internal docs |
| Features location | Move into package | Required for Python package data bundling |

## Impact

- Affected specs: None (new capability)
- New spec: `distribution`
- Affected code: `installer/python/nexus.py` (feature path resolution)
- New files: `pyproject.toml`, `.gitattributes`, `.github/workflows/release.yml`
- Restructuring: `features/` → `installer/python/features/`
- New repo: `N3SSQwiK/homebrew-nexus-ai`
