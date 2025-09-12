# Build script for Printing Rates (Windows)
# Cross-platform build using CMake

param(
    [switch]$Debug,
    [switch]$Clean,
    [switch]$Help
)

function Write-ColorMessage {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

if ($Help) {
    Write-Host "Usage: .\build.ps1 [OPTIONS]"
    Write-Host "Options:"
    Write-Host "  -Debug     Build in Debug mode"
    Write-Host "  -Clean     Clean build directory first"
    Write-Host "  -Help      Show this help"
    exit 0
}

$BuildType = if ($Debug) { "Debug" } else { "Release" }
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent $ScriptDir

Write-ColorMessage "Building Printing Rates..." "Blue"
Write-ColorMessage "Build Type: $BuildType" "Blue"
Write-ColorMessage "Project Root: $ProjectRoot" "Blue"

Set-Location $ProjectRoot

# Clean build directory if requested
if ($Clean) {
    Write-ColorMessage "Cleaning build directory..." "Yellow"
    Remove-Item -Recurse -Force "build" -ErrorAction SilentlyContinue
}

# Create and configure build
Write-ColorMessage "Configuring CMake..." "Blue"
cmake -B build -DCMAKE_BUILD_TYPE="$BuildType"

if ($LASTEXITCODE -ne 0) {
    Write-ColorMessage "CMake configuration failed!" "Red"
    exit 1
}

# Build the project
Write-ColorMessage "Building project..." "Blue"
$ProcessorCount = [Environment]::ProcessorCount
cmake --build build --config "$BuildType" -j $ProcessorCount

if ($LASTEXITCODE -ne 0) {
    Write-ColorMessage "Build failed!" "Red"
    exit 1
}

# Install to local directory
Write-ColorMessage "Installing to .\install..." "Blue"
cmake --build build --target install_local --config "$BuildType"

if ($LASTEXITCODE -ne 0) {
    Write-ColorMessage "Installation failed!" "Red"
    exit 1
}

Write-ColorMessage "Build completed successfully!" "Green"
Write-ColorMessage "Executable installed to: .\install\bin\" "Blue"
Write-ColorMessage "Run '.\install\bin\Printing Rates.exe' to test the application" "Blue"
