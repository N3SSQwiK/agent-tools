# Tasks: Add Homebrew Distribution

## Phase 1: Python Packaging

### 1.1 Create pyproject.toml
- [ ] Create `pyproject.toml` with project metadata
- [ ] Define `nexus-ai` entry point script
- [ ] Add Textual and other dependencies
- [ ] **Verification:** `pip install -e .` succeeds

### 1.2 Refactor entry point
- [ ] Add `main()` function to `nexus.py` if not present
- [ ] Ensure proper `if __name__ == "__main__"` guard
- [ ] **Verification:** `python -m installer.python.nexus` works

### 1.3 Test local installation
- [ ] Run `pip install -e .` in project root
- [ ] Verify `nexus-ai` command launches TUI
- [ ] **Verification:** `which nexus-ai` shows installed path

## Phase 2: Homebrew Formula

### 2.1 Create Formula directory
- [ ] Create `Formula/nexus-ai.rb`
- [ ] Define formula class with description, homepage, url placeholders
- [ ] Add `sha256` placeholder for release tarball
- [ ] **Verification:** Formula file exists with correct structure

### 2.2 Implement formula install method
- [ ] Set up Python virtualenv in libexec
- [ ] Install package dependencies
- [ ] Create bin wrapper script
- [ ] **Verification:** Formula syntax is valid Ruby

### 2.3 Add formula metadata
- [ ] Define dependencies (python@3.11)
- [ ] Add test block
- [ ] Add caveats if needed
- [ ] **Verification:** `brew audit --strict Formula/nexus-ai.rb` passes

## Phase 3: Release Automation

### 3.1 Create release workflow
- [ ] Create `.github/workflows/release.yml`
- [ ] Trigger on tag push (`v*`)
- [ ] Build Python source distribution
- [ ] **Verification:** Workflow YAML is valid

### 3.2 Add release asset upload
- [ ] Upload tarball to GitHub release
- [ ] Generate SHA256 checksum
- [ ] Include in release notes
- [ ] **Verification:** Assets appear in release

### 3.3 Add formula update step (optional)
- [ ] Auto-update Formula/nexus-ai.rb with new SHA
- [ ] Commit and push formula update
- [ ] **Verification:** Formula SHA matches release tarball

## Phase 4: Documentation

### 4.1 Update README
- [ ] Add Homebrew installation instructions
- [ ] Add development setup section
- [ ] Document release process
- [ ] **Verification:** README reflects new install method

### 4.2 Create CONTRIBUTING.md (optional)
- [ ] Document local development workflow
- [ ] Explain release tagging process
- [ ] **Verification:** Contributors can follow guide

## Dependencies

```
Phase 1 (Packaging) → Phase 2 (Formula) → Phase 3 (Automation)
                                              ↓
                                       Phase 4 (Docs)
```

## Completion Summary

| Phase | Status |
|-------|--------|
| Phase 1: Python Packaging | Pending |
| Phase 2: Homebrew Formula | Pending |
| Phase 3: Release Automation | Pending |
| Phase 4: Documentation | Pending |
