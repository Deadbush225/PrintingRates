#!/bin/bash
# Generic cross-platform deployment script
# Usage: ./generic-deploy.sh [all|windows|linux|appimage|deb|rpm|arch]
#
# This script expects the following environment variables or config file:
# - APP_NAME: Display name (e.g., "Folder Customizer", "Download Sorter")
# - APP_BINARY: Binary name (e.g., "FolderCustomizer", "DownloadSorter")
# - APP_PACKAGE: Package name (e.g., "folder-customizer", "download-sorter")
# - APP_DESCRIPTION: Short description
# - APP_CATEGORIES: Desktop categories (e.g., "Utility;FileManager;")
# - APP_MAINTAINER: Maintainer info
# - APP_URL: Project URL
# - APP_LICENSE: License type (e.g., "MIT")
#
# Optional:
# - APP_ICON_SOURCE: Path to icon source (default: detect from project)
# - APP_DEPS_DEB: Debian dependencies
# - APP_DEPS_RPM: RPM dependencies
# - EXTRA_HELPERS: Additional helper scripts to include

set -e

# Get the project root (where this script is called from)
PROJECT_ROOT="$(pwd)"
BUILD_DIR="$PROJECT_ROOT/build"
INSTALL_DIR="$PROJECT_ROOT/install"
SCRIPTS_DIR="$PROJECT_ROOT/scripts"

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

# Load deployment configuration
load_config() {
    # Read configuration from manifest.json
    if [ ! -f "$PROJECT_ROOT/manifest.json" ]; then
        log_error "manifest.json not found in project root"
        exit 1
    fi

    # Check if jq is available for JSON parsing
    if ! command -v jq &> /dev/null; then
        log_warning "jq not found, using fallback JSON parsing"
        # Fallback to grep-based parsing
        APP_NAME=$(grep -o '"name"[^"]*"[^"]*"' "$PROJECT_ROOT/manifest.json" | sed 's/.*"\([^"]*\)"/\1/')
        VERSION=$(grep -o '"version"[^"]*"[0-9.]*"' "$PROJECT_ROOT/manifest.json" | sed 's/.*"\([0-9.]*\)"/\1/')
        APP_DESCRIPTION=$(grep -o '"description"[^"]*"[^"]*"' "$PROJECT_ROOT/manifest.json" | sed 's/.*"\([^"]*\)"/\1/')
        APP_BINARY=$(grep -o '"executable"[^"]*"[^"]*"' "$PROJECT_ROOT/manifest.json" | sed 's/.*"\([^"]*\)"/\1/')
        APP_PACKAGE=$(grep -o '"package_id"[^"]*"[^"]*"' "$PROJECT_ROOT/manifest.json" | sed 's/.*"\([^"]*\)"/\1/')
        APP_CATEGORIES=$(grep -o '"categories"[^"]*"[^"]*"' "$PROJECT_ROOT/manifest.json" | sed 's/.*"\([^"]*\)"/\1/')
        # Set defaults for complex fields when jq is not available
        APP_MAINTAINER="Unknown <unknown@example.com>"
        APP_URL="https://github.com/user/repo"
        APP_LICENSE="MIT"
        APP_DEPS_DEB="libc6, libqt6core6, libqt6gui6, libqt6widgets6"
        APP_DEPS_RPM="qt6-qtbase qt6-qtbase-gui"
    else
        log_info "Loading configuration from: $PROJECT_ROOT/manifest.json"
        # Use jq for precise JSON parsing
        APP_NAME=$(jq -r '.name' "$PROJECT_ROOT/manifest.json")
        VERSION=$(jq -r '.version' "$PROJECT_ROOT/manifest.json")
        APP_DESCRIPTION=$(jq -r '.description' "$PROJECT_ROOT/manifest.json")
        APP_BINARY=$(jq -r '.desktop.executable' "$PROJECT_ROOT/manifest.json")
        APP_PACKAGE=$(jq -r '.desktop.package_id' "$PROJECT_ROOT/manifest.json")
        APP_CATEGORIES=$(jq -r '.desktop.categories' "$PROJECT_ROOT/manifest.json")
        APP_MAINTAINER=$(jq -r '.maintainer // "Unknown <unknown@example.com>"' "$PROJECT_ROOT/manifest.json")
        APP_URL=$(jq -r '.homepage // "https://github.com/user/repo"' "$PROJECT_ROOT/manifest.json")
        APP_LICENSE=$(jq -r '.license // "MIT"' "$PROJECT_ROOT/manifest.json")
        APP_DEPS_DEB=$(jq -r '.deployment.dependencies.deb // "libc6, libqt6core6, libqt6gui6, libqt6widgets6"' "$PROJECT_ROOT/manifest.json")
        APP_DEPS_RPM=$(jq -r '.deployment.dependencies.rpm // "qt6-qtbase qt6-qtbase-gui"' "$PROJECT_ROOT/manifest.json")
    fi
    
    # Validate required configuration
    if [ -z "$APP_NAME" ] || [ -z "$APP_BINARY" ] || [ -z "$APP_PACKAGE" ]; then
        log_error "Missing required configuration in manifest.json"
        log_info "Ensure manifest.json contains:"
        echo "  \"name\": \"Your App Name\""
        echo "  \"desktop\": {"
        echo "    \"executable\": \"YourAppBinary\","
        echo "    \"package_id\": \"your-app-package\""
        echo "  }"
        exit 1
    fi
    
    echo "=== Generic Deployment Script ==="
    echo "Application: $APP_NAME"
    echo "Binary: $APP_BINARY"
    echo "Package: $APP_PACKAGE"
    echo "Version: $VERSION"
    echo "Project root: $PROJECT_ROOT"
}

# Check if build exists
check_build() {
    log_info "Checking for build artifacts in: $INSTALL_DIR"
    if [ ! -d "$INSTALL_DIR" ]; then
        log_error "Install directory '$INSTALL_DIR' does not exist. Please run: cmake --build build --target install_local"
        exit 1
    fi

    # Show what's in the install directory to help debugging
    echo "--- Install directory structure ---"
    find "$INSTALL_DIR" -type f | head -20 || true
    echo "--- End structure ---"

    # Find main executable in bin/ (prioritize main app over utilities)
    BIN_NAME=""
    if [ -d "$INSTALL_DIR/bin" ]; then
        # First look for the specified binary
        if [ -f "$INSTALL_DIR/bin/$APP_BINARY" ] && [ -x "$INSTALL_DIR/bin/$APP_BINARY" ]; then
            BIN_NAME="$APP_BINARY"
            MAIN_EXECUTABLE="$INSTALL_DIR/bin/$APP_BINARY"
            log_info "Found main executable: $BIN_NAME"
        else
            # Fallback to any executable that's not a utility
            for f in "$INSTALL_DIR/bin"/*; do
                if [ -f "$f" ] && [ -x "$f" ]; then
                    basename_f="$(basename "$f")"
                    # Skip known utilities
                    case "$basename_f" in
                        eUpdater|eUpdater.exe) continue ;;
                        *) BIN_NAME="$basename_f"; MAIN_EXECUTABLE="$f"; log_info "Found executable: $BIN_NAME"; break ;;
                    esac
                fi
            done
        fi
    fi
    
    if [ -z "$BIN_NAME" ]; then
        log_error "No executable found in $INSTALL_DIR/bin/. Please build the project first:"
        echo "  cmake -B build -DCMAKE_BUILD_TYPE=Release"
        echo "  cmake --build build"
        echo "  cmake --build build --target install_local"
        exit 1
    fi
}

# Prepare dist directory
prepare_dist() {
    mkdir -p "$PROJECT_ROOT/dist"
    if [ "${KEEP_OLD_DIST:-0}" != "1" ]; then
        log_info "Cleaning dist/ (set KEEP_OLD_DIST=1 to keep)"
        rm -rf "$PROJECT_ROOT/dist/package" "$PROJECT_ROOT"/dist/${APP_PACKAGE}-* "$PROJECT_ROOT"/dist/${APP_BINARY}-* 2>/dev/null || true
    fi
}

# Find and copy icon
copy_icon() {
    local dest="$1"
    local icon_name="$2"
    
    # Try various icon locations in order of preference
    local icon_sources=(
        "$INSTALL_DIR/icons/${APP_NAME}.png"
        "$INSTALL_DIR/icons/${APP_BINARY}.png"
        "$APP_ICON_SOURCE"
        "$PROJECT_ROOT/Icons/${APP_NAME}.png"
        "$PROJECT_ROOT/src/icons/${APP_NAME}.png"
        "$PROJECT_ROOT/icons/${APP_NAME}.png"
    )
    
    for icon_src in "${icon_sources[@]}"; do
        if [ -n "$icon_src" ] && [ -f "$icon_src" ]; then
            cp "$icon_src" "$dest/$icon_name"
            log_info "Copied icon from: $icon_src"
            return 0
        fi
    done
    
    log_warning "Icon not found, using placeholder"
    # Create a simple placeholder icon
    echo "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==" | base64 -d > "$dest/$icon_name" 2>/dev/null || true
    return 1
}

# Create AppImage (Universal Linux)
create_appimage() {
    log_info "Creating AppImage..."
    
    local appdir="$PROJECT_ROOT/dist/${APP_BINARY}.AppDir"
    rm -rf "$appdir"
    mkdir -p "$appdir/usr/bin"
    mkdir -p "$appdir/usr/lib"
    
    # Copy application
    cp "$MAIN_EXECUTABLE" "$appdir/usr/bin/$APP_BINARY"
    
    # Copy manifest.json if available
    if [ -f "$INSTALL_DIR/manifest.json" ]; then
        cp "$INSTALL_DIR/manifest.json" "$appdir/usr/bin/manifest.json"
    fi
    
    # Copy eUpdater if available
    if [ -f "$INSTALL_DIR/bin/eUpdater" ] || [ -f "$INSTALL_DIR/bin/eUpdater.exe" ]; then
        cp "$INSTALL_DIR/bin"/eUpdater* "$appdir/usr/bin/" 2>/dev/null || true
    fi
    
    # Copy libraries from lib/
    if [ -d "$INSTALL_DIR/lib" ] && ls "$INSTALL_DIR/lib"/*.so* 1> /dev/null 2>&1; then
        cp "$INSTALL_DIR/lib"/*.so* "$appdir/usr/lib/" 2>/dev/null || true
    fi
    
    # Include any app-specific customizations for AppImage
    if command -v "${APP_PACKAGE//-/_}_appimage_extras" >/dev/null 2>&1; then
        "${APP_PACKAGE//-/_}_appimage_extras" "$appdir"
    fi
    
    # Create desktop file
    cat > "$appdir/${APP_BINARY}.desktop" << EOF
[Desktop Entry]
Type=Application
Name=$APP_NAME
Comment=$APP_DESCRIPTION
Exec=$APP_BINARY
Icon=${APP_PACKAGE}
Categories=$APP_CATEGORIES
EOF
    
    # Copy icon
    copy_icon "$appdir" "${APP_PACKAGE}.png"
    
    # Create AppRun script
    cat > "$appdir/AppRun" << EOF
#!/bin/bash
HERE="\$(dirname "\$(readlink -f "\${0}")")"
export LD_LIBRARY_PATH="\${HERE}/usr/lib:\${LD_LIBRARY_PATH}"
export PATH="\${HERE}/usr/bin:\${PATH}"
exec "\${HERE}/usr/bin/$APP_BINARY" "\$@"
EOF
    chmod +x "$appdir/AppRun"
    
    # Download appimagetool if needed
    if [ ! -f "$SCRIPTS_DIR/appimagetool" ]; then
        log_info "Downloading appimagetool..."
        mkdir -p "$SCRIPTS_DIR"
        wget -O "$SCRIPTS_DIR/appimagetool" "https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage" || true
        chmod +x "$SCRIPTS_DIR/appimagetool" 2>/dev/null || true
    fi

    mkdir -p "$PROJECT_ROOT/dist"
    cd "$PROJECT_ROOT/dist"

    # Try to run appimagetool normally (requires FUSE)
    if "$SCRIPTS_DIR/appimagetool" "$appdir" "${APP_BINARY}-${VERSION}-x86_64.AppImage" 2>appimage.err; then
        log_success "AppImage created: dist/${APP_BINARY}-${VERSION}-x86_64.AppImage"
        return
    fi

    # If FUSE is missing, extract and run embedded appimagetool without FUSE
    if grep -qi "libfuse" appimage.err; then
        log_warning "FUSE not available, trying extracted appimagetool"
        (
            cd "$SCRIPTS_DIR" && \
            ./appimagetool --appimage-extract >/dev/null 2>&1 && \
            chmod +x "$SCRIPTS_DIR/squashfs-root/AppRun" && \
            "$SCRIPTS_DIR/squashfs-root/AppRun" "$appdir" "$PROJECT_ROOT/dist/${APP_BINARY}-${VERSION}-x86_64.AppImage"
        ) && {
            log_success "AppImage created (no FUSE): dist/${APP_BINARY}-${VERSION}-x86_64.AppImage"
            return
        }
    fi

    # Fallback to tarball
    tar czf "${APP_PACKAGE}-${VERSION}-x86_64.tar.gz" -C "$(dirname "$appdir")" "$(basename "$appdir")"
    log_success "Archive created: dist/${APP_PACKAGE}-${VERSION}-x86_64.tar.gz"
}

# Create DEB package (Ubuntu/Debian)
create_deb() {
    log_info "Creating DEB package..."
    
    local debdir="$PROJECT_ROOT/dist/deb"
    rm -rf "$debdir"
    mkdir -p "$debdir/DEBIAN"
    mkdir -p "$debdir/usr/bin"
    mkdir -p "$debdir/usr/lib/$APP_PACKAGE"
    mkdir -p "$debdir/usr/share/applications"
    mkdir -p "$debdir/usr/share/icons/hicolor/256x256/apps"
    
    # Copy application and libraries
    cp "$MAIN_EXECUTABLE" "$debdir/usr/lib/$APP_PACKAGE/$APP_BINARY"
    
    # Copy manifest.json if available
    if [ -f "$INSTALL_DIR/manifest.json" ]; then
        cp "$INSTALL_DIR/manifest.json" "$debdir/usr/lib/$APP_PACKAGE/"
    fi
    
    # Copy eUpdater if available
    if [ -f "$INSTALL_DIR/bin/eUpdater" ] || [ -f "$INSTALL_DIR/bin/eUpdater.exe" ]; then
        cp "$INSTALL_DIR/bin"/eUpdater* "$debdir/usr/lib/$APP_PACKAGE/" 2>/dev/null || true
    fi
    
    # Copy libraries from lib/
    if [ -d "$INSTALL_DIR/lib" ] && ls "$INSTALL_DIR/lib"/*.so* 1> /dev/null 2>&1; then
        cp "$INSTALL_DIR/lib"/*.so* "$debdir/usr/lib/$APP_PACKAGE/" 2>/dev/null || true
    fi
    
    # Include any app-specific customizations for DEB
    if command -v "${APP_PACKAGE//-/_}_deb_extras" >/dev/null 2>&1; then
        "${APP_PACKAGE//-/_}_deb_extras" "$debdir"
    fi
    
    # Create wrapper script
    cat > "$debdir/usr/bin/$APP_PACKAGE" << EOF
#!/bin/bash
export LD_LIBRARY_PATH="/usr/lib/$APP_PACKAGE:\\\$LD_LIBRARY_PATH"
export PATH="/usr/lib/$APP_PACKAGE:\\\$PATH"
exec "/usr/lib/$APP_PACKAGE/$APP_BINARY" "\\\$@"
EOF
    chmod +x "$debdir/usr/bin/$APP_PACKAGE"
    
    # Create desktop file
    cat > "$debdir/usr/share/applications/$APP_PACKAGE.desktop" << EOF
[Desktop Entry]
Name=$APP_NAME
Comment=$APP_DESCRIPTION
Exec=$APP_PACKAGE
Icon=$APP_PACKAGE
Type=Application
Categories=$APP_CATEGORIES
EOF
    
    # Copy icon
    copy_icon "$debdir/usr/share/icons/hicolor/256x256/apps" "$APP_PACKAGE.png"
    
    # Create control file
    cat > "$debdir/DEBIAN/control" << EOF
Package: $APP_PACKAGE
Version: $VERSION
Section: utils
Priority: optional
Architecture: amd64
Maintainer: $APP_MAINTAINER
Description: $APP_NAME - $APP_DESCRIPTION
 $APP_DESCRIPTION
Depends: $APP_DEPS_DEB
EOF
    
    # Build package
    if command -v dpkg-deb &> /dev/null; then
        dpkg-deb --build "$debdir" "$PROJECT_ROOT/dist/${APP_PACKAGE}_${VERSION}_amd64.deb"
        log_success "DEB package created: dist/${APP_PACKAGE}_${VERSION}_amd64.deb"
    else
        log_warning "dpkg-deb not found, creating tar.gz instead"
        cd "$PROJECT_ROOT/dist"
        tar czf "${APP_PACKAGE}_${VERSION}_amd64.tar.gz" -C "$debdir" .
        log_success "Archive created: dist/${APP_PACKAGE}_${VERSION}_amd64.tar.gz"
    fi
}

# Create RPM package (Fedora/RHEL)
create_rpm() {
    log_info "Creating RPM package..."

    # Force tarball on non-RPM distros or when requested
    if [ "${FORCE_RPM_TARBALL:-}" = "1" ]; then
        log_warning "FORCE_RPM_TARBALL=1 set; creating tar.gz instead of RPM"
        cd "$PROJECT_ROOT/dist"
        tar czf "${APP_PACKAGE}-${VERSION}-1.x86_64.tar.gz" -C "$INSTALL_DIR" bin lib icons *.sh *.json 2>/dev/null || tar czf "${APP_PACKAGE}-${VERSION}-1.x86_64.tar.gz" -C "$INSTALL_DIR" .
        log_success "Archive created: dist/${APP_PACKAGE}-${VERSION}-1.x86_64.tar.gz"
        return
    fi

    # Check for rpmbuild and appropriate distro
    if ! command -v rpmbuild &> /dev/null; then
        log_warning "rpmbuild not found, creating tar.gz instead"
        cd "$PROJECT_ROOT/dist"
        tar czf "${APP_PACKAGE}-${VERSION}-1.x86_64.tar.gz" -C "$INSTALL_DIR" bin lib icons *.sh *.json 2>/dev/null || tar czf "${APP_PACKAGE}-${VERSION}-1.x86_64.tar.gz" -C "$INSTALL_DIR" .
        log_success "Archive created: dist/${APP_PACKAGE}-${VERSION}-1.x86_64.tar.gz"
        return
    fi

    if [ -r /etc/os-release ]; then
        . /etc/os-release
        case "${ID_LIKE}${ID}" in
            *fedora*|*rhel*|*centos*|*suse*) : ;;
            *)
                log_warning "Non-RPM-based distro detected (${ID:-unknown}); creating tar.gz instead"
                cd "$PROJECT_ROOT/dist"
                tar czf "${APP_PACKAGE}-${VERSION}-1.x86_64.tar.gz" -C "$INSTALL_DIR" bin lib icons *.sh *.json 2>/dev/null || tar czf "${APP_PACKAGE}-${VERSION}-1.x86_64.tar.gz" -C "$INSTALL_DIR" .
                log_success "Archive created: dist/${APP_PACKAGE}-${VERSION}-1.x86_64.tar.gz"
                return
                ;;
        esac
    fi
    
    local rpmdir="$PROJECT_ROOT/dist/rpm"
    rm -rf "$rpmdir"
    mkdir -p "$rpmdir"/{BUILD,BUILDROOT,RPMS,SOURCES,SPECS,SRPMS}
    
    # Create spec file
    cat > "$rpmdir/SPECS/$APP_PACKAGE.spec" << EOF
Name:           $APP_PACKAGE
Version:        $VERSION
Release:        1%{?dist}
Summary:        $APP_DESCRIPTION
License:        $APP_LICENSE
URL:            $APP_URL
Source0:        %{name}-%{version}.tar.gz

BuildRequires:  qt6-qtbase-devel
Requires:       $APP_DEPS_RPM

%description
$APP_DESCRIPTION

%prep
%setup -q

%build
# Files are pre-built

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}/usr/bin
mkdir -p %{buildroot}/usr/lib/%{name}
mkdir -p %{buildroot}/usr/share/applications

# Install files
cp -r * %{buildroot}/usr/lib/%{name}/

# Create wrapper script
cat > %{buildroot}/usr/bin/%{name} << 'EOFSCRIPT'
#!/bin/bash
export LD_LIBRARY_PATH="/usr/lib/$APP_PACKAGE:\$LD_LIBRARY_PATH"
export PATH="/usr/lib/$APP_PACKAGE:\$PATH"
exec "/usr/lib/$APP_PACKAGE/$APP_BINARY" "\$@"
EOFSCRIPT
chmod +x %{buildroot}/usr/bin/%{name}

%files
/usr/bin/%{name}
/usr/lib/%{name}/
%if 0%{?fedora} || 0%{?rhel} >= 8
/usr/share/applications/%{name}.desktop
%endif

%changelog
* $(date +'%a %b %d %Y') $APP_MAINTAINER - $VERSION-1
- Initial RPM package
EOF
    
    # Create source tarball
    cd "$INSTALL_DIR"
    tar czf "$rpmdir/SOURCES/${APP_PACKAGE}-${VERSION}.tar.gz" bin lib icons *.sh *.json 2>/dev/null || tar czf "$rpmdir/SOURCES/${APP_PACKAGE}-${VERSION}.tar.gz" *
    
    # Build RPM
    if ! rpmbuild --define "_topdir $rpmdir" -bb "$rpmdir/SPECS/$APP_PACKAGE.spec"; then
        log_warning "RPM build failed, creating tar.gz"
        cd "$PROJECT_ROOT/dist"
        tar czf "${APP_PACKAGE}-${VERSION}-1.x86_64.tar.gz" -C "$INSTALL_DIR" bin lib icons *.sh *.json 2>/dev/null || tar czf "${APP_PACKAGE}-${VERSION}-1.x86_64.tar.gz" -C "$INSTALL_DIR" .
        log_success "Archive created: dist/${APP_PACKAGE}-${VERSION}-1.x86_64.tar.gz"
        return
    fi
    
    # Copy result
    cp "$rpmdir/RPMS/x86_64/${APP_PACKAGE}-${VERSION}-1."*.rpm "$PROJECT_ROOT/dist/" 2>/dev/null || true
    log_success "RPM package created in dist/"
}

# Create Arch Linux package
create_arch() {
    log_info "Creating Arch Linux package..."
    
    local archdir="$PROJECT_ROOT/dist/arch"
    rm -rf "$archdir"
    mkdir -p "$archdir"
    
    if ! command -v makepkg &> /dev/null; then
        log_warning "makepkg not found, creating tar.gz instead"
        cd "$PROJECT_ROOT/dist"
        tar czf "${APP_PACKAGE}-${VERSION}-x86_64.tar.gz" -C "$INSTALL_DIR" bin lib icons *.sh *.json 2>/dev/null || tar czf "${APP_PACKAGE}-${VERSION}-x86_64.tar.gz" -C "$INSTALL_DIR" .
        log_success "Archive created: dist/${APP_PACKAGE}-${VERSION}-x86_64.tar.gz"
        return
    fi
    
    # Create PKGBUILD
    cat > "$archdir/PKGBUILD" << EOF
# Maintainer: $APP_MAINTAINER
pkgname=$APP_PACKAGE
pkgver=$VERSION
pkgrel=1
pkgdesc="$APP_DESCRIPTION"
arch=('x86_64')
url="$APP_URL"
license=('$APP_LICENSE')
depends=('qt6-base')
source=()
md5sums=()

package() {
    # Install binary and libraries
    install -dm755 "\$pkgdir/usr/lib/\$pkgname"
    
    # Copy from the bin/ subdirectory
    if [ -f "$INSTALL_DIR/bin/$APP_BINARY" ]; then
        cp "$INSTALL_DIR/bin/$APP_BINARY" "\$pkgdir/usr/lib/\$pkgname/$APP_BINARY"
    fi
    
    # Copy libraries if they exist
    if [ -d "$INSTALL_DIR/lib" ] && ls "$INSTALL_DIR/lib"/*.so* 1> /dev/null 2>&1; then
        cp "$INSTALL_DIR/lib"/*.so* "\$pkgdir/usr/lib/\$pkgname/" 2>/dev/null || true
    fi
    
    # Copy other files as needed
    if [ -f "$INSTALL_DIR/manifest.json" ]; then
        cp "$INSTALL_DIR/manifest.json" "\$pkgdir/usr/lib/\$pkgname/"
    fi
    
    # Create wrapper script
    install -dm755 "\$pkgdir/usr/bin"
    cat > "\$pkgdir/usr/bin/\$pkgname" << 'EOFSCRIPT'
#!/bin/bash
export LD_LIBRARY_PATH="/usr/lib/$APP_PACKAGE:\$LD_LIBRARY_PATH"
export PATH="/usr/lib/$APP_PACKAGE:\$PATH"
exec "/usr/lib/$APP_PACKAGE/$APP_BINARY" "\$@"
EOFSCRIPT
    chmod +x "\$pkgdir/usr/bin/\$pkgname"
    
    # Desktop file
    install -dm755 "\$pkgdir/usr/share/applications"
    cat > "\$pkgdir/usr/share/applications/\$pkgname.desktop" << 'EOFDESKTOP'
[Desktop Entry]
Name=$APP_NAME
Comment=$APP_DESCRIPTION
Exec=$APP_PACKAGE
Icon=$APP_PACKAGE
Type=Application
Categories=$APP_CATEGORIES
EOFDESKTOP

    # Application icon
    install -dm755 "\$pkgdir/usr/share/icons/hicolor/256x256/apps"
}
EOF
    
    cd "$archdir"
    makepkg -f || {
        log_warning "makepkg failed, creating tar.gz instead"
        cd "$PROJECT_ROOT/dist"
        tar czf "${APP_PACKAGE}-${VERSION}-x86_64.tar.gz" -C "$INSTALL_DIR" bin lib icons *.sh *.json 2>/dev/null || tar czf "${APP_PACKAGE}-${VERSION}-x86_64.tar.gz" -C "$INSTALL_DIR" .
        log_success "Archive created: dist/${APP_PACKAGE}-${VERSION}-x86_64.tar.gz"
        return
    }
    
    # Copy result
    cp *.pkg.tar.* "$PROJECT_ROOT/dist/" 2>/dev/null || true
    log_success "Arch package created in dist/"
}

# Create all Linux packages
create_linux() {
    log_info "Creating all Linux packages..."
    create_appimage
    create_deb
    create_rpm
    create_arch
}

# Create Windows installer (placeholder)
create_windows() {
    log_info "Creating Windows installer..."
    
    if command -v powershell &> /dev/null; then
        cd "$PROJECT_ROOT"
        if [ -f "./scripts/update_installer.ps1" ]; then
            powershell -ExecutionPolicy Bypass -File "./scripts/update_installer.ps1"
            log_success "Windows installer created"
        else
            log_warning "update_installer.ps1 not found in scripts/"
        fi
    else
        log_warning "PowerShell not found. Run update_installer.ps1 on Windows."
    fi
}

# Main deployment function
deploy_all() {
    log_info "Creating all deployment packages..."
    prepare_dist
    create_linux
    create_windows
    log_success "All packages created in dist/ directory"
}

# Main script logic
main() {
    load_config
    
    case "${1:-all}" in
        "all")
            check_build
            deploy_all
            ;;
        "windows")
            create_windows
            ;;
        "linux")
            check_build
            create_linux
            ;;
        "appimage")
            check_build
            create_appimage
            ;;
        "deb")
            check_build
            create_deb
            ;;
        "rpm")
            check_build
            create_rpm
            ;;
        "arch")
            check_build
            create_arch
            ;;
        *)
            echo "Usage: $0 [all|windows|linux|appimage|deb|rpm|arch]"
            exit 1
            ;;
    esac
    
    log_success "Deployment completed!"
}

# Only run main if script is executed directly
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi
