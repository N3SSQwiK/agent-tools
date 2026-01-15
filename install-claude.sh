#!/bin/bash

# Claude Code installer (legacy)
# For the interactive TUI installer, run: ./install.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
START_MARKER="<!-- AGENT-TOOLS:START -->"
END_MARKER="<!-- AGENT-TOOLS:END -->"

echo "Installing Claude Code tools..."

mkdir -p ~/.claude/commands

# Install all features for Claude
for feature_dir in "$SCRIPT_DIR/features"/*/; do
    feature=$(basename "$feature_dir")
    claude_dir="$feature_dir/claude"

    if [ -d "$claude_dir" ]; then
        # Managed block for CLAUDE.md
        if [ -f "$claude_dir/CLAUDE.md" ]; then
            CLAUDE_MD=~/.claude/CLAUDE.md
            SOURCE_CONTENT=$(cat "$claude_dir/CLAUDE.md")
            MANAGED_BLOCK="$START_MARKER
$SOURCE_CONTENT
$END_MARKER"

            if [ -f "$CLAUDE_MD" ]; then
                if grep -q "$START_MARKER" "$CLAUDE_MD"; then
                    perl -i -p0e "s|\Q$START_MARKER\E.*?\Q$END_MARKER\E|$MANAGED_BLOCK|s" "$CLAUDE_MD"
                    echo "✓ Updated managed block in CLAUDE.md"
                else
                    echo "" >> "$CLAUDE_MD"
                    echo "$MANAGED_BLOCK" >> "$CLAUDE_MD"
                    echo "✓ Added managed block to CLAUDE.md"
                fi
            else
                echo "$MANAGED_BLOCK" > "$CLAUDE_MD"
                echo "✓ Created CLAUDE.md"
            fi
        fi

        # Symlink commands
        if [ -d "$claude_dir/commands" ]; then
            for cmd in "$claude_dir/commands"/*.md; do
                if [ -f "$cmd" ]; then
                    cmd_name=$(basename "$cmd")
                    ln -sf "$cmd" ~/.claude/commands/"$cmd_name"
                    echo "✓ Linked command: $cmd_name"
                fi
            done
        fi
    fi
done

echo "✓ Claude Code configured"
