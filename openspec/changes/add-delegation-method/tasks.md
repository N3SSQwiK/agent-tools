# Tasks: Add Explicit Task Delegation Method to Maestro

## 1. Update Claude Code Run Command

- [ ] 1.1 Update `maestro-run.md` to specify delegation method selection
  - Add decision logic: same-tool → Task tool, cross-tool → CLI spawn
  - Document Task tool invocation pattern for self-delegation
  - Preserve existing CLI spawn patterns for cross-tool delegation

## 2. Update Codex CLI Run Command

- [ ] 2.1 Update `maestro-run.md` (Codex version)
  - Document that all delegation uses CLI spawn
  - No Task tool equivalent available

## 3. Update Gemini CLI Run Command

- [ ] 3.1 Update `maestro-run.toml`
  - Document that all delegation uses CLI spawn
  - No within-session subagent equivalent available

## 4. Update Spoke Contract Documentation

- [ ] 4.1 Update `SPOKE-CONTRACT.md`
  - Add "Delegation Method Selection" section
  - Document Task tool vs CLI spawn decision matrix
  - Clarify that Task tool provides same isolation guarantees as CLI spawn

## 5. Validation

- [ ] 5.1 Verify Claude Code self-delegation uses Task tool
- [ ] 5.2 Verify Claude Code cross-tool delegation uses CLI spawn
- [ ] 5.3 Verify Gemini/Codex always use CLI spawn
