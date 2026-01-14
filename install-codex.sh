#!/bin/bash

# Codex CLI installer

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
START_MARKER="<!-- AGENT-TOOLS:START -->"
END_MARKER="<!-- AGENT-TOOLS:END -->"

echo "Installing Codex CLI tools..."

mkdir -p ~/.codex/prompts

# Managed block for AGENTS.md
AGENTS_MD=~/.codex/AGENTS.md
SOURCE_CONTENT=$(cat "$SCRIPT_DIR/codex/AGENTS.md")
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

# Symlink prompts
for prompt in "$SCRIPT_DIR/codex/prompts"/*.md; do
    if [ -f "$prompt" ]; then
        prompt_name=$(basename "$prompt")
        ln -sf "$prompt" ~/.codex/prompts/"$prompt_name"
        echo "✓ Linked prompt: $prompt_name"
    fi
done

echo "✓ Codex CLI configured"
