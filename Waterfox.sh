#!/bin/sh

set -e

# Define paths
DOWNLOADS_DIR="$HOME/Downloads"
INSTALL_DIR="/opt/waterfox"
BIN_LINK="/usr/local/bin/waterfox"
DESKTOP_FILE="/usr/share/applications/waterfox.desktop"

# Ensure run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "Please run this script as root (e.g., with sudo)."
    exit 1
fi

# Find Waterfox archive in Downloads folder
ARCHIVE=$(find "$DOWNLOADS_DIR" -maxdepth 1 -type f -iname "waterfox*.tar.*" | head -n 1)

if [ -z "$ARCHIVE" ]; then
    echo "No Waterfox archive found in $DOWNLOADS_DIR."
    exit 1
fi

echo "Found archive: $ARCHIVE"
echo "Installing to: $INSTALL_DIR"

# Create install directory and clean any previous install
rm -rf "$INSTALL_DIR"
mkdir -p "$INSTALL_DIR"

# Extract archive
tar -xf "$ARCHIVE" -C "$INSTALL_DIR" --strip-components=1

# Create symlink
ln -sf "$INSTALL_DIR/waterfox" "$BIN_LINK"

# Create .desktop launcher
cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Name=Waterfox
Exec=$BIN_LINK %u
Icon=$INSTALL_DIR/browser/chrome/icons/default/default128.png
Type=Application
Categories=Network;WebBrowser;
MimeType=text/html;text/xml;application/xhtml+xml;application/xml;x-scheme-handler/http;x-scheme-handler/https;
StartupNotify=true
EOF

chmod +x "$DESKTOP_FILE"

echo "Waterfox installed successfully!"
echo "You can now launch it from your app menu or by typing 'waterfox'"