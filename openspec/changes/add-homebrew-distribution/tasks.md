# Tasks: Add Homebrew Distribution

## Phase 0: Repository Restructuring

This phase must be completed first as all other phases depend on the new structure.

### 0.1 Move features directory
- [ ] Move `features/` to `installer/python/features/`
- [ ] Update any hardcoded paths in `nexus.py` that reference `features/`
- [ ] **Verification:** `ls installer/python/features/` shows continuity, maestro, openspec directories

### 0.2 Update nexus.py feature path resolution
- [ ] Add `get_features_path()` function using `importlib.resources`
- [ ] Update all code that references `repo / "features"` to use the new function
- [ ] Ensure fallback to repo structure for development mode
- [ ] **Verification:** Running `./install.sh` still works after the move

### 0.3 Update install.sh
- [ ] Update any paths that reference the old `features/` location
- [ ] **Verification:** `./install.sh` completes successfully

### 0.4 Add __init__.py files
- [ ] Create `installer/__init__.py` (empty or with version)
- [ ] Create `installer/python/__init__.py` (empty or with version)
- [ ] **Verification:** `python -c "import installer.python"` succeeds

## Phase 1: Python Packaging

### 1.1 Create pyproject.toml
- [ ] Create `pyproject.toml` in repo root with build-system configuration
- [ ] Add project metadata (name, version, description, license)
- [ ] Add dependencies (textual>=0.50.0)
- [ ] Define `nexus-ai` entry point script
- [ ] Configure setuptools to find packages and include package data
- [ ] **Verification:** `pip install -e .` succeeds

### 1.2 Add main() function
- [ ] Ensure `nexus.py` has a `main()` function that can be called as entry point
- [ ] Add `--help` flag support
- [ ] Add `--version` flag support
- [ ] **Verification:** `python -m installer.python.nexus --help` works

### 1.3 Test local installation
- [ ] Run `pip install -e .` in project root
- [ ] Verify `nexus-ai` command is available
- [ ] Verify `nexus-ai` launches the TUI
- [ ] Verify TUI can install features to config directories
- [ ] **Verification:** `which nexus-ai` shows installed path; features install correctly

## Phase 2: Tarball Configuration

### 2.1 Create .gitattributes
- [ ] Create `.gitattributes` in repo root
- [ ] Add export-ignore for `.ai/`
- [ ] Add export-ignore for `.github/`
- [ ] Add export-ignore for `openspec/`
- [ ] Add export-ignore for `docs/`
- [ ] Add export-ignore for `*.md` with exceptions for README.md and feature files
- [ ] **Verification:** File exists with correct patterns

### 2.2 Test tarball exclusions
- [ ] Run `git archive --format=tar.gz HEAD -o test-release.tar.gz`
- [ ] Extract and verify `openspec/` is NOT present
- [ ] Extract and verify `installer/python/features/` IS present
- [ ] Extract and verify feature `.md` files ARE present
- [ ] Clean up test tarball
- [ ] **Verification:** Tarball contains only essential files

## Phase 3: Homebrew Tap Repository

### 3.1 Create tap repository on GitHub
- [ ] Create new GitHub repo: `N3SSQwiK/homebrew-nexus-ai`
- [ ] Add description: "Homebrew tap for nexus-ai"
- [ ] Initialize with README
- [ ] **Verification:** Repo exists at `github.com/N3SSQwiK/homebrew-nexus-ai`

### 3.2 Create Formula directory and initial formula
- [ ] Create `Formula/` directory in tap repo
- [ ] Create `Formula/nexus-ai.rb` with formula skeleton
- [ ] Add `desc`, `homepage`, `license` metadata
- [ ] Add placeholder `url` and `sha256` (will be updated by first release)
- [ ] Add `depends_on "python@3.11"`
- [ ] Implement `install` method using `virtualenv_install_with_resources`
- [ ] Add `test` block
- [ ] **Verification:** Formula file has valid Ruby syntax

### 3.3 Create tap update workflow
- [ ] Create `.github/workflows/update-formula.yml` in tap repo
- [ ] Configure `repository_dispatch` trigger for `update-formula` event
- [ ] Implement formula update logic (sed for url and sha256)
- [ ] Configure git commit and push
- [ ] **Verification:** Workflow YAML is valid

### 3.4 Update tap README
- [ ] Document tap usage: `brew tap N3SSQwiK/nexus-ai`
- [ ] Document installation: `brew install nexus-ai`
- [ ] Document one-liner: `brew install N3SSQwiK/nexus-ai/nexus-ai`
- [ ] **Verification:** README is clear and complete

### 3.5 Test formula locally (with placeholder values)
- [ ] Run `brew audit --strict Formula/nexus-ai.rb`
- [ ] Fix any audit issues
- [ ] **Verification:** Audit passes (warnings about placeholder SHA are expected)

## Phase 4: Release Automation

### 4.1 Create Personal Access Token
- [ ] Create GitHub PAT with `repo` scope for tap repo access
- [ ] Add PAT as secret `TAP_UPDATE_TOKEN` in agent-tools repo settings
- [ ] **Verification:** Secret is visible in repo settings (value hidden)

### 4.2 Create release workflow
- [ ] Create `.github/workflows/release.yml` in agent-tools repo
- [ ] Configure trigger on tag push (`v*`)
- [ ] Add checkout step
- [ ] Add GitHub Release creation step with auto-generated notes
- [ ] Add step to compute SHA256 of release tarball
- [ ] Add repository-dispatch step to trigger tap update
- [ ] **Verification:** Workflow YAML is valid

### 4.3 Test release workflow (dry run)
- [ ] Review workflow for correctness
- [ ] Optionally test with a pre-release tag (`v0.0.1-test`)
- [ ] Verify tap update was triggered (check tap repo for dispatch event)
- [ ] Clean up test release if created
- [ ] **Verification:** Workflow executes without errors

## Phase 5: First Release

### 5.1 Final pre-release checks
- [ ] Ensure all tests pass locally
- [ ] Ensure `pip install -e . && nexus-ai` works
- [ ] Ensure `./install.sh` still works
- [ ] Review all changes for completeness
- [ ] **Verification:** All local checks pass

### 5.2 Create and push v1.0.0 tag
- [ ] `git tag v1.0.0`
- [ ] `git push origin v1.0.0`
- [ ] **Verification:** Tag appears on GitHub

### 5.3 Verify release automation
- [ ] Wait for release workflow to complete
- [ ] Verify GitHub Release was created
- [ ] Verify release notes were generated
- [ ] Check tap repo for formula update commit
- [ ] Verify SHA256 in formula matches release tarball
- [ ] **Verification:** Tap formula has correct URL and SHA256

### 5.4 Test Homebrew installation
- [ ] `brew tap N3SSQwiK/nexus-ai`
- [ ] `brew install nexus-ai`
- [ ] Run `nexus-ai` and verify TUI launches
- [ ] Test installing a feature via the TUI
- [ ] Verify feature files were copied to config directory
- [ ] **Verification:** End-to-end installation works

## Phase 6: Documentation

### 6.1 Update agent-tools README
- [ ] Add Homebrew installation instructions
- [ ] Keep existing `./install.sh` instructions for developers
- [ ] Add development setup section (`pip install -e .`)
- [ ] Document release process for maintainers
- [ ] **Verification:** README reflects all installation methods

### 6.2 Update any other affected documentation
- [ ] Check CLAUDE.md for references to installation
- [ ] Update if necessary
- [ ] **Verification:** No stale documentation

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
| Phase 0 | Pending | Repository Restructuring |
| Phase 1 | Pending | Python Packaging |
| Phase 2 | Pending | Tarball Configuration |
| Phase 3 | Pending | Homebrew Tap Repository |
| Phase 4 | Pending | Release Automation |
| Phase 5 | Pending | First Release |
| Phase 6 | Pending | Documentation |
