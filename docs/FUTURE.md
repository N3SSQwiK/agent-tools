# Future Exploration Topics

Ideas and problems to explore in future sessions.

---

## AI Detection of Unintentional Duplicate Specs

**Added:** 2026-01-17
**Context:** OpenSpec allows `ADDED` requirements that bypass guardrails if typos make them appear "new"

### Problem Statement

When using `## ADDED Requirements`, a typo like "Instalation" instead of "Installation" creates a near-duplicate spec rather than modifying the existing one. The tooling catches `MODIFIED` typos ("not found") but not `ADDED` typos (silently creates duplicates).

### Questions to Explore

1. **How can an AI discern user intent when the delta uses ADDED?**
   - Should AI compare new requirement names against existing ones using fuzzy matching?
   - What similarity threshold indicates "probable typo" vs "intentionally new"?

2. **What signals indicate intent to modify vs. add?**
   - Semantic similarity of requirement text (not just header)
   - Context from proposal.md ("changing behavior" vs "adding capability")
   - Conversation history with user

3. **Tooling improvements**
   - `openspec validate` could warn: "ADDED 'X' is 92% similar to existing 'Y' — confirm intent?"
   - Pre-archive diff showing "will add" vs "will modify" for human review

4. **AI workflow improvements**
   - Always read existing spec before writing delta
   - Default to MODIFIED for existing capabilities, require explicit confirmation for ADDED
   - Present side-by-side comparison before user approval

### Related

- OpenSpec archive guardrails (MODIFIED catches typos, ADDED doesn't)
- Levenshtein distance / fuzzy string matching
- Intent classification in spec-driven workflows
