
Start-Process -FilePath "cmake" -ArgumentList "--build .\build\Desktop_Qt_6_7_2_MinGW_64_bit-Debug\" -Wait

Start-Process -FilePath '.\build\Desktop_Qt_6_7_2_MinGW_64_bit-Debug\Printing Rates.exe' -NoNewWindow -Wait

# Start-Sleep -Seconds 10000
