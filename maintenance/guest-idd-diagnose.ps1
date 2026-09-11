$ProgressPreference = 'SilentlyContinue'
Get-Content 'C:\Windows\INF\setupapi.dev.log' -Tail 180
Get-ChildItem 'C:\ProgramData\Looking Glass (IDD)','C:\Windows\System32\config\systemprofile\AppData\Roaming\Looking Glass (IDD)' -Recurse -ErrorAction SilentlyContinue | Select-Object FullName,Length | ConvertTo-Json
Get-CimInstance Win32_PnPEntity | Where-Object { $_.Name -match 'IVSHMEM|Looking Glass|LGIdd' } | Select-Object Name,Status,ConfigManagerErrorCode,PNPDeviceID | ConvertTo-Json
