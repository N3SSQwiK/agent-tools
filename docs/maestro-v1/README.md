> **DEPRECATED**: This is Maestro v1 documentation, archived for historical reference.
> Maestro v2 is available at `features/maestro/` with tool-agnostic hub-spoke orchestration.
> See the [Maestro v2 proposal](../openspec/changes/rebuild-maestro-orchestration/) for details.

---

# MAESTRO Documentation (v1 - Archived)
**Multi-Agent Execution Strategy for Task Routing & Orchestration**

---

## Overview

**MAESTRO** is Claude Code's framework for orchestrating multiple AI agents (Gemini, Codex) to optimize token usage, enable parallel execution, and leverage specialized capabilities.

**Goal**: 60-70% reduction in Claude token usage via intelligent task delegation.

**Key Principle**: Right task, right model - Match task characteristics to model strengths while Claude maintains overall context and decision-making authority.

---

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    CLAUDE CODE (Brain)                  │
│  • Strategic decisions                                  │
│  • Architecture & design                                │
│  • Task decomposition & routing                         │
│  • Quality control & integration                        │
│  • Final code review & merge                            │
└──────────────┬──────────────────────────┬───────────────┘
               │                          │
       ┌───────▼────────┐        ┌────────▼───────┐
       │  GEMINI Agent  │        │  CODEX Agent   │
       │  (Worker)      │        │  (Worker)      │
       └───────┬────────┘        └───────┬────────┘
               │                         │
               └──────────┬──────────────┘
                          │
                ┌─────────▼─────────┐
                │   ~/.maestro/     │
                │  • Learnings      │
                │  • Workflows      │
                │  • Outputs        │
                └───────────────────┘
```

---

## Quick Start

### 1. Read the Core Guides

**For orchestration workflows**:
- **[GUIDE.md](GUIDE.md)** - Complete orchestration guide with examples and patterns

**For delegation decisions**:
- **[DELEGATION-MATRIX.md](DELEGATION-MATRIX.md)** - Strict routing rules (MUST follow)

**For agent-specific execution**:
- **[GEMINI.md](GEMINI.md)** - Gemini patterns, prompts, troubleshooting
- **[CODEX.md](CODEX.md)** - Codex invocation, validation, retry strategies

**For operational support**:
- **[FAILURE-RUNBOOK.md](FAILURE-RUNBOOK.md)** - Troubleshooting guide (timeouts, hallucinations, cost overruns)
- **[COST-GUARDRAILS.md](COST-GUARDRAILS.md)** - Token budgets, ROI analysis, monitoring

### 2. Understand Key Patterns

#### ⚡ Pre-Delegation Reconnaissance
**Always use cheap Claude tools BEFORE expensive delegation**

```bash
# Step 1: Quick check (100 tokens, <1 second)
Glob Services/*.swift

# Step 2: Assess - do we need delegation?
# Step 3: Delegate only if needed
```

**Token savings**: ~15K tokens (99% reduction in discovery)

#### 🔧 Gemini @path Pattern (MANDATORY)
**Use @path syntax - 9.2x more token-efficient than $(cat)**

```bash
# Step 1: Delegate with @path (4,468 tokens for 48KB file)
gtimeout 90 gemini -p "Analyze @Services/PDFExportService.swift for error handling" -y -o json > ~/.maestro/gemini/output.json

# Step 2: Claude reads results
Read ~/.maestro/gemini/output.json

# ❌ AVOID $(cat) pattern (41,295 tokens - 9.2x MORE expensive)
# Only use when preprocessing required (grep, head, sed filters)
```

#### 🎯 Hybrid Approach
**Claude finds → Claude reads → Gemini analyzes → Claude synthesizes**

**Why**: Multi-file searches timeout in Gemini; hybrid approach = 100% reliability

### 3. Review Examples
**EXAMPLES.md** *(coming soon)* - Common workflow templates

---

## Files in This Directory

| File | Description |
|------|-------------|
| **README.md** | This file - overview and quick start |
| **GUIDE.md** | Complete orchestration guide (workflows, patterns, examples) |
| **DELEGATION-MATRIX.md** | Strict routing rules (authoritative decision contract) |
| **GEMINI.md** | Gemini execution contract (file access, prompts, validation) |
| **CODEX.md** | Codex execution contract (invocation, formats, gates) |
| **FAILURE-RUNBOOK.md** | ✨ Operational troubleshooting (symptom → cause → fix) |
| **COST-GUARDRAILS.md** | ✨ Budget enforcement (token ceilings, ROI, monitoring) |
| **WORKSPACE-AUDIT.md** | Pre-use verification checklist |

---

## Working Directory

Agent outputs and learnings stored in: **`~/.maestro/`**

**Key files**:
- `learnings.md` - Persistent patterns (survives context compaction)
- `workflows/` - Audit trails of delegation sessions
- `discoveries/` - Critical findings and breakthroughs
- `gemini/` - Gemini CLI outputs
- `codex/` - Codex CLI outputs

---

## Established Patterns (Dec 17, 2025)

### ✅ Pattern 1: Pre-Delegation Reconnaissance
Always scout with Claude tools before delegating.

**Impact**: 99% token reduction in discovery phase

### ✅ Pattern 2: Correct Gemini Headless Usage
Use `-p` flag explicitly: `gemini -p "query" -y -o json`

**Impact**: Follows documented best practice

### ✅ Pattern 3: Atomic Query Pattern
Gemini works with single-file, targeted queries only.

**Impact**: 100% success rate vs timeouts

### ✅ Pattern 4: NO --files Flag!
Gemini CLI has no `--files` flag - must inline contents.

**Impact**: All previous examples were incorrect (now fixed)

---

## When to Use MAESTRO

### ✅ Good Use Cases
- Multi-file codebase analysis (parallel Gemini instances)
- Large file analysis (Gemini's 2M context window)
- Boilerplate/test generation (Codex specialization)
- Documentation audits (Gemini + Claude synthesis)

### ❌ When to Skip Delegation
- Single small file analysis
- Critical business logic (needs Claude reasoning)
- Complex architectural decisions
- User-facing communication

---

## Migration Notes

**Previous location**: `docs/MULTI-AGENT-ORCHESTRATION.md`
**New location**: `docs/maestro/GUIDE.md`

**Backward compatibility**: Original file kept with redirect note.

---

## Production Status

- ✅ **Dec 17, 2025**: MAESTRO framework established
- ✅ **Dec 17, 2025**: Gemini CLI patterns validated
- ✅ **Dec 18, 2025**: Codex delegation patterns validated
- ✅ **Dec 18, 2025**: Phase 3 E2E testing complete
- ✅ **Dec 18, 2025**: Production documentation complete
  - DELEGATION-MATRIX.md (routing rules)
  - GEMINI.md (execution contract)
  - CODEX.md (execution contract)
  - FAILURE-RUNBOOK.md (operational troubleshooting)
  - COST-GUARDRAILS.md (budget enforcement)

**Production-ready as of December 18, 2025**

---

**Last Updated**: December 18, 2025
**Version**: 2.0 (Production-ready with operational guides)
