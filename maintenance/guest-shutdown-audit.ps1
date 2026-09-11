$ProgressPreference = 'SilentlyContinue'
Get-WinEvent -FilterHashtable @{LogName='System'; Id=1074,6006,6008,41; StartTime=(Get-Date).AddHours(-3)} -ErrorAction SilentlyContinue | Select-Object -First 12 TimeCreated,Id,ProviderName,Message | ConvertTo-Json
Get-PnpDevice -PresentOnly -Class Display | Select-Object Status,FriendlyName | ConvertTo-Json
Get-CimInstance Win32_VideoController | Select-Object Name,DriverVersion,ConfigManagerErrorCode | ConvertTo-Json
Get-Service 'LGIddHelper','Looking Glass (host)' | Select-Object Name,Status,StartType | ConvertTo-Json
