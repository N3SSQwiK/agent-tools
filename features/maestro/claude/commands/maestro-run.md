# Maestro Run Command

Execute approved orchestration plan or specific task.

## Behavior

1. Load plan from `.ai/MAESTRO.md`
   - If not exists: "No active plan. Run `/maestro plan <goal>` first."

2. If task ID provided (`/maestro run 3`), target that task
   - Otherwise, find next runnable task(s) (status=pending, dependencies satisfied)

3. For each runnable task:
   a. Perform pre-delegation reconnaissance (cheap checks)
   b. Validate preconditions (AAVSR)
   c. Build task handoff using Spoke Contract template
   d. Dispatch to assigned tool
   e. Collect and normalize result
   f. Validate result against quality gates
   g. Update state file
   h. Log execution (if logging enabled)

4. Continue until:
   - All tasks complete
   - Task fails (after retry ladder exhausted)
   - User intervention required

## Task Handoff Template

Send to spoke:

```markdown
## Task
[Clear, atomic task description]

## Context
[Relevant files, decisions, constraints - from recon]

## Success Criteria
- [ ] [Criterion 1]
- [ ] [Criterion 2]

## Constraints
- [Scope boundary]

## Guardrails

> **🚨 STRICT RULES — VIOLATIONS WILL CAUSE TASK REJECTION**
>
> 1. **ONLY modify files explicitly listed** — Do not touch any other files
> 2. **ONLY run commands required for THIS task** — No exploratory commands
> 3. **DO NOT install dependencies** unless explicitly requested
> 4. **DO NOT expand scope** — If additional work is needed, report it in Issues
> 5. **STOP if blocked** — Do not improvise solutions; report blockers instead

## Output Format
Return result as markdown with Status, Summary, Changes, Verification, Issues sections.

**You MUST use this exact format. Non-compliant responses will be rejected.**
```

## Result Validation

Parse spoke result and validate:

1. **Format Compliance** - Contains required sections
2. **Criteria Satisfaction** - Success criteria addressed
3. **Scope Adherence** - No out-of-scope changes reported

## CLI Dispatch Patterns

> **🚨 CRITICAL DISPATCH RULES — READ BEFORE EVERY DISPATCH**
>
> 1. **COPY THE EXACT COMMAND** — Do not modify, abbreviate, or omit any flags
> 2. **VERIFY ALL FLAGS** — Before executing, confirm your command matches the pattern
> 3. **FAILURE CONSEQUENCE** — Missing flags WILL cause spoke file write failures

### Gemini CLI

**EXACT COMMAND (do not modify):**
```bash
gemini -p "<handoff prompt>" -y -o json
```

**Pre-dispatch checklist:**
- [ ] Command starts with `gemini -p`
- [ ] Has `-y` flag (enables YOLO mode for file writes)
- [ ] Has `-o json` flag (structured output)
- [ ] Prompt is properly quoted

Use `@path/to/file` for file references (9.2x token efficiency).

### Codex CLI

**EXACT COMMAND (do not modify):**
```bash
codex exec "<handoff prompt>" --full-auto --json
```

**Pre-dispatch checklist:**
- [ ] Command starts with `codex exec`
- [ ] Has `--full-auto` flag (enables autonomous file writes)
- [ ] Has `--json` flag (structured output)

### Claude Code

**EXACT COMMAND (do not modify):**
```bash
claude -p "<handoff prompt>" --output-format json --dangerously-skip-permissions
```

**Pre-dispatch checklist:**
- [ ] Command starts with `claude -p`
- [ ] Has `--output-format json` flag
- [ ] Has `--dangerously-skip-permissions` flag (enables file writes)

**Security Note:** The `--dangerously-skip-permissions` flag grants broad file access to the sub-agent. This is appropriate for Maestro orchestration where tasks are pre-approved during planning. Use `--max-turns N` to limit agentic turns if needed.

### Permission Recovery

If a spoke returns a `permission_denials` response (e.g., Claude Code without the permissions flag), the hub MAY extract the file paths and content from the response and write files directly as a fallback.

## Precondition Checks (AAVSR)

Before dispatch, validate:

| Check | Failure Action |
|-------|----------------|
| **A**tomic | Decompose further |
| **A**uthority | Reassign specialist |
| **V**erifiable | Add concrete criteria |
| **S**cope | Add constraints |
| **R**isk | Add safeguards |

## Quality Gates

Before accepting result:

| Gate | Check | Failure Action |
|------|-------|----------------|
| Format | Result has required sections | Retry with clarified format |
| Criteria | All criteria addressed | Retry with focus on gaps |
| Scope | No out-of-scope work | Accept in-scope, note scope creep |

## Retry Ladder

On task failure:

1. **Immediate Retry** - Transient failures (network, timeout with complete output)
2. **Context Expansion** - Add more context, retry
3. **Task Decomposition** - Break into smaller subtasks
4. **User Escalation** - Present options to user

## Token Budgets

| Tool | Budget | Abort Threshold |
|------|--------|-----------------|
| Gemini CLI | 30,000 | 50,000 |
| Codex CLI | 40,000 | 60,000 |

Over budget: Log warning, continue
Over abort: Abort dispatch, handle task directly

## Timeout Handling (Exit 124)

If CLI times out:
1. Check if output structurally complete
2. If complete → Accept as soft success, log warning
3. If incomplete → Trigger retry with narrower scope

## State Updates

After each task:

1. Update task status in `.ai/MAESTRO.md`
2. If logging enabled, append to `.ai/MAESTRO-LOG.md`:

```
| [time] | Hub | Dispatch | [Tool] ([specialist]) | [tokens] | [duration] | [outcome] | [notes] |
```

## Flags

| Flag | Behavior |
|------|----------|
| `--log=summary` | Log actions and outcomes |
| `--log=detailed` | Log full prompts and outputs |
| `--dry-run` | Show what would execute without dispatching |

## Rules

- Always perform reconnaissance before dispatch
- Validate AAVSR before every dispatch
- Never skip quality gates
- Update state file after each task
- Use UTC timestamps
- If all tasks blocked, report and wait for user

## Examples

### Run next task
```
/maestro run
```

### Run specific task
```
/maestro run 3
```

### Dry run to preview
```
/maestro run --dry-run
```

### Run with logging
```
/maestro run --log=summary
```
