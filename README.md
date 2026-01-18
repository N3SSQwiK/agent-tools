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
│   ├── continuity/              # Session continuity feature
│   │   ├── claude/              # Claude Code files
│   │   ├── gemini/              # Gemini CLI files
│   │   └── codex/               # Codex CLI files
│   └── maestro/                 # Multi-agent orchestration
│       ├── claude/              # Claude Code commands
│       ├── gemini/              # Gemini CLI extensions
│       ├── codex/               # Codex CLI prompts
│       └── docs/                # Maestro documentation
├── installer/                   # Interactive TUI installers
│   ├── go/                      # Go + Bubbletea version
│   └── python/                  # Python + Textual version
├── docs/                        # Documentation
│   ├── CLAUDE-COMMANDS.md
│   ├── GEMINI-EXTENSIONS.md
│   └── CODEX-COMMANDS.md
└── install*.sh                  # Install scripts
```

## Features

### Continuity

Session continuity tracking across projects with seamless tool switching.

**How it works:**
1. **Run `/continuity`** → Agent reads `.ai/CONTINUITY.md`, presents summary and suggested prompt
2. **Update** → Confirm to update with current session state
3. **Next session** → Run `/continuity` again to resume context

**Unified location:** All tools read/write to `.ai/CONTINUITY.md` in your project root. This enables switching between Claude, Gemini, and Codex without losing context.

**Format (~500 tokens):**
```markdown
# Continuity

## Summary
[Project context - what is being built and why]

## Completed
- [Recent finished work items, 5-7 max]

## In Progress
- [Active work not yet complete]

## Blocked
[Impediments or "None"]

## Key Files
- `path/to/file` - [description]

## Context
[Session state, preferences, constraints]

## Suggested Prompt
> [Actionable prompt to continue work in next session]

## Source
[Tool Name] | [YYYY-MM-DD HH:MM UTC]
```

**Migration:** Tools automatically detect legacy files (`.claude/CONTINUITY.md`, `.gemini/CONTINUITY.md`, `.codex/CONTINUITY.md`) and offer to migrate them to the unified location.

### Maestro

Multi-agent orchestration system enabling any AI tool to coordinate complex tasks across Claude Code, Gemini CLI, and Codex CLI.

**Commands:**
| Command | Purpose |
|---------|---------|
| `/maestro plan <goal>` | Decompose goal into atomic tasks |
| `/maestro challenge` | Have spokes challenge the plan |
| `/maestro run [task-id]` | Execute plan or specific task |
| `/maestro review [task-id]` | Cross-tool review of completed work |
| `/maestro status` | Display current orchestration state |
| `/maestro report` | Generate execution walkthrough |

**How it works:**
1. **Plan** → Hub analyzes codebase, creates task breakdown with specialist assignments
2. **Approve** → Select from structured menu (Approve/Modify/Reject)
3. **Logging** → Choose logging level (None/Summary/Detailed) via interactive menu
4. **Challenge** (optional) → Different tool challenges plan assumptions
5. **Run** → Hub dispatches tasks to spokes with guardrails, collects and validates results
6. **Review** (optional) → Cross-tool review before accepting work

**Interactive menus:** All decision points use structured numbered menus for consistency. Select options by number or choose "Other" for custom responses.

**State files:**
- `.ai/MAESTRO.md` - Orchestration state (tasks, status, dependencies)
- `.ai/MAESTRO-LOG.md` - Execution log (opt-in via menu or `--log=summary`)

**Documentation:** See [features/maestro/docs/](features/maestro/docs/) for the full user guide, spoke contract, and troubleshooting.

## Adding Features

1. Create directory: `features/<feature-name>/`
2. Add tool-specific subdirectories with config files
3. Run `./install.sh` to install

### Structure for a new feature:

```
features/<feature-name>/
├── claude/
│   ├── CLAUDE.md              # Global instructions (merged, optional)
│   └── commands/
│       └── <feature-name>[-*].md   # Slash command(s)
├── gemini/
│   ├── GEMINI.md              # Global instructions (merged, optional)
│   └── extensions/
│       └── <feature-name>/
│           ├── gemini-extension.json
│           └── commands/
│               └── <feature-name>[-*].toml
└── codex/
    ├── AGENTS.md              # Global instructions (merged, optional)
    └── prompts/
        └── <feature-name>[-*].md   # Slash command(s)
```

**Single vs. multi-command features:**
- Single command: `continuity.md`
- Multiple commands: `maestro-plan.md`, `maestro-run.md`, `maestro-status.md`, etc.

## Managed Blocks

Config files use managed blocks to preserve your existing configuration:

```markdown
<!-- Nexus-AI:START -->
[Installer-managed content]
<!-- Nexus-AI:END -->
```

Your content outside these markers is preserved during updates.

## Documentation

- [Claude Code Commands](docs/CLAUDE-COMMANDS.md)
- [Gemini CLI Extensions](docs/GEMINI-EXTENSIONS.md)
- [Codex CLI Custom Prompts](docs/CODEX-COMMANDS.md)
