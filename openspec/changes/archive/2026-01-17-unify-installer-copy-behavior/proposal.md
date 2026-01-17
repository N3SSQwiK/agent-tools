# Change: Unify Installer to Use File Copies for All Tools

## Why

The installer currently uses inconsistent installation methods:
- **Claude Code:** Symlinks (requires repo to exist)
- **Gemini CLI:** File copies (self-contained)
- **Codex CLI:** Symlinks (requires repo to exist)

This inconsistency creates problems:
1. **Broken commands:** If users delete or move the cloned repo, Claude/Codex commands break (dangling symlinks)
2. **Confusing mental model:** Users expect "install = done", not "install = linked to repo"
3. **Distribution friction:** Users can't share their `~/.claude/commands/` setup without also sharing the repo
4. **Inconsistent update mechanism:** Gemini requires reinstall, Claude/Codex auto-update on `git pull`

## What Changes

- **MODIFIED** Claude Code Installation: Change from symlinks to file copies
- **MODIFIED** Codex CLI Installation: Change from symlinks to file copies
- **MODIFIED** Installation Idempotency: Update symlink scenario to file copy scenario

## Proposed Solution

Change both `install_claude()` and `install_codex()` functions to use the same copy pattern as `install_gemini()`:

```python
# Before (symlink)
dst_cmd.symlink_to(src_cmd)

# After (copy)
dst_cmd.write_text(src_cmd.read_text())
```

## Scope

### In Scope
- Change Claude command installation from symlinks to copies
- Change Codex prompt installation from symlinks to copies
- Update idempotency behavior for file replacement

### Out of Scope
- Gemini installation (already uses copies)
- Config file merging behavior (unchanged)
- TUI flow (unchanged)

## Success Criteria

1. All three tools use consistent file copy installation
2. Commands work even if repo is deleted after install
3. Existing symlinks are replaced with copies on reinstall
4. `openspec validate --strict` passes

## Impact

- Affected specs: `installer`
- Affected code: `installer/python/nexus.py` (functions `install_claude`, `install_codex`)
- **Trade-off:** Users must re-run installer to get updates (no more auto-update via git pull)
