$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
Get-PnpDevice | Where-Object { $_.InstanceId -like 'USB\VID_0451&PID_E022*' } | ForEach-Object {
    $device = $_
    $keys = 'DEVPKEY_Device_IsPresent','DEVPKEY_Device_DriverInfPath','DEVPKEY_Device_Service','DEVPKEY_Device_ProblemCode'
    $properties = @{}
    foreach ($key in $keys) { $properties[$key] = (Get-PnpDeviceProperty -InstanceId $device.InstanceId -KeyName $key -ErrorAction SilentlyContinue).Data }
    [pscustomobject]@{ Name=$device.FriendlyName; Status=$device.Status; Id=$device.InstanceId; Properties=$properties }
} | ConvertTo-Json -Depth 5
Get-CimInstance Win32_Service | Where-Object { $_.Name -match 'nspire|ticonnect|tiled|ticonn|tiserver' -or $_.DisplayName -match 'Texas Instruments|TI-Nspire|TI Connect' } | Select-Object Name, DisplayName, State, StartMode, PathName | ConvertTo-Json
Get-Process | Where-Object { $_.ProcessName -match 'nspire|student|TIConnect' } | Select-Object ProcessName, Id, SessionId, Path, MainWindowTitle | ConvertTo-Json
