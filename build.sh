#!/bin/bash
# Build script for Printing Rates
# Cross-platform build using CMake

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

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Parse arguments
BUILD_TYPE="Release"
CLEAN=0

for arg in "$@"; do
    case "$arg" in
        --debug|-d) BUILD_TYPE="Debug" ;;
        --clean|-c) CLEAN=1 ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo "Options:"
            echo "  --debug, -d    Build in Debug mode"
            echo "  --clean, -c    Clean build directory first"
            echo "  --help, -h     Show this help"
            exit 0
            ;;
    esac
done

log_info "Building Printing Rates..."
log_info "Build Type: $BUILD_TYPE"
log_info "Project Root: $PROJECT_ROOT"

cd "$PROJECT_ROOT"

# Clean build directory if requested
if [ "$CLEAN" -eq 1 ]; then
    log_info "Cleaning build directory..."
    rm -rf build
fi

# Create and configure build
log_info "Configuring CMake..."
cmake -B build -DCMAKE_BUILD_TYPE="$BUILD_TYPE"

# Build the project
log_info "Building project..."
cmake --build build --config "$BUILD_TYPE" -j "$(nproc 2>/dev/null || echo 4)"

# Install to local directory
log_info "Installing to ./install..."
cmake --build build --target install_local --config "$BUILD_TYPE"

log_success "Build completed successfully!"
log_info "Executable installed to: ./install/bin/"
log_info "Run './install/bin/Printing Rates' to test the application"
