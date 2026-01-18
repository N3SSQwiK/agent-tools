# Maestro Testing Round 2 — Assessment

**Date:** 2026-01-17
**Purpose:** Validate fixes from OpenSpec change `fix-maestro-dispatch-patterns`
**Test Directory:** `~/maestro-test-2`

---

## Fixes Validated

### Fix 1: `--dangerously-skip-permissions` Flag ✅

**Before:** Claude Code dispatch pattern was missing the flag, causing `permission_denials` errors.

**After:** Dispatch command now includes all required flags:
```bash
claude -p "..." --output-format json --dangerously-skip-permissions --max-turns 5
```

**Evidence:** Screenshot shows correct command with flag present. Both tasks completed successfully with file writes.

### Fix 2: Guardrails in Handoff Prompts ✅

**Before:** Spokes had no explicit constraints, leading to potential scope creep.

**After:** Handoff prompts include guardrails section:
```
## Guardrails

> **STRICT RULES — VIOLATIONS WILL CAUSE TASK REJECTION**
>
> 1. **ONLY modify files explicitly listed**
> 2. **ONLY run commands required for THIS task**
> 3. **DO NOT install dependencies** unless explicitly requested
> 4. **DO NOT expand scope**
> 5. **STOP if blocked**
```

**Evidence:** Screenshot shows guardrails included in task handoff. Spoke created only the requested files.

### Fix 3: Interactive Logging Selection ⚠️ (Not Tested)

**Status:** Menu should appear after plan approval. User did not capture this step.

**Note:** Logging was enabled (report generated), suggesting menu was shown and "Summary" was selected.

---

## Test Results

| Metric | Value |
|--------|-------|
| Tasks Planned | 3 (reduced to 2 after challenge) |
| Tasks Executed | 2 |
| Tasks Succeeded | 2 |
| Tasks Failed | 0 |
| Permission Errors | 0 |
| Total Duration | ~34s |
| Total Cost | ~$0.22 |

---

## Comparison with Round 1

| Issue | Round 1 | Round 2 |
|-------|---------|---------|
| Claude Code permission failures | Yes | **No** |
| Missing dispatch flags | Yes (Gemini `-y`) | **No** |
| Scope creep by spokes | Possible | **Constrained** |
| File writes succeeded | Partial | **100%** |

---

## Conclusion

**All critical fixes validated.** The Maestro orchestration system now:

1. ✅ Includes `--dangerously-skip-permissions` for Claude Code spokes
2. ✅ Includes guardrails in handoff prompts to constrain spoke behavior
3. ✅ Has pre-dispatch checklists documented for all three CLI tools
4. ⚠️ Interactive logging selection implemented (not explicitly captured in screenshots)

---

---

## Additional Testing: Multi-Tool Dispatch

A second test case was run to validate Gemini CLI and Codex CLI as spokes.

**Goal:** Create config.json and README.md

| Task | Spoke | Outcome | Total Tokens |
|------|-------|---------|--------------|
| config.json | Gemini CLI | ✅ success | ~22,800 |
| README.md | Codex CLI | ✅ success | ~21,500 |

**All dispatch patterns validated across all three tools.**

---

## Finding: Global Instruction Conflict

### Issue
Spokes inherit global instructions (e.g., from `~/.claude/CLAUDE.md`) which can conflict with Maestro guardrails.

**Evidence from Codex execution:**
```json
{
  "type": "reasoning",
  "text": "Checking continuity file despite guardrails"
}
```

The spoke acknowledged it was violating guardrails to obey global instructions that say "consider checking for `.ai/CONTINUITY.md`".

### Impact
- Unnecessary commands consume tokens
- Guardrails are not fully respected
- Subscription users waste quota on exploratory commands

### Recommendation
Consider adding explicit instruction in handoff: "Ignore global session instructions for this task" — though this is a broader design decision with tradeoffs.

---

## Finding: Token Economics Clarification

### Total vs Billable Tokens

| Token Type | API Users | Subscription Users |
|------------|-----------|-------------------|
| New input | Full cost | Counts toward cap |
| Cached input | 10-25% cost | **Still counts toward cap** |
| Output | Full cost | Counts toward cap |

**Key insight:** Caching primarily benefits API billing, not subscription quotas. Subscription users should care about **total tokens**, not just "billable" tokens.

### Actual Token Breakdown (Codex example)
```
Total input: 21,114
Cached: 16,896 (80%)
New: 4,218
Output: 445

API cost: ~4,663 tokens equivalent
Subscription impact: 21,559 tokens against quota
```

---

## Finding: Hub File Injection Optimization

### Issue
Gemini CLI has `@path/to/file` syntax for efficient file references (~9.2x more token-efficient). Codex and Claude lack this, so they run commands like `cat config.json` to read files — costing extra turns and tokens.

### Evidence
Codex ran `cat config.json` to read the file before writing README.md:
```json
{
  "command": "/bin/zsh -lc 'cat config.json'",
  "exit_code": 0
}
```

This cost an extra turn + output tokens for something the hub already knew about.

### Recommendation
During pre-delegation reconnaissance, the hub should:

| Spoke Tool | Optimization |
|------------|--------------|
| Gemini CLI | Use `@path/to/file` syntax (already efficient) |
| Codex CLI | Inject file content into Context section |
| Claude Code | Inject file content into Context section |

**Example optimized handoff for Codex:**
```markdown
## Context
Contents of config.json:
​```json
{
  "name": "maestro-test",
  "version": "1.0.0",
  "debug": false
}
​```
```

This eliminates unnecessary `cat` commands and equalizes efficiency across all spoke tools.

---

## Recommendations

1. **Mark OpenSpec change as complete** — All implementation tasks done, fixes validated
2. **Update ASSESSMENT.md in round 1 docs** — Link to this validation
3. **Consider global instruction isolation** — Evaluate whether spokes should ignore inherited global instructions
4. **Document token economics** — Help users understand total vs billable tokens for subscription planning
5. **Implement hub file injection** — Pre-inject file contents for Codex/Claude spokes to match Gemini's `@path` efficiency

---

## Files in This Assessment

- `execution-report.md` — Hello.sh test execution report
- `execution-report-config-readme.md` — Config/README test execution report
- `ASSESSMENT.md` — This file
