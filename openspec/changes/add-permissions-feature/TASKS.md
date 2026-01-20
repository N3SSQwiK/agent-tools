# Tasks: Add Permissions Feature

## Phase 1: Documentation + Templates

### 1.1 Create Feature Directory Structure
- [ ] Create `installer/python/features/permissions/` directory
- [ ] Create subdirectories: `claude/commands/`, `codex/prompts/`, `gemini/extensions/permissions/commands/`
- [ ] Create `templates/claude/`, `templates/codex/`, `templates/gemini/`
- [ ] Create `docs/` subdirectory

### 1.2 Move Templates from Research
- [ ] Copy `docs/Research/permissions-feature/templates/claude/*.json` → `installer/python/features/permissions/templates/claude/`
- [ ] Copy `docs/Research/permissions-feature/templates/codex/*.toml` → `installer/python/features/permissions/templates/codex/`
- [ ] Copy `docs/Research/permissions-feature/templates/gemini/*` → `installer/python/features/permissions/templates/gemini/`
- [ ] Add `_nexus` metadata block to each template for version tracking

### 1.3 Create Permission Equivalence Guide
- [ ] Move `docs/Research/permissions-feature/permission-equivalence-guide.md` → `docs/PERMISSION-EQUIVALENCE.md`
- [ ] Review and update content for accuracy
- [ ] Add link to guide in main `README.md`

### 1.4 Create Permission Snippets Document
- [ ] Create `docs/PERMISSION-SNIPPETS.md`
- [ ] Add snippet: "Allow all npm scripts"
- [ ] Add snippet: "Block all network access"
- [ ] Add snippet: "Auto-approve file reads, ask for writes"
- [ ] Add snippet: "Deny access to secrets and credentials"
- [ ] Add snippet: "Allow git operations except force push"
- [ ] Add snippet: "CI/CD headless mode setup"

### 1.5 Create Placeholder Commands
- [ ] Create `installer/python/features/permissions/claude/commands/permissions.md` (stub for Phase 4)
- [ ] Create `installer/python/features/permissions/codex/prompts/permissions.md` (stub for Phase 4)
- [ ] Create `installer/python/features/permissions/gemini/extensions/permissions/gemini-extension.json`
- [ ] Create `installer/python/features/permissions/gemini/extensions/permissions/commands/permissions.toml` (stub for Phase 4)

### 1.6 Register Feature in Installer
- [ ] Add "Permissions" feature to `FEATURES` list in `nexus.py`
- [ ] Set `default=False` (opt-in feature)
- [ ] Test TUI shows feature in selection screen

### 1.7 Validation
- [ ] Run installer with Permissions selected
- [ ] Verify templates copied to `~/.nexus/permissions/templates/`
- [ ] Verify placeholder commands installed to each tool

---

## Phase 2: Audit Logging

### 2.1 Create Audit Hook for Claude Code
- [ ] Create `installer/python/features/permissions/claude/hooks/permissions-audit-pre.sh`
- [ ] Create `installer/python/features/permissions/claude/hooks/permissions-audit-post.sh`
- [ ] Implement log format: `TIMESTAMP LEVEL [tool] ACTION Target: details`
- [ ] Handle missing `.ai/` directory (create or use global fallback)
- [ ] Set correct file permissions (600)

### 2.2 Update Installer for Hook Deployment
- [ ] Extend installer to copy hooks to `~/.claude/hooks/`
- [ ] Register hooks in Claude Code settings (if required)
- [ ] Document hook installation in feature README

### 2.3 Create Audit Analysis Command
- [ ] Implement `/permissions audit` command logic
- [ ] Add `--tool <name>` filter
- [ ] Add `--action <name>` filter
- [ ] Add `--since <time>` filter
- [ ] Format output as readable table

### 2.4 Create Stats Analysis
- [ ] Implement `/permissions audit --stats`
- [ ] Calculate most frequently asked permissions
- [ ] Calculate denial rate
- [ ] Calculate asks per hour
- [ ] Generate recommendations for auto-allow candidates

### 2.5 Implement Log Rotation
- [ ] Add rotation logic to audit command (triggered on read)
- [ ] Rotate when log exceeds 10MB or 10,000 lines
- [ ] Keep last 2 rotations (`.log.1`, `.log.2`)

### 2.6 Research Codex/Gemini Extensibility
- [ ] Research Codex CLI hook/callback support
- [ ] Research Gemini CLI hook/callback support
- [ ] Document findings in `DESIGN.md`
- [ ] Implement hooks if supported, or document limitation

### 2.7 Validation
- [ ] Manual test: run Claude Code with audit hooks
- [ ] Verify log entries appear in `.ai/permissions.log`
- [ ] Test `/permissions audit` command
- [ ] Test `/permissions audit --stats` command
- [ ] Test log rotation

---

## Definition of Done

### Phase 1 Complete When:
- [ ] Templates installable via TUI
- [ ] Docs moved to `docs/` and linked from README
- [ ] Placeholder commands installed for all three tools

### Phase 2 Complete When:
- [ ] Claude Code audit hooks capture permission events
- [ ] `/permissions audit` command displays recent events
- [ ] `/permissions audit --stats` shows permission fatigue analysis
- [ ] Log rotation prevents unbounded growth
- [ ] Codex/Gemini extensibility documented (even if "not supported")
