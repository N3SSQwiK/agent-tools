#!/bin/bash

# Nexus-AI Installer
# Interactive TUI for installing AI assistant configuration

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo ""
echo "  ╭──────────────────────────────────────────╮"
echo "  │                Nexus-AI                  │"
echo "  ╰──────────────────────────────────────────╯"
echo ""

# Check for Python (preferred - no build required)
if command -v python3 &> /dev/null; then
    VENV_DIR="$SCRIPT_DIR/installer/python/venv"
    VENV_PYTHON="$VENV_DIR/bin/python"

    # Use venv if it exists with deps installed, otherwise set it up
    if [ -f "$VENV_PYTHON" ] && "$VENV_PYTHON" -c "import textual" 2>/dev/null; then
        cd "$SCRIPT_DIR"
        "$VENV_PYTHON" installer/python/nexus.py
        exit 0
    fi

    # Create venv if needed
    if [ ! -f "$VENV_PYTHON" ]; then
        echo "  Creating virtual environment..."
        python3 -m venv "$VENV_DIR" || { echo "  Failed to create venv"; exit 1; }
    fi

    echo "  Installing dependencies..."
    "$VENV_PYTHON" -m pip install -q -r "$SCRIPT_DIR/installer/python/requirements.txt"

    cd "$SCRIPT_DIR"
    "$VENV_PYTHON" installer/python/nexus.py
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
