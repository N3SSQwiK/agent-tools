# Installer Design

## Context

The Nexus-AI installer provides a unified way to configure multiple AI coding assistant CLI tools with shared features. It must handle different installation mechanisms per tool while maintaining a consistent user experience.

## Tech Stack

| Component | Technology | Rationale |
|-----------|------------|-----------|
| TUI Framework | Python + Textual | Rich terminal UI, cross-platform, good accessibility |
| Alternative | Go + Bubbletea | Available at `installer/go/` (legacy) |
| Bootstrap | Bash (`install.sh`) | Detects Python, creates venv, launches TUI |

## Architecture

### Entry Points

```
install.sh (bash)
    └── Creates venv if needed
    └── Installs dependencies (textual)
    └── Launches installer/python/nexus.py

installer/python/nexus.py (Python)
    └── Textual App with screen-based wizard flow
```

### Screen Flow

```
WelcomeScreen
    │
    ▼
ToolsScreen (select: Claude, Gemini, Codex)
    │
    ▼
FeaturesScreen (select: continuity, maestro, etc.)
    │
    ▼
InstallingScreen (executes installation)
    │
    ▼
DoneScreen (summary)
```

### Key Data Structures

```python
@dataclass
class Tool:
    name: str        # "claude", "gemini", "codex"
    display: str     # "Claude Code", "Gemini CLI", "Codex CLI"
    config_dir: str  # "~/.claude", "~/.gemini", "~/.codex"

@dataclass
class Feature:
    name: str        # "continuity", "maestro"
    directory: str   # Feature directory name in features/
    description: str # Displayed in TUI
    default: bool    # Pre-selected state
```

## Key Functions

### `write_managed_config(dst_path, src_paths)`

**Purpose:** Rebuild managed block from all selected feature configs.

**Algorithm:**
1. Collect content from all source files that exist
2. Join contents with double newline separator
3. Build managed block with markers
4. If destination doesn't exist, create with managed block
5. If destination has existing managed block, replace it entirely
6. If no managed block exists, append new block

**Key Behavior:** The entire managed block is rebuilt on each run. This ensures:
- No stale content from updated features
- Feature removal is automatic (deselected features are excluded)
- Idempotent results (same inputs → same outputs)

**Markers:**
```
<!-- Nexus-AI:START -->
[all feature content]
<!-- Nexus-AI:END -->
```

### `install_claude(repo, features, claude_dir)`

**Purpose:** Install features for Claude Code.

**Steps:**
1. Create `~/.claude/commands/` if needed
2. For each feature:
   - Merge `CLAUDE.md` into `~/.claude/CLAUDE.md`
   - Glob `features/<feature>/claude/commands/<feature>-*.md`
   - Symlink each command file to `~/.claude/commands/`

### `install_gemini(repo, features, gemini_dir)`

**Purpose:** Install features for Gemini CLI.

**Steps:**
1. Create `~/.gemini/extensions/` if needed
2. For each feature:
   - Merge `GEMINI.md` into `~/.gemini/GEMINI.md`
   - Copy `gemini-extension.json` to extension directory
   - Glob and copy all `<feature>-*.toml` command files
   - Update `enabled.json` with `"<feature>": true`

### `install_codex(repo, features, codex_dir)`

**Purpose:** Install features for Codex CLI.

**Steps:**
1. Create `~/.codex/prompts/` if needed
2. For each feature:
   - Merge `AGENTS.md` into `~/.codex/AGENTS.md`
   - Glob `features/<feature>/codex/prompts/<feature>-*.md`
   - Symlink each prompt file to `~/.codex/prompts/`

## Design Decisions

### Decision: Symlinks for Claude/Codex, Copies for Gemini

**Rationale:**
- Claude and Codex support symlinked commands, enabling live updates from the repo
- Gemini requires files in specific locations with extension manifest, so copies are used

**Trade-off:** Gemini users must re-run installer to get updates; Claude/Codex get updates via `git pull`.

### Decision: Single Managed Block (Rebuilt)

**Rationale:**
- Simpler than per-feature namespaced blocks
- User content outside markers is preserved
- Rebuild approach ensures no stale content after feature updates
- Automatically removes deselected features

**Alternative Considered:**
1. Per-feature blocks (`<!-- Nexus-AI:feature:START -->`). Rejected due to added complexity.
2. Incremental merge with duplicate detection. Rejected because it couldn't handle updated content (only exact duplicates detected).

### Decision: Glob Pattern for Multi-Command Features

**Rationale:**
- Features like Maestro have 6+ commands
- Single-file assumption was limiting
- Glob `<feature>-*.md` handles both single and multi-command features

**Pattern:** `<feature>-*.md` matches `maestro-plan.md`, `maestro-run.md`, etc.

### Decision: Default Feature State

**Rationale:**
- Some features (continuity) are universally useful → `default=True`
- Some features (maestro) require setup → `default=False`
- Users can override defaults in TUI

## File Locations

| Tool | Config Directory | Commands | Config File |
|------|-----------------|----------|-------------|
| Claude Code | `~/.claude/` | `commands/*.md` | `CLAUDE.md` |
| Gemini CLI | `~/.gemini/` | `extensions/<ext>/commands/*.toml` | `GEMINI.md` |
| Codex CLI | `~/.codex/` | `prompts/*.md` | `AGENTS.md` |

## Risks / Mitigations

| Risk | Mitigation |
|------|------------|
| Broken symlinks after repo move | Document that symlinks require stable repo path |
| Gemini extension conflicts | Extension name matches feature name, isolated per-feature |
| Config file corruption | Managed blocks preserve user content; idempotent merging |

## Open Questions

- Should we support uninstallation (remove symlinks, clean managed blocks)?
- Should features declare tool compatibility (some features may not support all tools)?
