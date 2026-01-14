# Creating Slash Commands

Reference for creating custom slash commands in each AI CLI tool.

## Claude Code

**Location:** `~/.claude/commands/<name>.md`

**Format:** Markdown file with optional YAML frontmatter

```markdown
---
description: Brief description shown in command list
allowed-tools: Bash, Read, Write  # Optional: restrict available tools
---

Your prompt instructions here.

User input: $ARGUMENTS
```

**Invocation:** `/<name>` or `/<name> <args>`

**Notes:**
- Filename becomes command name (e.g., `foo.md` → `/foo`)
- `$ARGUMENTS` placeholder for user input
- Can reference files with `@file` syntax in prompt

---

## Gemini CLI

**Location:** `~/.gemini/extensions/<extension-name>/commands/<name>.toml`

**Required files:**
1. `gemini-extension.json` - Extension manifest
2. `commands/<name>.toml` - Command definition

**Extension manifest (`gemini-extension.json`):**
```json
{
  "name": "my-extension",
  "version": "1.0.0",
  "description": "My custom commands"
}
```

**Command format (`commands/<name>.toml`):**
```toml
description = "Brief description shown in command list"
prompt = """
Your prompt instructions here.

User input: {{args}}
"""
```

**Enable extension:**
Add to `~/.gemini/extensions/extension-enablement.json`:
```json
{
  "my-extension": true
}
```

**Invocation:** `/<name>` or `/<name> <args>`

**Notes:**
- `{{args}}` placeholder for user input
- Extension must be enabled in enablement JSON
- Commands live inside extension directories

---

## Codex CLI

**Location:** `~/.codex/prompts/<name>.md`

**Format:** Markdown with YAML frontmatter

```markdown
---
description: Brief description shown in command list
argument-hint: Optional hint for expected arguments
---

Your prompt instructions here.

User input is appended automatically.
```

**Invocation:** `/prompts/<name>` or `/prompts/<name> <args>`

**Notes:**
- Codex prepends `/prompts/` to the command name
- User arguments are appended to the prompt content
- Global instructions go in `~/.codex/AGENTS.md`

---

## Comparison Table

| Feature | Claude Code | Gemini CLI | Codex CLI |
|---------|-------------|------------|-----------|
| Location | `~/.claude/commands/` | `~/.gemini/extensions/<ext>/commands/` | `~/.codex/prompts/` |
| Format | Markdown | TOML | Markdown |
| Frontmatter | YAML (optional) | N/A (TOML fields) | YAML |
| Args placeholder | `$ARGUMENTS` | `{{args}}` | Appended |
| Invocation | `/<name>` | `/<name>` | `/prompts/<name>` |
| Extra setup | None | Extension + enablement | None |
