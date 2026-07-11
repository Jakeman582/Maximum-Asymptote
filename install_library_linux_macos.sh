#!/bin/bash
# Install or update Maximum Mathematics for Linux or macOS.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$SCRIPT_DIR"
INSTALL_DIR="$HOME/.asy/MaximumMathematics"

if ! command -v asy >/dev/null 2>&1; then
    echo "Error: Asymptote (asy) was not found on your PATH." >&2
    echo "Please install Asymptote and try again." >&2
    exit 1
fi

echo "Installing Maximum Mathematics library to $INSTALL_DIR..."

mkdir -p "$INSTALL_DIR/Utilities"
mkdir -p "$INSTALL_DIR/Visualizations"

cp "$PROJECT_DIR/MaximumMathematics.asy" "$INSTALL_DIR/"
cp -R "$PROJECT_DIR/Utilities/." "$INSTALL_DIR/Utilities/"
cp -R "$PROJECT_DIR/Visualizations/." "$INSTALL_DIR/Visualizations/"

CONFIG_DIR="$HOME/.asy"
CONFIG_FILE="$CONFIG_DIR/config.asy"
mkdir -p "$CONFIG_DIR"
if ! grep -q "MaximumMathematics" "$CONFIG_FILE" 2>/dev/null; then
    echo "" >> "$CONFIG_FILE"
    echo "// Add MaximumMathematics directory to Asymptote search path" >> "$CONFIG_FILE"
    echo "dir += \":$INSTALL_DIR\";" >> "$CONFIG_FILE"
fi

echo "✓ Library installed successfully to ~/.asy/MaximumMathematics/"
echo "✓ Search path added to ~/.asy/config.asy"
echo "✓ No wrapper file needed - using config.asy search path"
echo ""
echo "You can now use 'import MaximumMathematics;' from any Asymptote file."
echo ""
echo "To update after making changes, run this script again:"
echo "  ./install_library_linux_macos.sh"
