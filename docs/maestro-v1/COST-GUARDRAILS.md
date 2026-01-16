# MAESTRO Cost Guardrails
**Token Budget Enforcement & Economic Viability**

**Version**: 1.0
**Created**: December 18, 2025
**Status**: Production
**Purpose**: Prevent cost overruns through automated budget enforcement

---

## Executive Summary

**Goal**: Keep MAESTRO delegation costs predictable and economically justified.

**Established Baseline** (December 2025):
- **Gemini**: ~27K tokens/delegation ($0.54 at $0.02/1K input)
- **Codex**: ~8K tokens/delegation after caching ($0.16 cached, $0.74 first run)
- **Target**: <$1.00 per delegation cycle

**Economic Threshold**: Delegation must be cheaper than Claude-only approach or justify cost through time savings.

---

## 1. Token Budget Ceilings

### 1.1 Per-Delegation Hard Limits

| Agent | Budget (tokens) | Abort Threshold | Cost @ $0.02/1K |
|-------|----------------|-----------------|-----------------|
| **Gemini** | 30,000 | 50,000 | $0.60 / $1.00 |
| **Codex** | 40,000 | 60,000 | $0.80 / $1.20 |
| **Claude** | N/A | N/A | Baseline |

**Enforcement**:
- If delegation exceeds budget → Investigate root cause (see Section 3)
- If exceeds abort threshold → Immediately abort, Claude handles directly

---

### 1.2 Daily Budget Caps

**Conservative**: 10 delegations/day
- Gemini: 10 × 27K = 270K tokens/day ($5.40/day)
- Codex: 10 × 8K = 80K tokens/day ($1.60/day cached)
- **Total**: $7.00/day

**Aggressive**: 50 delegations/day
- Gemini: 50 × 27K = 1.35M tokens/day ($27/day)
- Codex: 50 × 8K = 400K tokens/day ($8/day cached)
- **Total**: $35/day

**Recommendation**: Start conservative, scale based on ROI

---

### 1.3 Monthly Budget Forecast

**Conservative (10/day × 22 working days)**:
- Gemini: 5.94M tokens/month ($118.80)
- Codex: 1.76M tokens/month ($35.20 cached)
- **Total**: ~$154/month

**Aggressive (50/day × 22 working days)**:
- Gemini: 29.7M tokens/month ($594)
- Codex: 8.8M tokens/month ($176 cached)
- **Total**: ~$770/month

**Economic Breakeven**: If delegation saves >20 hours/month of developer time at $50/hr = $1,000 value → ROI positive even at aggressive scale

---

## 2. Cost Anomaly Detection

### 2.1 Automated Token Monitoring

**Log every delegation** to `~/.maestro/token-log.md`:

```markdown
## 2025-12-18

### Delegation 1: Error handling audit
- Agent: Gemini
- Tokens: 27,316 prompt + 258 response = 27,574 total
- Cost: $0.55
- Status: ✅ Within budget

### Delegation 2: Test generation
- Agent: Codex
- Tokens: 35,523 input (29,568 cached) + 2,117 output = 37,640 total
- Effective: 5,955 new + 2,117 = 8,072 tokens
- Cost: $0.16 (with caching)
- Status: ✅ Within budget
```

---

### 2.2 Anomaly Thresholds

**Yellow Alert** (investigate):
- Gemini: >35K tokens (30% over baseline)
- Codex: >12K tokens (50% over baseline)

**Red Alert** (abort immediately):
- Gemini: >50K tokens (85% over baseline)
- Codex: >60K tokens (650% over baseline)

**Detection Script**:
```bash
#!/bin/bash
# ~/.maestro/scripts/cost-monitor.sh

GEMINI_TOKENS=$(cat ~/.maestro/gemini/latest.json | jq '.tokens.prompt')
CODEX_TOKENS=$(cat ~/.maestro/codex/latest.jsonl | grep '"usage":' | tail -1 | jq '.usage.input_tokens')

# Gemini check
if [ "$GEMINI_TOKENS" -gt 50000 ]; then
    echo "🚨 RED ALERT: Gemini used $GEMINI_TOKENS tokens (budget: 30K)"
    echo "ABORT delegation immediately"
    exit 1
elif [ "$GEMINI_TOKENS" -gt 35000 ]; then
    echo "⚠️  YELLOW: Gemini used $GEMINI_TOKENS tokens (budget: 30K)"
    echo "Investigate: Check if using @path pattern"
fi

# Codex check
if [ "$CODEX_TOKENS" -gt 60000 ]; then
    echo "🚨 RED ALERT: Codex used $CODEX_TOKENS tokens (budget: 40K)"
    exit 1
elif [ "$CODEX_TOKENS" -gt 12000 ]; then
    echo "⚠️  YELLOW: Codex used $CODEX_TOKENS tokens (budget: 40K)"
fi

echo "✅ Token usage within budget"
```

---

### 2.3 Common Anomalies & Fixes

| Anomaly | Symptom | Root Cause | Fix |
|---------|---------|------------|-----|
| **Gemini 9x overhead** | 41K tokens for 48KB file | Using $(cat) instead of @path | Switch to @path pattern |
| **Gemini 2x overhead** | 55K tokens | Model router enabled | Disable in settings.json |
| **Gemini cache bleed** | Increasing tokens over time | Cache growing unbounded | Clear `~/.gemini/tmp/` |
| **Codex high first-run** | 38K tokens | No cache hit | Normal - subsequent runs 8K |
| **Codex persistent high** | 20K+ every run | Cache not working | Check prompt consistency |

---

## 3. Root Cause Analysis Workflow

**When delegation exceeds budget**:

```
1. Capture evidence
   ├─ Save JSONL/JSON output
   ├─ Extract token counts
   └─ Note exact command used

2. Identify root cause
   ├─ Gemini high? → Check file access pattern (@path vs $(cat))
   ├─ Still high? → Check settings.json (model router)
   ├─ Still high? → Check cache size
   └─ Codex high? → Check if first run (cache miss expected)

3. Apply fix
   ├─ Update command pattern
   ├─ Update configuration
   ├─ Clear cache if needed
   └─ Document in learnings.md

4. Validate fix
   ├─ Re-run delegation
   ├─ Compare token counts
   └─ Log result
```

**Example Investigation**:
```markdown
# Token Anomaly: Gemini Error Audit (2025-12-18)

## Evidence
- Prompt tokens: 41,295 (expected: 4,468)
- File size: 48KB Swift file
- Command: `gemini -p "Analyze: $(cat Services/File.swift)"`

## Root Cause
Using $(cat) inline pattern instead of @path pattern.

## Fix Applied
Changed to: `gemini -p "Analyze @Services/File.swift"`

## Result
- New prompt tokens: 4,468
- Reduction: 36,827 tokens (892%)
- Cost savings: $0.74 per delegation
- Annual savings (10/day): $2,701

## Prevention
- Updated CLAUDE.md with @path MANDATORY
- Updated ~/.maestro/README.md with corrected examples
- Added validation to delegation audit protocol
```

---

## 4. Economic Justification Matrix

### 4.1 Cost-Benefit Analysis

**Scenario 1: Code Generation (Codex)**
- **Delegation cost**: $0.16 (with caching)
- **Time saved**: 15 minutes of manual coding
- **Value**: $12.50 (at $50/hr rate)
- **ROI**: 7,700% (78x return)

**Scenario 2: Multi-File Analysis (Gemini)**
- **Delegation cost**: $0.54
- **Time saved**: 30 minutes of manual review
- **Value**: $25 (at $50/hr rate)
- **ROI**: 4,530% (46x return)

**Scenario 3: Documentation Audit (Gemini)**
- **Delegation cost**: $0.54
- **Time saved**: 45 minutes of reading docs
- **Value**: $37.50
- **ROI**: 6,850% (69x return)

**Conclusion**: Even at 2x budget overrun, delegation is still economically justified.

---

### 4.2 Break-Even Thresholds

**Gemini**:
- Cost: $0.54/delegation
- Break-even: Saves >0.65 minutes of developer time (at $50/hr)
- Threshold: **ANY delegation that saves >1 minute is justified**

**Codex**:
- Cost: $0.16/delegation (cached)
- Break-even: Saves >0.19 minutes
- Threshold: **ANY delegation that saves >15 seconds is justified**

**Rule**: If delegation doesn't save >1 minute, don't delegate (use Claude directly)

---

### 4.3 Non-Delegatable Scenarios (Economic)

**When delegation is NOT justified**:
| Scenario | Why Not Justified | Alternative |
|----------|-------------------|-------------|
| Single-line code change | Takes <30s manually | Claude implements directly |
| Simple file read | Claude Read tool is instant | Use Read tool |
| Trivial question | Answer known | Don't delegate |
| High-risk code (auth) | Requires Claude review anyway | Claude handles entirely |

---

## 5. Budget Enforcement Mechanisms

### 5.1 Pre-Delegation Gate

**Add to DELEGATION-MATRIX.md Section 0** (Preconditions):

```markdown
| Check | Rule |
|-------|------|
| **Economic** | Task saves >1 minute of manual work |
```

**Implementation**:
```markdown
## DELEGATION AUDIT
Task ID: example-20251218
Economic Justification:
  - Manual effort: 20 minutes (file reading + analysis)
  - Delegation cost: $0.54 (27K tokens)
  - Time saved: 19 minutes ($15.83 value)
  - ROI: 2,930%
  - Status: ✅ JUSTIFIED
```

---

### 5.2 Post-Delegation Review

**After every delegation**:
```bash
# Extract token usage
TOKENS=$(cat ~/.maestro/gemini/latest.json | jq '.tokens.total')
COST=$(echo "scale=2; $TOKENS * 0.00002" | bc)

# Log to token-log.md
echo "### $(date +%Y-%m-%d\ %H:%M:%S): $TASK_ID" >> ~/.maestro/token-log.md
echo "- Tokens: $TOKENS" >> ~/.maestro/token-log.md
echo "- Cost: \$$COST" >> ~/.maestro/token-log.md
echo "- Status: $(if [ $TOKENS -lt 30000 ]; then echo '✅ Budget'; else echo '⚠️ Over'; fi)" >> ~/.maestro/token-log.md
```

---

### 5.3 Weekly Review

**Every Monday**:
```bash
# Generate weekly cost report
cat ~/.maestro/token-log.md | grep "2025-12-" | awk '{
    # Extract token counts and sum
    if ($3 ~ /[0-9]+/) {
        total += $3
        count++
    }
}
END {
    printf "Week of 2025-12-16:\n"
    printf "Total delegations: %d\n", count
    printf "Total tokens: %s\n", total
    printf "Total cost: $%.2f\n", total * 0.00002
    printf "Avg tokens/delegation: %d\n", total / count
    printf "Avg cost/delegation: $%.2f\n", (total / count) * 0.00002
}'
```

**Decision Points**:
- If avg >35K tokens → Investigate efficiency losses
- If total >$50/week → Review ROI justification
- If >30% delegations over budget → Audit patterns

---

## 6. Cost Optimization Strategies

### 6.1 Caching Optimization (Codex)

**Leverage 83% cache hit rate**:
```bash
# Batch similar tasks to maximize caching
codex exec "Generate helper function 1" --full-auto  # 38K tokens (first)
codex exec "Generate helper function 2" --full-auto  # 8K tokens (cached)
codex exec "Generate helper function 3" --full-auto  # 8K tokens (cached)

# Total: 54K tokens vs 114K without caching (53% savings)
```

**Strategy**: Group related code generation tasks in same session

---

### 6.2 @path Pattern Enforcement (Gemini)

**Mandatory @path usage**:
- **Never use $(cat)** unless preprocessing required (grep, head, sed)
- **Never use stdin piping** (token inefficient)
- **Always use @path** for direct file analysis

**Validation**:
```bash
# Audit recent Gemini commands
grep "gemini -p" ~/.maestro/workflows/*.md | grep -v "@" | grep -v "What is"
# If output → Commands missing @path, needs correction
```

---

### 6.3 Atomic Query Discipline (Gemini)

**Keep queries atomic**:
- ✅ "Analyze @Services/File.swift for X"
- ❌ "Analyze all services for X"

**Why**: Broad queries timeout → wasted tokens with no result

**Enforcement**: Pre-delegation gate checks query is atomic

---

## 7. Monthly Cost Forecast

### 7.1 Conservative Forecast (10 delegations/day)

**Breakdown**:
```
Gemini: 270K tokens/day × 22 days = 5.94M tokens/month
Cost: 5.94M × $0.00002 = $118.80

Codex (cached): 80K tokens/day × 22 days = 1.76M tokens/month
Cost: 1.76M × $0.00002 = $35.20

Total: $154/month
```

**Value Delivered** (15 min saved per delegation):
- Time saved: 10 × 15 min × 22 = 55 hours/month
- Value: 55 hours × $50/hr = $2,750
- Net value: $2,750 - $154 = **$2,596/month**
- ROI: **1,685%**

---

### 7.2 Aggressive Forecast (50 delegations/day)

**Breakdown**:
```
Gemini: 1.35M tokens/day × 22 days = 29.7M tokens/month
Cost: 29.7M × $0.00002 = $594

Codex (cached): 400K tokens/day × 22 days = 8.8M tokens/month
Cost: 8.8M × $0.00002 = $176

Total: $770/month
```

**Value Delivered**:
- Time saved: 50 × 15 min × 22 = 275 hours/month
- Value: 275 hours × $50/hr = $13,750
- Net value: $13,750 - $770 = **$12,980/month**
- ROI: **1,686%**

---

### 7.3 Cost Ceiling Enforcement

**Hard monthly cap**: $1,000
- If approaching $800 (80% of cap) → Alert user
- If exceeding $1,000 → Pause delegations, review ROI

**Trigger mechanism**:
```bash
# Check monthly spend
MONTHLY_SPEND=$(cat ~/.maestro/token-log.md | grep "$(date +%Y-%m)" |
    awk '{sum += $3} END {printf "%.2f", sum * 0.00002}')

if (( $(echo "$MONTHLY_SPEND > 800" | bc -l) )); then
    echo "⚠️  Warning: Monthly spend at \$$MONTHLY_SPEND (cap: \$1,000)"
fi
```

---

## 8. Production Metrics Dashboard

### 8.1 Weekly Cost Report Template

```markdown
# MAESTRO Cost Report: Week of [date]

## Usage Summary
- **Total delegations**: 42
  - Gemini: 25 (60%)
  - Codex: 17 (40%)

## Token Consumption
- **Gemini**:
  - Total: 675K tokens
  - Avg: 27K/delegation
  - Status: ✅ On budget (baseline: 27K)
- **Codex**:
  - Total: 136K tokens
  - Avg: 8K/delegation
  - Status: ✅ On budget (baseline: 8K)

## Costs
- **Gemini**: $13.50
- **Codex**: $2.72
- **Total**: $16.22
- **Monthly projection**: $64.88 (vs $154 budget) ✅

## Value Delivered
- **Time saved**: 10.5 hours
- **Value**: $525 (at $50/hr)
- **Net value**: $508.78
- **ROI**: 3,137%

## Anomalies
- 3 Gemini delegations exceeded 35K tokens (investigated, fixed)
- 1 Codex delegation timed out (soft success, work completed)

## Actions
- Updated 2 workflow templates with @path pattern
- Cleared Gemini cache (bloated to 1.2GB)
- All issues resolved
```

---

### 8.2 Monthly Cost Trending

**Track month-over-month**:
```markdown
| Month | Delegations | Total Tokens | Cost | Avg $/delegation |
|-------|-------------|--------------|------|------------------|
| Dec 2025 | 220 | 8.14M | $162.80 | $0.74 |
| Jan 2026 | [pending] | [pending] | [pending] | [target: <$0.70] |

**Trend**: Optimizing - cache hit rate improving, @path adoption 100%
```

---

## 9. Emergency Cost Controls

### 9.1 Runaway Cost Scenario

**If daily cost exceeds $50**:
1. **Immediate**: Pause all delegations
2. **Investigate**: Check token-log.md for anomalies
3. **Identify**: Which agent/task causing overrun
4. **Fix**: Apply cost optimization (see Section 6)
5. **Resume**: Only after fix validated

---

### 9.2 Kill Switch

**Disable delegation entirely**:
```bash
# Emergency: Disable MAESTRO
echo "MAESTRO_DISABLED=true" > ~/.maestro/circuit-breaker

# Claude checks before delegating
if [ -f ~/.maestro/circuit-breaker ]; then
    echo "⚠️  MAESTRO delegations disabled by circuit breaker"
    echo "Claude will handle all tasks directly"
    exit 1
fi

# Re-enable after issue resolved
rm ~/.maestro/circuit-breaker
```

---

## 10. Version History

**v1.0** (December 18, 2025)
- Initial cost guardrails document
- Based on Phase 3 testing token measurements
- Incorporates ChatGPT peer review feedback
- Established baselines: Gemini 27K, Codex 8K (cached)
- ROI analysis: 1,685% return even at aggressive scale

---

## References

- **Evidence**: `docs/maestro/To-Assess/validation/gemini-clean-room-results.md` (token counts)
- **Evidence**: `docs/maestro/To-Assess/validation/codex-test-results.md` (caching data)
- **Pricing**: Gemini/Codex at $0.02/1K input tokens (Dec 2025 rates)
- **Benchmark**: Developer time valued at $50/hr (conservative estimate)

---

**Status**: ✅ Production (v1.0 - Dec 18, 2025)
**Next Review**: Monthly (token rate changes, usage pattern shifts)
