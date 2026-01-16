# Proposal: Unify Continuity File

## Why

The current continuity feature creates separate files per AI tool (`.claude/CONTINUITY.md`, `.gemini/CONTINUITY.md`, `.codex/CONTINUITY.md`), causing context loss when switching between tools. A user working with Claude for several sessions loses all context when switching to Gemini. Additional issues include duplication, drift between files, and manual maintenance burden.

## What Changes

- Unify to a single shared continuity file at `.ai/CONTINUITY.md`
- Expand format from ~60 to ~500 tokens with richer context
- Add new sections: Summary, Completed, In Progress, Blocked, Key Files, Context, Suggested Prompt, Source
- Add migration logic for existing per-tool legacy files
- Add legacy file detection with `.ai/.legacy-checked` flag

## Proposed Solution

Unify to a **single shared continuity file** at `.ai/CONTINUITY.md` that all three tools read and write.

### Key Design Decisions

1. **Location**: `.ai/CONTINUITY.md` (tool-agnostic directory)
2. **Format**: Expand from ~60 tokens to ~500 tokens with richer context
3. **Suggested Prompt**: Include actionable continuation prompt for seamless handoff
4. **Backwards compatibility**: Check for legacy paths and offer migration

### Benefits

- Single source of truth for project state
- Seamless tool switching without context loss
- Reduced duplication and maintenance
- Team-friendly (different members can use different tools)

## Scope

### In Scope
- Update global instruction files (CLAUDE.md, GEMINI.md, AGENTS.md)
- Update slash commands for all three tools
- Expand continuity format from ~60 to ~500 tokens
- Add new sections: Summary, In Progress, Blocked, Key Files, Context, Suggested Prompt
- Add migration logic for existing per-tool files

### Out of Scope
- Multi-user conflict resolution
- Automatic merging of divergent files
- Version history within the file

## Success Criteria

1. All three tools read/write to `.ai/CONTINUITY.md`
2. Session start correctly loads unified continuity regardless of tool
3. `/continuity` command works identically across tools
4. Existing users see migration prompt for legacy files
5. Expanded format (~500 tokens) provides actionable context for session handoff
6. Suggested Prompt section enables copy-paste continuation
