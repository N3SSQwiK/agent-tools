# Maestro Troubleshooting

## Common Issues

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
3. Add stricter constraints to task handoff

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

## Getting Help

If issues persist:

1. Generate a report: `/maestro report`
2. Review the execution log for patterns
3. Check tool-specific documentation:
   - [Claude Code docs](https://code.claude.com/docs/en/cli-reference)
   - [Gemini CLI docs](https://geminicli.com/docs/cli/headless/#configuration-options)
   - [Codex CLI docs](https://developers.openai.com/codex/noninteractive/)
