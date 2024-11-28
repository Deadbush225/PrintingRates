Start-Process -FilePath binarycreator.exe -ArgumentList ( "-n -c config/config.xml -p packages .\PrintingRatesSetup-x64.exe")

Get-FileHash "./PrintingRatesSetup-x64.exe" | Format-List
