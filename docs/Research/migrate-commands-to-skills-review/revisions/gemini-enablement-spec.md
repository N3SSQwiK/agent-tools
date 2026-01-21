# Revision: Gemini Skills Enablement Detection

**Addresses:** Critical Issue C2
**Source:** [Gemini CLI Skills Docs](https://geminicli.com/docs/cli/skills/)

## Background

The Gemini CLI has a skills enablement system with these key commands:

```bash
# Terminal commands
gemini skills list           # View all discovered skills
gemini skills enable <name>  # Enable a specific skill
gemini skills disable <name> # Disable a skill

# Interactive session
/skills list
/skills enable <name>
/skills disable <name>
/skills reload
```

Skills are discovered from three locations (precedence order):
1. **Workspace Skills**: `.gemini/skills/`
2. **User Skills**: `~/.gemini/skills/`
3. **Extension Skills**: Bundled in extensions

## Proposed Addition to proposal.md

Add under "## What Changes" after Gemini enablement section:

---

### Gemini Enablement Detection

The installer detects Gemini skills readiness through the following checks:

1. **Binary Check**: Verify `gemini` command exists in PATH
2. **Skills List Check**: Run `gemini skills list` to verify skills subsystem is functional
3. **Skills Location Check**: Verify `~/.gemini/skills/` directory exists or can be created

**Note:** Unlike Claude Code, Gemini CLI does not require a global "enable" command. Skills are automatically discovered when placed in the skills directory. The TUI confirmation explains the skills system and confirms the user wants Nexus-AI to install skills.

---

## Proposed Addition to spec.md

Replace existing Gemini scenarios with:

```markdown
### Requirement: Gemini Skills Enablement

The installer MUST verify Gemini CLI is functional before installing skills.

#### Scenario: Gemini binary not found
- **Given** the user selected Gemini CLI
- **When** the installer checks for `gemini` binary in PATH
- **And** the binary is not found
- **Then** the installer displays a warning that Gemini CLI must be installed separately
- **And** skips Gemini skill installation
- **And** proceeds with other selected tools

#### Scenario: Gemini skills list check
- **Given** the user selected Gemini CLI
- **And** `gemini` binary exists in PATH
- **When** the installer runs `gemini skills list`
- **And** the command succeeds (exit code 0)
- **Then** the installer proceeds with skill installation

#### Scenario: Gemini skills list fails
- **Given** the user selected Gemini CLI
- **When** the installer runs `gemini skills list`
- **And** the command fails (non-zero exit code)
- **Then** the installer displays a warning about Gemini configuration
- **And** attempts skill installation anyway (skills may still work)

#### Scenario: First-time Gemini skills user
- **Given** the user selected Gemini CLI
- **And** `~/.gemini/skills/` directory does not exist
- **When** proceeding to installation
- **Then** the installer creates the skills directory
- **And** displays an informational message about Gemini skill usage

#### Scenario: Gemini skills confirmation screen
- **Given** the user selected Gemini CLI and features with skills
- **When** progressing past feature selection
- **Then** the installer displays a confirmation screen explaining:
  - What skills are and how they work in Gemini
  - That skills will be installed to `~/.gemini/skills/`
  - How to invoke skills (`/skill-name` or via auto-activation)
- **And** user can proceed or skip Gemini installation

#### Scenario: User confirms Gemini installation
- **Given** the user is on the Gemini skills confirmation screen
- **When** the user confirms
- **Then** the installer proceeds with Gemini skill installation

#### Scenario: User skips Gemini
- **Given** the user is on the Gemini skills confirmation screen
- **When** the user declines
- **Then** the installer skips Gemini skill installation
- **And** proceeds with other selected tools
```

---

## Proposed Addition to tasks.md

Update section 2:

```markdown
## 2. Add Gemini Skills Verification

- [ ] 2.1 Add `GeminiSkillsScreen` TUI screen after feature selection
- [ ] 2.2 Display explanation of Gemini skills and their usage:
  - Skills are discovered from `~/.gemini/skills/`
  - Invoke with `/skill-name` or via auto-activation
  - Use `/skills list` to see installed skills
- [ ] 2.3 Add confirmation button for user consent
- [ ] 2.4 Add check for `gemini` binary in PATH before screen
  - If not found: show warning, skip Gemini installation
- [ ] 2.5 Add check for `gemini skills list` functionality
  - If fails: show warning but continue (non-blocking)
- [ ] 2.6 Skip confirmation screen if Gemini not selected
- [ ] 2.7 Create `~/.gemini/skills/` directory if not exists
- [ ] 2.8 Handle user declining gracefully (skip Gemini only)
```

---

## Implementation Notes

### Python Implementation Sketch

```python
import shutil
import subprocess
from pathlib import Path

def check_gemini_available() -> tuple[bool, str]:
    """Check if Gemini CLI is available and functional."""
    # Check binary exists
    gemini_path = shutil.which("gemini")
    if not gemini_path:
        return False, "Gemini CLI not found in PATH"

    # Check skills subsystem works
    try:
        result = subprocess.run(
            ["gemini", "skills", "list"],
            capture_output=True,
            text=True,
            timeout=10
        )
        if result.returncode != 0:
            return True, f"Skills list failed: {result.stderr}"
        return True, "OK"
    except subprocess.TimeoutExpired:
        return True, "Skills list timed out (may still work)"
    except Exception as e:
        return True, f"Skills check error: {e}"

def ensure_gemini_skills_dir() -> Path:
    """Create Gemini skills directory if needed."""
    skills_dir = Path.home() / ".gemini" / "skills"
    skills_dir.mkdir(parents=True, exist_ok=True)
    return skills_dir
```

### TUI Screen Content

```
┌─────────────────────────────────────────────────────────────┐
│                   Gemini CLI Skills                          │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Nexus-AI will install skills to:                          │
│  ~/.gemini/skills/                                          │
│                                                             │
│  Skills provide:                                            │
│  • Slash commands: /maestro-plan, /continuity              │
│  • Auto-activation when context matches                     │
│  • Bundled templates and scripts                           │
│                                                             │
│  After installation, use /skills list to see               │
│  installed skills.                                          │
│                                                             │
│  [ Install Skills ]    [ Skip Gemini ]                      │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```
