$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
$exe = 'C:\ProgramData\PrecisionMaintenance\idd-B7-826\looking-glass-idd-setup.exe'
if ((Get-FileHash -Algorithm SHA256 $exe).Hash -ne '9084EACBFA2C7011AB5B0F866BE669169BA54B11D686D02049D49AD48090799B') { throw 'Installer hash mismatch' }
if ((Get-AuthenticodeSignature $exe).Status -ne 'Valid') { throw 'Installer signature invalid' }
# Keep only one shared-memory server; the original Auto setting is saved.
Stop-Service -Name 'Looking Glass (host)' -ErrorAction SilentlyContinue
Set-Service -Name 'Looking Glass (host)' -StartupType Disabled
$p = Start-Process -FilePath $exe -ArgumentList '/S','/ivshmem' -Wait -PassThru
Write-Output "Installer exit code: $($p.ExitCode)"
Get-PnpDevice -Class Display | Select-Object Status,FriendlyName,InstanceId | ConvertTo-Json
Get-ChildItem 'C:\Program Files\Looking Glass (IDD)' -Filter '*.cat' | ForEach-Object {
    Get-AuthenticodeSignature $_.FullName | Select-Object Path,Status,@{n='Signer';e={$_.SignerCertificate.Subject}}
} | ConvertTo-Json
Get-Service '*Looking*','*LGIdd*' | Select-Object Name,Status,StartType | ConvertTo-Json
if ($p.ExitCode -notin @(0,12,3010)) { throw "IDD install failed: $($p.ExitCode)" }
