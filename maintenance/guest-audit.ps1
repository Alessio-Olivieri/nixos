$ErrorActionPreference = 'Continue'
Get-CimInstance Win32_VideoController | Select-Object Name,PNPDeviceID,DriverVersion,Status | ConvertTo-Json
Get-Service | Where-Object {$_.Name -match 'qemu|spice|looking'} | Select-Object Name,Status | ConvertTo-Json
Get-ChildItem 'C:\Program Files','C:\Program Files (x86)' -ErrorAction SilentlyContinue | Where-Object {$_.Name -match 'Looking|NVIDIA|Steam'} | Select-Object FullName | ConvertTo-Json
Get-Tpm | Select-Object TpmPresent,TpmReady,TpmEnabled,TpmActivated | ConvertTo-Json
manage-bde -status C:
pnputil /enum-drivers /class Display
