# Tasks: Add Event-Driven Continuity Triggers

## Phase 1: Claude Code Hooks

### 1.1 Create hook scripts for Claude Code
- [ ] Create `features/continuity/claude/hooks/` directory
- [ ] Implement `session-start.sh` (check for `.ai/CONTINUITY.md`, output JSON with `additionalContext`)
- [ ] Implement `milestone-check.sh` (pattern-match milestone commands, suggest `/continuity`)
- [ ] Make scripts executable
- **Validation**: Run scripts manually with test JSON input; verify JSON output format

### 1.2 Create Claude Code hooks.json
- [ ] Create `features/continuity/claude/hooks/hooks.json`
- [ ] Configure `SessionStart` hook with `startup` matcher
- [ ] Configure `PostToolUse` hook with `Bash` matcher
- [ ] Use `${CLAUDE_PLUGIN_ROOT}` for script paths (or determine correct path pattern)
- **Validation**: JSON is valid; hook events and matchers are correct

### 1.3 Test Claude Code hooks manually
- [ ] Copy hooks to `~/.claude/` manually
- [ ] Add hook configuration to `~/.claude/settings.json`
- [ ] Start new Claude Code session in project with `.ai/CONTINUITY.md`
- [ ] Verify continuity content is presented
- [ ] Run `gh pr create` (or similar) and verify milestone suggestion appears
- **Validation**: Both triggers fire correctly

## Phase 2: Gemini CLI Hooks

### 2.1 Create hook scripts for Gemini CLI
- [ ] Create `features/continuity/gemini/extensions/continuity/hooks/` directory
- [ ] Copy/adapt `session-start.sh` from Claude (adjust tool name in messages)
- [ ] Copy/adapt `milestone-check.sh` from Claude (adjust matcher if needed)
- [ ] Make scripts executable
- **Validation**: Scripts are portable; no Claude-specific assumptions

### 2.2 Create Gemini CLI hooks.json
- [ ] Create `features/continuity/gemini/extensions/continuity/hooks/hooks.json`
- [ ] Configure `SessionStart` hook with `startup` matcher
- [ ] Configure `PostToolUse` hook with `Shell` matcher (verify Gemini's tool name)
- **Validation**: JSON is valid; aligns with Gemini hook API

### 2.3 Test Gemini CLI hooks manually
- [ ] Copy extension with hooks to `~/.gemini/extensions/`
- [ ] Enable extension in `enabled.json`
- [ ] Start new Gemini CLI session in project with `.ai/CONTINUITY.md`
- [ ] Verify continuity content is presented
- [ ] Run milestone command and verify suggestion appears
- **Validation**: Both triggers fire correctly (note: hooks are experimental)

## Phase 3: Codex CLI Workarounds

### 3.1 Create turn-reminder notify script
- [ ] Create `features/continuity/codex/notify/` directory
- [ ] Implement `turn-reminder.sh`:
  - Parse `agent-turn-complete` events
  - Track count in `.ai/.codex-turn-count`
  - Show notification at threshold (100)
  - Support both macOS (`osascript`) and Linux (`notify-send`)
- [ ] Make script executable
- **Validation**: Script handles JSON input correctly; notification fires

### 3.2 Create git hooks for Codex
- [ ] Create `features/continuity/codex/git-hooks/` directory
- [ ] Implement `post-merge` hook (show notification on merge)
- [ ] Implement `post-push` hook (custom hook, show notification on push)
- [ ] Make hooks executable
- **Validation**: Hooks fire correctly when git operations complete

### 3.3 Test Codex CLI workarounds manually
- [ ] Configure notify script in `~/.codex/config.json`
- [ ] Start Codex session and complete many turns (or lower threshold for testing)
- [ ] Verify notification appears at threshold
- [ ] Install git hooks in test repo
- [ ] Verify merge/push notifications appear
- **Validation**: All workarounds function correctly

## Phase 4: Installer Updates

### 4.1 Add Claude Code hook installation
- [ ] Update `nexus.py` to detect `hooks/` directory in Claude features
- [ ] Implement hook script copying to `~/.claude/hooks/<feature>/`
- [ ] Implement `hooks.json` merging into `~/.claude/settings.json`
- [ ] Handle path rewriting in merged hooks
- **Validation**: Hooks installed correctly; settings.json is valid

### 4.2 Add Gemini CLI hook installation
- [ ] Update `nexus.py` to copy `hooks/` directory with extension
- [ ] Ensure scripts are executable after copy
- [ ] Verify `hooks.json` is included in extension
- **Validation**: Extension hooks discovered by Gemini CLI

### 4.3 Add Codex CLI notify/git-hooks installation
- [ ] Update `nexus.py` to detect `notify/` directory
- [ ] Copy notify scripts to `~/.codex/scripts/<feature>/`
- [ ] Update `~/.codex/config.json` with notify path
- [ ] Copy git-hooks to `~/.codex/git-hooks/<feature>/`
- [ ] Add installation instructions to Done screen
- **Validation**: Notify configured; git hooks available for manual install

### 4.4 Handle conflicts and edge cases
- [ ] Handle multiple features with hooks (merge configurations)
- [ ] Handle Codex single-notify limitation (warn or create wrapper)
- [ ] Ensure idempotent installation (re-running doesn't break hooks)
- **Validation**: Installer handles all edge cases gracefully

## Phase 5: End-to-End Testing

### 5.1 Test full installation flow
- [ ] Run installer with continuity feature selected
- [ ] Verify hooks installed for Claude Code
- [ ] Verify hooks installed for Gemini CLI
- [ ] Verify notify script configured for Codex CLI
- [ ] Verify git hooks available in `~/.codex/git-hooks/`
- **Validation**: Complete installation succeeds

### 5.2 Test triggers in real usage
- [ ] Start fresh Claude Code session; verify continuity presented
- [ ] Complete a PR; verify milestone suggestion
- [ ] Start fresh Gemini CLI session; verify continuity presented
- [ ] Run extended Codex session; verify turn notification
- [ ] Perform git merge with hook installed; verify notification
- **Validation**: All triggers fire as expected in real usage

## Phase 6: Documentation

### 6.1 Update CLAUDE.md with hook documentation
- [ ] Document hook locations and configuration
- [ ] Document how to customize or disable hooks
- **Validation**: Documentation is accurate and helpful

### 6.2 Update README or feature documentation
- [ ] Document the automatic trigger behavior
- [ ] Document Codex limitations and workarounds
- [ ] Document git hook manual installation
- **Validation**: Users understand what to expect

---

## Dependencies

- Phase 2 can run in parallel with Phase 1 (scripts are similar)
- Phase 3 can run in parallel with Phases 1-2 (independent tool)
- Phase 4 depends on Phases 1-3 (need scripts to install)
- Phase 5 depends on Phase 4 (need installer to test)
- Phase 6 can start after Phase 4
