# PowerShell script to build Inno Setup installer for Printing Rates
# Based on the folder-customizer pattern - reads values from manifest.json

# Skip building install directory - it should already be built by the CI workflow with Qt dependencies deployed

# Read values from manifest.json
$manifest = Get-Content -Raw -Path "./manifest.json" | ConvertFrom-Json
$version = "$($manifest.version)".Trim()
$desktopName = "$($manifest.desktop.desktop_name)".Trim()
$packageId = "$($manifest.desktop.package_id)".Trim()
$description = "$($manifest.description)".Trim()
$executable = "$($manifest.desktop.executable)".Trim()

Write-Host "Building installer version $version for $desktopName (package: $packageId, executable: $executable)" -ForegroundColor Green

# Debug: Show what files are in the install directory
Write-Host "=== Files in install directory before building installer ===" -ForegroundColor Yellow
if (Test-Path "./install") {
    Get-ChildItem -Path "./install" -Recurse | ForEach-Object {
        if (-not $_.PSIsContainer) {
            $sizeInKB = [math]::Round($_.Length / 1KB, 2)
            $relativePath = $_.FullName.Replace((Resolve-Path "./install").Path, "").TrimStart('\')
            Write-Host "  $relativePath - ${sizeInKB} KB"
        }
    }
} else {
    Write-Host "  No install directory found!" -ForegroundColor Red
}

# Check if installer script exists
if (-not (Test-Path "./installer.iss")) {
    Write-Error "Installer script not found: ./installer.iss"
    exit 1
}

# Find Inno Setup compiler
$innoSetupPaths = @(
    "${env:ProgramFiles(x86)}\Inno Setup 6\ISCC.exe",
    "${env:ProgramFiles}\Inno Setup 6\ISCC.exe",
    "${env:ProgramFiles(x86)}\Inno Setup 5\ISCC.exe",
    "${env:ProgramFiles}\Inno Setup 5\ISCC.exe"
)

$isccPath = "ISCC.exe"  # Default to PATH
foreach ($path in $innoSetupPaths) {
    if (Test-Path $path) {
        $isccPath = $path
        break
    }
}

# Build the Windows installer with Inno Setup, passing values as defines
Write-Host "Compiling installer with Inno Setup..." -ForegroundColor Yellow
$arguments = @(
    "/DMyAppVersion=$version",
    "/DMyAppName=`"$desktopName`"",
    "/DMyPackageId=$packageId",
    "/DMyAppDescription=`"$description`"",
    "/DMyAppExecutable=$executable",
    "./installer.iss"
)

try {
    $process = Start-Process $isccPath -ArgumentList $arguments -NoNewWindow -Wait -PassThru
    
    if ($process.ExitCode -ne 0) {
        Write-Error "Installer compilation failed with exit code: $($process.ExitCode)"
        exit 1
    }
    
    Write-Host "Installer compiled successfully!" -ForegroundColor Green
} catch {
    Write-Error "Error running Inno Setup compiler: $_"
    Write-Host "Make sure Inno Setup is installed and ISCC.exe is in your PATH"
    exit 1
}

# Create windows-installer directory and move the installer there
if (!(Test-Path ./windows-installer)) { 
    New-Item -ItemType Directory -Path ./windows-installer | Out-Null 
    Write-Host "Created windows-installer directory" -ForegroundColor Blue
}

# Move the generated installer to windows-installer directory
$installerPattern = "${packageId}Setup-${version}-x64.exe"
$generatedInstallers = Get-ChildItem -Path . -Filter $installerPattern

if ($generatedInstallers.Count -eq 0) {
    # Fallback to any installer files in root
    $generatedInstallers = Get-ChildItem -Path . -Filter "*Setup-*.exe"
}

if ($generatedInstallers.Count -gt 0) {
    $generatedInstallers | ForEach-Object { 
        Write-Host "Moving installer: $($_.Name) -> windows-installer/" -ForegroundColor Blue
        Move-Item $_.FullName ./windows-installer/ -Force 
    }
} else {
    Write-Warning "No installer files found matching pattern: $installerPattern"
}

# Display hash information for the installer (but don't save to separate file)
$installerFiles = Get-ChildItem ./windows-installer -Filter "*Setup-*.exe" | Sort-Object LastWriteTime -Descending

if ($installerFiles.Count -gt 0) {
    Write-Host "`nInstaller Information:" -ForegroundColor Green
    
    $installerFiles | ForEach-Object {
        $sizeInMB = [math]::Round($_.Length / 1MB, 2)
        $hash = Get-FileHash $_.FullName -Algorithm SHA256
        
        Write-Host "  File: $($_.Name)"
        Write-Host "  Size: ${sizeInMB} MB"
        Write-Host "  SHA256: $($hash.Hash)" -ForegroundColor Cyan
        Write-Host ""
    }
} else {
    Write-Warning "No installer files found in ./windows-installer/"
}

Write-Host "`nInno Setup installer build completed!" -ForegroundColor Green
