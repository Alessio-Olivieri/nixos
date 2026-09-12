$ErrorActionPreference = 'Continue'
$ProgressPreference = 'SilentlyContinue'
$devices = Get-PnpDevice -PresentOnly | Where-Object InstanceId -Like 'PCI\VEN_10DE*'
$devices | Select-Object Status,Class,FriendlyName,InstanceId,Problem | ConvertTo-Json
foreach ($device in $devices) {
    Get-PnpDeviceProperty -InstanceId $device.InstanceId -KeyName 'DEVPKEY_Device_ProblemCode','DEVPKEY_Device_HardwareIds','DEVPKEY_Device_DriverInfPath','DEVPKEY_Device_MatchingDeviceId' -ErrorAction SilentlyContinue | Select-Object KeyName,Data | ConvertTo-Json -Depth 4
}
Get-WindowsDriver -Online | Where-Object ProviderName -Like '*NVIDIA*' | Select-Object Driver,OriginalFileName,ProviderName,ClassName,Version | ConvertTo-Json
Select-String -Path 'C:\Windows\INF\oem*.inf' -Pattern 'DEV_24B7' | Select-Object -First 20 Path,Line | ConvertTo-Json
Get-Content 'C:\ProgramData\Looking Glass (IDD)\looking-glass-idd.txt' -TotalCount 45
