# Tasks: Migrate Commands to Agent Skills

## 1. Update Installer Code

- [ ] 1.1 Add `install_skills()` method to copy skill directories to tool locations
- [ ] 1.2 Replace `install_claude()` command logic with skill installation
- [ ] 1.3 Replace `install_gemini()` extension logic with skill installation
- [ ] 1.4 Replace `install_codex()` prompt logic with skill installation
- [ ] 1.5 Remove command/extension/prompt installation code (deprecated)
- [ ] 1.6 Update glob pattern logic for skill directories
- [ ] 1.7 Add skill directory creation with `mkdir(parents=True, exist_ok=True)`

## 2. Add Gemini Skills Enablement

- [ ] 2.1 Add `GeminiSkillsScreen` TUI screen after feature selection
- [ ] 2.2 Display explanation of skills and what enablement does
- [ ] 2.3 Add confirmation checkbox/button for user consent
- [ ] 2.4 Run `gemini skills enable --global` if user confirms
- [ ] 2.5 Skip screen if Gemini not selected or skills already enabled
- [ ] 2.6 Handle enablement failure gracefully with notification

## 3. Migrate Continuity Feature

- [ ] 3.1 Create `features/continuity/skills/continuity/` directory
- [ ] 3.2 Create `SKILL.md` with frontmatter (name, description)
- [ ] 3.3 Move instruction content from command files
- [ ] 3.4 Add appropriate `allowed-tools` restrictions
- [ ] 3.5 Remove deprecated `commands/`, `extensions/`, `prompts/` directories
- [ ] 3.6 Test skill works on Claude Code
- [ ] 3.7 Test skill works on Gemini CLI
- [ ] 3.8 Test skill works on Codex CLI

## 4. Migrate Maestro Feature

- [ ] 4.1 Create skill directories for each Maestro command:
  - `features/maestro/skills/maestro-plan/`
  - `features/maestro/skills/maestro-run/`
  - `features/maestro/skills/maestro-review/`
  - `features/maestro/skills/maestro-challenge/`
  - `features/maestro/skills/maestro-status/`
  - `features/maestro/skills/maestro-report/`
- [ ] 4.2 Create `SKILL.md` for each with appropriate frontmatter
- [ ] 4.3 Move instruction content from respective command files
- [ ] 4.4 Add `templates/` directory to `maestro-plan` for plan output format
- [ ] 4.5 Add `templates/` directory to `maestro-run` for task handoff format
- [ ] 4.6 Add `hooks/` directory to `maestro-run` (from research):
  - `scope-guard.py`
  - `safety-rails.py`
  - `dispatch-validator.py`
  - `auto-logger.py`
  - `state-check.py`
- [ ] 4.7 Set `disable-model-invocation: true` for manual-only skills (run, challenge)
- [ ] 4.8 Set appropriate `allowed-tools` per skill
- [ ] 4.9 Remove deprecated `commands/`, `extensions/`, `prompts/` directories
- [ ] 4.10 Test all skills on Claude Code
- [ ] 4.11 Test all skills on Gemini CLI
- [ ] 4.12 Test all skills on Codex CLI

## 5. Update Installer Spec

- [ ] 5.1 Remove "Requirement: Multi-Command File Installation" (deprecated)
- [ ] 5.2 Remove "Requirement: Claude Code Installation" command scenarios (deprecated)
- [ ] 5.3 Remove "Requirement: Gemini CLI Installation" extension scenarios (deprecated)
- [ ] 5.4 Remove "Requirement: Codex CLI Installation" prompt scenarios (deprecated)
- [ ] 5.5 Add "Requirement: Skill Installation" with scenarios
- [ ] 5.6 Add "Requirement: Gemini Skills Enablement" with scenarios
- [ ] 5.7 Update "Requirement: Feature Directory Structure" for skills

## 6. Update Documentation

- [ ] 6.1 Update `CLAUDE.md` Feature Structure section for skills
- [ ] 6.2 Remove references to commands/extensions/prompts patterns
- [ ] 6.3 Document skills enablement for Gemini users

## 7. Testing & Validation

- [ ] 7.1 Test fresh install with skills on all three tools
- [ ] 7.2 Verify slash commands work after skill installation
- [ ] 7.3 Test Gemini enablement flow in TUI
- [ ] 7.4 Test auto-invocation triggers correctly
- [ ] 7.5 Run `openspec validate migrate-commands-to-skills --strict`
