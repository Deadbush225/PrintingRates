# Version management for Printing Rates
# This file is automatically updated by the bump_version script

$version = "0.1.0"
$prerelease = $false

# Update this when creating a new release
Write-Host "Current version: $version"
if ($prerelease) {
    Write-Host "This is a pre-release version"
}
