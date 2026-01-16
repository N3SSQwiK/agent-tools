# Design: Unified Continuity File

## Architecture Overview

```
project/
├── .ai/
│   └── CONTINUITY.md    # Shared by all tools
├── .claude/             # Legacy (migration source)
│   └── CONTINUITY.md
├── .gemini/             # Legacy (migration source)
│   └── CONTINUITY.md
└── .codex/              # Legacy (migration source)
    └── CONTINUITY.md
```

## Design Decisions

### 1. File Location: `.ai/CONTINUITY.md`

**Considered alternatives:**
| Option | Pros | Cons |
|--------|------|------|
| `CONTINUITY.md` (root) | Simple, visible | Clutters project root |
| `.continuity/state.md` | Dedicated directory | New pattern, more nesting |
| `.ai/CONTINUITY.md` | Tool-agnostic, contained | New `.ai/` directory |

**Decision**: `.ai/CONTINUITY.md`
- Tool-agnostic naming supports future AI tools
- Hidden directory keeps project root clean
- `.ai/` can host other shared AI config in the future

### 2. File Format

Expand from ~60 tokens to ~500 tokens for richer context and actionable handoff:

```markdown
# Continuity

## Summary
[High-level project context - what is being built and why]

## Completed
[Work finished in recent sessions - bullet points]

## In Progress
[Active work items not yet complete]

## Blocked
[Impediments or decisions needed - or "None"]

## Key Files
[Important file paths for quick navigation]

## Context
[Session-specific state, user preferences, environment details]

## Suggested Prompt
> [Actionable, copy-pasteable prompt to continue the work]
> [Include specific next steps and any pending decisions]

## Source
[Tool Name] | [YYYY-MM-DD HH:MM UTC]
```

**Section purposes:**

| Section | ~Tokens | Purpose |
|---------|---------|---------|
| Summary | 60 | Project-level context for new sessions |
| Completed | 80 | What's done - prevents re-work |
| In Progress | 30 | Active work - enables continuation |
| Blocked | 10 | Surface impediments early |
| Key Files | 80 | Quick navigation, no searching |
| Context | 50 | Session state that doesn't fit elsewhere |
| Suggested Prompt | 120 | Actionable continuation - the key handoff mechanism |
| Source | 10 | Attribution and timestamp |

**Rationale for expansion:**
- 60 tokens was too sparse for meaningful context transfer
- Suggested Prompt is the key innovation - enables true seamless handoff
- Key Files eliminates "where was that?" friction when resuming

### 3. Migration Strategy

When a tool starts and finds no `.ai/CONTINUITY.md`:

1. Check for legacy files in order: `.claude/`, `.gemini/`, `.codex/`
2. If found, display content and ask: "Migrate to unified location?"
3. If yes, copy to `.ai/CONTINUITY.md` and suggest removing legacy file
4. If no, continue without migration (respect user choice)

**Rationale**: Non-destructive migration respects existing workflows.

### 4. Conflict Handling

**Approach**: Last-write-wins (simple)

- No locking mechanism
- No merge logic
- Source field shows which tool last updated

**Rationale**:
- Continuity files are still manageable (~500 tokens)
- Single-user workflow is the primary use case
- Complexity of conflict resolution outweighs benefits

### 5. Installer Changes

Update `install_managed_config()` behavior:

| Component | Current Path | New Path |
|-----------|--------------|----------|
| Global instructions | `~/.{tool}/TOOL.md` | No change |
| Slash commands | Per-tool paths | Update to reference `.ai/CONTINUITY.md` |

The global instruction files still go to tool-specific locations (they're merged into context), but now reference the shared continuity path.

## File Changes Summary

### Global Instructions (3 files)
- `features/continuity/claude/CLAUDE.md` → reference `.ai/CONTINUITY.md`
- `features/continuity/gemini/GEMINI.md` → reference `.ai/CONTINUITY.md`
- `features/continuity/codex/AGENTS.md` → reference `.ai/CONTINUITY.md`

### Slash Commands (3 files)
- `features/continuity/claude/commands/continuity.md`
- `features/continuity/gemini/extensions/continuity/commands/continuity.toml`
- `features/continuity/codex/prompts/continuity.md`

All updated to:
1. Read/write `.ai/CONTINUITY.md`
2. Check for legacy paths and offer migration

## Risks and Mitigations

| Risk | Mitigation |
|------|------------|
| User expects per-tool files | Clear migration prompt, documentation |
| `.ai/` conflicts with other tools | Unlikely; no known conflicts |
| Breaking existing workflows | Non-destructive migration, legacy support period |
