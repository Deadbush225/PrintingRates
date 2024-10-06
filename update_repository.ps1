Remove-Item -Path ./repository -Recurse

Start-Process -FilePath repogen.exe -ArgumentList ( "-p packages repository")