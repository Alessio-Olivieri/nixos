$ProgressPreference = 'SilentlyContinue'
Get-ChildItem 'C:\Program Files\Looking Glass (IDD)' -Filter '*.cat' | ForEach-Object {
    $s = Get-AuthenticodeSignature $_.FullName
    $s.SignerCertificate | Select-Object Subject,Issuer,Thumbprint,NotBefore,NotAfter,@{n='SignatureStatus';e={$s.Status}} | ConvertTo-Json
}
Get-ChildItem Cert:\LocalMachine\TrustedPublisher | Select-Object Subject,Thumbprint | ConvertTo-Json
