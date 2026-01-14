#!/bin/bash

# agent-tools master installer
# Runs all individual tool installers

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "agent-tools installer"
echo "====================="
echo ""

[ -f "$SCRIPT_DIR/install-claude.sh" ] && bash "$SCRIPT_DIR/install-claude.sh"
echo ""
[ -f "$SCRIPT_DIR/install-gemini.sh" ] && bash "$SCRIPT_DIR/install-gemini.sh"
echo ""
[ -f "$SCRIPT_DIR/install-codex.sh" ] && bash "$SCRIPT_DIR/install-codex.sh"

echo ""
echo "Done!"
