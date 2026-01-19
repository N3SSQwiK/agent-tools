# Tasks: Add Homebrew Distribution

## Phase 0: Repository Restructuring

This phase must be completed first as all other phases depend on the new structure.

### 0.1 Move features directory
- [x] Move `features/` to `installer/python/features/`
- [x] Update any hardcoded paths in `nexus.py` that reference `features/`
- [x] **Verification:** `ls installer/python/features/` shows continuity, maestro, openspec directories

### 0.2 Update nexus.py feature path resolution
- [x] Add `get_features_path()` function using `importlib.resources`
- [x] Update all code that references `repo / "features"` to use the new function
- [x] Ensure fallback to repo structure for development mode
- [x] **Verification:** Running `./install.sh` still works after the move

### 0.3 Update install.sh
- [x] Update any paths that reference the old `features/` location
- [x] **Verification:** `./install.sh` completes successfully

### 0.4 Add __init__.py files
- [x] Create `installer/__init__.py` (empty or with version)
- [x] Create `installer/python/__init__.py` (empty or with version)
- [x] **Verification:** `python -c "import installer.python"` succeeds

## Phase 1: Python Packaging

### 1.1 Create pyproject.toml
- [x] Create `pyproject.toml` in repo root with build-system configuration
- [x] Add project metadata (name, version, description, license)
- [x] Add dependencies (textual>=0.50.0)
- [x] Define `nexus-ai` entry point script
- [x] Configure setuptools to find packages and include package data
- [x] **Verification:** `pip install -e .` succeeds

### 1.2 Add main() function
- [x] Ensure `nexus.py` has a `main()` function that can be called as entry point
- [x] Add `--help` flag support
- [x] Add `--version` flag support
- [x] **Verification:** `python -m installer.python.nexus --help` works

### 1.3 Test local installation
- [x] Run `pip install -e .` in project root
- [x] Verify `nexus-ai` command is available
- [x] Verify `nexus-ai` launches the TUI
- [x] Verify TUI can install features to config directories
- [x] **Verification:** `which nexus-ai` shows installed path; features install correctly

## Phase 2: Tarball Configuration

### 2.1 Create .gitattributes
- [x] Create `.gitattributes` in repo root
- [x] Add export-ignore for `.ai/`
- [x] Add export-ignore for `.github/`
- [x] Add export-ignore for `openspec/`
- [x] Add export-ignore for `docs/`
- [x] Add export-ignore for `*.md` with exceptions for README.md and feature files
- [x] **Verification:** File exists with correct patterns

### 2.2 Test tarball exclusions
- [x] Run `git archive --format=tar.gz HEAD -o test-release.tar.gz`
- [x] Extract and verify `openspec/` is NOT present
- [x] Extract and verify `installer/python/features/` IS present
- [x] Extract and verify feature `.md` files ARE present
- [x] Clean up test tarball
- [x] **Verification:** Tarball contains only essential files

## Phase 3: Homebrew Tap Repository

### 3.1 Create tap repository on GitHub
- [x] Create new GitHub repo: `N3SSQwiK/homebrew-nexus-ai`
- [x] Add description: "Homebrew tap for nexus-ai"
- [x] Initialize with README
- [x] **Verification:** Repo exists at `github.com/N3SSQwiK/homebrew-nexus-ai`

### 3.2 Create Formula directory and initial formula
- [x] Create `Formula/` directory in tap repo
- [x] Create `Formula/nexus-ai.rb` with formula skeleton
- [x] Add `desc`, `homepage`, `license` metadata
- [x] Add placeholder `url` and `sha256` (will be updated by first release)
- [x] Add `depends_on "python@3.11"`
- [x] Implement `install` method using `virtualenv_install_with_resources`
- [x] Add `test` block
- [x] **Verification:** Formula file has valid Ruby syntax

### 3.3 Create tap update workflow
- [x] Create `.github/workflows/update-formula.yml` in tap repo
- [x] Configure `repository_dispatch` trigger for `update-formula` event
- [x] Implement formula update logic (sed for url and sha256)
- [x] Configure git commit and push
- [x] **Verification:** Workflow YAML is valid

### 3.4 Update tap README
- [x] Document tap usage: `brew tap N3SSQwiK/nexus-ai`
- [x] Document installation: `brew install nexus-ai`
- [x] Document one-liner: `brew install N3SSQwiK/nexus-ai/nexus-ai`
- [x] **Verification:** README is clear and complete

### 3.5 Test formula locally (with placeholder values)
- [x] Run `brew audit --strict Formula/nexus-ai.rb`
- [x] Fix any audit issues (removed trailing whitespace)
- [x] **Verification:** Audit passes

## Phase 4: Release Automation

### 4.1 Create Personal Access Token
- [x] Create GitHub PAT with `repo` scope for tap repo access
- [x] Add PAT as secret `TAP_UPDATE_TOKEN` in agent-tools repo settings
- [x] **Verification:** Secret is visible in repo settings (value hidden)

### 4.2 Create release workflow
- [x] Create `.github/workflows/release.yml` in agent-tools repo
- [x] Configure trigger on tag push (`v*`)
- [x] Add checkout step
- [x] Add GitHub Release creation step with auto-generated notes
- [x] Add step to compute SHA256 of release tarball
- [x] Add repository-dispatch step to trigger tap update
- [x] **Verification:** Workflow YAML is valid

### 4.3 Test release workflow (dry run)
- [x] Review workflow for correctness
- [x] Tested with actual release v1.0.0 (better than dry run)
- [x] Verify tap update was triggered (commit b8b3ea3 in tap repo)
- [x] N/A - no test release to clean up
- [x] **Verification:** Workflow executed successfully, tap auto-updated

## Phase 5: First Release

### 5.1 Final pre-release checks
- [x] Ensure all tests pass locally
- [x] Ensure `pip install -e . && nexus-ai` works
- [x] Ensure `./install.sh` still works
- [x] Review all changes for completeness
- [x] **Verification:** All local checks pass

### 5.2 Create and push v1.0.0 tag
- [x] `git tag v1.0.0`
- [x] `git push origin v1.0.0`
- [x] **Verification:** Tag appears on GitHub

### 5.3 Verify release automation
- [x] Wait for release workflow to complete
- [x] Verify GitHub Release was created
- [x] Verify release notes were generated
- [x] Check tap repo for formula update commit
- [x] Verify SHA256 in formula matches release tarball
- [x] **Verification:** Tap formula has correct URL and SHA256

### 5.4 Test Homebrew installation
- [x] `brew tap N3SSQwiK/nexus-ai`
- [x] `brew install nexus-ai`
- [x] Run `nexus-ai` and verify TUI launches
- [x] Features bundled in package (continuity/, maestro/ verified in libexec)
- [x] Target config directories exist (~/.claude/commands/, etc.)
- [x] **Verification:** End-to-end installation works, features accessible via get_features_path()

## Phase 6: Documentation

### 6.1 Update agent-tools README
- [x] Add Homebrew installation instructions
- [x] Keep existing `./install.sh` instructions for developers
- [x] Add development setup section (`pip install -e .`)
- [x] Document release process for maintainers (added to README Development section)
- [x] **Verification:** README reflects all installation methods

### 6.2 Update any other affected documentation
- [x] Check CLAUDE.md for references to installation (no changes needed)
- [x] Update repo structure and feature paths in README
- [x] **Verification:** No stale documentation

## Dependencies

```
Phase 0 (Restructure) ─────────────────────────────────────────────┐
     │                                                             │
     ▼                                                             │
Phase 1 (Python Packaging)                                         │
     │                                                             │
     ├──────────────────────────────────────────┐                  │
     │                                          │                  │
     ▼                                          ▼                  │
Phase 2 (Tarball Config)              Phase 3 (Homebrew Tap)       │
     │                                          │                  │
     └──────────────┬───────────────────────────┘                  │
                    │                                              │
                    ▼                                              │
             Phase 4 (Release Automation)                          │
                    │                                              │
                    ▼                                              │
             Phase 5 (First Release)                               │
                    │                                              │
                    ▼                                              │
             Phase 6 (Documentation) ◄─────────────────────────────┘
```

**Critical path:** Phase 0 → Phase 1 → Phase 4 → Phase 5

## Completion Summary

| Phase | Status | Description |
|-------|--------|-------------|
| Phase 0 | ✅ Complete | Repository Restructuring |
| Phase 1 | ✅ Complete | Python Packaging |
| Phase 2 | ✅ Complete | Tarball Configuration |
| Phase 3 | ✅ Complete | Homebrew Tap Repository |
| Phase 4 | ✅ Complete | Release Automation |
| Phase 5 | ✅ Complete | First Release (v1.0.0 published, brew install works) |
| Phase 6 | ✅ Complete | Documentation (README updated with Homebrew instructions) |
