#!/bin/bash

# Claude Code installer

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
START_MARKER="<!-- AGENT-TOOLS:START -->"
END_MARKER="<!-- AGENT-TOOLS:END -->"

echo "Installing Claude Code tools..."

mkdir -p ~/.claude

CLAUDE_MD=~/.claude/CLAUDE.md
SOURCE_CONTENT=$(cat "$SCRIPT_DIR/claude/CLAUDE.md")
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

mkdir -p ~/.claude/commands
for cmd in "$SCRIPT_DIR/claude/commands"/*.md; do
    if [ -f "$cmd" ]; then
        cmd_name=$(basename "$cmd")
        ln -sf "$cmd" ~/.claude/commands/"$cmd_name"
        echo "✓ Linked command: $cmd_name"
    fi
done

echo "✓ Claude Code configured"
