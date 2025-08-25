Start-Process -FilePath binarycreator.exe -ArgumentList ( "-n -c config/config.xml -p packages .\PrintingRatesSetup-x64.exe") -NoNewWindow -Wait

Get-FileHash "./PrintingRatesSetup-x64.exe" | Format-List
