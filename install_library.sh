#!/bin/bash
# Script to install/update Maximum Mathematics library system-wide
# Run this script whenever you make changes to the library

PROJECT_DIR="/home/jacobhiance/Development/Asymptote"
INSTALL_DIR="$HOME/.asy/MaximumMathematics"

echo "Installing Maximum Mathematics library to $INSTALL_DIR..."

# Create directories if they don't exist
mkdir -p "$INSTALL_DIR/Utilities"
mkdir -p "$INSTALL_DIR/Visualizations"

# Copy main library file (paths remain relative to MaximumMathematics folder)
cp "$PROJECT_DIR/MaximumMathematics.asy" "$INSTALL_DIR/"

# Copy utility modules
cp -r "$PROJECT_DIR/Utilities/"* "$INSTALL_DIR/Utilities/"

# Copy visualization modules
cp -r "$PROJECT_DIR/Visualizations/"* "$INSTALL_DIR/Visualizations/"

# Update config.asy to add MaximumMathematics to search path
CONFIG_FILE="$HOME/.asy/config.asy"
if ! grep -q "MaximumMathematics" "$CONFIG_FILE" 2>/dev/null; then
    # Add search path if not already present
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
echo "  ./install_library.sh"

