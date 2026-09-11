$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
$thumb = '57476AACDE410C05A63E9FEC8B97938605B9D8F5'
$signature = Get-AuthenticodeSignature 'C:\Program Files\Looking Glass (IDD)\lgidd.cat'
if ($signature.Status -ne 'Valid' -or $signature.SignerCertificate.Thumbprint -ne $thumb) { throw 'Unexpected IDD certificate' }
$store = New-Object System.Security.Cryptography.X509Certificates.X509Store('TrustedPublisher','LocalMachine')
$store.Open('ReadWrite')
$existing = @($store.Certificates | Where-Object Thumbprint -eq $thumb).Count -gt 0
try {
    if (-not $existing) { $store.Add($signature.SignerCertificate) }
    & 'C:\Program Files\Looking Glass (IDD)\LGIddInstall.exe' install
    $result = $LASTEXITCODE
    Write-Output "Driver installer result: $result"
    if ($result -notin @(0,12)) { throw "Driver installer failed: $result" }
} finally {
    if (-not $existing) { $store.Remove($signature.SignerCertificate) }
    $store.Close()
}
Write-Output "Temporary publisher approval removed: $(-not (Test-Path ('Cert:\LocalMachine\TrustedPublisher\' + $thumb)))"
Get-PnpDevice -PresentOnly -Class Display | Select-Object Status,FriendlyName,InstanceId | ConvertTo-Json
Get-Service '*LGIdd*' | Select-Object Name,Status,StartType | ConvertTo-Json
