# Maestro Hooks Research

**Status:** Research Complete | Implementation Pending
**Date:** 2026-01-20
**Goal:** Add self-enforcing hooks to Maestro commands for automated validation, logging, and safety rails
**Scope:** Claude Code only (see [Tool-Specific Limitations](#tool-specific-limitations))

## Background

Maestro's current enforcement model relies on **advisory guardrails** - instructions that tell spokes what to do, but nothing that *enforces* compliance. This research explores embedding Claude Code hooks directly into Maestro slash commands to move from "trust but verify" to "verify then trust."

### Current Gaps in Maestro

| Current (Advisory) | Problem |
|---|---|
| "ONLY modify files explicitly listed" | Nothing stops out-of-scope edits |
| "DO NOT install dependencies" | Spokes can still run `npm install` |
| "Verify command has all flags" | Human must remember to check |
| "Log execution" | Manual, often forgotten |

## Hook Embedding in Slash Commands

### Key Discovery

Claude Code allows hooks to be embedded directly in slash command `.md` files via YAML frontmatter:

```yaml
---
name: my-command
description: What this command does
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "${CLAUDE_PLUGIN_ROOT}/hooks/my-script.py"
  PostToolUse:
    - matcher: "Edit|Write"
      hooks:
        - type: command
          command: "${CLAUDE_PLUGIN_ROOT}/hooks/logger.py"
---

Command instructions here...
```

### Available Hook Events

| Event | Runs When | Can Block? | Use Case |
|-------|-----------|-----------|----------|
| **PreToolUse** | Before tool executes | Yes | Validation, permission checks |
| **PostToolUse** | After tool completes | No (feedback only) | Logging, formatting |
| **Stop** | Claude finishes responding | Yes | Continue or stop |

**Note:** Only `PreToolUse`, `PostToolUse`, and `Stop` are available in slash commands/skills.

### Hook Types

**Command-Based (Recommended for Maestro):**
```json
{
  "type": "command",
  "command": "./scripts/validate.py",
  "timeout": 30
}
```
- Exit code `0` = allow
- Exit code `2` = block
- Deterministic, fast

**Prompt-Based (LLM-Driven):**
```json
{
  "type": "prompt",
  "prompt": "Evaluate if this action is safe: $ARGUMENTS",
  "timeout": 30
}
```
- Uses Haiku for intelligent decisions
- Returns `{"ok": true/false, "reason": "..."}`
- Slower but context-aware

### Hook Input (stdin JSON)

Hooks receive rich context via stdin:

```json
{
  "session_id": "abc123",
  "transcript_path": "/path/to/session.jsonl",
  "cwd": "/current/working/directory",
  "hook_event_name": "PreToolUse",
  "tool_name": "Bash",
  "tool_input": {
    "command": "rm -rf /",
    "description": "Delete everything"
  },
  "tool_use_id": "toolu_01ABC123..."
}
```

### Matchers

- `Bash` - Exact tool name match
- `Edit|Write` - Regex OR (matches either)
- `mcp__.*` - MCP tools (regex)
- `""` or omit - Match all tools

## Proposed Architecture

### Directory Structure

```
installer/python/features/maestro/
├── claude/
│   ├── CLAUDE.md
│   ├── commands/
│   │   ├── maestro-run.md      ← Add hooks frontmatter
│   │   ├── maestro-plan.md
│   │   └── ...
│   └── hooks/                   ← NEW: Hook scripts
│       ├── scope-guard.py       # Block out-of-scope file edits
│       ├── dispatch-validator.py # Validate CLI command patterns
│       ├── auto-logger.py       # Log tool uses to MAESTRO-LOG.md
│       ├── state-check.py       # Ensure MAESTRO.md exists
│       └── safety-rails.py      # Block destructive commands
```

### Hook Flow for `/maestro run`

```
┌─────────────────────────────────────────────────────────────┐
│                      PreToolUse                              │
├─────────────────────────────────────────────────────────────┤
│  On ANY tool:     state-check.py    → MAESTRO.md exists?    │
│  On Bash:         safety-rails.py   → No rm -rf, force push │
│  On Bash:         dispatch-validator.py → CLI flags valid?  │
│  On Edit|Write:   scope-guard.py    → File in task scope?   │
└─────────────────────────────────────────────────────────────┘
                            ↓
                     [Tool Executes]
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                      PostToolUse                             │
├─────────────────────────────────────────────────────────────┤
│  On ANY tool:     auto-logger.py    → Append to LOG.md      │
└─────────────────────────────────────────────────────────────┘
```

### Enforcement Mechanisms

#### 1. Scope Enforcement (`scope-guard.py`)

**Purpose:** Block file modifications outside the current task's declared scope.

**Trigger:** `PreToolUse` on `Edit|Write`

**Logic:**
1. Read task manifest (`.ai/.maestro-task.json`)
2. Check if `tool_input.file_path` matches allowed patterns
3. Exit `0` (allow) or `2` (block)

#### 2. Command Validation (`dispatch-validator.py`)

**Purpose:** Ensure CLI dispatch commands include all required flags.

**Trigger:** `PreToolUse` on `Bash`

**Validation Rules:**
| CLI | Required Pattern |
|-----|-----------------|
| Gemini | `gemini -p "..." -y -o json` |
| Codex | `codex exec "..." --full-auto --json` |
| Claude | `claude -p "..." --output-format json --dangerously-skip-permissions` |

**Logic:**
1. Parse command from `tool_input.command`
2. If command starts with `gemini`/`codex`/`claude`, validate flags
3. Block if missing required flags

#### 3. Automatic Logging (`auto-logger.py`)

**Purpose:** Automatically log every tool use to MAESTRO-LOG.md.

**Trigger:** `PostToolUse` on all tools

**Logic:**
1. Read task manifest for logging level
2. If logging enabled, append entry to `.ai/MAESTRO-LOG.md`
3. Format: `| [time] | [tool] | [action] | [outcome] |`

#### 4. State Integrity (`state-check.py`)

**Purpose:** Ensure MAESTRO.md exists before any orchestration actions.

**Trigger:** `PreToolUse` on all tools (first check)

**Logic:**
1. Check if `.ai/MAESTRO.md` exists
2. Block with helpful message if missing

#### 5. Safety Rails (`safety-rails.py`)

**Purpose:** Block dangerous/destructive commands.

**Trigger:** `PreToolUse` on `Bash`

**Blocked Patterns:**
- `rm -rf` (recursive force delete)
- `git push --force` to main/master
- `:(){ :|:& };:` (fork bomb)
- `> /dev/sda` (disk overwrite)
- `dd if=` (raw disk operations)
- `chmod -R 777` (permission escalation)

## Design Decisions

### Decision 1: Scope Data Source

**Option A: Parse MAESTRO.md dynamically**
- Pros: No extra files, always current
- Cons: Complex parsing, slower, fragile

**Option B: Task manifest file (Recommended)**
- Pros: Fast lookup, explicit contract, easy to debug
- Cons: Requires maestro-run to write manifest before dispatch

**Recommended:** Option B - Have `/maestro run` write `.ai/.maestro-task.json` before each task dispatch:

```json
{
  "task_id": 3,
  "description": "Add logout button to navbar",
  "allowed_files": ["src/components/Navbar.tsx", "src/styles/navbar.css"],
  "allowed_patterns": ["src/auth/**/*.ts"],
  "logging_level": "summary",
  "blocked_commands": ["npm install", "pip install"]
}
```

### Decision 2: Script Language

**Option A: Bash scripts**
- Pros: Simple, no dependencies
- Cons: Complex JSON parsing, limited error handling

**Option B: Python scripts (Recommended)**
- Pros: Native JSON, better error handling, more readable
- Cons: Requires Python (already a dependency)

### Decision 3: Hook Granularity

**Option A: Single mega-hook per event**
- Pros: Fewer files, simpler config
- Cons: Harder to maintain, all-or-nothing

**Option B: Separate hooks per concern (Recommended)**
- Pros: Single responsibility, easy to enable/disable
- Cons: More files

## Example: maestro-run.md with Hooks

```yaml
---
name: maestro-run
description: Execute approved orchestration plan or specific task
hooks:
  PreToolUse:
    # State integrity - ensure MAESTRO.md exists
    - matcher: ""
      hooks:
        - type: command
          command: "${CLAUDE_PLUGIN_ROOT}/hooks/state-check.py"
          timeout: 5
    # Safety rails - block dangerous commands
    - matcher: "Bash"
      hooks:
        - type: command
          command: "${CLAUDE_PLUGIN_ROOT}/hooks/safety-rails.py"
          timeout: 5
    # Dispatch validation - ensure CLI flags are correct
    - matcher: "Bash"
      hooks:
        - type: command
          command: "${CLAUDE_PLUGIN_ROOT}/hooks/dispatch-validator.py"
          timeout: 5
    # Scope enforcement - block out-of-scope file edits
    - matcher: "Edit|Write"
      hooks:
        - type: command
          command: "${CLAUDE_PLUGIN_ROOT}/hooks/scope-guard.py"
          timeout: 5
  PostToolUse:
    # Automatic logging
    - matcher: ""
      hooks:
        - type: command
          command: "${CLAUDE_PLUGIN_ROOT}/hooks/auto-logger.py"
          timeout: 10
---

# Maestro Run Command

Execute approved orchestration plan or specific task.

[... rest of existing content ...]
```

## Example Hook Scripts

### safety-rails.py

```python
#!/usr/bin/env python3
"""Block dangerous commands during Maestro orchestration."""
import json
import re
import sys

BLOCKED_PATTERNS = [
    (r'\brm\s+-rf\b', "Recursive force delete is blocked"),
    (r'git\s+push\s+.*--force.*(?:main|master)', "Force push to main/master is blocked"),
    (r':\(\)\s*\{\s*:\|:&\s*\}\s*;:', "Fork bomb detected"),
    (r'>\s*/dev/sd[a-z]', "Direct disk write is blocked"),
    (r'\bdd\s+if=', "Raw disk operation is blocked"),
    (r'chmod\s+-R\s+777', "Recursive 777 permissions is blocked"),
]

def main():
    try:
        data = json.load(sys.stdin)
        command = data.get('tool_input', {}).get('command', '')

        for pattern, message in BLOCKED_PATTERNS:
            if re.search(pattern, command, re.IGNORECASE):
                print(f"🚨 BLOCKED: {message}", file=sys.stderr)
                print(f"   Command: {command[:100]}...", file=sys.stderr)
                sys.exit(2)  # Block

        sys.exit(0)  # Allow

    except Exception as e:
        print(f"Hook error: {e}", file=sys.stderr)
        sys.exit(1)  # Non-blocking error

if __name__ == "__main__":
    main()
```

### scope-guard.py

```python
#!/usr/bin/env python3
"""Block file modifications outside the current task's scope."""
import json
import fnmatch
import sys
from pathlib import Path

MANIFEST_PATH = ".ai/.maestro-task.json"

def main():
    try:
        data = json.load(sys.stdin)
        file_path = data.get('tool_input', {}).get('file_path', '')

        if not file_path:
            sys.exit(0)  # No file path, allow

        # Load task manifest
        manifest_file = Path(data.get('cwd', '.')) / MANIFEST_PATH
        if not manifest_file.exists():
            # No manifest = no scope enforcement
            sys.exit(0)

        manifest = json.loads(manifest_file.read_text())
        allowed_files = manifest.get('allowed_files', [])
        allowed_patterns = manifest.get('allowed_patterns', [])

        # Check exact matches
        if file_path in allowed_files:
            sys.exit(0)

        # Check pattern matches
        for pattern in allowed_patterns:
            if fnmatch.fnmatch(file_path, pattern):
                sys.exit(0)

        # Not in scope
        print(f"🚨 SCOPE VIOLATION: {file_path}", file=sys.stderr)
        print(f"   Allowed files: {allowed_files}", file=sys.stderr)
        print(f"   Allowed patterns: {allowed_patterns}", file=sys.stderr)
        sys.exit(2)  # Block

    except Exception as e:
        print(f"Hook error: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()
```

## Implementation Tasks

When ready to implement:

1. [ ] Create `installer/python/features/maestro/claude/hooks/` directory
2. [ ] Write `state-check.py` - verify MAESTRO.md exists
3. [ ] Write `safety-rails.py` - block dangerous commands
4. [ ] Write `dispatch-validator.py` - validate CLI patterns
5. [ ] Write `scope-guard.py` - enforce file scope
6. [ ] Write `auto-logger.py` - automatic logging
7. [ ] Add YAML frontmatter to `maestro-run.md`
8. [ ] Update `maestro-run.md` to write task manifest before dispatch
9. [ ] Test each hook independently
10. [ ] Test full orchestration flow with hooks

## Tool-Specific Limitations

> **Important:** This research applies exclusively to Claude Code. The hook system documented here is not available in Gemini CLI or Codex CLI.

### Extension System Comparison

| Tool | Extension System | Hook-Like Capability | Enforcement Model |
|------|------------------|---------------------|-------------------|
| **Claude Code** | Slash commands (.md) + Hooks | ✅ Full PreToolUse/PostToolUse interception | Hooks can block tool execution |
| **Gemini CLI** | Extensions (JSON bundles) | ❌ No tool interception | Extensions add capabilities, don't intercept |
| **Codex CLI** | Prompts (.md files) | ❌ No tool interception | Prompts guide behavior, don't enforce |

### What This Means for Maestro

When Claude Code is the **hub** orchestrating tasks:

```
┌──────────────────────────────────────────────────────────────┐
│  Claude Code Hub                                              │
│  ┌────────────────────────────────────────────────────────┐  │
│  │ PreToolUse hooks fire HERE                             │  │
│  │ → Can validate Bash commands before execution          │  │
│  │ → Can block malformed CLI dispatches                   │  │
│  │ → Can enforce dispatch patterns (flags, format)        │  │
│  └────────────────────────────────────────────────────────┘  │
│                            ↓                                  │
│                   Bash: gemini -p "..." -y -o json           │
│                            ↓                                  │
│  ┌────────────────────────────────────────────────────────┐  │
│  │ Gemini CLI Spoke (BLACK BOX)                           │  │
│  │ → Hooks CANNOT see inside                              │  │
│  │ → No interception of Gemini's tool uses                │  │
│  │ → Relies on prompt-based guardrails only               │  │
│  └────────────────────────────────────────────────────────┘  │
│                            ↓                                  │
│  ┌────────────────────────────────────────────────────────┐  │
│  │ PostToolUse hooks fire HERE                            │  │
│  │ → Can log the dispatch outcome                         │  │
│  │ → Can validate output format                           │  │
│  │ → CANNOT undo spoke actions                            │  │
│  └────────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────────┘
```

### Enforcement Coverage by Spoke Type

| Enforcement | Claude Code Spoke | Gemini/Codex Spoke |
|-------------|-------------------|-------------------|
| Scope enforcement (file restrictions) | ✅ Full | ❌ Prompt-based only |
| Command validation (CLI flags) | ✅ Pre-dispatch | ✅ Pre-dispatch |
| Automatic logging | ✅ Full | ⚠️ Dispatch-level only |
| State integrity | ✅ Full | ✅ Full (hub-side) |
| Safety rails (dangerous commands) | ✅ Full | ❌ Prompt-based only |

### Mitigation Strategies for Non-Claude Spokes

Since hooks cannot enforce behavior inside Gemini/Codex execution, consider:

1. **Stricter task handoff prompts** - Reinforce guardrails in the spoken prompt itself
2. **Post-execution validation** - Use PostToolUse to verify expected outcomes (file diffs, test results)
3. **Wrapper scripts** - Create CLI wrappers that enforce constraints before invoking the actual tool
4. **Sandboxed execution** - Run spokes in containers or restricted environments
5. **Output parsing** - Validate spoke output structure before accepting results

### Future Research Needed

- [ ] Gemini CLI extension capabilities - can extensions intercept or validate?
- [ ] Codex CLI hooks or middleware - any planned features?
- [ ] Cross-tool enforcement abstraction - unified model possible?

## References

- Claude Code Hooks Documentation: https://docs.anthropic.com/en/docs/claude-code/hooks
- `/plugin-dev:hook-development` skill for advanced patterns
- Exit codes: `0` = allow, `2` = block, other = warning
- Gemini CLI Extensions: *[TODO: Add link]*
- Codex CLI Documentation: *[TODO: Add link]*
