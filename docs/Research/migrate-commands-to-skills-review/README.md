# Peer Review: migrate-commands-to-skills Proposal

**Status:** Review Complete | Revisions Drafted
**Date:** 2026-01-21
**Reviewer:** Claude Code (code review agent)
**Verdict:** REQUEST CHANGES → Ready after revisions

## Summary

This proposal advocates migrating Nexus-AI from tool-specific file formats (Claude commands `.md`, Gemini extensions `.toml`/`.json`, Codex prompts `.md`) to the unified **Agent Skills** standard. The migration would:

- Consolidate three tool-specific installation paths into a single `skills/` directory structure
- Enable rich supporting files (hooks, templates, scripts) currently limited to commands
- Deprecate existing command/extension/prompt installation logic
- Add a Gemini-specific enablement flow requiring `gemini skills enable --global`
- Migrate Continuity (1 skill) and Maestro (6 skills) as first implementations

The proposal includes 35 tasks across 7 phases, spec deltas for the installer capability, and integrates the Maestro hooks research.

---

## Strengths

### 1. Clear Strategic Vision (95/100 confidence)
The "Why" section effectively articulates the value proposition:
- Cross-tool portability eliminates maintenance burden of three parallel formats
- Supporting files enable the well-researched Maestro hooks feature
- Auto-invocation and tool restrictions provide capabilities not available with current approach

The strategic timing is excellent - all three tools have adopted the standard, making this a natural evolution point.

### 2. Excellent Integration with Prior Research (100/100 confidence)
The proposal seamlessly integrates the Maestro hooks research (`docs/Research/maestro-hooks/`):
- Task 4.6 explicitly references adding `hooks/` directories
- Task 4.7 uses `disable-model-invocation: true` (a skills-only feature)
- The migration provides the infrastructure needed for previously-blocked enforcement features

This demonstrates strong continuity between research and implementation.

### 3. Comprehensive Task Breakdown (90/100 confidence)
The 35-task checklist is well-organized:
- Logical phases (installer → enablement → migration → docs → testing)
- Appropriate granularity (testable units of work)
- Clear testing requirements per feature (3.6-3.8, 4.10-4.12)
- Validation gate at the end (7.5)

### 4. Proper Spec Delta Structure (85/100 confidence)
The spec delta follows OpenSpec conventions:
- Uses `## ADDED|MODIFIED|REMOVED Requirements` structure
- Each requirement has multiple scenarios in `#### Scenario:` format
- Migration paths documented for removed requirements

---

## Critical Issues

### C1. Missing SKILL.md Specification (Confidence: 95/100)

**Issue**: The proposal references "SKILL.md format" and "frontmatter" but never defines what these actually are.

**Evidence**:
- Tasks 3.2, 4.2 require "Create SKILL.md with frontmatter (name, description)" but don't specify:
  - Required vs. optional frontmatter fields
  - YAML vs. TOML syntax
  - Validation rules
  - Example complete SKILL.md

- Spec delta says "SKILL.md # Required: Instructions + frontmatter" but doesn't specify what makes it valid

**Impact**: Implementers cannot complete tasks 3.2 or 4.2 without external research. The spec delta will not be testable.

**Resolution**: See [revisions/skill-format-spec.md](revisions/skill-format-spec.md)

### C2. Gemini Enablement Flow Underspecified (Confidence: 90/100)

**Issue**: The proposal adds a TUI screen for Gemini skills enablement but doesn't address several critical UX/implementation questions.

**Evidence from spec delta**:

**Scenario: Skills already enabled**
- "Then the installer skips the enablement confirmation screen"
- **Question**: How does the installer detect this? Check `~/.gemini/config.json`? Parse `gemini skills list` output? What if `gemini` binary isn't in PATH?

**Scenario: Enablement failure**
- "Then the installer displays a warning notification and proceeds with installation"
- **Question**: What if Gemini CLI isn't installed at all? Should this be detected earlier (Tools screen)? Does the user end up with broken skills?

**Missing scenarios**:
- Gemini not installed but selected (PATH check failed)
- `gemini skills enable` returns unexpected output
- Multiple Gemini versions with different config paths

**Impact**: Task 2.5 "Skip screen if Gemini not selected or skills already enabled" cannot be implemented without these decisions.

**Resolution**: See [revisions/gemini-enablement-spec.md](revisions/gemini-enablement-spec.md)

### C3. Breaking Change Migration Path Insufficient (Confidence: 85/100)

**Issue**: The proposal removes three existing installation mechanisms (commands/extensions/prompts) but doesn't address **existing users** with these installed.

**Current state**: Users have files at:
- `~/.claude/commands/maestro-plan.md`
- `~/.gemini/extensions/maestro/commands/maestro-plan.toml`
- `~/.codex/prompts/maestro-plan.md`

**Proposed state**: After migration, these files are orphaned. The installer writes to:
- `~/.claude/skills/maestro-plan/SKILL.md`
- `~/.gemini/skills/maestro-plan/SKILL.md`
- `~/.codex/skills/maestro-plan/SKILL.md`

**Questions not answered**:
1. Should the installer clean up old command files?
2. What if a user has **custom** commands installed (not from Nexus-AI)?
3. Should there be a "migration mode" that detects old installations?
4. What's the rollback path if the new format fails?

**Evidence**: Tasks 3.5 and 4.9 say "Remove deprecated directories" but this is about feature structure, not user installations.

**Impact**: Users upgrading from v1.0.1 to v2.0.0 (assuming major version bump) will have duplicate, conflicting slash commands.

**Resolution**: See [revisions/migration-path-spec.md](revisions/migration-path-spec.md)

---

## Major Issues

### M1. No Validation of Skill Supporting Files (Confidence: 80/100)

**Issue**: The spec delta says skills "MAY" include hooks/, templates/, scripts/ but doesn't specify:
- What makes a hook script valid?
- Are templates required to follow a format?
- Should scripts be executable?

**Evidence**: Task 4.6 references adding specific hook files (`scope-guard.py`, etc.) but:
- No validation that these are executable (`chmod +x`)
- No validation that they have proper shebang (`#!/usr/bin/env python3`)
- No validation that they exit with correct codes (0, 1, 2)

**Impact**: Broken hooks will silently fail at runtime instead of install-time.

**Fix**: Add to spec delta under `### Requirement: Skill Installation`:
```markdown
#### Scenario: Hook script validation
- **Given** a skill with files in `hooks/` directory
- **When** the installer copies the skill
- **Then** it verifies hook scripts have execute permissions
- **And** it verifies scripts have valid shebang lines
```

### M2. Globbing Pattern Change Not Explained (Confidence: 82/100)

**Issue**: Current implementation uses glob patterns like `<feature>.md` or `<feature>-*.md` (line 544 of nexus.py). The proposal switches to directory-based installation but doesn't explain how multi-skill features work.

**Current**: `maestro-plan.md`, `maestro-run.md` (6 files total)
**Proposed**: `skills/maestro-plan/SKILL.md`, `skills/maestro-run/SKILL.md` (6 directories)

**Question**: Does the installer:
- Scan for all directories under `features/<feature>/skills/`?
- Only install directories with a `SKILL.md` file present?
- Validate directory names against frontmatter `name:` field?

**Evidence**: Task 1.6 says "Update glob pattern logic for skill directories" but spec delta "Scenario: Feature with multiple skills" just says "finds all directories under skills/ containing SKILL.md" without implementation details.

**Fix**: Clarify in spec delta:
```markdown
#### Scenario: Skill directory discovery
- **Given** a feature with skills
- **When** the installer scans the feature
- **Then** it uses glob pattern `features/<feature>/skills/*/SKILL.md`
- **And** treats each parent directory as a skill bundle
```

### M3. Tasks 4.4-4.5 Reference Non-Existent Templates (Confidence: 88/100)

**Issue**: Task 4.4 says "Add templates/ directory to maestro-plan for plan output format" but:
1. The current `maestro-plan.md` (lines 64-114) already has a "Plan Output Format" section
2. No clarification on whether this becomes a template file or stays as documentation

**Similar issue**: Task 4.5 references "task handoff format" but doesn't specify what template files are needed.

**Impact**: Implementers will need to make design decisions mid-implementation (violates spec-driven approach).

**Fix**: Either:
- **Option A**: Clarify these are documentation sections, not template files
- **Option B**: Create example template files in the proposal (e.g., `maestro-plan-output.md.jinja2`)

---

## Minor Issues

### m1. Inconsistent Terminology (Confidence: 75/100)

The proposal uses "skills", "skill directories", and "skill bundles" interchangeably. Pick one term and use consistently.

**Suggestion**: Use "skill" for the concept, "skill directory" for `skills/<name>/`, "skill bundle" when referring to the directory + all supporting files.

### m2. No Mention of Package Manifest Updates (Confidence: 70/100)

Since features are bundled with the Python package, `pyproject.toml` may need updates:
- Are `skills/` directories included in `package-data`?
- Do hook scripts need special inclusion?

**Evidence**: `CLAUDE.md` line 110 mentions "pyproject.toml - Package metadata, dependencies, entry point" but proposal doesn't reference it.

**Fix**: Add to task list:
```markdown
## 6. Update Package Configuration
- [ ] 6.4 Update pyproject.toml to include skills/ and hooks/ in package data
```

### m3. Testing Doesn't Cover Migration (Confidence: 72/100)

Tasks 7.1-7.4 test **fresh installs** but not the critical migration path from v1.x to v2.x.

**Missing test**:
- Install v1.0.1, then upgrade to v2.0.0 - verify both formats work or old is cleaned up

---

## Questions Requiring Clarification

1. **Backward Compatibility**: Is this proposal targeting v2.0.0 (breaking change) or will it maintain compatibility?

2. **Tool Support Confirmation**: The proposal claims "all three supported CLI tools now support Agent Skills" - is there documentation confirming Gemini CLI and Codex CLI support the agentskills.io standard?

3. **Hook Portability**: The Maestro hooks research (line 420) states hooks are "Claude Code only" - how will skills with hooks work on Gemini/Codex? Will the installer skip hooks/ for those tools? Will this cause broken functionality?

4. **Installation Order**: Should Gemini enablement happen BEFORE skill copying or AFTER? The flow says "Gemini Skills (conditional) → Installing" but if enablement fails, skills are already copied - is that the intent?

5. **Maestro Challenge**: Task 4.1 lists `maestro-challenge` but I don't see it referenced in CONTINUITY.md or the current commands structure. Is this a new skill or existing?

6. **Feature Uninstall Impact**: Proposal #6 in CONTINUITY.md is "add-feature-uninstall" - will this need updates to handle skill removal? Should that be a dependency?

---

## Recommendations Summary

### High Priority (Blocking)

| # | Issue | Resolution |
|---|-------|------------|
| 1 | Add SKILL.md format specification | [revisions/skill-format-spec.md](revisions/skill-format-spec.md) |
| 2 | Specify Gemini enablement detection logic | [revisions/gemini-enablement-spec.md](revisions/gemini-enablement-spec.md) |
| 3 | Add migration path for existing users | [revisions/migration-path-spec.md](revisions/migration-path-spec.md) |
| 4 | Clarify hook portability | Addressed in skill format spec |

### Medium Priority

| # | Issue | Action |
|---|-------|--------|
| 5 | Add skill supporting file validation | Add scenarios to spec delta |
| 6 | Document template files | Clarify tasks 4.4-4.5 |
| 7 | Add upgrade testing | Add task 7.6 |

### Low Priority

| # | Issue | Action |
|---|-------|--------|
| 8 | Standardize terminology | Editorial pass |
| 9 | Update pyproject.toml tasks | Add task 6.4 |

---

## Overall Assessment

**REQUEST CHANGES**

This proposal has a strong strategic foundation and excellent integration with prior research, but has critical gaps in specification detail that will block implementation. Specifically:

1. **Missing SKILL.md format specification** - Cannot implement tasks 3.2, 4.2 without this
2. **Underspecified Gemini enablement** - Task 2.5 is unimplementable as written
3. **No migration path for existing users** - Breaking change without upgrade strategy

The proposal demonstrates good OpenSpec practices (clear structure, comprehensive tasks, proper spec deltas) but needs refinement before implementation can begin safely.

### Estimated Revision Effort

| Task | Time |
|------|------|
| Adding SKILL.md spec | 30-45 min |
| Clarifying Gemini enablement | 20-30 min |
| Documenting migration path | 45-60 min |
| **Total** | **~2-3 hours** |

After these revisions → **APPROVE**

---

## Files Examined

- `/Users/nexus/agent-tools/openspec/changes/migrate-commands-to-skills/proposal.md`
- `/Users/nexus/agent-tools/openspec/changes/migrate-commands-to-skills/specs/installer/spec.md`
- `/Users/nexus/agent-tools/openspec/changes/migrate-commands-to-skills/tasks.md`
- `/Users/nexus/agent-tools/CLAUDE.md`
- `/Users/nexus/agent-tools/openspec/AGENTS.md`
- `/Users/nexus/agent-tools/docs/Research/maestro-hooks/README.md`
- `/Users/nexus/agent-tools/installer/python/features/maestro/claude/commands/maestro-plan.md`
- `/Users/nexus/agent-tools/openspec/specs/installer/spec.md`

## External References

- [Claude Code Skills Documentation](https://code.claude.com/docs/en/skills)
- [Gemini CLI Skills Documentation](https://geminicli.com/docs/cli/skills/)
- [Agent Skills Open Standard](https://agentskills.io)
