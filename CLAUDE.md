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
# Homebrew (recommended for users)
brew install N3SSQwiK/nexus-ai/nexus-ai
nexus-ai

# From source (creates venv on first run)
./install.sh

# Development mode
pip install -e .
nexus-ai

# Direct execution (requires venv)
installer/python/venv/bin/python installer/python/nexus.py
```

## Architecture

**Nexus-AI** is a TUI installer for configuring AI assistant CLI tools (Claude Code, Gemini CLI, Codex CLI) with shared features.

### Entry Points
- `install.sh` - Bash bootstrap that detects Python, creates venv, runs TUI
- `installer/python/nexus.py` - Textual TUI app with multi-screen wizard flow

### Installation Flow
1. WelcomeScreen → ToolsScreen (select assistants) → FeaturesScreen → InstallingScreen → DoneScreen
2. Each tool installs skills to its config directory:
   - Claude: `~/.claude/skills/<name>/` (clean replace via `rmtree` + `copytree`)
   - Gemini: `~/.gemini/skills/<name>/` (auto-discovered, no enablement needed)
   - Codex: `~/.codex/skills/<name>/` (requires CLI restart to discover)
3. Legacy v1.x files (`commands/`, `extensions/`, `prompts/`) are automatically cleaned up

### Feature Structure
Features live in `installer/python/features/<name>/` (bundled with Python package):
```
installer/python/features/<name>/
├── claude/
│   └── CLAUDE.md                 # Global instructions (merged)
├── gemini/
│   └── GEMINI.md                 # Global instructions (merged)
├── codex/
│   └── AGENTS.md                 # Global instructions (merged)
└── skills/                       # Unified skills (all tools)
    └── <skill-name>/
        ├── SKILL.md              # Skill with YAML frontmatter
        └── templates/            # Optional template files
```

Each `SKILL.md` has YAML frontmatter with `name` (kebab-case, ≤64 chars) and `description` (single-line). Optional fields include `disable-model-invocation` for manual-only skills.

### Feature Path Resolution
The `get_features_path()` function in `nexus.py` finds features in multiple contexts:
1. **Installed package** (Homebrew/pip): Uses `importlib.resources` to find bundled package data
2. **Development mode**: Falls back to `Path(__file__).parent / "features"`
3. **Legacy**: Checks repo root `features/` for backwards compatibility with old `install.sh`

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

## Homebrew Distribution

### Tap Repository
The Homebrew tap lives at `N3SSQwiK/homebrew-nexus-ai` (separate repo).
- Naming convention: `homebrew-*` prefix allows `brew tap N3SSQwiK/nexus-ai`
- Formula location: `Formula/nexus-ai.rb`
- Auto-update workflow: `.github/workflows/update-formula.yml`

### Python Packaging
Key files for Homebrew compatibility:
- `pyproject.toml` - Package metadata, dependencies, entry point
- `installer/__init__.py` - Package with `__version__`
- `.gitattributes` - Export-ignore rules for release tarballs

### Formula Pattern (IMPORTANT)
Homebrew's `venv.pip_install` and `pip_install_and_link` use `--no-deps` by default.
For packages with dependencies, use direct pip invocation:

```ruby
def install
  virtualenv_create(libexec, "python3.11")
  system libexec/"bin/python", "-m", "pip", "install", "--upgrade", "pip"
  system libexec/"bin/python", "-m", "pip", "install", buildpath
  bin.install_symlink libexec/"bin/nexus-ai"
end
```

### Release Automation
Push a tag to trigger automatic release:
```bash
git tag v1.x.x
git push origin v1.x.x
```

Flow:
1. `.github/workflows/release.yml` creates GitHub Release
2. Computes SHA256 of tarball (with retry loop for CDN propagation)
3. Dispatches `update-formula` event to tap repo via `repository-dispatch`
4. Tap workflow updates formula URL and SHA256, commits

### Update Workflow Gotchas
When updating formula SHA256, only replace the FIRST occurrence (main tarball), not resource SHAs:
```bash
# BAD: Replaces ALL sha256 lines
sed -i "s|sha256 \".*\"|sha256 \"${SHA256}\"|"

# GOOD: Only replace first occurrence
awk -v sha="${SHA256}" '
  /sha256 "/ && !replaced {
    sub(/sha256 "[^"]*"/, "sha256 \"" sha "\"")
    replaced = 1
  }
  { print }
' Formula/nexus-ai.rb
```

### Tarball Exclusions
`.gitattributes` controls what's excluded from `git archive` / GitHub release tarballs:
```gitattributes
.ai export-ignore
.github export-ignore
openspec export-ignore
docs export-ignore
```

### ImportError Fallback Pattern
For code that runs both installed (Homebrew) and directly (`./install.sh`):
```python
try:
    from installer import __version__
except ImportError:
    __version__ = "1.0.0"  # Fallback for direct script execution
```

### brew audit Requirements
- No trailing whitespace on any line (including blank lines)
- Run `brew audit --strict n3ssqwik/nexus-ai/nexus-ai` before releasing

### Debugging Homebrew Installs
```bash
# Check what's installed
ls /opt/homebrew/Cellar/nexus-ai/1.0.0/libexec/lib/python3.11/site-packages/

# View install logs
cat /Users/nexus/Library/Logs/Homebrew/nexus-ai/*.log

# Force clean reinstall
brew uninstall nexus-ai && brew untap n3ssqwik/nexus-ai
brew tap n3ssqwik/nexus-ai && brew install nexus-ai

# Update local tap manually
cd /opt/homebrew/Library/Taps/n3ssqwik/homebrew-nexus-ai && git pull
```
