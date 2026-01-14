# Gemini CLI Extensions

Reference for creating custom extensions and slash commands in Gemini CLI.

## Extension Structure

```
~/.gemini/extensions/<extension-name>/
├── gemini-extension.json    # Extension manifest (required)
├── commands/                # Slash commands directory
│   └── <name>.toml          # Command definitions
├── GEMINI.md                # Context file (optional)
└── ... (MCP server files if needed)
```

## Extension Manifest

**File:** `gemini-extension.json`

```json
{
  "name": "my-extension",
  "version": "1.0.0",
  "description": "My custom commands",
  "contextFileName": "GEMINI.md"
}
```

| Field | Required | Description |
|-------|----------|-------------|
| `name` | Yes | Unique identifier for the extension |
| `version` | Yes | Semantic version number |
| `description` | No | Brief description of the extension |
| `contextFileName` | No | Path to context file (like CLAUDE.md) |
| `mcpServers` | No | MCP server definitions for tools |

## Command Format

**File:** `commands/<name>.toml`

```toml
description = "Brief description shown in command list"
prompt = """
Your prompt instructions here.

User input: {{args}}
"""
```

## Invocation

- `/<name>` - Run command without arguments
- `/<name> <args>` - Run command with arguments

## Placeholders

| Placeholder | Description |
|-------------|-------------|
| `{{args}}` | User input after the command |

## Enabling Extensions

Add to `~/.gemini/extensions/extension-enablement.json`:

```json
{
  "my-extension": true
}
```

## MCP Servers (Advanced)

Extensions can expose tools via Model Context Protocol:

```json
{
  "name": "my-extension",
  "version": "1.0.0",
  "mcpServers": {
    "myServer": {
      "command": "node",
      "args": ["${extensionPath}${/}dist${/}server.js"],
      "cwd": "${extensionPath}"
    }
  }
}
```

**Variables:**
- `${extensionPath}` - Extension installation directory
- `${/}` - Platform-specific path separator

## Context Files

`GEMINI.md` provides persistent instructions to the model:

```markdown
# Extension Context

## Behavior
- Always use UTC timestamps
- Keep responses concise

## Project Info
This extension handles session continuity.
```

Reference it in the manifest with `"contextFileName": "GEMINI.md"`.

## Development Workflow

1. Create extension structure manually, or use:
   ```bash
   gemini extensions new <name> mcp-server
   ```

2. For MCP servers, install dependencies:
   ```bash
   npm install && npm run build
   ```

3. Link for development:
   ```bash
   gemini extensions link .
   ```

4. Enable the extension in `extension-enablement.json`

## Example

**Extension:** `~/.gemini/extensions/workflow/`

**Manifest:** `gemini-extension.json`
```json
{
  "name": "workflow",
  "version": "1.0.0",
  "description": "Workflow automation commands"
}
```

**Command:** `commands/status.toml`
```toml
description = "Show project status and recent changes"
prompt = """
Check the current project status:
1. Show git status
2. List recent commits (last 5)
3. Summarize any uncommitted changes

Focus area: {{args}}
"""
```

**Usage:** `/status backend changes`

## Resources

- [Gemini CLI Extensions Docs](https://geminicli.com/docs/extensions/getting-started-extensions/)
