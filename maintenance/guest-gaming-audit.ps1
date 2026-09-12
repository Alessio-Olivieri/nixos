$ErrorActionPreference = 'Continue'
$ProgressPreference = 'SilentlyContinue'
Get-CimInstance Win32_VideoController | Select-Object Name,PNPDeviceID,DriverVersion,Status,ConfigManagerErrorCode,CurrentHorizontalResolution,CurrentVerticalResolution | ConvertTo-Json
Get-PnpDevice -PresentOnly -Class Display | Select-Object Status,FriendlyName,InstanceId | ConvertTo-Json
Get-Service '*LGIdd*','*Looking*' | Select-Object Name,Status,StartType | ConvertTo-Json
Get-CimInstance Win32_Process | Where-Object {$_.Name -match 'LGIdd|looking-glass'} | Select-Object Name,ProcessId,SessionId | ConvertTo-Json
foreach ($name in @('looking-glass-idd.txt','looking-glass-idd-service.txt','looking-glass-idd-helper.txt')) {
    $path = Join-Path 'C:\ProgramData\Looking Glass (IDD)' $name
    if (Test-Path $path) { $path; Get-Content $path -Tail 30 }
}
& 'C:\Windows\System32\nvidia-smi.exe' --query-gpu=name,driver_version,pci.device_id,memory.used --format=csv
