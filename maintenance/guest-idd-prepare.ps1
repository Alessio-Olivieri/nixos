$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
$dir = 'C:\ProgramData\PrecisionMaintenance'
New-Item -ItemType Directory -Force -Path $dir | Out-Null
$zip = Join-Path $dir 'looking-glass-idd-B7-826.zip'
Invoke-WebRequest -UseBasicParsing -Uri 'https://looking-glass.io/artifact/B7-826-236efcb1/idd' -OutFile $zip
$hash = (Get-FileHash -Algorithm SHA256 $zip).Hash.ToLowerInvariant()
if ($hash -ne '34daa6ddb403c1f503fb2ace94360159818fda1795fc5c2be5cec1f4391d5d57') { throw 'Looking Glass archive hash mismatch; not executing' }
Expand-Archive -Path $zip -DestinationPath (Join-Path $dir 'idd-B7-826') -Force
$exe = Join-Path $dir 'idd-B7-826\looking-glass-idd-setup.exe'
Get-AuthenticodeSignature $exe | Select-Object Status,StatusMessage,@{n='Signer';e={$_.SignerCertificate.Subject}} | ConvertTo-Json
Get-CimInstance Win32_Service -Filter "Name='Looking Glass (host)'" | Select-Object Name,State,StartMode | ConvertTo-Json | Set-Content (Join-Path $dir 'original-host-service.json')
Get-Content (Join-Path $dir 'original-host-service.json')
Get-FileHash -Algorithm SHA256 $exe | ConvertTo-Json
