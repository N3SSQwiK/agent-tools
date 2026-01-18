# Maestro Testing Round 2

Validation testing for OpenSpec change `fix-maestro-dispatch-patterns`.

## Test Cases

### Test 1: Hello Script
> Create a hello.sh script that prints 'Hello, Maestro!' and a test script

- **Spoke:** Claude Code
- **Result:** ✅ SUCCESS

### Test 2: Config + README
> Create config.json and README.md documenting the options

- **Spokes:** Gemini CLI, Codex CLI
- **Result:** ✅ SUCCESS

## Contents

| File | Description |
|------|-------------|
| `ASSESSMENT.md` | Detailed assessment with findings |
| `execution-report.md` | Hello.sh test report |
| `execution-report-config-readme.md` | Config/README test report |

## Key Findings

### Fixes Validated ✅
- `--dangerously-skip-permissions` flag now included in Claude Code dispatch
- Guardrails section included in spoke handoff prompts
- Zero permission failures (vs. multiple in Round 1)
- 100% task success rate across all three spoke tools

### Issues Discovered
- **Global instruction conflict** — Spokes inherit global instructions that can override guardrails
- **Token economics** — Subscription users should monitor total tokens, not just billable tokens
- **Hub file injection** — Codex/Claude spokes run `cat` to read files; hub should pre-inject content like Gemini's `@path` syntax
