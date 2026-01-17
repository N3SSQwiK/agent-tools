# Proposal: Document Installer Specification

## Why

The Nexus-AI installer lacks formal specification documentation, leading to:
- P1 bug: Single-command file assumption broke multi-command features (Maestro)
- P2 bug: Managed block replacement broke multi-feature installs
- Undocumented invariants around file patterns, config merging, and feature structure

Formalizing the installer specification will prevent future regressions by providing AI assistants and contributors with authoritative reference documentation.

## What Changes

- **ADDED** `installer` capability spec documenting:
  - Feature discovery and registration
  - Multi-command file installation patterns
  - Managed config block merging behavior
  - Tool-specific installation paths (Claude, Gemini, Codex)
  - Idempotency requirements
  - Extension enablement (Gemini JSON manifest)

## Proposed Solution

Create comprehensive specification covering:

1. **Feature Structure Requirements** - Directory layout, file naming conventions
2. **Command Installation** - Multi-file glob patterns for slash commands
3. **Config Merging** - Managed block behavior, merge vs replace, duplicate detection
4. **Tool Integration** - Claude symlinks, Gemini copies + enablement, Codex symlinks
5. **TUI Flow** - Screen progression, selection state, installation triggers

## Scope

### In Scope
- Feature directory structure specification
- Command/prompt file installation patterns
- Managed config block behavior specification
- Tool-specific installation requirements
- Idempotency and re-run behavior

### Out of Scope
- TUI visual design/styling
- Python/Go implementation details (internal)
- Error message wording
- Future feature ideas

## Success Criteria

1. AI assistants can reference spec before modifying installer
2. New features follow documented patterns without regressions
3. Spec covers all current installer behaviors
4. Validation passes with `openspec validate --strict`

## Impact

- Affected specs: None (new capability)
- Affected code: `installer/python/nexus.py` (documentation only, no changes)
