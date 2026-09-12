$ErrorActionPreference = 'Continue'
$ProgressPreference = 'SilentlyContinue'
Get-CimInstance Win32_VideoController | Select-Object Name,DriverVersion,Status,ConfigManagerErrorCode,CurrentHorizontalResolution,CurrentVerticalResolution | ConvertTo-Json
Get-PnpDevice -Class Monitor -PresentOnly | Select-Object FriendlyName,Status,InstanceId | ConvertTo-Json
Get-CimInstance -Namespace root\wmi -ClassName WmiMonitorID | ForEach-Object {
    [pscustomobject]@{
        InstanceName=$_.InstanceName; Active=$_.Active
        Manufacturer=([string]::new([char[]]($_.ManufacturerName | Where-Object { $_ -ne 0 })))
        Name=([string]::new([char[]]($_.UserFriendlyName | Where-Object { $_ -ne 0 })))
    }
} | ConvertTo-Json
Get-CimInstance -Namespace root\wmi -ClassName WmiMonitorConnectionParams | Select-Object InstanceName,Active,VideoOutputTechnology | ConvertTo-Json
Get-ItemProperty 'HKLM:\SOFTWARE\LookingGlass\IDD' | Select-Object ExclusiveMonitor | ConvertTo-Json
