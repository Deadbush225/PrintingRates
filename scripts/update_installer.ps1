# PowerShell script to create/update Windows installer
param(
    [switch]$Help
)

if ($Help) {
    Write-Host "Usage: .\update_installer.ps1"
    Write-Host ""
    Write-Host "This script creates a Windows installer for Printing Rates"
    Write-Host "Requires: Qt Installer Framework (qtifw)"
    exit 0
}

$ProjectRoot = Split-Path -Parent $PSScriptRoot
$InstallDir = Join-Path $ProjectRoot "install"
$PackagesDir = Join-Path $ProjectRoot "packages"
$WindowsInstallerDir = Join-Path $ProjectRoot "windows-installer"

Write-Host "Creating Windows installer..." -ForegroundColor Blue

# Check if install directory exists
if (-not (Test-Path $InstallDir)) {
    Write-Error "Install directory not found: $InstallDir"
    Write-Host "Please run 'cmake --build build --target install_local' first"
    exit 1
}

# Create output directory
if (-not (Test-Path $WindowsInstallerDir)) {
    New-Item -ItemType Directory -Path $WindowsInstallerDir | Out-Null
}

# Check for Qt Installer Framework
$binaryCreator = Get-Command "binarycreator.exe" -ErrorAction SilentlyContinue
if (-not $binaryCreator) {
    $qtIfwPath = "${env:ProgramFiles}\Qt\Tools\QtInstallerFramework\*\bin\binarycreator.exe"
    $binaryCreatorCandidates = Get-ChildItem $qtIfwPath -ErrorAction SilentlyContinue | Sort-Object Name -Descending
    if ($binaryCreatorCandidates) {
        $binaryCreator = $binaryCreatorCandidates[0]
        Write-Host "Found Qt IFW: $($binaryCreator.FullName)"
    } else {
        Write-Warning "Qt Installer Framework not found. Trying direct command..."
        # Fall back to trying the command directly
        $binaryCreator = "binarycreator.exe"
    }
} else {
    Write-Host "Using binarycreator: $($binaryCreator.Source)"
}

# Copy install files to package data directory
$packageDataDir = Join-Path $PackagesDir "com.mainprogram" "data"
if (Test-Path $packageDataDir) {
    Remove-Item -Recurse -Force $packageDataDir
}
New-Item -ItemType Directory -Path $packageDataDir -Force | Out-Null

# Copy installation files
Write-Host "Copying application files..."
Copy-Item -Recurse -Path "$InstallDir\*" -Destination $packageDataDir

# Read version for installer filename
$manifestPath = Join-Path $ProjectRoot "manifest.json"
if (Test-Path $manifestPath) {
    $manifest = Get-Content $manifestPath | ConvertFrom-Json
    $version = $manifest.version
} else {
    $version = "unknown"
}

# Create installer
$installerName = "PrintingRatesSetup-x64.exe"
$installerPath = Join-Path $WindowsInstallerDir $installerName

Write-Host "Building installer: $installerName"

$configPath = Join-Path $ProjectRoot "config" "config.xml"
$packagesPath = $PackagesDir

try {
    # Try to run binarycreator
    if ($binaryCreator.GetType().Name -eq "ApplicationInfo") {
        $binaryCreatorExe = $binaryCreator.Source
    } elseif ($binaryCreator.GetType().Name -eq "FileInfo") {
        $binaryCreatorExe = $binaryCreator.FullName
    } else {
        $binaryCreatorExe = $binaryCreator
    }

    # Use the original command structure but with better error handling
    Start-Process -FilePath $binaryCreatorExe -ArgumentList @(
        "--offline-only",
        "-c", $configPath,
        "-p", $packagesPath,
        $installerPath
    ) -NoNewWindow -Wait -PassThru | ForEach-Object {
        if ($_.ExitCode -ne 0) {
            throw "binarycreator failed with exit code: $($_.ExitCode)"
        }
    }
    
    if (Test-Path $installerPath) {
        Write-Host "Installer created successfully: $installerPath" -ForegroundColor Green
        
        # Show file size
        $fileInfo = Get-Item $installerPath
        $sizeInMB = [math]::Round($fileInfo.Length / 1MB, 2)
        Write-Host "Installer size: ${sizeInMB} MB"
        
        # Calculate and display hash
        $hash = Get-FileHash $installerPath -Algorithm SHA256
        Write-Host "SHA256: $($hash.Hash)"
        
        # Save hash to file for release notes
        $hashFile = Join-Path $WindowsInstallerDir "installer-hash.txt"
        "$installerName`: $($hash.Hash)" | Set-Content $hashFile
        Write-Host "Hash saved to: $hashFile"
        
        # Also display in the original format for backward compatibility
        Write-Host "`nHash details:"
        Get-FileHash $installerPath | Format-List
        
    } else {
        Write-Error "Installer file was not created: $installerPath"
        exit 1
    }
} catch {
    Write-Error "Error creating installer: $_"
    Write-Host "Falling back to original command structure..."
    
    # Fallback to original command
    try {
        Start-Process -FilePath "binarycreator.exe" -ArgumentList @(
            "-n", "-c", "config/config.xml", "-p", "packages", ".\PrintingRatesSetup-x64.exe"
        ) -NoNewWindow -Wait
        
        if (Test-Path ".\PrintingRatesSetup-x64.exe") {
            Get-FileHash ".\PrintingRatesSetup-x64.exe" | Format-List
            Write-Host "Installer created successfully (fallback method)" -ForegroundColor Green
        }
    } catch {
        Write-Error "Fallback method also failed: $_"
        exit 1
    }
}

Write-Host "Windows installer creation completed!" -ForegroundColor Green
