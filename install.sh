#!/bin/bash
# Printing Rates Linux Installation Script
# This script installs Printing Rates on Linux

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Prompt helper (yes/no)
confirm() {
    read -r -p "${1:-Are you sure?} [y/N] " response
    case "$response" in
        [yY][eE][sS]|[yY]) return 0 ;;
        *) return 1 ;;
    esac
}

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    INSTALL_PREFIX="/usr"
    INSTALL_USER="system-wide"
else
    INSTALL_PREFIX="$HOME/.local"
    INSTALL_USER="user-specific"
fi

log_info "Printing Rates Installation Script"
log_info "Installing for: $INSTALL_USER"
log_info "Install prefix: $INSTALL_PREFIX"

# Parse args
ACTION="install"
AUTO_YES=0
for arg in "$@"; do
    case "$arg" in
        uninstall|--uninstall)
            ACTION="uninstall" ;;
        validate|--validate)
            ACTION="validate" ;;
        -y|--yes)
            AUTO_YES=1 ;;
        -h|--help)
            echo "Usage: $0 [--uninstall] [--validate] [-y]";
            echo "  (no args)   Install Printing Rates";
            echo "  --uninstall Uninstall Printing Rates";
            echo "  --validate  Validate desktop integration is working";
            echo "  -y, --yes   Skip confirmation prompts";
            exit 0 ;;
    esac
done

# Uninstall routine
do_uninstall() {
    log_info "Uninstalling Printing Rates from $INSTALL_PREFIX ..."

    if [ "$AUTO_YES" -ne 1 ]; then
        if ! confirm "Remove Printing Rates from $INSTALL_PREFIX?"; then
            log_warning "Uninstall cancelled"
            exit 0
        fi
    fi

    # Remove binaries and libraries
    rm -f "$INSTALL_PREFIX/bin/printing-rates" || true
    rm -rf "$INSTALL_PREFIX/lib/printing-rates" || true
    
    # Remove desktop integration
    rm -f "$INSTALL_PREFIX/share/applications/printing-rates.desktop" || true
    rm -f "$INSTALL_PREFIX/share/icons/hicolor/256x256/apps/printing-rates.png" || true
    rm -rf "$INSTALL_PREFIX/share/printing-rates" || true
    
    # Remove any additional icon sizes that might have been installed
    find "$INSTALL_PREFIX/share/icons" -name "printing-rates.png" -delete 2>/dev/null || true

    # Update system databases
    if command -v update-desktop-database &> /dev/null; then
        log_info "Updating desktop database..."
        update-desktop-database "$INSTALL_PREFIX/share/applications" 2>/dev/null || true
    fi

    if command -v gtk-update-icon-cache &> /dev/null; then
        log_info "Updating icon cache..."
        gtk-update-icon-cache -f -t "$INSTALL_PREFIX/share/icons/hicolor" 2>/dev/null || true
    fi

    # Clean up any remaining empty directories
    rmdir "$INSTALL_PREFIX/share/printing-rates" 2>/dev/null || true
    rmdir "$INSTALL_PREFIX/lib" 2>/dev/null || true

    log_success "Printing Rates uninstalled from $INSTALL_PREFIX"
    exit 0
}

if [ "$ACTION" = "uninstall" ]; then
    do_uninstall
fi

do_install() {
    # Locate package/build directory relative to this script
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    INSTALL_DIR="$SCRIPT_DIR/install"

    # Support repo root (with install/) or packaged release in current dir
    if [ -f "$SCRIPT_DIR/install/Printing Rates" ] || [ -f "$SCRIPT_DIR/install/bin/Printing Rates" ]; then
        INSTALL_DIR="$SCRIPT_DIR/install"
    elif [ -f "$SCRIPT_DIR/Printing Rates" ]; then
        INSTALL_DIR="$SCRIPT_DIR"
    else
        INSTALL_DIR="$SCRIPT_DIR"
    fi

    # Resolve binary name in package/build
    if [ -f "$INSTALL_DIR/bin/Printing Rates" ]; then
        BIN_SRC="Printing Rates"
        BIN_DIR="$INSTALL_DIR/bin"
    elif [ -f "$INSTALL_DIR/Printing Rates" ]; then
        BIN_SRC="Printing Rates"
        BIN_DIR="$INSTALL_DIR"
    else
        log_error "Package not found."
        echo "Run this script from the extracted package directory (containing 'Printing Rates' and 'manifest.json'),"
        echo "or build the project and run it from the repo root after 'install_local' to use ./install/bin/."
        exit 1
    fi

    # Read version from manifest.json if available
    if [ -f "$INSTALL_DIR/manifest.json" ]; then
        VERSION=$(grep -o '"version"[[:space:]]*:[[:space:]]*"[^"]*"' "$INSTALL_DIR/manifest.json" | sed 's/.*: *"\([^"]*\)".*/\1/')
        log_info "Installing version $VERSION"
    else
        log_info "Installing version (unknown)"
    fi

    # Create directories
    log_info "Creating installation directories..."
    mkdir -p "$INSTALL_PREFIX/bin"
    mkdir -p "$INSTALL_PREFIX/lib/printing-rates"
    mkdir -p "$INSTALL_PREFIX/share/applications"
    mkdir -p "$INSTALL_PREFIX/share/icons/hicolor/256x256/apps"
    mkdir -p "$INSTALL_PREFIX/share/printing-rates"

    # Install application and libraries
    log_info "Installing Printing Rates..."
    cp "$BIN_DIR/$BIN_SRC" "$INSTALL_PREFIX/lib/printing-rates/"
    cp "$INSTALL_DIR/manifest.json" "$INSTALL_PREFIX/lib/printing-rates/" 2>/dev/null || true

    # Install eUpdater if available
    if [ -f "$INSTALL_DIR/bin/eUpdater" ] || [ -f "$INSTALL_DIR/eUpdater" ]; then
        log_info "Installing eUpdater..."
        cp "$INSTALL_DIR"/bin/eUpdater* "$INSTALL_PREFIX/lib/printing-rates/" 2>/dev/null || true
        cp "$INSTALL_DIR"/eUpdater* "$INSTALL_PREFIX/lib/printing-rates/" 2>/dev/null || true
    fi

    # Copy Qt libraries
    if ls "$INSTALL_DIR"/*.so* 1> /dev/null 2>&1; then
        log_info "Installing Qt libraries..."
        cp "$INSTALL_DIR"/*.so* "$INSTALL_PREFIX/lib/printing-rates/" 2>/dev/null || true
    fi

    if [ -d "$INSTALL_DIR/lib" ] && ls "$INSTALL_DIR/lib"/*.so* 1> /dev/null 2>&1; then
        log_info "Installing shared libraries..."
        cp "$INSTALL_DIR/lib"/*.so* "$INSTALL_PREFIX/lib/printing-rates/" 2>/dev/null || true
    fi

    # Install config templates if available
    if [ -d "$INSTALL_DIR/config" ]; then
        log_info "Installing config templates..."
        cp -r "$INSTALL_DIR/config" "$INSTALL_PREFIX/share/printing-rates/" 2>/dev/null || true
    fi

    # Create wrapper script
    log_info "Creating launcher script..."
    cat > "$INSTALL_PREFIX/bin/printing-rates" << EOF
#!/bin/bash

# Debug mode - uncomment to enable troubleshooting
# export PR_DEBUG=1

if [ "\$PR_DEBUG" = "1" ]; then
    echo "=== Printing Rates Debug Mode ==="
    echo "LD_LIBRARY_PATH: \$LD_LIBRARY_PATH"
    echo "PATH: \$PATH"
    echo "Checking dependencies..."
    ldd "$INSTALL_PREFIX/lib/printing-rates/$BIN_SRC" 2>/dev/null | grep -E "(boost|not found)" || true
    echo "Checking eUpdater..."
    ls -la "$INSTALL_PREFIX/lib/printing-rates/eUpdater"* 2>/dev/null || echo "eUpdater not found in $INSTALL_PREFIX/lib/printing-rates/"
    echo "=================================="
fi

export LD_LIBRARY_PATH="$INSTALL_PREFIX/lib/printing-rates:\$LD_LIBRARY_PATH"
export PATH="$INSTALL_PREFIX/lib/printing-rates:\$PATH"
exec "$INSTALL_PREFIX/lib/printing-rates/$BIN_SRC" "\$@"
EOF
    chmod +x "$INSTALL_PREFIX/bin/printing-rates"

    # Install desktop file
    log_info "Installing desktop entry..."
    if [ -f "$SCRIPT_DIR/printing-rates.desktop" ]; then
        # Use the comprehensive desktop file from the project
        cp "$SCRIPT_DIR/printing-rates.desktop" "$INSTALL_PREFIX/share/applications/"
        # Update the Exec path to use the installed wrapper script
        sed -i 's|Exec=printing-rates|Exec=printing-rates|g' "$INSTALL_PREFIX/share/applications/printing-rates.desktop"
    elif [ -f "$INSTALL_DIR/printing-rates.desktop" ]; then
        cp "$INSTALL_DIR/printing-rates.desktop" "$INSTALL_PREFIX/share/applications/"
        sed -i 's|Exec=printing-rates|Exec=printing-rates|g' "$INSTALL_PREFIX/share/applications/printing-rates.desktop"
    else
        # Fallback: create a comprehensive desktop file
        cat > "$INSTALL_PREFIX/share/applications/printing-rates.desktop" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Printing Rates
GenericName=Printing Calculator
Comment=Professional printing rate calculator and quotation tool
Exec=printing-rates
Icon=printing-rates
Terminal=false
Categories=Office;Finance;Calculator;
Keywords=printing;rates;calculator;quotation;business;office;
StartupNotify=true
StartupWMClass=Printing Rates
Actions=NewInstance;

[Desktop Action NewInstance]
Name=New Instance
Exec=printing-rates
EOF
    fi
    chmod 644 "$INSTALL_PREFIX/share/applications/printing-rates.desktop"

    # Install icon if available
    if [ -f "$SCRIPT_DIR/docs/Printing Rates.png" ]; then
        log_info "Installing application icon..."
        cp "$SCRIPT_DIR/docs/Printing Rates.png" "$INSTALL_PREFIX/share/icons/hicolor/256x256/apps/printing-rates.png"
    elif [ -f "$INSTALL_DIR/icons/Printing Rates.png" ]; then
        log_info "Installing application icon..."
        cp "$INSTALL_DIR/icons/Printing Rates.png" "$INSTALL_PREFIX/share/icons/hicolor/256x256/apps/printing-rates.png"
    else
        log_warning "No icon found, application will use default icon"
    fi

    # Update desktop database if available
    if command -v update-desktop-database &> /dev/null; then
        log_info "Updating desktop database..."
        update-desktop-database "$INSTALL_PREFIX/share/applications" 2>/dev/null || true
    fi

    # Update icon cache if available
    if command -v gtk-update-icon-cache &> /dev/null; then
        log_info "Updating icon cache..."
        gtk-update-icon-cache -t "$INSTALL_PREFIX/share/icons/hicolor" 2>/dev/null || true
    fi

    log_success "Printing Rates installed successfully!"
    log_info "You can now run 'printing-rates' from the command line"
    log_info "Or find it in your application menu under Office"

    # Show additional usage information
    echo ""
    log_info "Usage examples:"
    echo "  printing-rates                       # Open the GUI"
    echo "  PR_DEBUG=1 printing-rates            # Debug mode (if issues occur)"

    # Offer to add to PATH for user installs
    if [ "$EUID" -ne 0 ] && [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        echo ""
        log_warning "~/.local/bin is not in your PATH"
        if [ -n "$ZSH_VERSION" ]; then
            echo "Add this line to your ~/.zprofile or ~/.zshrc:"
        else
            echo "Add this line to your ~/.bashrc or ~/.profile:"
        fi
        echo "export PATH=\"$HOME/.local/bin:\$PATH\""
        echo "Then restart your terminal or run: source ~/.bashrc"
    fi

    echo ""
    log_info "Desktop integration features:"
    echo "  • Application appears in your applications menu"
    echo "  • Automatic updates via Help → Check Updates"

    echo ""
    log_info "To validate the installation, run:"
    echo "  $0 --validate"

    log_success "Installation complete!"
}

# Run install when requested
if [ "$ACTION" = "install" ]; then
    do_install
fi

# Validate desktop integration when requested
if [ "$ACTION" = "validate" ]; then
    log_info "Validating desktop integration ($INSTALL_USER)"
    echo ""

    # Check desktop file
    DESKTOP_FILE="$INSTALL_PREFIX/share/applications/printing-rates.desktop"
    if [ -f "$DESKTOP_FILE" ]; then
        log_success "Desktop file found: $DESKTOP_FILE"
        
        # Validate desktop file
        if command -v desktop-file-validate >/dev/null 2>&1; then
            if desktop-file-validate "$DESKTOP_FILE" 2>/dev/null; then
                log_success "Desktop file is valid"
            else
                log_warning "Desktop file validation warnings:"
                desktop-file-validate "$DESKTOP_FILE" 2>&1 || true
            fi
        else
            log_info "desktop-file-validate not available (install desktop-file-utils to validate)"
        fi
        
        # Check if executable exists
        EXEC_LINE=$(grep "^Exec=" "$DESKTOP_FILE" | head -1)
        if [ -n "$EXEC_LINE" ]; then
            EXEC_CMD=$(echo "$EXEC_LINE" | sed 's/Exec=//; s/ %F//; s/ %U//; s/ %f//; s/ %u//')
            if command -v "$EXEC_CMD" >/dev/null 2>&1; then
                log_success "Executable is available: $EXEC_CMD"
            else
                log_error "Executable not found: $EXEC_CMD"
            fi
        fi
    else
        log_error "Desktop file not found: $DESKTOP_FILE"
    fi

    # Check icon
    ICON_FILE="$INSTALL_PREFIX/share/icons/hicolor/256x256/apps/printing-rates.png"
    if [ -f "$ICON_FILE" ]; then
        log_success "Icon found: $ICON_FILE"
        
        # Check icon size
        if command -v identify >/dev/null 2>&1; then
            ICON_SIZE=$(identify "$ICON_FILE" 2>/dev/null | awk '{print $3}' | head -1)
            log_info "Icon size: $ICON_SIZE"
        fi
    else
        log_warning "Icon not found: $ICON_FILE (application will use default icon)"
    fi

    # Check desktop database
    echo ""
    log_info "Desktop database status:"
    DESKTOP_CACHE="$INSTALL_PREFIX/share/applications/mimeinfo.cache"
    if [ -f "$DESKTOP_CACHE" ]; then
        if grep -q "printing-rates" "$DESKTOP_CACHE" 2>/dev/null; then
            log_success "Application registered in desktop database"
        else
            log_warning "Application not found in desktop database"
            echo "   Try running: update-desktop-database $INSTALL_PREFIX/share/applications"
        fi
    else
        log_info "Desktop database cache not found (this may be normal)"
    fi

    # Check icon cache
    ICON_CACHE="$INSTALL_PREFIX/share/icons/hicolor/icon-theme.cache"
    if [ -f "$ICON_CACHE" ]; then
        log_success "Icon cache exists"
    else
        log_warning "Icon cache not found"
        echo "   Try running: gtk-update-icon-cache $INSTALL_PREFIX/share/icons/hicolor"
    fi

    echo ""
    log_info "Manual test suggestions:"
    echo "1. Check if 'Printing Rates' appears in your application launcher"
    echo "2. Try searching for 'printing' or 'calculator' in your app menu"
    echo "3. Test command line: printing-rates"
    if command -v gtk-launch >/dev/null 2>&1; then
        echo "4. Test desktop launch: gtk-launch printing-rates"
    fi

    log_success "Validation complete!"
fi
