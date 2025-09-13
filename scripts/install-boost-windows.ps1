# Fast Boost installation for Windows using vcpkg or precompiled binaries
# Usage: ./install-boost-windows.ps1 [components] [toolchain]
# Examples: 
#   ./install-boost-windows.ps1 log mingw
#   ./install-boost-windows.ps1 "log log-setup" msvc

param(
    [string]$Components = "log log-setup",
    [string]$Toolchain = "auto",
    [string]$Architecture = "x64",
    [switch]$UseVcpkg,
    [switch]$UseChocolatey,
    [switch]$UsePrecompiled,
    [switch]$Force
)

$ErrorActionPreference = "Stop"

# Colors for output
function Write-Info { param($msg) Write-Host "INFO: $msg" -ForegroundColor Blue }
function Write-Success { param($msg) Write-Host "SUCCESS: $msg" -ForegroundColor Green }
function Write-Warning { param($msg) Write-Host "WARNING: $msg" -ForegroundColor Yellow }
function Write-Error { param($msg) Write-Host "ERROR: $msg" -ForegroundColor Red }

Write-Info "Fast Boost installer for Windows - $($MyInvocation.MyCommand.Name)"
Write-Info "Components: $Components | Toolchain: $Toolchain | Architecture: $Architecture"

# Auto-detect toolchain if not specified
if ($Toolchain -eq "auto") {
    if (Get-Command "gcc.exe" -ErrorAction SilentlyContinue) {
        $Toolchain = "mingw"
        Write-Info "Auto-detected MinGW toolchain"
    } elseif (Get-Command "cl.exe" -ErrorAction SilentlyContinue) {
        $Toolchain = "msvc"
        Write-Info "Auto-detected MSVC toolchain"
    } else {
        Write-Warning "Cannot auto-detect toolchain. Using MinGW as fallback."
        $Toolchain = "mingw"
    }
}

# Method 1: Try vcpkg (fastest if available)
function Install-VcpkgBoost {
    Write-Info "Attempting vcpkg installation..."
    
    # Check if vcpkg is available
    $vcpkgPath = $null
    $vcpkgCandidates = @(
        "$env:VCPKG_ROOT\vcpkg.exe",
        "C:\vcpkg\vcpkg.exe",
        "C:\tools\vcpkg\vcpkg.exe",
        "vcpkg.exe"  # In PATH
    )
    
    foreach ($candidate in $vcpkgCandidates) {
        if (Test-Path $candidate -PathType Leaf -ErrorAction SilentlyContinue) {
            $vcpkgPath = $candidate
            break
        }
    }
    
    if (-not $vcpkgPath) {
        try {
            $vcpkgPath = (Get-Command "vcpkg.exe" -ErrorAction Stop).Source
        } catch {
            Write-Warning "vcpkg not found in standard locations or PATH"
            return $false
        }
    }
    
    Write-Info "Found vcpkg at: $vcpkgPath"
    
    # Map components to vcpkg package names
    $componentMap = @{
        "program-options" = "boost-program-options"
        "log" = "boost-log"
        "log-setup" = "boost-log"
        "filesystem" = "boost-filesystem"
        "system" = "boost-system"
        "thread" = "boost-thread"
    }
    
    $vcpkgPackages = @()
    $Components.Split(" ") | ForEach-Object {
        $component = $_.Trim()
        if ($componentMap.ContainsKey($component)) {
            $vcpkgPackages += $componentMap[$component]
        } else {
            $vcpkgPackages += "boost-$component"
        }
    }
    
    # Remove duplicates
    $vcpkgPackages = $vcpkgPackages | Select-Object -Unique
    
    # Determine triplet based on toolchain
    $triplet = switch ($Toolchain) {
        "msvc" { "$Architecture-windows" }
        "mingw" { "$Architecture-mingw-dynamic" }
        default { "$Architecture-windows" }
    }
    
    Write-Info "Installing packages: $($vcpkgPackages -join ', ') for triplet: $triplet"
    
    try {
        foreach ($package in $vcpkgPackages) {
            & $vcpkgPath install "${package}:${triplet}"
            if ($LASTEXITCODE -ne 0) {
                throw "vcpkg install failed for $package"
            }
        }
        
        # Set environment variables for CMake to find vcpkg
        $vcpkgRoot = Split-Path -Parent $vcpkgPath
        $env:CMAKE_TOOLCHAIN_FILE = "$vcpkgRoot\scripts\buildsystems\vcpkg.cmake"
        $env:VCPKG_TARGET_TRIPLET = $triplet
        
        Write-Success "vcpkg installation completed successfully"
        Write-Info "CMAKE_TOOLCHAIN_FILE set to: $env:CMAKE_TOOLCHAIN_FILE"
        Write-Info "VCPKG_TARGET_TRIPLET set to: $env:VCPKG_TARGET_TRIPLET"
        return $true
        
    } catch {
        Write-Warning "vcpkg installation failed: $_"
        return $false
    }
}

# Method 2: Try Chocolatey (medium speed)
function Install-ChocolateyBoost {
    Write-Info "Attempting Chocolatey installation..."
    
    try {
        $chocoPath = (Get-Command "choco.exe" -ErrorAction Stop).Source
    } catch {
        Write-Warning "Chocolatey not found"
        return $false
    }
    
    Write-Info "Found Chocolatey at: $chocoPath"
    
    try {
        # Chocolatey has boost packages
        & choco install boost-msvc-14.3 -y --force:$Force
        if ($LASTEXITCODE -ne 0) {
            throw "Chocolatey install failed"
        }
        
        # Try to detect Boost location
        $boostPaths = @(
            "C:\local\boost_*",
            "C:\tools\boost\*",
            "C:\ProgramData\chocolatey\lib\boost*\tools\*"
        )
        
        $boostPath = $null
        foreach ($pattern in $boostPaths) {
            $matches = Get-ChildItem $pattern -Directory -ErrorAction SilentlyContinue | Sort-Object Name -Descending | Select-Object -First 1
            if ($matches) {
                $boostPath = $matches.FullName
                break
            }
        }
        
        if ($boostPath) {
            $env:BOOST_ROOT = $boostPath
            Write-Success "Chocolatey installation completed successfully"
            Write-Info "BOOST_ROOT set to: $env:BOOST_ROOT"
            return $true
        } else {
            Write-Warning "Boost installed via Chocolatey but path not found"
            return $false
        }
        
    } catch {
        Write-Warning "Chocolatey installation failed: $_"
        return $false
    }
}

# Method 3: Download precompiled binaries (slowest but most reliable)
function Install-PrecompiledBoost {
    Write-Info "Attempting precompiled binary installation..."
    
    $boostVersion = "1.87.0"
    $boostVersionUnder = $boostVersion.Replace(".", "_")
    $installDir = "C:\boost_$boostVersionUnder"
    
    if ((Test-Path $installDir) -and -not $Force) {
        Write-Info "Boost already installed at $installDir (use -Force to reinstall)"
        $env:BOOST_ROOT = $installDir
        Write-Success "Using existing Boost installation"
        Write-Info "BOOST_ROOT set to: $env:BOOST_ROOT"
        return $true
    }
    
    # Determine download URL based on toolchain
    $downloadUrl = switch ($Toolchain) {
        "msvc" { 
            if ($Architecture -eq "x64") {
                "https://boostorg.jfrog.io/artifactory/main/release/$boostVersion/binaries/boost_$boostVersionUnder-msvc-14.3-64.exe"
            } else {
                "https://boostorg.jfrog.io/artifactory/main/release/$boostVersion/binaries/boost_$boostVersionUnder-msvc-14.3-32.exe"
            }
        }
        "mingw" { 
            "https://boostorg.jfrog.io/artifactory/main/release/$boostVersion/source/boost_$boostVersionUnder.7z"
        }
        default { 
            "https://boostorg.jfrog.io/artifactory/main/release/$boostVersion/source/boost_$boostVersionUnder.7z"
        }
    }
    
    $downloadFile = "$env:TEMP\$(Split-Path -Leaf $downloadUrl)"
    
    Write-Info "Downloading Boost $boostVersion from: $downloadUrl"
    Write-Info "Download file: $downloadFile"
    
    try {
        # Download with progress
        $webClient = New-Object System.Net.WebClient
        $webClient.DownloadFile($downloadUrl, $downloadFile)
        
        Write-Success "Download completed: $(((Get-Item $downloadFile).Length / 1MB).ToString('F1')) MB"
        
        # Extract based on file type
        if ($downloadFile -match "\.exe$") {
            # Self-extracting exe
            Write-Info "Extracting self-extracting archive..."
            & $downloadFile /S /D=$installDir
            if ($LASTEXITCODE -ne 0) {
                throw "Extraction failed"
            }
        } elseif ($downloadFile -match "\.7z$") {
            # 7zip archive - need to build from source for MinGW
            Write-Info "Extracting 7z archive..."
            
            # Check for 7zip
            $7zipPath = $null
            $7zipCandidates = @(
                "C:\Program Files\7-Zip\7z.exe",
                "C:\Program Files (x86)\7-Zip\7z.exe",
                "${env:ProgramFiles}\7-Zip\7z.exe",
                "7z.exe"
            )
            
            foreach ($candidate in $7zipCandidates) {
                if (Test-Path $candidate -PathType Leaf -ErrorAction SilentlyContinue) {
                    $7zipPath = $candidate
                    break
                }
            }
            
            if (-not $7zipPath) {
                try {
                    $7zipPath = (Get-Command "7z.exe" -ErrorAction Stop).Source
                } catch {
                    throw "7-Zip not found. Please install 7-Zip to extract Boost source."
                }
            }
            
            & $7zipPath x $downloadFile "-o$((Split-Path -Parent $installDir))" -y
            if ($LASTEXITCODE -ne 0) {
                throw "7z extraction failed"
            }
            
            # Rename extracted directory
            $extractedDir = "$((Split-Path -Parent $installDir))\boost_$boostVersionUnder"
            if (Test-Path $extractedDir) {
                if (Test-Path $installDir) {
                    Remove-Item $installDir -Recurse -Force
                }
                Rename-Item $extractedDir $installDir
            }
            
            # For MinGW, we need to build the libraries
            Write-Info "Building Boost libraries for MinGW..."
            Push-Location $installDir
            try {
                & .\bootstrap.bat mingw
                if ($LASTEXITCODE -ne 0) {
                    throw "Bootstrap failed"
                }
                
                $componentArgs = @()
                $Components.Split(" ") | ForEach-Object {
                    $component = $_.Trim()
                    if ($component -and $component -ne "log-setup") {  # log-setup is built with log
                        $componentArgs += "--with-$component"
                    }
                }
                
                & .\b2.exe toolset=gcc $componentArgs variant=release link=shared threading=multi --stagedir=stage
                if ($LASTEXITCODE -ne 0) {
                    throw "Build failed"
                }
                
                Write-Success "Boost libraries built successfully"
            } finally {
                Pop-Location
            }
        }
        
        $env:BOOST_ROOT = $installDir
        Write-Success "Precompiled installation completed successfully"
        Write-Info "BOOST_ROOT set to: $env:BOOST_ROOT"
        return $true
        
    } catch {
        Write-Warning "Precompiled installation failed: $_"
        return $false
    } finally {
        # Clean up download file
        if (Test-Path $downloadFile) {
            Remove-Item $downloadFile -Force -ErrorAction SilentlyContinue
        }
    }
}

# Main installation logic
function Install-Boost {
    Write-Info "Starting Boost installation with preferred methods..."
    
    # Try methods in order of preference unless specific method requested
    $methods = @()
    if ($UseVcpkg) { $methods += "vcpkg" }
    elseif ($UseChocolatey) { $methods += "chocolatey" }
    elseif ($UsePrecompiled) { $methods += "precompiled" }
    else {
        # Auto mode - try all methods
        $methods = @("vcpkg", "chocolatey", "precompiled")
    }
    
    foreach ($method in $methods) {
        Write-Info "Trying method: $method"
        
        $success = switch ($method) {
            "vcpkg" { Install-VcpkgBoost }
            "chocolatey" { Install-ChocolateyBoost }
            "precompiled" { Install-PrecompiledBoost }
            default { $false }
        }
        
        if ($success) {
            Write-Success "Boost installation completed using method: $method"
            
            # Create a simple CMake find script hint
            $cmakeHint = @"
# Boost installation completed via $method
# Add these to your CMake configuration:
# set(CMAKE_TOOLCHAIN_FILE `"$env:CMAKE_TOOLCHAIN_FILE`")
# set(BOOST_ROOT `"$env:BOOST_ROOT`")
# set(VCPKG_TARGET_TRIPLET `"$env:VCPKG_TARGET_TRIPLET`")
"@
            Write-Info "CMake hints:"
            Write-Host $cmakeHint -ForegroundColor Cyan
            
            return
        }
    }
    
    Write-Error "All installation methods failed. Please install Boost manually."
    exit 1
}

# Verify installation
function Verify-Installation {
    Write-Info "Verifying Boost installation..."
    
    $boostFound = $false
    
    # Check vcpkg
    if ($env:CMAKE_TOOLCHAIN_FILE -and (Test-Path $env:CMAKE_TOOLCHAIN_FILE)) {
        Write-Success "vcpkg toolchain file found: $env:CMAKE_TOOLCHAIN_FILE"
        $boostFound = $true
    }
    
    # Check BOOST_ROOT
    if ($env:BOOST_ROOT -and (Test-Path $env:BOOST_ROOT)) {
        Write-Success "BOOST_ROOT found: $env:BOOST_ROOT"
        
        # Look for specific component libraries
        $libDir = "$env:BOOST_ROOT\lib*", "$env:BOOST_ROOT\stage\lib"
        foreach ($dir in $libDir) {
            $libFiles = Get-ChildItem $dir -Filter "*boost_log*" -ErrorAction SilentlyContinue
            if ($libFiles) {
                Write-Success "Found Boost libraries in: $dir"
                Write-Info "Sample files: $($libFiles.Name[0..2] -join ', ')"
                $boostFound = $true
                break
            }
        }
    }
    
    if (-not $boostFound) {
        Write-Warning "Boost installation verification failed"
        return $false
    }
    
    Write-Success "Boost installation verification completed successfully!"
    return $true
}

# Run installation
try {
    Install-Boost
    Verify-Installation
    
    Write-Success "Boost installation script completed successfully!"
    Write-Info "You can now build your project with CMake."
    Write-Info "Note: You may need to restart your terminal/IDE for environment variables to take effect."
    
} catch {
    Write-Error "Installation script failed: $_"
    exit 1
}
