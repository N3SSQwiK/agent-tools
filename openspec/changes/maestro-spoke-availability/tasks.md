# Tasks: Add Spoke Availability Detection to Maestro

## 1. Update Plan Command for Spoke Detection

- [ ] 1.1 Update Claude Code command (`maestro-plan.md`)
  - Add spoke detection step before reconnaissance (new step 1)
  - Add confirmation menu for available tools
  - Add `## Available Tools` section to state file output
  - Constrain task assignment to confirmed tools

- [ ] 1.2 Update Codex CLI command (`maestro-plan.md`)
  - Same changes as Claude version
  - Update `argument-hint` if needed

- [ ] 1.3 Update Gemini CLI command (`maestro-plan.toml`)
  - Same changes as Claude version

## 2. Update State File Format

- [ ] 2.1 Update STATE-FILE-SPEC.md
  - Add `## Available Tools` section specification
  - Document hub and spoke fields

- [ ] 2.2 Define state file header format
  ```markdown
  ## Available Tools
  - **Hub:** Claude Code
  - **Spokes:** Gemini CLI, Codex CLI
  ```

## 3. Update Challenge Command for Tool Selection Menu

- [ ] 3.1 Update Claude Code command (`maestro-challenge.md`)
  - Add interactive menu at step 2 (after loading plan)
  - Menu reads available tools from state file
  - Add "Tool Selection Configuration" section
  - Remove "Default Challenger Selection" (replaced by menu)

- [ ] 3.2 Update Codex CLI command (`maestro-challenge.md`)
  - Add `argument-hint: [--tool=<name>] [--all]` to frontmatter
  - Add interactive menu at step 2
  - Add "Tool Selection Configuration" section

- [ ] 3.3 Update Gemini CLI command (`maestro-challenge.toml`)
  - Add interactive menu at step 2
  - Add "Tool Selection Configuration" section

## 4. Update Review Command for Tool Selection Menu

- [ ] 4.1 Update Claude Code command (`maestro-review.md`)
  - Add interactive menu at step 4 (before dispatch)
  - Menu reads available tools from state file
  - Add "Tool Selection Configuration" section
  - Remove "Default Reviewer Selection" (replaced by menu)

- [ ] 4.2 Update Codex CLI command (`maestro-review.md`)
  - Add `argument-hint: [task-id] [--tool=<name>] [--auto]` to frontmatter
  - Add interactive menu at step 4
  - Add "Tool Selection Configuration" section

- [ ] 4.3 Update Gemini CLI command (`maestro-review.toml`)
  - Add interactive menu at step 4
  - Add "Tool Selection Configuration" section

## 5. Update Documentation

- [ ] 5.1 Update User Guide (`USER-GUIDE.md`)
  - Add "Tool Detection" section under Planning
  - Add "Tool Selection" subsection under "Challenging Plans"
  - Add "Tool Selection" subsection under "Reviewing Work"
  - Document interactive menu behavior
  - Document flag bypass for power users

## 6. Validation

- [ ] 6.1 Verify plan detects available tools at start
- [ ] 6.2 Verify state file includes Available Tools section
- [ ] 6.3 Verify tasks only assigned to available tools
- [ ] 6.4 Verify challenge menu only shows available spokes
- [ ] 6.5 Verify review menu only shows available spokes
- [ ] 6.6 Verify `--tool` and `--all` flags bypass menus
