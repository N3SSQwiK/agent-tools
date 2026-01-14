#!/bin/bash

# Gemini CLI installer

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
START_MARKER="<!-- AGENT-TOOLS:START -->"
END_MARKER="<!-- AGENT-TOOLS:END -->"

echo "Installing Gemini CLI tools..."

mkdir -p ~/.gemini/extensions

# Copy extension
cp -r "$SCRIPT_DIR/gemini/extensions/agent-tools" ~/.gemini/extensions/
echo "✓ Copied agent-tools extension"

# Enable extension in extension-enablement.json
ENABLEMENT=~/.gemini/extensions/extension-enablement.json
if [ -f "$ENABLEMENT" ]; then
    if grep -q '"agent-tools"' "$ENABLEMENT"; then
        echo "✓ Extension already enabled"
    else
        # Add agent-tools to existing JSON
        sed -i '' 's/}$/,\n  "agent-tools": true\n}/' "$ENABLEMENT"
        echo "✓ Enabled agent-tools extension"
    fi
else
    printf '{\n  "agent-tools": true\n}' > "$ENABLEMENT"
    echo "✓ Created extension-enablement.json"
fi

# Managed block for GEMINI.md
GEMINI_MD=~/.gemini/GEMINI.md
SOURCE_CONTENT=$(cat "$SCRIPT_DIR/gemini/GEMINI.md")
MANAGED_BLOCK="$START_MARKER
$SOURCE_CONTENT
$END_MARKER"

if [ -f "$GEMINI_MD" ]; then
    if grep -q "$START_MARKER" "$GEMINI_MD"; then
        perl -i -p0e "s|\Q$START_MARKER\E.*?\Q$END_MARKER\E|$MANAGED_BLOCK|s" "$GEMINI_MD"
        echo "✓ Updated managed block in GEMINI.md"
    else
        echo "" >> "$GEMINI_MD"
        echo "$MANAGED_BLOCK" >> "$GEMINI_MD"
        echo "✓ Added managed block to GEMINI.md"
    fi
else
    echo "$MANAGED_BLOCK" > "$GEMINI_MD"
    echo "✓ Created GEMINI.md"
fi

echo "✓ Gemini CLI configured"
