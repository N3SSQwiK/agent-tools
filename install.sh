#!/bin/bash

# agent-tools installer
# Creates symlinks from this repo to tool config locations

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Installing agent-tools from $SCRIPT_DIR"

# Claude Code
if [ -d "$SCRIPT_DIR/claude" ]; then
    mkdir -p ~/.claude

    # Backup existing configs
    [ -f ~/.claude/CLAUDE.md ] && [ ! -L ~/.claude/CLAUDE.md ] && mv ~/.claude/CLAUDE.md ~/.claude/CLAUDE.md.bak
    [ -d ~/.claude/commands ] && [ ! -L ~/.claude/commands ] && mv ~/.claude/commands ~/.claude/commands.bak

    # Create symlinks
    ln -sf "$SCRIPT_DIR/claude/CLAUDE.md" ~/.claude/CLAUDE.md
    ln -sf "$SCRIPT_DIR/claude/commands" ~/.claude/commands

    echo "✓ Claude Code configured"
fi

echo "Done!"
