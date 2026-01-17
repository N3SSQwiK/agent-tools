# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

<!-- OPENSPEC:START -->
# OpenSpec Instructions

These instructions are for AI assistants working in this project.

Always open `@/openspec/AGENTS.md` when the request:
- Mentions planning or proposals (words like proposal, spec, change, plan)
- Introduces new capabilities, breaking changes, architecture shifts, or big performance/security work
- Sounds ambiguous and you need the authoritative spec before coding

Use `@/openspec/AGENTS.md` to learn:
- How to create and apply change proposals
- Spec format and conventions
- Project structure and guidelines

Keep this managed block so 'openspec update' can refresh the instructions.

<!-- OPENSPEC:END -->

## Commands

```bash
# Run the TUI installer (creates venv on first run)
./install.sh

# Run Python installer directly (requires venv setup)
installer/python/venv/bin/python installer/python/nexus.py

# Legacy bash-only installers
./install-claude.sh
./install-gemini.sh
./install-codex.sh
```

## Architecture

**Nexus-AI** is a TUI installer for configuring AI assistant CLI tools (Claude Code, Gemini CLI, Codex CLI) with shared features.

### Entry Points
- `install.sh` - Bash bootstrap that detects Python, creates venv, runs TUI
- `installer/python/nexus.py` - Textual TUI app with multi-screen wizard flow

### Installation Flow
1. WelcomeScreen → ToolsScreen (select assistants) → FeaturesScreen → InstallingScreen → DoneScreen
2. Each tool installs to its config directory:
   - Claude: `~/.claude/commands/` (copies)
   - Gemini: `~/.gemini/extensions/` (copies + JSON enablement)
   - Codex: `~/.codex/prompts/` (copies)

### Feature Structure
Features live in `features/<name>/` with tool-specific subdirectories:
```
features/<name>/
├── claude/
│   ├── CLAUDE.md                 # Global instructions (merged)
│   └── commands/<name>[-*].md    # Slash command(s) (copied)
├── gemini/
│   ├── GEMINI.md                 # Global instructions (merged)
│   └── extensions/<name>/        # Extension bundle (copied)
└── codex/
    ├── AGENTS.md                 # Global instructions (merged)
    └── prompts/<name>[-*].md     # Prompt(s) (copied)
```

Multi-command features use the `<name>-<subcommand>.md` pattern (e.g., `maestro-plan.md`, `maestro-run.md`).

### Managed Blocks
Config files use markers to preserve user content during updates:
```markdown
<!-- Nexus-AI:START -->
# Global Instructions
[Installer-managed content from all features]
<!-- Nexus-AI:END -->
```
The `write_managed_config()` function in `nexus.py` rebuilds the entire block from all selected features.

## Design

Fraternal color scheme:
- Red: #C41E3A
- White: #FFFFFF
- Navy: #1E3A8A
- Gold: #E8C547 (accent)
