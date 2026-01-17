# Maestro Status Command

Display current orchestration state.

## Behavior

1. Check if `.ai/MAESTRO.md` exists
   - If not: Report "No active Maestro orchestration. Run `/maestro plan <goal>` to start."
   - If yes: Continue to step 2

2. Read and parse `.ai/MAESTRO.md`

3. Display formatted status:
   - Goal
   - Task completion summary
   - Current task status table
   - Blocking issues (if any)
   - Suggested next action

4. If `--save` flag provided, update Source timestamp

## Output Format

```
## Maestro Status

**Goal:** [objective]

**Progress:** [done]/[total] tasks complete

### Tasks
| ID | Description | Status | Tool |
|----|-------------|--------|------|
| 1 | [desc] | done | Gemini CLI |
| 2 | [desc] | running | Codex CLI |
| 3 | [desc] | pending | Claude Code |

### Blocking Issues
[Issues or "None"]

### Suggested Next Action
[What to do next - run, review, or user action needed]

---
Last updated: [timestamp from file]
```

## Status Indicators

| Status | Display |
|--------|---------|
| `pending` | Waiting |
| `running` | In Progress |
| `done` | Complete |
| `failed` | Failed |
| `blocked` | Blocked |

## Suggested Actions

Based on state, recommend:

| State | Suggestion |
|-------|------------|
| All pending | "Run `/maestro run` to start execution" |
| Some running | "Tasks in progress. Wait for completion or check tool output" |
| Failed tasks | "Review failed tasks. Run `/maestro run [id]` to retry" |
| Blocked tasks | "User intervention needed: [blocker description]" |
| All done | "Orchestration complete. Review changes and clean up state file" |

## Flags

| Flag | Behavior |
|------|----------|
| `--save` | Update Source timestamp without changing state |
| `--json` | Output as JSON (for programmatic use) |

## JSON Output Format

When `--json` flag is used:

```json
{
  "goal": "[objective]",
  "tasks": [
    {
      "id": 1,
      "description": "[desc]",
      "status": "done",
      "specialist": "code",
      "tool": "Gemini CLI",
      "depends": []
    }
  ],
  "progress": {
    "done": 2,
    "running": 1,
    "pending": 2,
    "failed": 0,
    "blocked": 0,
    "total": 5
  },
  "lastUpdated": "2026-01-16 14:30 UTC"
}
```

## Rules

- Read-only by default (no state modification)
- If state file is malformed, report error and suggest manual review
- Always show Source timestamp from file
- Use relative descriptions for time (e.g., "2 hours ago")
