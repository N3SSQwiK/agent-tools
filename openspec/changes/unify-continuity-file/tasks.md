# Tasks: Unify Continuity File

## Implementation Order

### Phase 1: Update Global Instructions
*Can be done in parallel*

- [x] **1.1** Update `features/continuity/claude/CLAUDE.md`
  - Change path from `.claude/CONTINUITY.md` to `.ai/CONTINUITY.md`
  - Validation: Read file, verify new path referenced

- [x] **1.2** Update `features/continuity/gemini/GEMINI.md`
  - Change path from `.gemini/CONTINUITY.md` to `.ai/CONTINUITY.md`
  - Validation: Read file, verify new path referenced

- [x] **1.3** Update `features/continuity/codex/AGENTS.md`
  - Change path from `.codex/CONTINUITY.md` to `.ai/CONTINUITY.md`
  - Validation: Read file, verify new path referenced

### Phase 2: Update Slash Commands with Expanded Format
*Can be done in parallel*

- [x] **2.1** Update Claude command (`features/continuity/claude/commands/continuity.md`)
  - Change read/write path to `.ai/CONTINUITY.md`
  - Implement expanded ~500 token format with all sections
  - Add migration check for `.claude/CONTINUITY.md`
  - Validation: Manual test with `/continuity` command

- [x] **2.2** Update Gemini extension (`features/continuity/gemini/extensions/continuity/commands/continuity.toml`)
  - Change read/write path to `.ai/CONTINUITY.md`
  - Implement expanded ~500 token format with all sections
  - Add migration check for `.gemini/CONTINUITY.md`
  - Validation: Manual test with `/continuity` command

- [x] **2.3** Update Codex prompt (`features/continuity/codex/prompts/continuity.md`)
  - Change read/write path to `.ai/CONTINUITY.md`
  - Implement expanded ~500 token format with all sections
  - Add migration check for `.codex/CONTINUITY.md`
  - Validation: Manual test with `/continuity` command

**Expanded format sections (all commands):**
- Summary (~60 tokens) - project-level context
- Completed (~80 tokens) - finished work items
- In Progress (~30 tokens) - active work
- Blocked (~10 tokens) - impediments or "None"
- Key Files (~80 tokens) - relevant file paths
- Context (~50 tokens) - session-specific state
- Suggested Prompt (~120 tokens) - actionable continuation
- Source (~10 tokens) - tool name + UTC timestamp

### Phase 3: Documentation & Cleanup

- [x] **3.1** Update README if continuity feature is documented
  - Document new unified path
  - Explain migration from legacy paths

- [x] **3.2** Test end-to-end flow
  - Create legacy file in one tool's path
  - Start session with different tool
  - Verify migration prompt appears
  - Verify unified file works across tools

## Dependencies

```
Phase 1 (parallel) ──┐
                     ├──► Phase 3
Phase 2 (parallel) ──┘
```

Phases 1 and 2 can proceed in parallel. Phase 3 depends on both completing.

## Validation Checklist

- [x] All three tools reference `.ai/CONTINUITY.md` in global instructions
- [x] All three slash commands read/write to unified path
- [x] Expanded format includes all 8 sections
- [x] Suggested Prompt section is actionable and copy-pasteable
- [x] Total token count is approximately 500 tokens
- [x] Migration prompts work for each legacy path
- [x] New installs create `.ai/CONTINUITY.md` correctly
- [x] Existing installs are prompted to migrate
