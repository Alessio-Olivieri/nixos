$ErrorActionPreference = 'Continue'
Get-Item 'C:\Program Files\Looking Glass (host)\looking-glass-host.exe' | Select-Object -ExpandProperty VersionInfo | Select-Object FileVersion,ProductVersion | ConvertTo-Json
Get-Service 'Looking Glass*' | Select-Object Name,Status | ConvertTo-Json
Get-ChildItem 'C:\ProgramData\Looking Glass*','C:\Program Files\Looking Glass (host)' -Filter '*.log' -Recurse -ErrorAction SilentlyContinue | ForEach-Object { $_.FullName; Get-Content $_.FullName -Tail 35 }
Get-CimInstance Win32_Process | Where-Object {$_.Name -like '*looking*'} | Select-Object Name,ProcessId,SessionId | ConvertTo-Json
