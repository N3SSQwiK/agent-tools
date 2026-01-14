#!/bin/bash

# Codex CLI installer

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Installing Codex CLI tools..."

mkdir -p ~/.codex/prompts

# Symlink prompts
for prompt in "$SCRIPT_DIR/codex/prompts"/*.md; do
    if [ -f "$prompt" ]; then
        prompt_name=$(basename "$prompt")
        ln -sf "$prompt" ~/.codex/prompts/"$prompt_name"
        echo "✓ Linked prompt: $prompt_name"
    fi
done

echo "✓ Codex CLI configured"
echo "  Note: Codex uses AGENTS.md per-project for global instructions"
