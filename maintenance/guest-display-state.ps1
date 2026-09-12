$ErrorActionPreference = 'Continue'
$ProgressPreference = 'SilentlyContinue'
Get-ItemProperty 'HKLM:\SOFTWARE\LookingGlass\IDD' | Select-Object ExclusiveMonitor, NoGPU, DefaultRefresh, ForceIndirectCopy, ForceFullDirectCopy | ConvertTo-Json
Get-Process -Name explorer,LogonUI,LGIddHelper -ErrorAction SilentlyContinue | Select-Object ProcessName,Id,SessionId | ConvertTo-Json
Get-ScheduledTask -TaskName 'Precision Windows Gaming Display' -ErrorAction SilentlyContinue | Select-Object TaskName,State | ConvertTo-Json
Get-ScheduledTaskInfo -TaskName 'Precision Windows Gaming Display' -ErrorAction SilentlyContinue | Select-Object LastRunTime,LastTaskResult | ConvertTo-Json
foreach ($name in @('startup.log','displays.txt','errors.txt')) {
    $path = Join-Path 'C:\ProgramData\PrecisionWindowsDisplay' $name
    if (Test-Path $path) { $path; Get-Content $path -Tail 35 }
}
Get-ChildItem 'C:\ProgramData\Looking Glass (IDD)' -Filter '*.txt' | Select-Object Name,LastWriteTime,Length | ConvertTo-Json
Get-ChildItem 'C:\ProgramData\Looking Glass (IDD)' -Filter '*helper*' | Where-Object { -not $_.PSIsContainer } | ForEach-Object { $_.Name; Get-Content $_.FullName -Tail 60 }
