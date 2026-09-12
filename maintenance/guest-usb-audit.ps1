$ErrorActionPreference = 'Stop'
Get-PnpDevice -PresentOnly | Where-Object { $_.InstanceId -like 'USB\VID_0451&PID_E022*' } | ForEach-Object {
    $problem = Get-PnpDeviceProperty -InstanceId $_.InstanceId -KeyName 'DEVPKEY_Device_ProblemCode'
    [pscustomobject]@{ Name = $_.FriendlyName; Status = $_.Status; InstanceId = $_.InstanceId; Problem = $problem.Data }
} | ConvertTo-Json -Depth 5
Get-Process | Where-Object { $_.ProcessName -match 'nspire|student|TIConnect' } | Select-Object ProcessName, Id, MainWindowTitle | ConvertTo-Json
