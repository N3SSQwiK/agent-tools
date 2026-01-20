# Proposal: Add Event-Driven Continuity Triggers

## Problem

The continuity feature's automatic triggers aren't firing. The current implementation relies on passive instructions in `CLAUDE.md`, `GEMINI.md`, and `AGENTS.md` that tell AI assistants to check for `.ai/CONTINUITY.md` at session start and suggest updates after milestones.

**The core issue**: These instructions are guidance, not enforcement. AI assistants process thousands of tokens of context and don't reliably prioritize these instructions—especially at session boundaries where no explicit user prompt references them.

**Current behavior**:
- ✅ `/continuity` slash command works flawlessly when explicitly invoked
- ❌ Session start: AI doesn't automatically present continuity context
- ❌ Milestone completion: AI doesn't prompt to update continuity after PRs/merges

## Solution

Replace passive instructions with event-driven hooks where the CLI tool supports them; implement workarounds where hooks aren't available.

| CLI Tool | Hook Support | Solution |
|----------|--------------|----------|
| Claude Code | Full | `SessionStart` + `PostToolUse` hooks |
| Gemini CLI | Full (experimental) | `SessionStart` + `PostToolUse` hooks |
| Codex CLI | Limited | `notify` script + git hooks |

## Scope

### In Scope

1. **Claude Code hooks**: `SessionStart` to present continuity, `PostToolUse` to detect milestones
2. **Gemini CLI hooks**: Mirror Claude Code implementation
3. **Codex CLI workarounds**: Turn-count notify script, git hooks for milestones
4. **Installer updates**: Deploy hooks/scripts to appropriate locations
5. **Spec updates**: Document hook requirements in continuity and installer specs

### Out of Scope

- Codex `SessionStart` auto-load (not possible until Codex adds proper hooks)
- Over-engineering for hypothetical future Codex hook API
- Changes to the `/continuity` slash command behavior

## Capabilities Affected

- **continuity**: New requirements for event-driven triggers
- **installer**: New requirements for hook deployment

## Success Criteria

1. Claude Code automatically presents `.ai/CONTINUITY.md` on session start
2. Gemini CLI automatically presents `.ai/CONTINUITY.md` on session start
3. Claude/Gemini suggest running `/continuity` after milestone commands
4. Codex users receive desktop notifications after extended work sessions
5. All hooks are deployed via the existing installer flow

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| Gemini hooks are experimental | Document as experimental; monitor for API changes |
| Codex may add hooks later | Keep Codex implementation modular for easy migration |
| Hook scripts may fail silently | Include error handling and logging |
| Cross-platform compatibility | Use portable shell scripts; test on macOS/Linux |
