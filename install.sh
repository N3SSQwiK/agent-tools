#!/bin/bash

# NEXUS Agent Tools Installer
# Interactive TUI for installing agent tools configuration

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo ""
echo "  ╭──────────────────────────────────────────╮"
echo "  │         NEXUS Agent Tools                │"
echo "  ╰──────────────────────────────────────────╯"
echo ""

# Check for Python (preferred - no build required)
if command -v python3 &> /dev/null; then
    echo "  Starting Python installer..."
    echo ""

    # Install dependencies if needed
    if ! python3 -c "import textual" 2>/dev/null; then
        echo "  Installing dependencies..."
        pip3 install -q -r "$SCRIPT_DIR/installer/python/requirements.txt"
    fi

    cd "$SCRIPT_DIR"
    python3 installer/python/installer.py
    exit 0
fi

# Check for Go binary
if [ -f "$SCRIPT_DIR/installer/go/nexus-install" ]; then
    echo "  Starting Go installer..."
    echo ""
    cd "$SCRIPT_DIR"
    ./installer/go/nexus-install
    exit 0
fi

# Check for Go compiler
if command -v go &> /dev/null; then
    echo "  Building Go installer..."
    cd "$SCRIPT_DIR/installer/go"
    go mod tidy
    go build -o nexus-install
    cd "$SCRIPT_DIR"
    ./installer/go/nexus-install
    exit 0
fi

# Fallback message
echo "  No suitable runtime found."
echo ""
echo "  Please install one of:"
echo "    • Python 3.9+  (recommended)"
echo "    • Go 1.21+"
echo ""
echo "  Or run the legacy installers directly:"
echo "    ./install-claude.sh"
echo "    ./install-gemini.sh"
echo "    ./install-codex.sh"
echo ""
exit 1
