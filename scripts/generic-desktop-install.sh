#!/bin/bash
# Generic Linux Desktop Integration Framework
# Version: 1.1
# 
# This script provides desktop integration for any Linux application
# that follows the expected project structure.
#
# Required project structure:
# project-root/
# ├── manifest.json (with name, version, description + desktop config)
# ├── bin/
# │   └── MainExecutable (or specified in config)
# ├── lib/
# │   └── *.so* (shared libraries)
# ├── icons/
# │   └── AppIcon.png (or specified in config)
# ├── install.sh (this script)
# └── scripts/
#     └── post-install.sh (optional customization script)
#
# Optional post-install.sh script:
# If present, this script will be called after the main installation
# with arguments: INSTALL_PREFIX PACKAGE_ID APP_NAME
# Use this for app-specific customization like CLI helpers, config setup, etc.

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Prompt helper (yes/no)
confirm() {
    read -r -p "${1:-Are you sure?} [y/N] " response
    case "$response" in
        [yY][eE][sS]|[yY]) return 0 ;;
        *) return 1 ;;
    esac
}

# Configuration loader
load_config() {
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    
    # Load manifest.json for all configuration
    if [ -f "$SCRIPT_DIR/manifest.json" ]; then
        # Basic app info
        APP_NAME=$(grep -o '"name"[[:space:]]*:[[:space:]]*"[^"]*"' "$SCRIPT_DIR/manifest.json" | sed 's/.*: *"\([^"]*\)".*/\1/' || echo "")
        APP_VERSION=$(grep -o '"version"[[:space:]]*:[[:space:]]*"[^"]*"' "$SCRIPT_DIR/manifest.json" | sed 's/.*: *"\([^"]*\)".*/\1/' || echo "")
        APP_DESCRIPTION=$(grep -o '"description"[[:space:]]*:[[:space:]]*"[^"]*"' "$SCRIPT_DIR/manifest.json" | sed 's/.*: *"\([^"]*\)".*/\1/' || echo "")
        
        # Desktop integration config (from desktop section or fallback to separate file)
        if grep -q '"desktop"[[:space:]]*:' "$SCRIPT_DIR/manifest.json"; then
            # Extract desktop configuration from manifest.json
            DESKTOP_NAME=$(grep -A 20 '"desktop"[[:space:]]*:' "$SCRIPT_DIR/manifest.json" | grep -o '"desktop_name"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*: *"\([^"]*\)".*/\1/' || echo "$APP_NAME")
            DESKTOP_GENERIC_NAME=$(grep -A 20 '"desktop"[[:space:]]*:' "$SCRIPT_DIR/manifest.json" | grep -o '"generic_name"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*: *"\([^"]*\)".*/\1/' || echo "")
            DESKTOP_COMMENT=$(grep -A 20 '"desktop"[[:space:]]*:' "$SCRIPT_DIR/manifest.json" | grep -o '"comment"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*: *"\([^"]*\)".*/\1/' || echo "$APP_DESCRIPTION")
            DESKTOP_CATEGORIES=$(grep -A 20 '"desktop"[[:space:]]*:' "$SCRIPT_DIR/manifest.json" | grep -o '"categories"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*: *"\([^"]*\)".*/\1/' || echo "Utility;")
            DESKTOP_KEYWORDS=$(grep -A 20 '"desktop"[[:space:]]*:' "$SCRIPT_DIR/manifest.json" | grep -o '"keywords"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*: *"\([^"]*\)".*/\1/' || echo "")
            DESKTOP_MIME_TYPES=$(grep -A 20 '"desktop"[[:space:]]*:' "$SCRIPT_DIR/manifest.json" | grep -o '"mime_types"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*: *"\([^"]*\)".*/\1/' || echo "")
            EXECUTABLE_NAME=$(grep -A 20 '"desktop"[[:space:]]*:' "$SCRIPT_DIR/manifest.json" | grep -o '"executable"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*: *"\([^"]*\)".*/\1/' || echo "")
            ICON_PATH=$(grep -A 20 '"desktop"[[:space:]]*:' "$SCRIPT_DIR/manifest.json" | grep -o '"icon_path"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*: *"\([^"]*\)".*/\1/' || echo "")
            PACKAGE_ID=$(grep -A 20 '"desktop"[[:space:]]*:' "$SCRIPT_DIR/manifest.json" | grep -o '"package_id"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*: *"\([^"]*\)".*/\1/' || echo "")
            SUPPORTS_FILES=$(grep -A 20 '"desktop"[[:space:]]*:' "$SCRIPT_DIR/manifest.json" | grep -o '"supports_files"[[:space:]]*:[[:space:]]*[^,}]*' | sed 's/.*: *\(.*\)/\1/' || echo "false")
            HAS_CLI_HELPER=$(grep -A 20 '"desktop"[[:space:]]*:' "$SCRIPT_DIR/manifest.json" | grep -o '"cli_helper"[[:space:]]*:[[:space:]]*[^,}]*' | sed 's/.*: *\(.*\)/\1/' || echo "false")
        elif [ -f "$SCRIPT_DIR/app-config.json" ]; then
            # Fallback to separate app-config.json file (for backwards compatibility)
            DESKTOP_NAME=$(grep -o '"desktop_name"[[:space:]]*:[[:space:]]*"[^"]*"' "$SCRIPT_DIR/app-config.json" | sed 's/.*: *"\([^"]*\)".*/\1/' || echo "$APP_NAME")
            DESKTOP_GENERIC_NAME=$(grep -o '"generic_name"[[:space:]]*:[[:space:]]*"[^"]*"' "$SCRIPT_DIR/app-config.json" | sed 's/.*: *"\([^"]*\)".*/\1/' || echo "")
            DESKTOP_COMMENT=$(grep -o '"comment"[[:space:]]*:[[:space:]]*"[^"]*"' "$SCRIPT_DIR/app-config.json" | sed 's/.*: *"\([^"]*\)".*/\1/' || echo "$APP_DESCRIPTION")
            DESKTOP_CATEGORIES=$(grep -o '"categories"[[:space:]]*:[[:space:]]*"[^"]*"' "$SCRIPT_DIR/app-config.json" | sed 's/.*: *"\([^"]*\)".*/\1/' || echo "Utility;")
            DESKTOP_KEYWORDS=$(grep -o '"keywords"[[:space:]]*:[[:space:]]*"[^"]*"' "$SCRIPT_DIR/app-config.json" | sed 's/.*: *"\([^"]*\)".*/\1/' || echo "")
            DESKTOP_MIME_TYPES=$(grep -o '"mime_types"[[:space:]]*:[[:space:]]*"[^"]*"' "$SCRIPT_DIR/app-config.json" | sed 's/.*: *"\([^"]*\)".*/\1/' || echo "")
            EXECUTABLE_NAME=$(grep -o '"executable"[[:space:]]*:[[:space:]]*"[^"]*"' "$SCRIPT_DIR/app-config.json" | sed 's/.*: *"\([^"]*\)".*/\1/' || echo "")
            ICON_PATH=$(grep -o '"icon_path"[[:space:]]*:[[:space:]]*"[^"]*"' "$SCRIPT_DIR/app-config.json" | sed 's/.*: *"\([^"]*\)".*/\1/' || echo "")
            PACKAGE_ID=$(grep -o '"package_id"[[:space:]]*:[[:space:]]*"[^"]*"' "$SCRIPT_DIR/app-config.json" | sed 's/.*: *"\([^"]*\)".*/\1/' || echo "")
            SUPPORTS_FILES=$(grep -o '"supports_files"[[:space:]]*:[[:space:]]*[^,}]*' "$SCRIPT_DIR/app-config.json" | sed 's/.*: *\(.*\)/\1/' || echo "false")
            HAS_CLI_HELPER=$(grep -o '"cli_helper"[[:space:]]*:[[:space:]]*[^,}]*' "$SCRIPT_DIR/app-config.json" | sed 's/.*: *\(.*\)/\1/' || echo "false")
        else
            # Defaults if no desktop config
            DESKTOP_NAME="$APP_NAME"
            DESKTOP_GENERIC_NAME=""
            DESKTOP_COMMENT="$APP_DESCRIPTION"
            DESKTOP_CATEGORIES="Utility;"
            DESKTOP_KEYWORDS=""
            DESKTOP_MIME_TYPES=""
            EXECUTABLE_NAME=""
            ICON_PATH=""
            PACKAGE_ID=""
            SUPPORTS_FILES="false"
            HAS_CLI_HELPER="false"
        fi
    else
        log_error "manifest.json not found"
        exit 1
    fi
    
    # Generate package ID if not provided
    if [ -z "$PACKAGE_ID" ]; then
        if [ -n "$APP_NAME" ]; then
            PACKAGE_ID=$(echo "$APP_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')
        else
            PACKAGE_ID="unknown-app"
        fi
    fi
    
    # Set installation prefix
    if [ "$EUID" -eq 0 ]; then
        INSTALL_PREFIX="/usr"
        INSTALL_USER="system-wide"
    else
        INSTALL_PREFIX="$HOME/.local"
        INSTALL_USER="user-specific"
    fi
    
    # Locate install directories
    INSTALL_BIN="$SCRIPT_DIR/bin"
    INSTALL_LIB="$SCRIPT_DIR/lib"
    INSTALL_ICONS="$SCRIPT_DIR/icons"
    # Find main executable in bin
    if [ -f "$INSTALL_BIN/$EXECUTABLE_NAME" ]; then
        BIN_SRC="$EXECUTABLE_NAME"
    else
        candidates="main app"
        if [ -n "$APP_NAME" ]; then
            candidates="$APP_NAME $(echo "$APP_NAME" | tr ' ' '') $(echo "$APP_NAME" | tr '[:upper:]' '[:lower:]') $candidates"
        fi
        for candidate in $candidates; do
            if [ -f "$INSTALL_BIN/$candidate" ]; then
                BIN_SRC="$candidate"
                break
            fi
        done
    fi
    if [ -z "$BIN_SRC" ]; then
        log_error "Could not find main executable in $INSTALL_BIN"
        log_info "Available files:"
        ls -la "$INSTALL_BIN" 2>/dev/null || echo "  (directory not found)"
        exit 1
    fi
    # Locate icon
    if [ -n "$ICON_PATH" ] && [ -f "$SCRIPT_DIR/$ICON_PATH" ]; then
        ICON_FILE="$SCRIPT_DIR/$ICON_PATH"
    else
        for ext in png ico svg; do
            icon_names="icon logo"
            if [ -n "$APP_NAME" ]; then
                icon_names="$APP_NAME $(echo "$APP_NAME" | tr ' ' '') $icon_names"
            fi
            for name in $icon_names; do
                if [ -f "$INSTALL_ICONS/$name.$ext" ]; then
                    ICON_FILE="$INSTALL_ICONS/$name.$ext"
                    break 2
                fi
            done
        done
    fi
}


# Generate desktop file content
generate_desktop_file() {
    local exec_cmd="$PACKAGE_ID"
    local exec_params=""
    
    if [ "$SUPPORTS_FILES" = "true" ]; then
        exec_params=" %F"
    fi
    
    cat << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=$DESKTOP_NAME
EOF
    
    if [ -n "$DESKTOP_GENERIC_NAME" ]; then
        echo "GenericName=$DESKTOP_GENERIC_NAME"
    fi
    
    cat << EOF
Comment=$DESKTOP_COMMENT
Exec=$exec_cmd$exec_params
Icon=$PACKAGE_ID
Terminal=false
EOF
    
    if [ -n "$DESKTOP_MIME_TYPES" ]; then
        echo "MimeType=$DESKTOP_MIME_TYPES"
    fi
    
    cat << EOF
Categories=$DESKTOP_CATEGORIES
StartupNotify=true
StartupWMClass=$BIN_SRC
EOF
    
    if [ -n "$DESKTOP_KEYWORDS" ]; then
        echo "Keywords=$DESKTOP_KEYWORDS"
    fi
    
    if [ "$SUPPORTS_FILES" = "true" ]; then
        cat << EOF
Actions=NewInstance;

[Desktop Action NewInstance]
Name=New Instance
Exec=$exec_cmd
EOF
    fi
}

# Parse command line arguments
ACTION="install"
AUTO_YES=0
DEBUG_MODE=0

for arg in "$@"; do
    case "$arg" in
        install|--install) ACTION="install" ;;
        uninstall|--uninstall) ACTION="uninstall" ;;
        validate|--validate) ACTION="validate" ;;
        -y|--yes) AUTO_YES=1 ;;
        -d|--debug) DEBUG_MODE=1 ;;
        -h|--help|help)
            echo "Generic Linux Desktop Integration Framework"
            echo "Usage: $0 [ACTION] [OPTIONS]"
            echo ""
            echo "ACTIONS:"
            echo "  install     Install application with desktop integration (default)"
            echo "  uninstall   Uninstall application"
            echo "  validate    Validate desktop integration"
            echo ""
            echo "OPTIONS:"
            echo "  -y, --yes   Skip confirmation prompts"
            echo "  -d, --debug Enable debug output"
            echo "  -h, --help  Show this help"
            echo ""
            echo "Required project structure:"
            echo "  manifest.json        - App metadata with desktop integration config"
            echo "  bin/                 - Built application executables"
            echo "  lib/                 - Shared libraries (optional)"
            echo "  icons/               - Application icons (optional)"
            echo "  install.sh           - This installer script"
            echo ""
            echo "Configuration (manifest.json):"
            echo "  Basic: name, version, description"
            echo "  Desktop: desktop.desktop_name, desktop.categories, etc."
            exit 0 ;;
    esac
done

# Load configuration
load_config

if [ "$DEBUG_MODE" -eq 1 ]; then
    echo "=== DEBUG INFO ==="
    echo "APP_NAME: $APP_NAME"
    echo "APP_VERSION: $APP_VERSION"
    echo "APP_DESCRIPTION: $APP_DESCRIPTION"
    echo "DESKTOP_NAME: $DESKTOP_NAME"
    echo "DESKTOP_CATEGORIES: $DESKTOP_CATEGORIES"
    echo "PACKAGE_ID: $PACKAGE_ID"
    echo "BIN_SRC: $BIN_SRC"
    echo "INSTALL_PREFIX: $INSTALL_PREFIX"
    echo "ICON_FILE: $ICON_FILE"
    echo "=================="
fi

log_info "$APP_NAME Installation Framework"
log_info "Version: $APP_VERSION"
log_info "Installing for: $INSTALL_USER"
log_info "Install prefix: $INSTALL_PREFIX"

# Main action handlers
case "$ACTION" in
    "install")
        if [ "$AUTO_YES" -ne 1 ]; then
            if ! confirm "Install $APP_NAME to $INSTALL_PREFIX?"; then
                log_warning "Installation cancelled"
                exit 0
            fi
        fi
        
        # Create directories
        log_info "Creating installation directories..."
        mkdir -p "$INSTALL_PREFIX/bin"
        mkdir -p "$INSTALL_PREFIX/lib"
        mkdir -p "$INSTALL_PREFIX/icons"
        mkdir -p "$INSTALL_PREFIX/share/applications"
        mkdir -p "$INSTALL_PREFIX/share/icons/hicolor/256x256/apps"

        # Install application
        log_info "Installing $APP_NAME..."
        cp "$INSTALL_BIN/$BIN_SRC" "$INSTALL_PREFIX/bin/"

        # Copy manifest.json
        if [ -f "$SCRIPT_DIR/manifest.json" ]; then
            cp "$SCRIPT_DIR/manifest.json" "$INSTALL_PREFIX/"
        fi

        # Copy shared libraries
        if ls "$INSTALL_LIB"/*.so* 1> /dev/null 2>&1; then
            log_info "Installing shared libraries..."
            cp "$INSTALL_LIB"/*.so* "$INSTALL_PREFIX/lib/" 2>/dev/null || true
        fi

        # Install icons
        if [ -n "$ICON_FILE" ] && [ -f "$ICON_FILE" ]; then
            log_info "Installing application icon..."
            cp "$ICON_FILE" "$INSTALL_PREFIX/icons/$PACKAGE_ID.png"
            cp "$ICON_FILE" "$INSTALL_PREFIX/share/icons/hicolor/256x256/apps/$PACKAGE_ID.png"
        else
            log_warning "No icon found, application will use default icon"
        fi

        # Create wrapper script
        log_info "Creating launcher script..."
        cat > "$INSTALL_PREFIX/bin/$PACKAGE_ID" << EOF
#!/bin/bash
export LD_LIBRARY_PATH="$INSTALL_PREFIX/lib:\$LD_LIBRARY_PATH"
export PATH="$INSTALL_PREFIX/bin:\$PATH"
exec "$INSTALL_PREFIX/bin/$BIN_SRC" "\$@"
EOF
        chmod +x "$INSTALL_PREFIX/bin/$PACKAGE_ID"

        # Run optional post-install customization script
        if [ -f "$SCRIPT_DIR/post-install.sh" ]; then
            log_info "Running post-install customization script..."
            bash "$SCRIPT_DIR/post-install.sh" "$INSTALL_PREFIX" "$PACKAGE_ID" "$APP_NAME"
        fi

        # Install desktop file
        log_info "Installing desktop entry..."
        generate_desktop_file > "$INSTALL_PREFIX/share/applications/$PACKAGE_ID.desktop"
        chmod 644 "$INSTALL_PREFIX/share/applications/$PACKAGE_ID.desktop"

        # Update system databases
        if command -v update-desktop-database &> /dev/null; then
            log_info "Updating desktop database..."
            update-desktop-database "$INSTALL_PREFIX/share/applications" 2>/dev/null || true
        fi

        if command -v gtk-update-icon-cache &> /dev/null; then
            log_info "Updating icon cache..."
            gtk-update-icon-cache -t "$INSTALL_PREFIX/share/icons/hicolor" 2>/dev/null || true
        fi

        log_success "$APP_NAME installed successfully!"
        log_info "Run '$PACKAGE_ID' to launch the application"
        log_info "Or find it in your application menu"
        echo ""
        log_info "To validate the installation, run: $0 --validate"
        ;;
        
    "uninstall")
        if [ "$AUTO_YES" -ne 1 ]; then
            if ! confirm "Remove $APP_NAME from $INSTALL_PREFIX?"; then
                log_warning "Uninstall cancelled"
                exit 0
            fi
        fi
        
        log_info "Uninstalling $APP_NAME..."
        rm -f "$INSTALL_PREFIX/bin/$PACKAGE_ID" || true
        rm -rf "$INSTALL_PREFIX/lib/$PACKAGE_ID" || true
        rm -f "$INSTALL_PREFIX/share/applications/$PACKAGE_ID.desktop" || true
        rm -f "$INSTALL_PREFIX/share/icons/hicolor/256x256/apps/$PACKAGE_ID.png" || true
        
        # Update system databases
        if command -v update-desktop-database &> /dev/null; then
            update-desktop-database "$INSTALL_PREFIX/share/applications" 2>/dev/null || true
        fi
        
        if command -v gtk-update-icon-cache &> /dev/null; then
            gtk-update-icon-cache -f -t "$INSTALL_PREFIX/share/icons/hicolor" 2>/dev/null || true
        fi
        
        log_success "$APP_NAME uninstalled successfully!"
        ;;
        
    "validate")
        log_info "Validating $APP_NAME desktop integration..."
        echo ""
        
        # Check desktop file
        DESKTOP_FILE="$INSTALL_PREFIX/share/applications/$PACKAGE_ID.desktop"
        if [ -f "$DESKTOP_FILE" ]; then
            log_success "Desktop file found: $DESKTOP_FILE"
            
            if command -v desktop-file-validate >/dev/null 2>&1; then
                if desktop-file-validate "$DESKTOP_FILE" 2>/dev/null; then
                    log_success "Desktop file is valid"
                else
                    log_warning "Desktop file validation warnings:"
                    desktop-file-validate "$DESKTOP_FILE" 2>&1 || true
                fi
            fi
            
            # Check executable
            if command -v "$PACKAGE_ID" >/dev/null 2>&1; then
                log_success "Executable '$PACKAGE_ID' is available"
            else
                log_error "Executable '$PACKAGE_ID' not found in PATH"
            fi
        else
            log_error "Desktop file not found: $DESKTOP_FILE"
        fi
        
        # Check icon
        ICON_FILE_INSTALLED="$INSTALL_PREFIX/share/icons/hicolor/256x256/apps/$PACKAGE_ID.png"
        if [ -f "$ICON_FILE_INSTALLED" ]; then
            log_success "Icon found: $ICON_FILE_INSTALLED"
        else
            log_warning "Icon not found: $ICON_FILE_INSTALLED"
        fi
        
        log_success "Validation complete!"
        ;;
esac
