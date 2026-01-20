# Proposal: Add Feature Uninstall to TUI

## Problem

The Nexus-AI TUI installer can install features but provides no way to uninstall them. Users who want to remove a feature must manually:

1. Delete command/prompt files from `~/.claude/commands/`, `~/.codex/prompts/`
2. Delete extension directories from `~/.gemini/extensions/`
3. Edit managed blocks in `CLAUDE.md`, `GEMINI.md`, `AGENTS.md`
4. Update `extension-enablement.json` for Gemini

This is error-prone and requires knowledge of the installation structure.

## Solution

Add an uninstall flow to the TUI with a two-step selection process:
1. First, select a feature to uninstall
2. Then, select which tools to uninstall it from

This provides granular control (feature × tool level) while keeping the UI scalable for any number of features.

## Scope

### In Scope

1. **New TUI screens**: Feature selection → Tool selection → Confirm → Progress → Done
2. **Filesystem detection**: Detect installed features by checking known file locations
3. **Uninstall actions**: Delete files, rebuild managed blocks, update enablement
4. **Entry point**: New choice on WelcomeScreen ("Install" vs "Uninstall")
5. **Queue support**: "Add Another Feature" to batch multiple uninstalls

### Out of Scope

- State file / installation manifest (filesystem detection is sufficient)
- Bulk "uninstall all" (user selects features one at a time)
- Rollback / undo uninstall
- Hook uninstallation (will be added when hooks proposal ships)

## Detection Strategy

**Filesystem-based detection** (no state file):

| Tool | Detection Method |
|------|------------------|
| Claude Code | `~/.claude/commands/{feature}*.md` exists |
| Gemini CLI | `~/.gemini/extensions/{feature}/` directory exists |
| Codex CLI | `~/.codex/prompts/{feature}*.md` exists |
| Config merged | Feature content present in managed block |

## Edge Cases

| Scenario | Behavior |
|----------|----------|
| Expected file missing | Silent skip (already gone, nothing to remove) |
| File was renamed by user | Not detected as installed; user's responsibility |
| CLI tool is running | Warning before uninstall proceeds |
| Partial feature install | Only show tools where feature is detected |
| User cancels mid-flow | No changes made until final confirm |
| No features installed | Show message, no uninstall action available |

## Success Criteria

1. User can uninstall any feature from any tool via TUI
2. Uninstalling removes command files, extensions, and managed block content
3. Gemini extension enablement is updated on uninstall
4. Re-running installer after uninstall shows feature as not installed
5. Uninstall is idempotent (running twice doesn't error)

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| User accidentally uninstalls wrong feature | Confirmation screen before execution |
| Managed block parsing fails | Robust regex; warn and skip on parse failure |
| Files have been modified by user | Detect by filename only; user responsible for renamed files |
