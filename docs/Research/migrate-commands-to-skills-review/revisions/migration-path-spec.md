# Revision: Migration Path for Existing Users

**Addresses:** Critical Issue C3
**Impact:** Breaking change requiring v2.0.0 version bump

## Background

Users upgrading from v1.0.x have Nexus-AI features installed at deprecated locations:

| Tool | Old Location | New Location |
|------|--------------|--------------|
| Claude | `~/.claude/commands/maestro-*.md` | `~/.claude/skills/maestro-*/` |
| Gemini | `~/.gemini/extensions/maestro/` | `~/.gemini/skills/maestro-*/` |
| Codex | `~/.codex/prompts/maestro-*.md` | `~/.codex/skills/maestro-*/` |

Without cleanup, users will have **duplicate slash commands** - both old and new formats registered simultaneously.

## Design Decision: Cleanup Strategy

**Recommended: Optional cleanup with detection**

The installer should:
1. Detect existing command/extension/prompt files from previous Nexus-AI installations
2. Prompt user to remove them (opt-in cleanup)
3. Only remove files that match known Nexus-AI patterns (not custom user files)
4. Proceed with skills installation regardless of cleanup choice

**Why not automatic cleanup?**
- User may have customized the old files
- Rollback becomes difficult if new format fails
- Principle of least surprise

**Why not leave duplicates?**
- Confusing UX with duplicate commands
- Potential for conflicting behavior
- Old files become orphaned cruft

## Proposed Addition to proposal.md

Add new section after "## What Changes":

---

### Migration Path for Existing Users

This is a **breaking change** requiring a major version bump to v2.0.0.

#### Detection Phase

The installer detects previous Nexus-AI installations by checking for known file patterns:

```
# Claude Code (check for Nexus-AI commands)
~/.claude/commands/maestro-*.md
~/.claude/commands/continuity.md

# Gemini CLI (check for Nexus-AI extensions)
~/.gemini/extensions/maestro/
~/.gemini/extensions/continuity/

# Codex CLI (check for Nexus-AI prompts)
~/.codex/prompts/maestro-*.md
~/.codex/prompts/continuity.md
```

#### Cleanup Prompt

If legacy files are detected, the installer displays a cleanup confirmation:

```
┌─────────────────────────────────────────────────────────────┐
│                   Upgrade Detected                          │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Found previous Nexus-AI installation:                      │
│  • ~/.claude/commands/maestro-plan.md                       │
│  • ~/.claude/commands/maestro-run.md                        │
│  • (4 more files)                                           │
│                                                             │
│  These files use the old format and will be replaced        │
│  by the new skills format.                                  │
│                                                             │
│  [ Remove Old Files ]    [ Keep Both ]                      │
│                                                             │
│  Note: Keeping both may cause duplicate commands.           │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

#### Cleanup Rules

The installer only removes files matching these exact patterns (to avoid deleting user customizations):

| Feature | Claude Pattern | Gemini Pattern | Codex Pattern |
|---------|---------------|----------------|---------------|
| Maestro | `maestro-{plan,run,review,challenge,status,report}.md` | `extensions/maestro/` (entire dir) | `maestro-{plan,run,review,challenge,status,report}.md` |
| Continuity | `continuity.md` | `extensions/continuity/` | `continuity.md` |

Files with non-standard names (e.g., `maestro-plan-custom.md`) are NOT removed.

#### Coexistence Mode

If user chooses "Keep Both":
- Both old commands and new skills will be available
- User is warned about potential duplicates
- Installation proceeds normally
- User can manually remove old files later

---

## Proposed Addition to spec.md

Add new requirement section:

```markdown
### Requirement: Legacy Installation Detection

The installer MUST detect and offer cleanup of previous Nexus-AI installations.

#### Scenario: No legacy files detected
- **Given** no Nexus-AI files exist at deprecated locations
- **When** running the installer
- **Then** the installer proceeds normally without cleanup prompt

#### Scenario: Legacy Claude commands detected
- **Given** files exist at `~/.claude/commands/maestro-*.md`
- **When** the installer scans for legacy installations
- **Then** it identifies these as Nexus-AI v1.x files
- **And** includes them in the cleanup prompt

#### Scenario: Legacy Gemini extensions detected
- **Given** directory exists at `~/.gemini/extensions/maestro/`
- **When** the installer scans for legacy installations
- **Then** it identifies this as Nexus-AI v1.x extension
- **And** includes it in the cleanup prompt

#### Scenario: Legacy Codex prompts detected
- **Given** files exist at `~/.codex/prompts/maestro-*.md`
- **When** the installer scans for legacy installations
- **Then** it identifies these as Nexus-AI v1.x files
- **And** includes them in the cleanup prompt

#### Scenario: User confirms cleanup
- **Given** legacy files are detected
- **And** user is on the cleanup confirmation screen
- **When** user selects "Remove Old Files"
- **Then** the installer removes only the identified Nexus-AI files
- **And** logs which files were removed
- **And** proceeds with skills installation

#### Scenario: User declines cleanup
- **Given** legacy files are detected
- **And** user is on the cleanup confirmation screen
- **When** user selects "Keep Both"
- **Then** the installer proceeds without removing files
- **And** displays warning about potential duplicate commands
- **And** proceeds with skills installation

#### Scenario: Cleanup failure
- **Given** user confirmed cleanup
- **When** the installer attempts to remove a file
- **And** removal fails (permissions, etc.)
- **Then** the installer logs the failure
- **And** displays a warning
- **And** continues with remaining cleanup
- **And** proceeds with skills installation

#### Scenario: Custom files preserved
- **Given** user has custom files at `~/.claude/commands/my-custom-command.md`
- **When** the installer scans for legacy installations
- **Then** it does NOT include custom files in cleanup
- **And** only offers to remove known Nexus-AI patterns
```

---

## Proposed Addition to tasks.md

Add new section after section 2:

```markdown
## 2.5 Legacy Installation Migration

- [ ] 2.5.1 Add `detect_legacy_installation()` function to scan for v1.x files
- [ ] 2.5.2 Define known Nexus-AI file patterns per tool:
  - Claude: `maestro-{plan,run,review,challenge,status,report}.md`, `continuity.md`
  - Gemini: `extensions/maestro/`, `extensions/continuity/`
  - Codex: `maestro-{plan,run,review,challenge,status,report}.md`, `continuity.md`
- [ ] 2.5.3 Add `MigrationScreen` TUI screen (conditional on detection)
- [ ] 2.5.4 Display detected files with option to remove or keep
- [ ] 2.5.5 Implement `cleanup_legacy_files()` function with:
  - Only remove files matching exact patterns
  - Log each removed file
  - Handle permission errors gracefully
- [ ] 2.5.6 Show duplicate command warning if user keeps both
- [ ] 2.5.7 Skip migration screen if no legacy files found
```

Update section 7:

```markdown
## 7. Testing & Validation

- [ ] 7.1 Test fresh install with skills on all three tools
- [ ] 7.2 Verify slash commands work after skill installation
- [ ] 7.3 Test Gemini enablement flow in TUI
- [ ] 7.4 Test auto-invocation triggers correctly
- [ ] 7.5 **NEW** Test upgrade from v1.0.1 with cleanup confirmed
- [ ] 7.6 **NEW** Test upgrade from v1.0.1 with cleanup declined (coexistence)
- [ ] 7.7 **NEW** Test that custom user commands are NOT removed
- [ ] 7.8 Run `openspec validate migrate-commands-to-skills --strict`
```

---

## Implementation Notes

### Detection Function

```python
from pathlib import Path
from typing import Dict, List

LEGACY_PATTERNS = {
    "claude": {
        "path": Path.home() / ".claude" / "commands",
        "patterns": [
            "maestro-plan.md",
            "maestro-run.md",
            "maestro-review.md",
            "maestro-challenge.md",
            "maestro-status.md",
            "maestro-report.md",
            "continuity.md",
        ]
    },
    "gemini": {
        "path": Path.home() / ".gemini" / "extensions",
        "patterns": [
            "maestro/",
            "continuity/",
        ]
    },
    "codex": {
        "path": Path.home() / ".codex" / "prompts",
        "patterns": [
            "maestro-plan.md",
            "maestro-run.md",
            "maestro-review.md",
            "maestro-challenge.md",
            "maestro-status.md",
            "maestro-report.md",
            "continuity.md",
        ]
    }
}

def detect_legacy_installation() -> Dict[str, List[Path]]:
    """Detect Nexus-AI v1.x files at deprecated locations."""
    found = {}

    for tool, config in LEGACY_PATTERNS.items():
        base_path = config["path"]
        if not base_path.exists():
            continue

        tool_files = []
        for pattern in config["patterns"]:
            target = base_path / pattern
            if target.exists():
                tool_files.append(target)

        if tool_files:
            found[tool] = tool_files

    return found

def cleanup_legacy_files(files: Dict[str, List[Path]]) -> Dict[str, List[str]]:
    """Remove legacy files, return status per file."""
    results = {"removed": [], "failed": []}

    for tool, paths in files.items():
        for path in paths:
            try:
                if path.is_dir():
                    shutil.rmtree(path)
                else:
                    path.unlink()
                results["removed"].append(str(path))
            except Exception as e:
                results["failed"].append(f"{path}: {e}")

    return results
```

### Version Bump

Update `installer/__init__.py`:

```python
__version__ = "2.0.0"  # Breaking change: skills migration
```

Update `CHANGELOG.md`:

```markdown
## [2.0.0] - 2026-XX-XX

### Breaking Changes
- Migrated from commands/extensions/prompts to unified Agent Skills format
- Deprecated file locations no longer used (see Migration section)

### Migration
Run the installer to upgrade. When prompted:
- Choose "Remove Old Files" to clean up deprecated locations
- Choose "Keep Both" to preserve old files alongside new skills

### Added
- Agent Skills support for Claude Code, Gemini CLI, and Codex CLI
- Skills enablement screen for Gemini CLI
- Legacy installation detection and cleanup
```
