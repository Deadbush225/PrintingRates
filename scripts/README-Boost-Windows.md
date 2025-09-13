# Fast Boost Installation for Windows

This directory contains scripts to quickly install Boost libraries on Windows using multiple methods.

## Quick Start

### For Printing Rates (log, log-setup)

```powershell
.\scripts\install-boost-windows.ps1
```

### For other components

```powershell
.\scripts\install-boost-windows.ps1 "program-options filesystem"
```

## Installation Methods

The script tries these methods in order:

1. **vcpkg** (fastest if available)

   - Uses existing vcpkg installation
   - Installs pre-compiled libraries
   - Sets up CMake toolchain automatically

2. **Chocolatey** (medium speed)

   - Uses system package manager
   - Downloads pre-compiled binaries
   - Sets BOOST_ROOT environment variable

3. **Precompiled Binaries** (slowest but most reliable)
   - Downloads official Boost binaries from boostorg
   - For MSVC: Uses pre-compiled .exe installers
   - For MinGW: Downloads source and compiles only needed components

## Usage Options

```powershell
# Install specific components
.\install-boost-windows.ps1 "log log-setup" msvc

# Force a specific method
.\install-boost-windows.ps1 -UseVcpkg
.\install-boost-windows.ps1 -UseChocolatey
.\install-boost-windows.ps1 -UsePrecompiled

# Force reinstall
.\install-boost-windows.ps1 -Force

# Specify architecture
.\install-boost-windows.ps1 -Architecture x86
```

## Parameters

- `Components`: Space-separated list of Boost components (default: "log log-setup")
- `Toolchain`: "auto", "mingw", or "msvc" (default: "auto")
- `Architecture`: "x64" or "x86" (default: "x64")
- `UseVcpkg`: Force vcpkg method
- `UseChocolatey`: Force Chocolatey method
- `UsePrecompiled`: Force precompiled binary method
- `Force`: Force reinstallation even if already installed

## Supported Components

- `log`: Logging framework (required for this project)
- `log-setup`: Logging setup utilities (required for this project)
- `program-options`: Command line parsing
- `filesystem`: File system operations
- `system`: System utilities
- `thread`: Threading support

## CMake Integration

After installation, the script sets these environment variables:

### vcpkg Method

```cmake
set(CMAKE_TOOLCHAIN_FILE "C:/vcpkg/scripts/buildsystems/vcpkg.cmake")
set(VCPKG_TARGET_TRIPLET "x64-windows")
```

### Traditional Method

```cmake
set(BOOST_ROOT "C:/boost_1_87_0")
```

## Requirements

- PowerShell 5.1 or later
- Internet connection for downloads
- For MinGW builds: MinGW-w64 toolchain
- For MSVC builds: Visual Studio with C++ tools
- For 7z extraction: 7-Zip installed

## Troubleshooting

### "vcpkg not found"

Install vcpkg:

```cmd
git clone https://github.com/Microsoft/vcpkg.git C:\vcpkg
C:\vcpkg\bootstrap-vcpkg.bat
```

### "Chocolatey not found"

Install Chocolatey:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
```

### "7-Zip not found"

Install 7-Zip for source archive extraction:

```cmd
choco install 7zip
```

### MinGW Build Fails

Ensure MinGW-w64 is in your PATH:

```cmd
where gcc
```

## Performance Tips

1. **Use vcpkg** for the fastest installation
2. **Install Chocolatey** as a fallback
3. **Keep BOOST_ROOT** between builds to avoid re-downloads
4. **Use specific components** to reduce build time

## Integration with Build System

The scripts are automatically integrated with the CMake build system and will:

1. Deploy only the required Boost DLLs (log and log-setup)
2. Remove unused Boost components during installation pruning
3. Set up proper linking for static/dynamic builds
4. Configure CMake variables correctly

## Project-Specific Configuration

### Printing Rates

- Default components: `log log-setup`
- Uses static linking when possible
- Keeps only logging-related Boost DLLs during installation
- Removes all other Boost libraries to minimize installer size
