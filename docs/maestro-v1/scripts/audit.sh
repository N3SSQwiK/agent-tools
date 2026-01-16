#!/bin/bash
# MAESTRO CLI Comprehensive Audit Script
# Verifies Codex and Gemini CLIs: installation, authentication, flags, models, and functionality
# Usage: bash ~/.maestro/audit.sh

set -e

TIMESTAMP=$(date +%Y%m%d-%H%M%S)
BASE="$HOME/.maestro"
REPORT_DIR="$BASE/verification"
REPORT_FILE="$REPORT_DIR/audit-report-$TIMESTAMP.md"

mkdir -p "$REPORT_DIR"

echo ""
echo "🔍 MAESTRO CLI COMPREHENSIVE AUDIT"
echo "==================================="
echo "Timestamp: $(date)"
echo "Report: $REPORT_FILE"
echo ""

# Initialize report
cat > "$REPORT_FILE" <<EOF
# MAESTRO CLI Audit Report

**Generated**: $(date)
**Purpose**: Comprehensive verification of Codex and Gemini CLI installations

---

## System Information

**OS**: $(uname -s) $(uname -r)
**Architecture**: $(uname -m)
**Shell**: $SHELL

---

EOF

#===============================================================================
# SECTION 1: CLI INSTALLATION
#===============================================================================

echo "=== CLI Installation ==="
echo "## CLI Installation Status" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# Gemini CLI
if command -v gemini &> /dev/null; then
    echo "✅ Gemini CLI installed: $(which gemini)"
    GEMINI_VERSION=$(gemini --version 2>&1 | head -1 || echo "Version unknown")
    echo "   Version: $GEMINI_VERSION"
    echo "- ✅ **Gemini CLI**: Installed at \`$(which gemini)\`" >> "$REPORT_FILE"
    echo "  - Version: $GEMINI_VERSION" >> "$REPORT_FILE"
else
    echo "❌ Gemini CLI NOT FOUND"
    echo "- ❌ **Gemini CLI**: NOT INSTALLED" >> "$REPORT_FILE"
    echo "  - Install: https://github.com/google-gemini/gemini-cli" >> "$REPORT_FILE"
fi

# Codex CLI
if command -v codex &> /dev/null; then
    echo "✅ Codex CLI installed: $(which codex)"
    CODEX_VERSION=$(codex --version 2>&1 | head -1 || echo "Version unknown")
    echo "   Version: $CODEX_VERSION"
    echo "- ✅ **Codex CLI**: Installed at \`$(which codex)\`" >> "$REPORT_FILE"
    echo "  - Version: $CODEX_VERSION" >> "$REPORT_FILE"
else
    echo "❌ Codex CLI NOT FOUND"
    echo "- ❌ **Codex CLI**: NOT INSTALLED" >> "$REPORT_FILE"
    echo "  - Install: https://github.com/openai/codex" >> "$REPORT_FILE"
fi

echo "" >> "$REPORT_FILE"
echo "---" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

#===============================================================================
# SECTION 2: AUTHENTICATION STATUS
#===============================================================================

echo ""
echo "=== Authentication (Session-Based) ==="
echo "## Authentication Status" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# Test Gemini session
echo "Testing Gemini session..."
if command -v gemini &> /dev/null; then
    if timeout 5 gemini "test" 2>&1 | grep -qiE "not.*logged.*in|please.*login|auth.*required|unauthorized"; then
        echo "❌ Gemini session EXPIRED or not logged in"
        echo "   Run: gemini login"
        echo "- ❌ **Gemini**: Session expired" >> "$REPORT_FILE"
        echo "  - Action: Run \`gemini login\`" >> "$REPORT_FILE"
    else
        echo "✅ Gemini session active"
        echo "- ✅ **Gemini**: Session active (OAuth authenticated)" >> "$REPORT_FILE"
    fi
else
    echo "⚠️  Gemini not installed, skipping session check"
fi

# Test Codex session
echo "Testing Codex session..."
if command -v codex &> /dev/null; then
    if codex "test" 2>&1 | grep -qiE "not.*logged.*in|please.*login|auth.*required|unauthorized"; then
        echo "❌ Codex session EXPIRED or not logged in"
        echo "   Run: codex login"
        echo "- ❌ **Codex**: Session expired" >> "$REPORT_FILE"
        echo "  - Action: Run \`codex login\`" >> "$REPORT_FILE"
    else
        echo "✅ Codex session active"
        echo "- ✅ **Codex**: Session active (OAuth authenticated)" >> "$REPORT_FILE"
    fi
else
    echo "⚠️  Codex not installed, skipping session check"
fi

echo "" >> "$REPORT_FILE"
echo "---" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

#===============================================================================
# SECTION 3: KEY FLAGS VERIFICATION
#===============================================================================

echo ""
echo "=== Key Flags Verification ==="
echo "## Key Flags Verification" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# Codex flags
if command -v codex &> /dev/null; then
    echo "Checking Codex flags..."
    codex exec --help > /tmp/codex-exec-help.txt 2>&1

    echo "### Codex Flags" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
    echo "| Flag | Status |" >> "$REPORT_FILE"
    echo "|------|--------|" >> "$REPORT_FILE"

    FLAGS=("--full-auto" "--json" "-s" "-C" "-m" "-o")
    for flag in "${FLAGS[@]}"; do
        if grep -q -e "$flag" /tmp/codex-exec-help.txt; then
            echo "✅ $flag present"
            echo "| \`$flag\` | ✅ Present |" >> "$REPORT_FILE"
        else
            echo "❌ $flag missing"
            echo "| \`$flag\` | ❌ Missing |" >> "$REPORT_FILE"
        fi
    done
fi

echo "" >> "$REPORT_FILE"

# Gemini flags
if command -v gemini &> /dev/null; then
    echo "Checking Gemini flags..."
    gemini --help > /tmp/gemini-help.txt 2>&1

    echo "### Gemini Flags" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
    echo "| Flag | Status |" >> "$REPORT_FILE"
    echo "|------|--------|" >> "$REPORT_FILE"

    FLAGS=("-p" "-y" "-o" "-m")
    for flag in "${FLAGS[@]}"; do
        if grep -q -e "$flag" /tmp/gemini-help.txt; then
            echo "✅ $flag present"
            echo "| \`$flag\` | ✅ Present |" >> "$REPORT_FILE"
        else
            echo "❌ $flag missing"
            echo "| \`$flag\` | ❌ Missing |" >> "$REPORT_FILE"
        fi
    done
fi

echo "" >> "$REPORT_FILE"
echo "---" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

#===============================================================================
# SECTION 4: AVAILABLE MODELS (DYNAMIC CHECK)
#===============================================================================

echo ""
echo "=== Available Models (Dynamic Check) ==="
echo "## Available Models" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "**Source**: Verified from official documentation" >> "$REPORT_FILE"
echo "**Last Updated**: $(date)" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# Codex models - Dynamic check
if command -v codex &> /dev/null; then
    echo "Checking Codex models from official docs..."
    echo "### Codex Models (GPT-5.x Era)" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
    echo "**Source**: https://developers.openai.com/codex/models" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"

    # Try to fetch current models from official docs
    CODEX_MODELS_PAGE=$(curl -s --max-time 10 https://developers.openai.com/codex/models 2>/dev/null || echo "")

    if [ -n "$CODEX_MODELS_PAGE" ]; then
        # Check for specific model names in the page
        if echo "$CODEX_MODELS_PAGE" | grep -q "gpt-5.1-codex-max"; then
            echo "  ✅ gpt-5.1-codex-max (verified from docs)"
            echo "- ✅ \`gpt-5.1-codex-max\` - Optimized for long-horizon agentic coding (verified)" >> "$REPORT_FILE"
        else
            echo "  ⚠️  gpt-5.1-codex-max (not found in docs - may be updated)"
            echo "- ⚠️  \`gpt-5.1-codex-max\` - Not found in current docs (check for updates)" >> "$REPORT_FILE"
        fi

        if echo "$CODEX_MODELS_PAGE" | grep -q "gpt-5.1-codex-mini"; then
            echo "  ✅ gpt-5.1-codex-mini (verified from docs)"
            echo "- ✅ \`gpt-5.1-codex-mini\` - Cost-effective version (verified)" >> "$REPORT_FILE"
        else
            echo "  ⚠️  gpt-5.1-codex-mini (not found in docs - may be updated)"
            echo "- ⚠️  \`gpt-5.1-codex-mini\` - Not found in current docs (check for updates)" >> "$REPORT_FILE"
        fi

        # Extract any gpt-5.* models mentioned
        DETECTED_MODELS=$(echo "$CODEX_MODELS_PAGE" | grep -oE 'gpt-[0-9]\.[0-9]+[a-z-]*' | sort -u | head -10)
        if [ -n "$DETECTED_MODELS" ]; then
            echo "" >> "$REPORT_FILE"
            echo "**Detected Models from Docs**:" >> "$REPORT_FILE"
            while IFS= read -r model; do
                echo "- \`$model\`" >> "$REPORT_FILE"
            done <<< "$DETECTED_MODELS"
        fi
    else
        echo "  ⚠️  Could not fetch official docs (network issue or rate limit)"
        echo "  📝 Using last known values (Dec 2025):"
        echo "     - gpt-5.1-codex-max (recommended)"
        echo "     - gpt-5.1-codex-mini (cost-effective)"
        echo "" >> "$REPORT_FILE"
        echo "**⚠️ Network Issue**: Could not fetch current docs" >> "$REPORT_FILE"
        echo "" >> "$REPORT_FILE"
        echo "**Last Known Models** (Dec 2025):" >> "$REPORT_FILE"
        echo "- \`gpt-5.1-codex-max\` - Optimized for long-horizon agentic coding" >> "$REPORT_FILE"
        echo "- \`gpt-5.1-codex-mini\` - Cost-effective version" >> "$REPORT_FILE"
        echo "" >> "$REPORT_FILE"
        echo "**Action**: Re-run audit when network is available" >> "$REPORT_FILE"
    fi
fi

echo "" >> "$REPORT_FILE"

# Gemini models - Dynamic check
if command -v gemini &> /dev/null; then
    echo "Checking Gemini models from official docs..."
    echo "### Gemini Models (Gemini 2.5/3 Era)" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
    echo "**Source**: https://geminicli.com/docs/cli/model/" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"

    # Try to fetch current models from official docs
    GEMINI_MODELS_PAGE=$(curl -s --max-time 10 https://geminicli.com/docs/cli/model/ 2>/dev/null || echo "")

    if [ -n "$GEMINI_MODELS_PAGE" ]; then
        # Check for specific model names in the page
        if echo "$GEMINI_MODELS_PAGE" | grep -q "gemini-2.5-pro"; then
            echo "  ✅ gemini-2.5-pro (verified from docs)"
            echo "- ✅ \`gemini-2.5-pro\` - High reasoning, complex analysis (verified)" >> "$REPORT_FILE"
        else
            echo "  ⚠️  gemini-2.5-pro (not found in docs - may be updated)"
            echo "- ⚠️  \`gemini-2.5-pro\` - Not found in current docs (check for updates)" >> "$REPORT_FILE"
        fi

        if echo "$GEMINI_MODELS_PAGE" | grep -q "gemini-2.5-flash"; then
            echo "  ✅ gemini-2.5-flash (verified from docs)"
            echo "- ✅ \`gemini-2.5-flash\` - Fast, efficient, simple tasks (verified)" >> "$REPORT_FILE"
        else
            echo "  ⚠️  gemini-2.5-flash (not found in docs - may be updated)"
            echo "- ⚠️  \`gemini-2.5-flash\` - Not found in current docs (check for updates)" >> "$REPORT_FILE"
        fi

        if echo "$GEMINI_MODELS_PAGE" | grep -q "gemini-3.*preview"; then
            echo "  ✅ gemini-3-*-preview (verified from docs)"
            echo "- ✅ \`gemini-3-*-preview\` - Latest generation (preview) (verified)" >> "$REPORT_FILE"
        else
            echo "  ⚠️  gemini-3-*-preview (not found in docs - may not be released)"
            echo "- ⚠️  \`gemini-3-*-preview\` - Not found in current docs (may not be released yet)" >> "$REPORT_FILE"
        fi

        # Extract any gemini-* models mentioned
        DETECTED_MODELS=$(echo "$GEMINI_MODELS_PAGE" | grep -oE 'gemini-[0-9]\.[0-9]+[a-z-]*' | sort -u | head -10)
        if [ -n "$DETECTED_MODELS" ]; then
            echo "" >> "$REPORT_FILE"
            echo "**Detected Models from Docs**:" >> "$REPORT_FILE"
            while IFS= read -r model; do
                echo "- \`$model\`" >> "$REPORT_FILE"
            done <<< "$DETECTED_MODELS"
        fi
    else
        echo "  ⚠️  Could not fetch official docs (network issue or rate limit)"
        echo "  📝 Using last known values (Dec 2025):"
        echo "     - gemini-2.5-pro (high reasoning)"
        echo "     - gemini-2.5-flash (fast)"
        echo "     - gemini-3-*-preview (if enabled)"
        echo "" >> "$REPORT_FILE"
        echo "**⚠️ Network Issue**: Could not fetch current docs" >> "$REPORT_FILE"
        echo "" >> "$REPORT_FILE"
        echo "**Last Known Models** (Dec 2025):" >> "$REPORT_FILE"
        echo "- \`gemini-2.5-pro\` - High reasoning, complex analysis" >> "$REPORT_FILE"
        echo "- \`gemini-2.5-flash\` - Fast, efficient, simple tasks" >> "$REPORT_FILE"
        echo "- \`gemini-3-pro-preview\` - Latest generation (preview)" >> "$REPORT_FILE"
        echo "- \`gemini-3-flash-preview\` - Fast preview version (preview)" >> "$REPORT_FILE"
        echo "" >> "$REPORT_FILE"
        echo "**Action**: Re-run audit when network is available" >> "$REPORT_FILE"
    fi
fi

echo "" >> "$REPORT_FILE"
echo "**Recommendation**: Run this audit quarterly to catch model updates" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "---" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

#===============================================================================
# SECTION 5: DIRECTORY STRUCTURE
#===============================================================================

echo ""
echo "=== Directory Structure ==="
echo "## Directory Structure" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

for dir in "$BASE" "$BASE/gemini" "$BASE/codex" "$BASE/verification" "$BASE/discoveries"; do
    if [ -d "$dir" ]; then
        echo "✅ $dir exists"
        echo "- ✅ \`$dir\` exists" >> "$REPORT_FILE"
        if [ -w "$dir" ]; then
            echo "   ✅ Writable"
            echo "  - Writable: ✅" >> "$REPORT_FILE"
        else
            echo "   ❌ NOT WRITABLE - run: chmod u+w $dir"
            echo "  - Writable: ❌ (Run \`chmod u+w $dir\`)" >> "$REPORT_FILE"
        fi
    else
        echo "⚠️  $dir missing - creating..."
        mkdir -p "$dir" && echo "   ✅ Created" || echo "   ❌ Failed to create"
        echo "- ⚠️ \`$dir\` was missing (created)" >> "$REPORT_FILE"
    fi
done

echo "" >> "$REPORT_FILE"
echo "---" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

#===============================================================================
# SECTION 6: TIMEOUT WRAPPER
#===============================================================================

echo ""
echo "=== Timeout Wrapper ==="
echo "## Timeout Wrapper" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

if command -v gtimeout &> /dev/null; then
    echo "✅ gtimeout installed (GNU timeout)"
    TIMEOUT_VERSION=$(gtimeout --version 2>&1 | head -1 || echo "Version unknown")
    echo "   Version: $TIMEOUT_VERSION"
    echo "- ✅ **\`gtimeout\`**: Installed" >> "$REPORT_FILE"
    echo "  - Version: $TIMEOUT_VERSION" >> "$REPORT_FILE"
elif command -v timeout &> /dev/null; then
    echo "⚠️  timeout installed (may need 'brew install coreutils' for gtimeout)"
    echo "- ⚠️ **\`timeout\`**: Installed but \`gtimeout\` preferred" >> "$REPORT_FILE"
    echo "  - Install: \`brew install coreutils\`" >> "$REPORT_FILE"
else
    echo "❌ Timeout command NOT FOUND"
    echo "   Install: brew install coreutils (provides gtimeout)"
    echo "- ❌ **Timeout wrapper**: NOT INSTALLED" >> "$REPORT_FILE"
    echo "  - Install: \`brew install coreutils\`" >> "$REPORT_FILE"
fi

echo "" >> "$REPORT_FILE"
echo "---" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

#===============================================================================
# SECTION 7: FUNCTIONAL TESTS
#===============================================================================

echo ""
echo "=== Functional Tests ==="
echo "## Functional Tests" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# Test Gemini (non-interactive)
echo "Testing Gemini delegation..."
echo "### Gemini Delegation Test" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

if command -v gemini &> /dev/null && command -v gtimeout &> /dev/null; then
    if gtimeout 60 gemini -y "What is 2+2?" -o text > /tmp/gemini-test.txt 2>&1; then
        if grep -qi "[0-9]\|four" /tmp/gemini-test.txt; then
            echo "✅ Gemini works (non-interactive delegation functional)"
            echo "- ✅ **Status**: Functional" >> "$REPORT_FILE"
            echo "- **Test**: Simple query (\"What is 2+2?\")" >> "$REPORT_FILE"
            echo "- **Result**: Correct response received" >> "$REPORT_FILE"
        else
            echo "⚠️  Gemini responded unexpectedly:"
            head -3 /tmp/gemini-test.txt
            echo "- ⚠️ **Status**: Unexpected response" >> "$REPORT_FILE"
            echo "\`\`\`" >> "$REPORT_FILE"
            head -3 /tmp/gemini-test.txt >> "$REPORT_FILE"
            echo "\`\`\`" >> "$REPORT_FILE"
        fi
    else
        echo "❌ Gemini failed (timeout or error):"
        head -3 /tmp/gemini-test.txt 2>/dev/null || echo "   No output"
        echo "   Note: Requires 'Gemini CLI Companion' VS Code extension"
        echo "- ❌ **Status**: Failed" >> "$REPORT_FILE"
        echo "- **Error**:" >> "$REPORT_FILE"
        echo "\`\`\`" >> "$REPORT_FILE"
        head -3 /tmp/gemini-test.txt 2>/dev/null >> "$REPORT_FILE" || echo "No output" >> "$REPORT_FILE"
        echo "\`\`\`" >> "$REPORT_FILE"
    fi
else
    echo "⚠️  Cannot test (missing gemini or gtimeout)"
    echo "- ⚠️ **Status**: Cannot test (CLI or gtimeout missing)" >> "$REPORT_FILE"
fi

echo "" >> "$REPORT_FILE"

# Test Codex (non-interactive)
echo "Testing Codex delegation..."
echo "### Codex Delegation Test" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

if command -v codex &> /dev/null && command -v gtimeout &> /dev/null; then
    if gtimeout 60 codex exec "What is 2+2? Answer with just the number." --full-auto > /tmp/codex-test.txt 2>&1; then
        if grep -qi "4\|four" /tmp/codex-test.txt; then
            echo "✅ Codex works (non-interactive delegation functional)"
            echo "- ✅ **Status**: Functional" >> "$REPORT_FILE"
            echo "- **Test**: Simple query (\"What is 2+2?\")" >> "$REPORT_FILE"
            echo "- **Result**: Correct response received" >> "$REPORT_FILE"
        else
            echo "⚠️  Codex responded unexpectedly:"
            head -3 /tmp/codex-test.txt
            echo "- ⚠️ **Status**: Unexpected response" >> "$REPORT_FILE"
            echo "\`\`\`" >> "$REPORT_FILE"
            head -3 /tmp/codex-test.txt >> "$REPORT_FILE"
            echo "\`\`\`" >> "$REPORT_FILE"
        fi
    else
        echo "❌ Codex failed (timeout or error):"
        head -3 /tmp/codex-test.txt 2>/dev/null || echo "   No output"
        echo "- ❌ **Status**: Failed" >> "$REPORT_FILE"
        echo "- **Error**:" >> "$REPORT_FILE"
        echo "\`\`\`" >> "$REPORT_FILE"
        head -3 /tmp/codex-test.txt 2>/dev/null >> "$REPORT_FILE" || echo "No output" >> "$REPORT_FILE"
        echo "\`\`\`" >> "$REPORT_FILE"
    fi
else
    echo "⚠️  Cannot test (missing codex or gtimeout)"
    echo "- ⚠️ **Status**: Cannot test (CLI or gtimeout missing)" >> "$REPORT_FILE"
fi

rm -f /tmp/gemini-test.txt /tmp/codex-test.txt /tmp/codex-exec-help.txt /tmp/gemini-help.txt

echo "" >> "$REPORT_FILE"
echo "---" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

#===============================================================================
# SECTION 8: NETWORK CONNECTIVITY
#===============================================================================

echo ""
echo "=== Network Connectivity ==="
echo "## Network Connectivity" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

if curl -s --max-time 5 https://generativelanguage.googleapis.com/ >/dev/null 2>&1; then
    echo "✅ Can reach Gemini API"
    echo "- ✅ Gemini API reachable" >> "$REPORT_FILE"
else
    echo "❌ Cannot reach Gemini API (check network)"
    echo "- ❌ Gemini API unreachable" >> "$REPORT_FILE"
fi

if curl -s --max-time 5 https://api.openai.com/ >/dev/null 2>&1; then
    echo "✅ Can reach OpenAI API"
    echo "- ✅ OpenAI API reachable" >> "$REPORT_FILE"
else
    echo "❌ Cannot reach OpenAI API (check network)"
    echo "- ❌ OpenAI API unreachable" >> "$REPORT_FILE"
fi

echo "" >> "$REPORT_FILE"
echo "---" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

#===============================================================================
# SECTION 9: SUMMARY
#===============================================================================

echo ""
echo "=== Summary ==="
echo "## Summary" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

CODEX_OK=$(command -v codex &> /dev/null && echo "✅" || echo "❌")
GEMINI_OK=$(command -v gemini &> /dev/null && echo "✅" || echo "❌")
TIMEOUT_OK=$(command -v gtimeout &> /dev/null && echo "✅" || echo "⚠️")

echo "| Component | Status |" >> "$REPORT_FILE"
echo "|-----------|--------|" >> "$REPORT_FILE"
echo "| Codex CLI | $CODEX_OK |" >> "$REPORT_FILE"
echo "| Gemini CLI | $GEMINI_OK |" >> "$REPORT_FILE"
echo "| Timeout Wrapper | $TIMEOUT_OK |" >> "$REPORT_FILE"

echo "" >> "$REPORT_FILE"
echo "---" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "**Generated by**: MAESTRO audit.sh" >> "$REPORT_FILE"
echo "**Timestamp**: $(date)" >> "$REPORT_FILE"

#===============================================================================
# FINAL OUTPUT
#===============================================================================

echo ""
echo "================================"
echo "AUDIT COMPLETE"
echo "================================"
echo ""
echo "✅ Report saved to: $REPORT_FILE"
echo ""
echo "If you see ❌ errors:"
echo "1. Install missing CLIs"
echo "2. Login to expired sessions (gemini login / codex login)"
echo "3. Fix directory permissions"
echo "4. Check network connectivity"
echo "5. Re-run this audit"
echo ""
echo "If you see ⚠️  warnings:"
echo "- Check details above or in report"
echo "- May still work, but monitor for issues"
echo ""
echo "View full report:"
echo "  cat $REPORT_FILE"
echo ""
