#!/bin/bash
set -e

# Zlaunch Installation Script for Bazzite
# This script downloads and sets up zlaunch with a custom opaque Dracula theme

echo "Installing zlaunch on Bazzite..."

# Create necessary directories
mkdir -p ~/.local/bin
mkdir -p ~/.local/share/applications
mkdir -p ~/.config/zlaunch/themes

# Fetch latest zlaunch version from GitHub
echo "Fetching latest zlaunch version..."
LATEST_RELEASE=$(curl -s https://api.github.com/repos/zortax/zlaunch/releases/latest | grep '"tag_name":' | cut -d '"' -f 4)
if [ -z "$LATEST_RELEASE" ]; then
    echo "Error: Failed to fetch latest version from GitHub"
    exit 1
fi
echo "Latest version: $LATEST_RELEASE"

# Download latest zlaunch binary
echo "Downloading zlaunch binary..."
cd /tmp
DOWNLOAD_URL="https://github.com/zortax/zlaunch/releases/download/${LATEST_RELEASE}/zlaunch-${LATEST_RELEASE}-x86_64-linux.tar.gz"
wget -q "$DOWNLOAD_URL" -O "zlaunch-${LATEST_RELEASE}-x86_64-linux.tar.gz"
tar -xzf "zlaunch-${LATEST_RELEASE}-x86_64-linux.tar.gz"

# Install binary
echo "Installing zlaunch to ~/.local/bin..."
cp /tmp/zlaunch-${LATEST_RELEASE}-x86_64-linux/zlaunch ~/.local/bin/zlaunch-native
chmod +x ~/.local/bin/zlaunch-native

# Create wrapper script
echo "Creating wrapper script..."
cat > ~/.local/bin/zlaunch << 'EOF'
#!/bin/bash
~/.local/bin/zlaunch-native "$@"
EOF
chmod +x ~/.local/bin/zlaunch

# Create custom Dracula opaque theme
echo "Creating custom Dracula opaque theme..."
cat > ~/.config/zlaunch/themes/dracula-opaque.toml << 'THEME_EOF'
name = "dracula-opaque"

# Window - solid background with low transparency
window_background = "#282a36ff"
window_border = "#bd93f9ff"
window_border_radius = 12.0

# Input
input_background = "#44475aff"
input_text = "#f8f8f2"
input_placeholder = "#6272a4"
input_caret = "#f8f8f2"

# List items - solid backgrounds
item_background = "#282a36ff"
item_background_hover = "#44475aff"
item_background_selected = "#6272a4ff"
item_text = "#f8f8f2"
item_text_secondary = "#bd93f9"

# Icons
icon_background = "#bd93f9ff"
icon_color = "#bd93f9"

# Section headers
section_text = "#50fa7b"
section_background = "#282a36ff"

# Scrollbar
scrollbar_track = "#282a36ff"
scrollbar_thumb = "#44475aff"
scrollbar_thumb_hover = "#6272a4ff"

[calculator]
icon_background = "#bd93f9ff"
result_text = "#50fa7b"
error_color = "#ff5555"

[emoji]
columns = 8
cell_size = 72.0
cell_background = "#282a36ff"
cell_background_hover = "#44475aff"

[ai]
user_bubble_background = "#bd93f9ff"
assistant_bubble_background = "#44475aff"
error_background = "#ff5555ff"

[markdown]
code_background = "#44475aff"
code_text = "#f1fa8c"
link_color = "#bd93f9"
heading_color = "#8be9fd"

[clipboard]
preview_background = "#282a36ff"
preview_border = "#6272a4ff"

[action_indicator]
background = "#50fa7bff"
text = "#282a36ff"
THEME_EOF

# Create config file to set default theme
echo "Creating zlaunch config file..."
mkdir -p ~/.config/zlaunch
cat > ~/.config/zlaunch/config.toml << 'CONFIG_EOF'
theme = "dracula-opaque"
CONFIG_EOF

# Create desktop entry
echo "Creating desktop entry..."
cat > ~/.local/share/applications/zlaunch.desktop << 'DESKTOP_EOF'
[Desktop Entry]
Type=Application
Name=zlaunch
Comment=Fast Wayland Application Launcher
Exec=$HOME/.local/bin/zlaunch toggle
Icon=launcher
Terminal=false
Categories=Utility;
DESKTOP_EOF

# Create KDE global shortcut
echo "Creating KDE global shortcut..."

# Backup existing kglobalshortcutsrc if it exists
if [ -f ~/.config/kglobalshortcutsrc ]; then
    cp ~/.config/kglobalshortcutsrc ~/.config/kglobalshortcutsrc.backup
    echo "Backed up existing kglobalshortcutsrc"
fi

# Append zlaunch shortcut to kglobalshortcutrc
# F15 key code is 6 in KDE format
echo "" >> ~/.config/kglobalshortcutrc
echo "[services][zlaunch.desktop]" >> ~/.config/kglobalshortcutrc
echo "_launch=Launch (6)" >> ~/.config/kglobalshortcutrc

echo "KDE shortcut created: F15 → zlaunch toggle"
echo "Note: You may need to log out and log back in for the shortcut to take effect"

# Cleanup
echo "Cleaning up temporary files..."
rm -rf "/tmp/zlaunch-${LATEST_RELEASE}-x86_64-linux"
rm -f "/tmp/zlaunch-${LATEST_RELEASE}-x86_64-linux.tar.gz"

echo ""
echo "================================================"
echo ""
echo "Installed version: $LATEST_RELEASE"
echo "Binary installed to: ~/.local/bin/zlaunch"
echo "Theme location: ~/.config/zlaunch/themes/dracula-opaque.toml"
echo "Config file: ~/.config/zlaunch/config.toml (theme set to dracula-opaque)"
echo "KDE shortcut: F15 → zlaunch toggle"
echo ""
echo "To use zlaunch:"
echo "  zlaunch              # Start daemon"
echo "  zlaunch toggle       # Toggle launcher window (or press F15)"
echo "  zlaunch show         # Show launcher"
echo "  zlaunch hide         # Hide launcher"
echo ""
echo "To customize the shortcut:"
echo "  System Settings → Shortcuts → Custom Shortcuts → zlaunch"
echo ""
echo "To customize the theme:"
echo "  Edit ~/.config/zlaunch/themes/dracula-opaque.toml"
echo "  Changes are hot-reloaded automatically!"
echo ""
echo "Note: If F15 doesn't work, log out and log back in."
echo "================================================"
echo ""
echo "Installed version: $LATEST_RELEASE"
echo "Binary installed to: ~/.local/bin/zlaunch"
echo "Theme location: ~/.config/zlaunch/themes/dracula-opaque.toml"
echo "KDE shortcut: F15 → zlaunch toggle"
echo ""
echo "To use zlaunch:"
echo "  zlaunch              # Start daemon"
echo "  zlaunch toggle       # Toggle launcher window (or press F15)"
echo "  zlaunch show         # Show launcher"
echo "  zlaunch hide         # Hide launcher"
echo ""
echo "To customize of shortcut:"
echo "  System Settings → Shortcuts → Custom Shortcuts → zlaunch"
echo ""
echo "To customize of theme:"
echo "  Edit ~/.config/zlaunch/themes/dracula-opaque.toml"
echo "  Changes are hot-reloaded automatically!"
echo ""
echo "Note: If F15 doesn't work, log out and log back in."
echo "================================================"
echo ""
echo "Installed version: $LATEST_RELEASE"
echo "Binary installed to: ~/.local/bin/zlaunch"
echo "Theme location: ~/.config/zlaunch/themes/dracula-opaque.toml"
echo "Config file: ~/.config/zlaunch/config.toml (theme set to dracula-opaque)"
echo "KDE shortcut: F15 → zlaunch toggle"
echo ""
echo "To use zlaunch:"
echo "  zlaunch              # Start daemon"
echo "  zlaunch toggle       # Toggle launcher window (or press F15)"
echo "  zlaunch show         # Show launcher"
echo "  zlaunch hide         # Hide launcher"
echo ""
echo "To customize the shortcut:"
echo "  System Settings → Shortcuts → Custom Shortcuts → zlaunch"
echo ""
echo "To customize the theme:"
echo "  Edit ~/.config/zlaunch/themes/dracula-opaque.toml"
echo "  Changes are hot-reloaded automatically!"
echo ""
echo "Note: If F15 doesn't work, log out and log back in."
echo "================================================"

# Optional: Start daemon
read -p "Would you like to start the zlaunch daemon now? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Starting zlaunch daemon..."
    ~/.local/bin/zlaunch &
    echo "Daemon started. You can now use 'zlaunch toggle' to open the launcher!"
fi