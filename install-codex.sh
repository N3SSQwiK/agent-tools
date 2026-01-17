#!/bin/bash

# Codex CLI installer (legacy)
# For the interactive TUI installer, run: ./install.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
START_MARKER="<!-- Nexus-AI:START -->"
END_MARKER="<!-- Nexus-AI:END -->"

echo "Installing Codex CLI tools..."

mkdir -p ~/.codex/prompts

# Install all features for Codex
for feature_dir in "$SCRIPT_DIR/features"/*/; do
    feature=$(basename "$feature_dir")
    codex_dir="$feature_dir/codex"

    if [ -d "$codex_dir" ]; then
        # Managed block for AGENTS.md
        if [ -f "$codex_dir/AGENTS.md" ]; then
            AGENTS_MD=~/.codex/AGENTS.md
            SOURCE_CONTENT=$(cat "$codex_dir/AGENTS.md")
            MANAGED_BLOCK="$START_MARKER
$SOURCE_CONTENT
$END_MARKER"

            if [ -f "$AGENTS_MD" ]; then
                if grep -q "$START_MARKER" "$AGENTS_MD"; then
                    perl -i -p0e "s|\Q$START_MARKER\E.*?\Q$END_MARKER\E|$MANAGED_BLOCK|s" "$AGENTS_MD"
                    echo "✓ Updated managed block in AGENTS.md"
                else
                    echo "" >> "$AGENTS_MD"
                    echo "$MANAGED_BLOCK" >> "$AGENTS_MD"
                    echo "✓ Added managed block to AGENTS.md"
                fi
            else
                echo "$MANAGED_BLOCK" > "$AGENTS_MD"
                echo "✓ Created AGENTS.md"
            fi
        fi

        # Symlink prompts
        if [ -d "$codex_dir/prompts" ]; then
            for prompt in "$codex_dir/prompts"/*.md; do
                if [ -f "$prompt" ]; then
                    prompt_name=$(basename "$prompt")
                    ln -sf "$prompt" ~/.codex/prompts/"$prompt_name"
                    echo "✓ Linked prompt: $prompt_name"
                fi
            done
        fi
    fi
done

echo "✓ Codex CLI configured"
