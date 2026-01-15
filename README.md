# Nexus-AI

```
███╗   ██╗███████╗██╗  ██╗██╗   ██╗███████╗
████╗  ██║██╔════╝╚██╗██╔╝██║   ██║██╔════╝
██╔██╗ ██║█████╗   ╚███╔╝ ██║   ██║███████╗
██║╚██╗██║██╔══╝   ██╔██╗ ██║   ██║╚════██║
██║ ╚████║███████╗██╔╝ ██╗╚██████╔╝███████║
╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝
```

Configuration and commands for AI coding assistants.

## Install

```bash
git clone https://github.com/N3SSQwiK/agent-tools.git ~/agent-tools
cd ~/agent-tools
chmod +x *.sh
./install.sh
```

The installer provides an interactive TUI for selecting tools and features.

**Requirements:** Python 3.9+ (recommended) or Go 1.21+

**Legacy installers (bash only):**
```bash
./install-claude.sh   # Claude Code only
./install-gemini.sh   # Gemini CLI only
./install-codex.sh    # Codex CLI only
```

## Repo Structure

```
agent-tools/
├── features/                    # Feature modules
│   └── continuity/              # Session continuity feature
│       ├── claude/              # Claude Code files
│       ├── gemini/              # Gemini CLI files
│       └── codex/               # Codex CLI files
├── installer/                   # Interactive TUI installers
│   ├── go/                      # Go + Bubbletea version
│   └── python/                  # Python + Textual version
├── docs/                        # Documentation
│   ├── CLAUDE-COMMANDS.md
│   ├── GEMINI-EXTENSIONS.md
│   └── CODEX-COMMANDS.md
└── install*.sh                  # Install scripts
```

## Supported Tools

| Tool | Config Location | Commands |
|------|-----------------|----------|
| Claude Code | `~/.claude/` | `/continuity` |
| Gemini CLI | `~/.gemini/` | `/continuity` |
| Codex CLI | `~/.codex/` | `/prompts:continuity` |

## Features

### Continuity

Session continuity tracking across projects.

**How it works:**
1. **Session start** → Agent reads project's CONTINUITY.md, asks to proceed or adjust
2. **Milestone reached** → Agent updates CONTINUITY.md
3. **Manual update** → Run `/continuity`

**Format (~60 tokens):**
```markdown
# Continuity

## Done
[Brief summary of completed work]

## Next
[What to work on next]

## Source
[Tool Name] | [YYYY-MM-DD HH:MM UTC]
```

**File locations:**
| Tool | Continuity file |
|------|-----------------|
| Claude Code | `.claude/CONTINUITY.md` |
| Gemini CLI | `.gemini/CONTINUITY.md` |
| Codex CLI | `.codex/CONTINUITY.md` |

## Adding Features

1. Create directory: `features/<feature-name>/`
2. Add tool-specific subdirectories with config files
3. Run `./install.sh` to install

### Structure for a new feature:

```
features/<feature-name>/
├── claude/
│   ├── CLAUDE.md              # Global instructions (optional)
│   └── commands/
│       └── <feature-name>.md  # Slash command
├── gemini/
│   ├── GEMINI.md              # Global instructions (optional)
│   └── extensions/
│       └── <feature-name>/
│           ├── gemini-extension.json
│           └── commands/
│               └── <feature-name>.toml
└── codex/
    ├── AGENTS.md              # Global instructions (optional)
    └── prompts/
        └── <feature-name>.md  # Slash command
```

## Managed Blocks

Config files use managed blocks to preserve your existing configuration:

```markdown
<!-- AGENT-TOOLS:START -->
[Installer-managed content]
<!-- AGENT-TOOLS:END -->
```

Your content outside these markers is preserved during updates.

## Documentation

- [Claude Code Commands](docs/CLAUDE-COMMANDS.md)
- [Gemini CLI Extensions](docs/GEMINI-EXTENSIONS.md)
- [Codex CLI Custom Prompts](docs/CODEX-COMMANDS.md)
