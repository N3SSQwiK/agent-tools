# Permission Equivalence Guide

How to achieve equivalent trust levels across Claude Code, Codex CLI, and Gemini CLI.

## Quick Reference: Permission Modes

| Trust Level | Claude Code | Codex CLI | Gemini CLI |
|-------------|-------------|-----------|------------|
| **Ask everything** | `default` | `suggest` | (default behavior) |
| **Auto-approve edits** | `acceptEdits` | `auto-edit` | `allowedTools: [edit_file]` |
| **Read-only** | `plan` | `sandbox: read-only` | (no equivalent) |
| **Full automation** | `bypassPermissions` | `full-auto` / `never` | `--yolo` |

---

## Configuration File Locations

### Claude Code

| Scope | Location |
|-------|----------|
| User global | `~/.claude/settings.json` |
| Project shared | `.claude/settings.json` |
| Project local | `.claude/settings.local.json` |
| Enterprise (macOS) | `/Library/Application Support/ClaudeCode/managed-settings.json` |
| Enterprise (Linux) | `/etc/claude-code/managed-settings.json` |

### Codex CLI

| Scope | Location |
|-------|----------|
| User global | `~/.codex/config.toml` |
| Enterprise | `/etc/codex/managed_config.toml` |

### Gemini CLI

| Scope | Location |
|-------|----------|
| User global | `~/.gemini/settings.json` |
| Project | `.gemini/settings.json` |
| Policies | `~/.gemini/policies/*.toml` |

---

## Preset Configurations

### Conservative (Ask Before Most Actions)

**Use case:** Learning new codebase, unfamiliar project, maximum safety

#### Claude Code (`.claude/settings.json`)
```json
{
  "permissions": {
    "defaultMode": "default",
    "allow": [
      "Read",
      "Glob",
      "Grep"
    ],
    "deny": [
      "Read(**/.env*)",
      "Read(**/secrets/**)",
      "Read(**/*.pem)",
      "Read(**/*.key)",
      "Bash(rm -rf:*)",
      "Bash(git push --force:*)"
    ]
  }
}
```

#### Codex CLI (`~/.codex/config.toml`)
```toml
approval_policy = "suggest"
sandbox_mode = "workspace-write"

[sandbox_workspace_write]
network_access = false
writable_roots = ["./"]
```

#### Gemini CLI (`.gemini/settings.json`)
```json
{
  "tools": {
    "sandbox": true,
    "autoApprove": [
      "read_file",
      "glob",
      "grep"
    ]
  }
}
```

---

### Balanced (Auto-Approve Safe Operations)

**Use case:** Day-to-day development, familiar codebase

#### Claude Code (`.claude/settings.json`)
```json
{
  "permissions": {
    "defaultMode": "default",
    "allow": [
      "Read",
      "Glob",
      "Grep",
      "Bash(npm run lint)",
      "Bash(npm run test:*)",
      "Bash(npm run build)",
      "Bash(git status)",
      "Bash(git diff:*)",
      "Bash(git log:*)",
      "Bash(git add:*)",
      "Bash(git commit:*)"
    ],
    "deny": [
      "Read(**/.env*)",
      "Read(**/secrets/**)",
      "Read(**/*.pem)",
      "Read(**/*.key)",
      "Bash(rm -rf:*)",
      "Bash(git push --force:*)",
      "Bash(curl:*)",
      "Bash(wget:*)"
    ],
    "ask": [
      "Edit",
      "Write",
      "Bash(git push:*)"
    ]
  }
}
```

#### Codex CLI (`~/.codex/config.toml`)
```toml
approval_policy = "auto-edit"
sandbox_mode = "workspace-write"

[sandbox_workspace_write]
network_access = false
writable_roots = ["./", "/tmp"]
```

#### Gemini CLI (`.gemini/settings.json`)
```json
{
  "tools": {
    "sandbox": true,
    "autoApprove": [
      "read_file",
      "glob",
      "grep",
      "run_shell_command(npm run lint)",
      "run_shell_command(npm run test)",
      "run_shell_command(npm run build)",
      "run_shell_command(git status)",
      "run_shell_command(git diff)",
      "run_shell_command(git log)",
      "run_shell_command(git add)",
      "run_shell_command(git commit)"
    ]
  }
}
```

**Gemini policy file** (`~/.gemini/policies/balanced.toml`):
```toml
[[rule]]
toolName = "run_shell_command"
commandPrefix = ["rm -rf", "git push --force", "curl", "wget"]
decision = "deny"
priority = 999

[[rule]]
toolName = "read_file"
commandRegex = ".*\\.env.*|.*secrets.*|.*\\.pem$|.*\\.key$"
decision = "deny"
priority = 999
```

---

### Autonomous (Minimal Interruptions)

**Use case:** Trusted codebase, experienced user, CI/CD pipelines

#### Claude Code (`.claude/settings.json`)
```json
{
  "permissions": {
    "defaultMode": "acceptEdits",
    "allow": [
      "Read",
      "Edit",
      "Write",
      "Glob",
      "Grep",
      "Bash(npm:*)",
      "Bash(yarn:*)",
      "Bash(pnpm:*)",
      "Bash(git:*)",
      "Bash(make:*)",
      "Bash(cargo:*)",
      "Bash(go:*)",
      "Bash(python:*)",
      "Bash(pip:*)"
    ],
    "deny": [
      "Read(**/.env*)",
      "Read(**/secrets/**)",
      "Read(**/*.pem)",
      "Read(**/*.key)",
      "Bash(rm -rf /)",
      "Bash(git push --force origin main)",
      "Bash(git push --force origin master)"
    ],
    "ask": [
      "Bash(git push --force:*)",
      "Bash(rm -rf:*)"
    ]
  }
}
```

#### Codex CLI (`~/.codex/config.toml`)
```toml
approval_policy = "full-auto"
sandbox_mode = "workspace-write"

[sandbox_workspace_write]
network_access = false
writable_roots = ["./", "/tmp", "~/.npm", "~/.cargo"]
```

#### Gemini CLI (`.gemini/settings.json`)
```json
{
  "tools": {
    "sandbox": true,
    "autoApprove": [
      "read_file",
      "edit_file",
      "write_file",
      "glob",
      "grep",
      "run_shell_command"
    ]
  }
}
```

**Gemini policy file** (`~/.gemini/policies/autonomous.toml`):
```toml
[[rule]]
toolName = "run_shell_command"
commandPrefix = ["rm -rf /", "git push --force origin main", "git push --force origin master"]
decision = "deny"
priority = 999

[[rule]]
toolName = "read_file"
commandRegex = ".*\\.env.*|.*secrets.*|.*\\.pem$|.*\\.key$"
decision = "deny"
priority = 999
```

---

## Rule Syntax Comparison

### Pattern Matching

| Pattern Type | Claude Code | Codex CLI | Gemini CLI |
|--------------|-------------|-----------|------------|
| Exact match | `Bash(npm test)` | N/A | `run_shell_command(npm test)` |
| Prefix match | `Bash(npm run:*)` | N/A | `commandPrefix = ["npm run"]` |
| Glob patterns | `Read(**/*.env)` | Not supported | Not supported |
| Regex | Not supported | Not supported | `commandRegex = "pattern"` |

### Achieving Glob-like Behavior

**Claude Code** supports globs natively:
```json
"deny": ["Read(**/.env*)"]
```

**Gemini CLI** uses regex instead:
```toml
commandRegex = ".*\\.env.*"
```

**Codex CLI** relies on sandbox restrictions rather than granular rules.

---

## Common Gotchas

### Claude Code
- Deny rules **should** override allow rules, but there have been reported bugs
- Bash patterns can be bypassed via shell features (variables, redirects)
- Use hooks as a more robust fallback for critical denials

### Codex CLI
- No granular command rules — relies on sandbox + approval prompts
- `full-auto` mode still respects sandbox restrictions
- MCP servers don't work on native Windows (use WSL2)

### Gemini CLI
- Policy rules use priority (higher = evaluated first)
- Regex patterns must escape special characters
- Sandbox profiles (Docker/Podman) provide additional isolation

---

## CI/CD and Headless Mode

### Claude Code
```bash
claude -p "Run tests and fix failures" \
  --allowedTools "Read,Edit,Bash(npm run test)" \
  --output-format stream-json
```

Or for full automation (use in isolated containers only):
```bash
claude -p "Deploy to staging" --dangerously-skip-permissions
```

### Codex CLI
```bash
codex --approval-policy=full-auto --sandbox-mode=workspace-write \
  "Run the test suite"
```

### Gemini CLI
```bash
gemini-cli --yolo "Run tests"
```

---

## Security Recommendations

1. **Never auto-allow destructive operations** — `rm -rf`, `git push --force` should always ask
2. **Deny sensitive file access** — `.env`, `secrets/`, `*.pem`, `*.key`
3. **Use sandbox mode** — Available in Codex and Gemini; Claude uses hooks
4. **Disable network by default** — Prevent data exfiltration
5. **Audit regularly** — Review what's being auto-allowed

---

## See Also

- [Claude Code Settings Documentation](https://code.claude.com/docs/en/settings)
- [Codex CLI Reference](https://developers.openai.com/codex/cli/reference/)
- [Gemini CLI Documentation](https://github.com/google-gemini/gemini-cli)
