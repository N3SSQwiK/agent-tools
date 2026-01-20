# Tasks: Add Feature Uninstall to TUI

## Phase 1: Detection Logic

### 1.1 Implement feature detection function
- [ ] Create `detect_installed_features()` function in `nexus.py`
- [ ] Detect Claude Code installations via `~/.claude/commands/{feature}*.md`
- [ ] Detect Gemini CLI installations via `~/.gemini/extensions/{feature}/`
- [ ] Detect Codex CLI installations via `~/.codex/prompts/{feature}*.md`
- [ ] Return dict mapping feature_id → {tool_id → is_installed}
- **Validation**: Unit test with mock filesystem; manual test on real install

### 1.2 Handle edge cases in detection
- [ ] Handle missing tool directories gracefully (tool not installed)
- [ ] Handle empty directories (tool installed but no features)
- [ ] Handle glob patterns for multi-command features (e.g., `maestro-*.md`)
- **Validation**: Test with partial installations, missing directories

## Phase 2: Welcome Screen Modification

### 2.1 Add mode selection to WelcomeScreen
- [ ] Add `SelectableItem` widgets for "Install features" and "Uninstall features"
- [ ] Track selected mode in screen state
- [ ] Update key bindings for navigation (up/down/enter)
- [ ] Route to appropriate next screen based on mode
- **Validation**: Visual test; verify both paths work

### 2.2 Update welcome screen styling
- [ ] Position mode selection below banner
- [ ] Match existing SelectableItem styling
- [ ] Update help text to reflect new options
- **Validation**: Visual consistency with existing screens

## Phase 3: Uninstall Feature Screen

### 3.1 Create UninstallFeatureScreen class
- [ ] New Screen subclass with single-select list of features
- [ ] Call `detect_installed_features()` on mount
- [ ] Display features with "Detected in: Tool1, Tool2" subtitle
- [ ] Handle empty state (no features installed)
- **Validation**: Displays correctly with 0, 1, and multiple features

### 3.2 Implement navigation and selection
- [ ] Up/down navigation between features
- [ ] Enter to select and proceed to UninstallToolsScreen
- [ ] Escape to go back to WelcomeScreen
- [ ] Pass selected feature to next screen
- **Validation**: Navigation works; state passed correctly

## Phase 4: Uninstall Tools Screen

### 4.1 Create UninstallToolsScreen class
- [ ] New Screen subclass receiving feature_id from previous screen
- [ ] Display tool checkboxes based on detection results
- [ ] Disable checkboxes for tools where feature not installed
- [ ] Pre-select all tools where feature is installed
- **Validation**: Correct tools shown as installed/not installed

### 4.2 Implement tool selection logic
- [ ] Space to toggle tool selection (only for installed tools)
- [ ] Enter to add to queue and proceed to confirm
- [ ] "Add another feature" action (+ key or button)
- [ ] Escape to go back to UninstallFeatureScreen
- **Validation**: Selection works; queue accumulates correctly

### 4.3 Implement uninstall queue
- [ ] Create `UninstallItem` dataclass (feature_id, tools list)
- [ ] Add app-level `uninstall_queue` list
- [ ] "Add another" returns to feature selection with queue intact
- [ ] Queue displayed/processed in confirm screen
- **Validation**: Multiple features can be queued

## Phase 5: Uninstall Confirm Screen

### 5.1 Create UninstallConfirmScreen class
- [ ] New Screen subclass displaying queued uninstalls
- [ ] List each feature with specific file/directory paths
- [ ] Show CLI running warning message
- **Validation**: All queued items displayed with correct paths

### 5.2 Implement confirmation actions
- [ ] Enter to confirm and proceed to UninstallingScreen
- [ ] Escape to cancel and return to tools screen
- [ ] Clear queue on cancel (or preserve for editing?)
- **Validation**: Confirm proceeds; cancel doesn't delete anything

## Phase 6: Uninstall Execution

### 6.1 Implement Claude Code uninstall
- [ ] Create `uninstall_claude(feature_id)` async function
- [ ] Delete all matching command files
- [ ] Handle FileNotFoundError gracefully
- **Validation**: Files deleted; missing files don't cause errors

### 6.2 Implement Gemini CLI uninstall
- [ ] Create `uninstall_gemini(feature_id)` async function
- [ ] Delete extension directory recursively
- [ ] Update `extension-enablement.json` to remove feature
- **Validation**: Directory deleted; enablement updated

### 6.3 Implement Codex CLI uninstall
- [ ] Create `uninstall_codex(feature_id)` async function
- [ ] Delete all matching prompt files
- [ ] Handle FileNotFoundError gracefully
- **Validation**: Files deleted; missing files don't cause errors

### 6.4 Implement managed block rebuild
- [ ] After file deletion, determine remaining installed features per tool
- [ ] Call existing `write_managed_config()` with remaining features
- [ ] Handle case where no features remain (empty or remove block)
- **Validation**: Config files updated correctly; no duplicates

### 6.5 Create UninstallingScreen class
- [ ] New Screen subclass similar to InstallingScreen
- [ ] Build step list from uninstall queue
- [ ] Process steps with progress indication
- [ ] Rebuild configs after all file deletions
- [ ] Transition to UninstallDoneScreen on completion
- **Validation**: Progress displays; all steps complete

## Phase 7: Uninstall Done Screen

### 7.1 Create UninstallDoneScreen class
- [ ] New Screen subclass showing completion summary
- [ ] List removed features and tools
- [ ] Enter/q to exit
- **Validation**: Summary accurate; exit works

## Phase 8: Integration & Polish

### 8.1 Wire up screen transitions
- [ ] WelcomeScreen → UninstallFeatureScreen
- [ ] UninstallFeatureScreen → UninstallToolsScreen
- [ ] UninstallToolsScreen → UninstallConfirmScreen (or back to feature)
- [ ] UninstallConfirmScreen → UninstallingScreen
- [ ] UninstallingScreen → UninstallDoneScreen
- **Validation**: Full flow works end-to-end

### 8.2 Add CSS styling for new screens
- [ ] Style UninstallFeatureScreen
- [ ] Style UninstallToolsScreen
- [ ] Style UninstallConfirmScreen (warning styling)
- [ ] Style UninstallDoneScreen
- **Validation**: Visual consistency with install flow

### 8.3 End-to-end testing
- [ ] Install features via TUI
- [ ] Uninstall single feature from single tool
- [ ] Uninstall single feature from multiple tools
- [ ] Uninstall multiple features via queue
- [ ] Verify files removed and configs updated
- [ ] Re-run install to verify features can be reinstalled
- **Validation**: Full cycle works correctly

## Dependencies

- Phase 1 must complete before Phase 3 (detection needed for feature list)
- Phases 2-5 can be worked in sequence (screen flow)
- Phase 6 can start after Phase 1 (uninstall logic independent of UI)
- Phase 7 depends on Phase 6 (needs completion to show summary)
- Phase 8 depends on all previous phases
