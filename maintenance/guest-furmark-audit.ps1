$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
Get-CimInstance Win32_VideoController | Select-Object Name,DriverVersion,ConfigManagerErrorCode | ConvertTo-Json
Get-CimInstance Win32_Process | Where-Object Name -Match 'furmark|gpumagick' | Select-Object Name,ProcessId,ExecutablePath | ConvertTo-Json
$roots = @('C:\Program Files\Geeks3D', 'C:\Program Files (x86)\Geeks3D')
foreach ($root in $roots) {
    if (Test-Path $root) {
        Get-ChildItem -LiteralPath $root -Directory | Select-Object FullName | ConvertTo-Json
        Get-ChildItem -LiteralPath $root -File -Recurse | Where-Object { $_.Extension -in '.txt','.log' } | Select-Object FullName,LastWriteTime | ConvertTo-Json
        Get-ChildItem -LiteralPath $root -File -Recurse | Where-Object { $_.Name -like '*log*.txt' -or $_.Extension -eq '.log' } | ForEach-Object {
            $_.FullName
            Select-String -LiteralPath $_.FullName -Pattern 'OpenGL|NVIDIA|QXL|renderer|vendor|version|error|started' | Select-Object -Last 35 | ForEach-Object Line
        }
    }
}
& 'C:\Windows\System32\nvidia-smi.exe' --query-gpu=name,driver_version,utilization.gpu,memory.used --format=csv
Get-ScheduledTaskInfo -TaskName 'Precision Windows Gaming Display' | Select-Object LastRunTime,LastTaskResult | ConvertTo-Json
Get-Content 'C:\ProgramData\PrecisionWindowsDisplay\startup.log'
Get-ChildItem 'C:\ProgramData\PrecisionWindowsDisplay' -File | Select-Object Name,Length | ConvertTo-Json
