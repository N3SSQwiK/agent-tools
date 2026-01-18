# Change: Add Hub Task Classification

## Why

When the hub dispatches tasks to spokes, it currently has no guidance on which tasks are appropriate for autonomous spoke execution versus which require user interaction and should remain at the hub. This was observed when a task requiring `npm create vite` (an interactive CLI command) was dispatched to a Gemini spoke running in `-y` (YOLO) mode. The spoke correctly stopped at "Interactive shell awaiting input" per guardrail #5 (STOP if blocked), but the task was fundamentally unsuitable for spoke execution.

The guardrails are working correctly—the problem is the dispatch decision itself. Tasks requiring user input should never leave the hub.

## What Changes

- Add a new **Task Classification** requirement to the Maestro spec
- Define **hub-only tasks** (interactive, require user approval) vs **delegatable tasks** (autonomous, non-interactive)
- Add classification criteria the hub must evaluate before dispatch
- Require hub to execute hub-only tasks directly rather than delegating them

## Impact

- Affected specs: `maestro-orchestration`
- Affected code: All `/maestro run` command implementations (Claude, Gemini, Codex)
- No breaking changes—this adds classification logic before existing dispatch
