Start-Process -FilePath repogen.exe -ArgumentList ( "-p packages --update-new-components -i com.vendor.root repository")
Write-Host "Repository folder updated"
