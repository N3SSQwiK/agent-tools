# Permissions Feature - Implementation Tasks

## Phase 1: Documentation + Templates (2-3 days)

### Task 1.1: Permission Equivalence Guide
**File:** `docs/PERMISSION-EQUIVALENCE.md`

Create a reference guide showing equivalent permission settings across tools:

- [ ] Document Claude Code permission modes (`default`, `acceptEdits`, `plan`, `bypassPermissions`)
- [ ] Document Codex CLI approval policies (`suggest`, `auto-edit`, `full-auto`)
- [ ] Document Gemini CLI settings (`default`, `auto_edit`, `yolo`)
- [ ] Create mapping table: "To achieve X trust level, configure Y in each tool"
- [ ] Document config file locations for each tool
- [ ] Document rule syntax differences (glob vs regex vs implicit)
- [ ] Include common gotchas and edge cases

### Task 1.2: Pre-built Config Templates
**Directory:** `installer/python/features/permissions/templates/`

Create config templates for each preset × tool combination:

- [ ] `claude/conservative.json` - Claude Code conservative preset
- [ ] `claude/balanced.json` - Claude Code balanced preset
- [ ] `claude/autonomous.json` - Claude Code autonomous preset
- [ ] `codex/conservative.toml` - Codex CLI conservative preset
- [ ] `codex/balanced.toml` - Codex CLI balanced preset
- [ ] `codex/autonomous.toml` - Codex CLI autonomous preset
- [ ] `gemini/conservative.json` - Gemini CLI conservative preset
- [ ] `gemini/balanced.json` - Gemini CLI balanced preset
- [ ] `gemini/autonomous.json` - Gemini CLI autonomous preset

Each template should include:
- Common safe commands (git status, npm test, etc.)
- Common deny rules (.env, secrets, keys)
- Comments explaining each rule

### Task 1.3: Common Scenario Snippets
**File:** `docs/PERMISSION-SNIPPETS.md`

Copy-paste snippets for common scenarios:

- [ ] "Allow all npm scripts"
- [ ] "Block all network access"
- [ ] "Auto-approve file reads, ask for writes"
- [ ] "Deny access to secrets and credentials"
- [ ] "Allow git operations except force push"
- [ ] "CI/CD headless mode setup"

---

## Phase 2: Lightweight Audit Logging (1-2 weeks)

### Task 2.1: Audit Log Format Design
**File:** `installer/python/features/permissions/audit.py`

Design the log format:

```
2026-01-20T10:15:32Z INFO  [claude] ALLOWED shell: git status
2026-01-20T10:15:45Z INFO  [claude] ASKED   shell: npm install
2026-01-20T10:15:47Z INFO  [claude] APPROVED shell: npm install (user)
2026-01-20T10:16:02Z WARN  [claude] DENIED  file: .env (rule: deny **/.env*)
```

- [ ] Define log entry schema (timestamp, level, tool, action, target, rule)
- [ ] Implement append-only file writer (`.ai/permissions.log`)
- [ ] Add log rotation (keep last 7 days or 10MB)
- [ ] Create `AuditLogger` class with `log_allowed()`, `log_denied()`, `log_asked()`, `log_approved()`

### Task 2.2: Claude Code Audit Hook
**Files:** `installer/python/features/permissions/claude/hooks/audit.sh`

- [ ] Create PreToolUse hook that logs permission checks
- [ ] Create PostToolUse hook that logs approvals
- [ ] Add hook configuration to settings.json template
- [ ] Test with common operations (Read, Edit, Bash)

### Task 2.3: Codex CLI Audit Integration
**Research required:** Determine if Codex has hook system or event callbacks

- [ ] Research Codex CLI extensibility options
- [ ] Implement audit logging if possible
- [ ] Document limitations if not possible

### Task 2.4: Gemini CLI Audit Integration
**Research required:** Determine if Gemini has hook system or event callbacks

- [ ] Research Gemini CLI extensibility options
- [ ] Implement audit logging if possible
- [ ] Document limitations if not possible

### Task 2.5: Audit Analysis Commands
**File:** `installer/python/features/permissions/cli.py`

- [ ] `/permissions audit` - Show recent events
- [ ] `/permissions audit --tool claude` - Filter by tool
- [ ] `/permissions audit --action denied` - Filter by action
- [ ] `/permissions audit --stats` - Show permission fatigue analysis
- [ ] `/permissions audit --export json` - Export for analysis

---

## Phase 3: Survey (1 week)

### Task 3.1: Design Survey Questions
Based on audit data collected in Phase 2:

- [ ] "Do you actively configure permissions on more than one AI CLI tool?"
- [ ] "Do you want the *same* permission rules across tools, or intentionally different?"
- [ ] "What's your primary tool vs. secondary tools?"
- [ ] "When you configure permissions, do you copy settings between tools, or configure each independently?"
- [ ] Add questions informed by audit patterns (e.g., "We observed X is approved 95% of the time. Should it be auto-allowed?")

### Task 3.2: Create Survey
- [ ] Set up GitHub Discussion or Google Form
- [ ] Include context about what we're building
- [ ] Share with Nexus-AI users

### Task 3.3: Analyze Results
- [ ] Compile responses
- [ ] Validate/invalidate assumptions
- [ ] Adjust Phase 4 design based on findings

---

## Phase 4: Preset Commands (1-2 weeks)

### Task 4.1: Core Preset Engine
**File:** `installer/python/features/permissions/presets.py`

- [ ] Define `Preset` dataclass with trust levels
- [ ] Implement `CONSERVATIVE`, `BALANCED`, `AUTONOMOUS` presets
- [ ] Add method to convert preset to native config format

### Task 4.2: Claude Code Preset Writer
**File:** `installer/python/features/permissions/writers/claude.py`

- [ ] Read existing `.claude/settings.json`
- [ ] Merge preset rules with existing rules (for `--merge`)
- [ ] Write updated config
- [ ] Implement `--dry-run` (show diff without writing)
- [ ] Track Nexus-managed rules for `reset` command

### Task 4.3: Codex CLI Preset Writer
**File:** `installer/python/features/permissions/writers/codex.py`

- [ ] Read existing `~/.codex/config.toml`
- [ ] Merge preset rules with existing rules
- [ ] Write updated config
- [ ] Implement `--dry-run`
- [ ] Track Nexus-managed rules for `reset`

### Task 4.4: Gemini CLI Preset Writer
**File:** `installer/python/features/permissions/writers/gemini.py`

- [ ] Read existing `.gemini/settings.json`
- [ ] Merge preset rules with existing rules
- [ ] Write updated config
- [ ] Implement `--dry-run`
- [ ] Track Nexus-managed rules for `reset`

### Task 4.5: Slash Commands
**Files:**
- `installer/python/features/permissions/claude/commands/permissions.md`
- `installer/python/features/permissions/gemini/extensions/permissions/`
- `installer/python/features/permissions/codex/prompts/permissions.md`

Implement commands for each tool:

- [ ] `/permissions preset <name>` - Apply preset
- [ ] `/permissions preset <name> --merge` - Merge with existing
- [ ] `/permissions preset <name> --dry-run` - Preview changes
- [ ] `/permissions show` - Show current permissions
- [ ] `/permissions diff` - Show deviation from closest preset
- [ ] `/permissions diff <name>` - Deviation from specific preset
- [ ] `/permissions export` - Dump current config
- [ ] `/permissions reset` - Remove Nexus rules

### Task 4.6: Add to Nexus-AI Installer
**File:** `installer/python/nexus.py`

- [ ] Add "Permissions" feature to TUI
- [ ] Allow selecting which tools to configure
- [ ] Allow selecting preset during install

---

## Deferred: Full Translation Layer

**Only pursue if Phase 3 survey validates demand AND Phase 4 presets prove insufficient.**

Tasks from original spec:
- Unified schema parser (`.ai/permissions.yaml`)
- Translation engine
- Drift detection
- Conflict resolution UI

---

## Definition of Done

Each phase is complete when:

1. **Phase 1:** Docs are in `docs/`, templates are installable, README references them
2. **Phase 2:** Audit log captures events from at least Claude Code, analysis commands work
3. **Phase 3:** Survey completed, results documented, Phase 4 design adjusted if needed
4. **Phase 4:** `/permissions preset balanced` works on all three tools with safety flags

## Notes

- Use managed blocks pattern (like Continuity/Maestro) for any generated content
- All file writes should preserve user content outside managed blocks
- Test on macOS and Linux; Windows support is secondary
