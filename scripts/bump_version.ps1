# Define the file path and the current version
$filePaths = @(
    "./config/config.xml",
    "./packages/com.mainprogram/meta/package.xml"
)

$currentVersion = (Get-Content -Path "./scripts/version.txt").Trim()

foreach ($filePath in $filePaths) {

    # Read the file content
    $fileContent = Get-Content -Path $filePath -Raw
    
    # Replace the version between <Version> tags
    $updatedContent = $fileContent -replace "<Version>.*?</Version>", "<Version>$currentVersion</Version>"
}
    
    # Write the updated content back to the file
    Set-Content -Path $filePath -Value $updatedContent
    
    Write-Host "Version updated to $currentVersion"