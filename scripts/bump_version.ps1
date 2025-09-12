# PowerShell script to bump version in manifest.json and other files
param(
    [Parameter(Mandatory=$false)]
    [string]$NewVersion,
    
    [Parameter(Mandatory=$false)]
    [switch]$Major,
    
    [Parameter(Mandatory=$false)]
    [switch]$Minor,
    
    [Parameter(Mandatory=$false)]
    [switch]$Patch,
    
    [Parameter(Mandatory=$false)]
    [switch]$Help
)

if ($Help) {
    Write-Host "Usage: .\bump_version.ps1 [-NewVersion <version>] [-Major|-Minor|-Patch]"
    Write-Host ""
    Write-Host "Examples:"
    Write-Host "  .\bump_version.ps1 -NewVersion '1.2.3'   # Set specific version"
    Write-Host "  .\bump_version.ps1 -Major                # Increment major version"
    Write-Host "  .\bump_version.ps1 -Minor                # Increment minor version"  
    Write-Host "  .\bump_version.ps1 -Patch                # Increment patch version"
    exit 0
}

$ProjectRoot = Split-Path -Parent $PSScriptRoot
$ManifestPath = Join-Path $ProjectRoot "manifest.json"

# Define the file paths to update
$filePaths = @(
    "./config/config.xml",
    "./packages/com.mainprogram/meta/package.xml"
)

if (-not (Test-Path $ManifestPath)) {
    Write-Error "manifest.json not found at: $ManifestPath"
    exit 1
}

# Read current version from manifest.json
$manifest = Get-Content $ManifestPath | ConvertFrom-Json
$currentVersion = $manifest.version

# Also try to read from version.txt for backward compatibility
$versionTxtPath = "./scripts/version.txt"
if (Test-Path $versionTxtPath) {
    $versionTxtVersion = (Get-Content -Path $versionTxtPath).Trim()
    if ($versionTxtVersion -ne $currentVersion) {
        Write-Warning "Version mismatch between manifest.json ($currentVersion) and version.txt ($versionTxtVersion)"
        Write-Host "Using manifest.json version: $currentVersion"
    }
}

Write-Host "Current version: $currentVersion"

if ($NewVersion) {
    $newVer = $NewVersion
} elseif ($Major -or $Minor -or $Patch) {
    $versionParts = $currentVersion.Split('.')
    if ($versionParts.Length -ne 3) {
        Write-Error "Invalid version format. Expected x.y.z"
        exit 1
    }
    
    $major = [int]$versionParts[0]
    $minor = [int]$versionParts[1]
    $patch = [int]$versionParts[2]
    
    if ($Major) {
        $major++
        $minor = 0
        $patch = 0
    } elseif ($Minor) {
        $minor++
        $patch = 0
    } elseif ($Patch) {
        $patch++
    }
    
    $newVer = "$major.$minor.$patch"
} else {
    # If no parameters, just sync existing XML files with manifest version
    $newVer = $currentVersion
}

Write-Host "Target version: $newVer"

if ($newVer -ne $currentVersion) {
    # Confirm the change
    $confirm = Read-Host "Update version from $currentVersion to $newVer? (y/N)"
    if ($confirm -ne 'y' -and $confirm -ne 'Y') {
        Write-Host "Version update cancelled"
        exit 0
    }

    # Update manifest.json
    $manifest.version = $newVer
    $manifest | ConvertTo-Json -Depth 10 | Set-Content $ManifestPath
    Write-Host "Updated manifest.json"

    # Update CMakeLists.txt
    $cmakePath = Join-Path $ProjectRoot "CMakeLists.txt"
    if (Test-Path $cmakePath) {
        $cmakeContent = Get-Content $cmakePath
        $cmakeContent = $cmakeContent -replace "project\(PrintingRates VERSION \d+\.\d+\.\d+\)", "project(PrintingRates VERSION $newVer)"
        $cmakeContent | Set-Content $cmakePath
        Write-Host "Updated CMakeLists.txt"
    }

    # Update version.txt
    if (Test-Path $versionTxtPath) {
        Set-Content -Path $versionTxtPath -Value $newVer
        Write-Host "Updated version.txt"
    }
}

# Update XML files (always sync these with the version)
foreach ($filePath in $filePaths) {
    if (Test-Path $filePath) {
        # Read the file content
        $fileContent = Get-Content -Path $filePath -Raw
        
        # Replace the version between <Version> tags
        $updatedContent = $fileContent -replace "<Version>.*?</Version>", "<Version>$newVer</Version>"
        
        # Write the updated content back to the file
        Set-Content -Path $filePath -Value $updatedContent
        
        Write-Host "Updated $filePath"
    }
}

if ($newVer -ne $currentVersion) {
    Write-Host "Version bumped successfully to $newVer" -ForegroundColor Green
    Write-Host "Don't forget to:"
    Write-Host "1. Update release notes"
    Write-Host "2. Commit the changes"
    Write-Host "3. Create and push a git tag: git tag v$newVer && git push origin v$newVer"
} else {
    Write-Host "XML files synchronized with current version: $newVer" -ForegroundColor Green
}