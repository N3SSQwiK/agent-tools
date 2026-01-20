# Permission Templates

Pre-built configuration templates for Claude Code, Codex CLI, and Gemini CLI.

## Usage

### Claude Code

Copy the appropriate template to your project or user config:

```bash
# Project-level (shared with team)
cp claude/balanced.json .claude/settings.json

# User-level (personal defaults)
cp claude/balanced.json ~/.claude/settings.json
```

### Codex CLI

Copy the appropriate template to your user config:

```bash
cp codex/balanced.toml ~/.codex/config.toml
```

### Gemini CLI

Copy both the settings and policy files:

```bash
# Settings
cp gemini/balanced.json .gemini/settings.json

# Policy rules
mkdir -p ~/.gemini/policies
cp gemini/balanced-policy.toml ~/.gemini/policies/nexus-balanced.toml
```

## Presets

### Conservative

**Use case:** Learning new codebase, unfamiliar project, maximum safety

| Action | Behavior |
|--------|----------|
| Read files | Auto-approve |
| Write/edit files | Ask |
| Safe shell commands | Ask |
| Destructive commands | Deny |
| Network access | Deny |

### Balanced

**Use case:** Day-to-day development, familiar codebase

| Action | Behavior |
|--------|----------|
| Read files | Auto-approve |
| Write/edit files | Ask |
| Safe shell commands (lint, test, build) | Auto-approve |
| Git operations (except push) | Auto-approve |
| Destructive commands | Deny |
| Network access | Deny |

### Autonomous

**Use case:** Trusted codebase, experienced user, CI/CD pipelines

| Action | Behavior |
|--------|----------|
| Read files | Auto-approve |
| Write/edit files | Auto-approve |
| Most shell commands | Auto-approve |
| Destructive commands (rm -rf, force push) | Ask |
| Catastrophic commands (rm -rf /) | Deny |
| Network access | Deny (configurable) |

## Customization

These templates are starting points. Customize by:

1. Adding project-specific commands to `allow` lists
2. Adding sensitive paths to `deny` lists
3. Moving commands between `allow`/`ask`/`deny` based on your workflow

## Files

```
templates/
├── claude/
│   ├── conservative.json
│   ├── balanced.json
│   └── autonomous.json
├── codex/
│   ├── conservative.toml
│   ├── balanced.toml
│   └── autonomous.toml
├── gemini/
│   ├── conservative.json
│   ├── conservative-policy.toml
│   ├── balanced.json
│   ├── balanced-policy.toml
│   ├── autonomous.json
│   └── autonomous-policy.toml
└── README.md
```
