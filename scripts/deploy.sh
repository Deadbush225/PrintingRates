#!/bin/bash
# Printing Rates specific deployment script
# This script calls the generic deployment framework
set -e

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Source the generic deployment script
source "$SCRIPT_DIR/generic-deploy.sh"

# Application-specific customization functions (optional)
printing_rates_appimage_extras() {
    local appdir="$1"
    # Add any Printing Rates specific files to AppImage
    echo "Adding Printing Rates specific files to AppImage..."
    
    # Copy config templates if they exist
    if [ -d "$INSTALL_DIR/config" ]; then
        mkdir -p "$appdir/usr/share/printing-rates/config"
        cp -r "$INSTALL_DIR/config"/* "$appdir/usr/share/printing-rates/config/" 2>/dev/null || true
    fi
}

printing_rates_deb_extras() {
    local debdir="$1"
    # Add any Printing Rates specific files to DEB package
    echo "Adding Printing Rates specific files to DEB package..."
    
    # Copy config templates
    if [ -d "$INSTALL_DIR/config" ]; then
        mkdir -p "$debdir/usr/share/printing-rates/config"
        cp -r "$INSTALL_DIR/config"/* "$debdir/usr/share/printing-rates/config/" 2>/dev/null || true
    fi
}

# Run the main deployment
main "$@"
