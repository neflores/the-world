$ErrorActionPreference = 'Stop'
$key = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock'
New-Item -Path $key -Force | Out-Null
New-ItemProperty -Path $key -Name AllowDevelopmentWithoutDevLicense -PropertyType DWord -Value 1 -Force | Out-Null
New-ItemProperty -Path $key -Name AllowAllTrustedApps -PropertyType DWord -Value 1 -Force | Out-Null
Write-Output 'Windows Developer Mode enabled.'
