# Maestro Troubleshooting

## Common Issues

### Spoke Cannot Write Files (Permission Denied)

**Symptom**: Spoke reports permission denied or `permission_denials` in output.

**Causes**:
1. Missing auto-approve flags in dispatch command
2. Tool not running in the correct mode

**Solutions**:

Verify the hub is using correct dispatch patterns:

| Tool | Required Command |
|------|------------------|
| Claude Code | `claude -p "..." --output-format json --dangerously-skip-permissions` |
| Gemini CLI | `gemini -p "..." -y -o json` |
| Codex CLI | `codex exec "..." --full-auto --json` |

**Note**: The `--dangerously-skip-permissions` flag for Claude Code is required for file writes. The `-y` flag enables Gemini's "YOLO mode" for auto-approving tool calls.

**Recovery**: If a spoke returns `permission_denials`, the hub may extract file paths and content to write files directly as a fallback.

---

### "No active Maestro orchestration"

**Symptom**: Running `/maestro status` or `/maestro run` reports no active orchestration.

**Cause**: No `.ai/MAESTRO.md` file exists.

**Solution**: Run `/maestro plan <goal>` to create an orchestration plan first.

---

### "No execution log found"

**Symptom**: Running `/maestro report` reports no execution log.

**Cause**: Logging was not enabled during plan or run.

**Solution**: Enable logging when planning or running:
```
/maestro plan "goal" --log=summary
/maestro run --log=detailed
```

---

### Task Timeouts

**Symptom**: Spoke tasks timeout frequently.

**Causes**:
1. Tasks are too complex
2. Network issues
3. Tool rate limiting

**Solutions**:
1. Decompose tasks further (smaller scope)
2. Check network connectivity
3. Wait and retry, or reduce parallelization

---

### Token Budget Exceeded

**Symptom**: Hub logs "token budget exceeded" warnings.

**Cause**: Spoke received too much context or task was too complex.

**Solutions**:
1. Reduce context in task handoff
2. Use Gemini's `@path` syntax instead of inline content
3. Decompose task into smaller subtasks

---

### Quality Gate Failures

**Symptom**: Hub rejects spoke results due to failed quality gates.

**Causes**:
1. Spoke output doesn't match expected format
2. Success criteria not satisfied
3. Scope creep detected

**Solutions**:
1. Add clearer output format instructions to task
2. Make success criteria more explicit
3. Guardrails are automatically included in handoffs to prevent scope creep

---

### Spoke Ignores Guardrails

**Symptom**: Spoke modifies files not listed in the task or runs exploratory commands.

**Cause**: Global instructions in the spoke's configuration (e.g., `~/.claude/CLAUDE.md`) may conflict with Maestro guardrails.

**Example**: A global instruction to "check for `.ai/CONTINUITY.md`" causes the spoke to run extra commands even though guardrails say "ONLY run commands required for THIS task."

**Solutions**:
1. Review global instructions for conflicts with Maestro guardrails
2. Consider removing or scoping global instructions that cause exploration
3. Accept that some overhead is unavoidable due to inherited configuration

**Note**: Spokes acknowledge guardrail conflicts in their reasoning (e.g., "Checking continuity file despite guardrails"). This is a known limitation when global and task-specific instructions conflict.

---

### Cross-Tool Dispatch Failures

**Symptom**: Hub cannot dispatch to spoke tool.

**Causes**:
1. Tool not authenticated
2. Tool not installed
3. CLI command format incorrect

**Solutions**:
1. Verify tool authentication: run the tool directly
2. Verify tool installation: `which gemini`, `which codex`
3. Check CLI syntax in spoke contract

---

### State File Corruption

**Symptom**: `/maestro status` shows malformed state or errors.

**Cause**: Manual editing or incomplete write.

**Solutions**:
1. Review `.ai/MAESTRO.md` manually
2. Fix formatting issues
3. If unrecoverable, delete and run `/maestro plan` again

---

## Retry Ladder Behavior

When a task fails, Maestro follows this escalation:

| Step | Action | When Used |
|------|--------|-----------|
| 1 | Immediate retry | Network errors, timeouts with partial output |
| 2 | Context expansion | Spoke reported missing context |
| 3 | Task decomposition | Task too complex for single dispatch |
| 4 | User escalation | All retries exhausted |

---

## Exit Code 124 (Timeout)

Exit code 124 from CLI tools indicates timeout, but this doesn't always mean failure.

**Hub behavior**:
1. Check if output is structurally complete
2. If complete → Accept as "soft success"
3. If incomplete → Trigger retry ladder

**You may see**: "Accepted as soft success despite timeout"

---

## Debugging Tips

### Enable Detailed Logging

```
/maestro run --log=detailed
```

This captures full prompts and outputs for debugging.

### Check State File

```
cat .ai/MAESTRO.md
```

Verify task status, dependencies, and timestamps.

### Check Execution Log

```
cat .ai/MAESTRO-LOG.md
```

Review execution timeline, token usage, and outcomes.

### Run Single Task

Instead of running the full plan, isolate issues by running one task:

```
/maestro run 3
```

### Dry Run

Preview execution without dispatching:

```
/maestro run --dry-run
```

---

## Token Usage Higher Than Expected

**Symptom**: Simple tasks use many more tokens than expected.

**Causes**:
1. **Cached vs. new tokens**: Total tokens include cached tokens, but only new tokens cost full price for API users
2. **Multi-model routing**: Some tools use multiple models (e.g., Gemini uses a lite model for routing + main model for execution)
3. **Global instructions**: Inherited configuration adds to context size
4. **Exploratory commands**: Spokes may run commands like `ls` or `cat` that weren't strictly necessary

**Understanding token counts**:
```
Total input: 21,114
Cached: 16,896 (80%)
New: 4,218       ← API users pay reduced rate for cached
Output: 445

API cost: ~4,663 tokens equivalent
Subscription impact: 21,559 tokens against quota  ← Subscription users pay full quota
```

**Key insight**: Caching benefits API billing but not subscription quotas. Subscription users should monitor total tokens.

---

## Getting Help

If issues persist:

1. Generate a report: `/maestro report`
2. Review the execution log for patterns
3. Check tool-specific documentation:
   - [Claude Code docs](https://docs.anthropic.com/en/docs/claude-code)
   - [Gemini CLI docs](https://github.com/google-gemini/gemini-cli)
   - [Codex CLI docs](https://github.com/openai/codex)
