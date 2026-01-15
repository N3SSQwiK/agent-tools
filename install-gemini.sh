#!/bin/bash

# Gemini CLI installer (legacy)
# For the interactive TUI installer, run: ./install.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
START_MARKER="<!-- AGENT-TOOLS:START -->"
END_MARKER="<!-- AGENT-TOOLS:END -->"

echo "Installing Gemini CLI tools..."

mkdir -p ~/.gemini/extensions

# Install all features for Gemini
for feature_dir in "$SCRIPT_DIR/features"/*/; do
    feature=$(basename "$feature_dir")
    gemini_dir="$feature_dir/gemini"

    if [ -d "$gemini_dir" ]; then
        # Managed block for GEMINI.md
        if [ -f "$gemini_dir/GEMINI.md" ]; then
            GEMINI_MD=~/.gemini/GEMINI.md
            SOURCE_CONTENT=$(cat "$gemini_dir/GEMINI.md")
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
        fi

        # Copy extensions
        if [ -d "$gemini_dir/extensions" ]; then
            for ext in "$gemini_dir/extensions"/*/; do
                ext_name=$(basename "$ext")
                cp -r "$ext" ~/.gemini/extensions/
                echo "✓ Copied extension: $ext_name"

                # Enable extension
                ENABLEMENT=~/.gemini/extensions/extension-enablement.json
                if [ -f "$ENABLEMENT" ]; then
                    if ! grep -q "\"$ext_name\"" "$ENABLEMENT"; then
                        # Add to existing JSON
                        sed -i '' "s/}$/,\n  \"$ext_name\": true\n}/" "$ENABLEMENT"
                        echo "✓ Enabled extension: $ext_name"
                    fi
                else
                    printf '{\n  "%s": true\n}' "$ext_name" > "$ENABLEMENT"
                    echo "✓ Created extension-enablement.json"
                fi
            done
        fi
    fi
done

echo "✓ Gemini CLI configured"
