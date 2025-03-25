Start-Process -FilePath repogen.exe -ArgumentList ( "-p packages --update-new-components -i com.mainprogram repository") -NoNewWindow -Wait
Write-Host "Repository folder updated"
