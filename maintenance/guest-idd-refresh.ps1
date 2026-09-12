$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
$gpu = Get-PnpDevice -PresentOnly | Where-Object InstanceId -Like 'PCI\VEN_10DE&DEV_24B7*'
if (@($gpu).Count -ne 1 -or $gpu.Status -ne 'OK') { throw 'Expected healthy A4000 before refreshing the display driver' }
$idd = Get-PnpDevice -PresentOnly -Class Display | Where-Object FriendlyName -EQ 'Looking Glass Indirect Display Device'
if (@($idd).Count -ne 1) { throw 'Expected one Looking Glass display driver' }
pnputil /restart-device $idd.InstanceId
if ($LASTEXITCODE -ne 0) { throw "Display device refresh failed: $LASTEXITCODE" }
Start-Sleep -Seconds 8
Get-Content 'C:\ProgramData\Looking Glass (IDD)\looking-glass-idd.txt' -Tail 60
