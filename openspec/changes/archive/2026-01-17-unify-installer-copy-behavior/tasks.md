# Tasks: Unify Installer Copy Behavior

## 1. Implementation

- [x] 1.1 Update `install_claude()` to use `write_text()` instead of `symlink_to()`
- [x] 1.2 Update `install_codex()` to use `write_text()` instead of `symlink_to()`
- [x] 1.3 Update existing symlink handling to replace with file on reinstall

## 2. Testing

- [x] 2.1 Run installer with Claude + Maestro, verify files are copies (not symlinks)
- [x] 2.2 Run installer with Codex + Maestro, verify files are copies (not symlinks)
- [x] 2.3 Re-run installer over existing installation, verify idempotency

## 3. Documentation

- [x] 3.1 Update CLAUDE.md feature structure docs if needed
- [ ] 3.2 Commit and push changes
