# Change: Add Homebrew Distribution

## Why

The installer currently requires users to clone the repo and run `./install.sh`. This creates friction:
1. **Discovery:** Users can't find it via `brew search`
2. **Installation:** Multi-step process (git clone, cd, chmod, run)
3. **Updates:** Manual `git pull` required
4. **Portability:** Requires git and repo on disk

Homebrew distribution enables `brew install nexus-ai` for one-command installation.

## What Changes

- **ADDED** Python packaging with `pyproject.toml` and `nexus-ai` entry point
- **ADDED** Homebrew formula (`Formula/nexus-ai.rb`)
- **ADDED** GitHub Actions release workflow for automated builds
- **ADDED** Local development linking for testing

## Proposed Solution

### 1. Python Packaging (`pyproject.toml`)
```toml
[project]
name = "nexus-ai"
version = "1.0.0"
scripts = { nexus-ai = "installer.python.nexus:main" }
```

### 2. Homebrew Formula (`Formula/nexus-ai.rb`)
Ruby formula that:
- Downloads release tarball
- Installs Python package into libexec
- Creates `bin/nexus-ai` wrapper

### 3. Release Automation (`.github/workflows/release.yml`)
On git tag push:
- Build Python wheel
- Create GitHub release
- Update Homebrew formula SHA

### 4. Local Testing
```bash
pip install -e .
nexus-ai  # runs installer
```

## Scope

### In Scope
- Python packaging setup (`pyproject.toml`)
- Homebrew formula creation
- GitHub Actions release workflow
- Local development setup

### Out of Scope
- PyPI publishing (future enhancement)
- Linux package managers (apt, dnf)
- Windows distribution (scoop, winget)
- Homebrew tap creation (uses main repo for now)

## Success Criteria

1. `pip install -e .` enables local `nexus-ai` command
2. Homebrew formula validates with `brew audit`
3. GitHub Actions workflow triggers on tag push
4. `brew install --build-from-source ./Formula/nexus-ai.rb` works locally

## Impact

- Affected specs: None (new capability)
- New spec: `distribution`
- Affected code: Add `pyproject.toml`, `Formula/`, `.github/workflows/`
