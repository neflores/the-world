# Run elevated. Installs the Linux container prerequisite for local Fluxer.
# Never restarts the computer automatically.
$ErrorActionPreference = 'Stop'
$worldSetupLogDir = Join-Path $env:USERPROFILE 'develop\world-setup'
New-Item -ItemType Directory -Path $worldSetupLogDir -Force | Out-Null
Start-Transcript -Path (Join-Path $worldSetupLogDir 'wsl-admin.log') -Append
try {
    $worldPrincipal = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
    if (-not $worldPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        throw 'Run this script from PowerShell as Administrator.'
    }
    & winget install --id Microsoft.WSL --exact --source winget --accept-source-agreements --accept-package-agreements --silent --disable-interactivity
    $worldWslInstallCode = $LASTEXITCODE
    if ($worldWslInstallCode -ne 0) {
        & wsl --version
        if ($LASTEXITCODE -ne 0) { throw "WSL installation failed: $worldWslInstallCode" }
    }
    & dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
    if ($LASTEXITCODE -notin @(0, 3010)) { throw "VirtualMachinePlatform failed: $LASTEXITCODE" }
    & dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
    if ($LASTEXITCODE -notin @(0, 3010)) { throw "WSL feature failed: $LASTEXITCODE" }
    'WSL installation finished. A Windows restart may be required before Docker can start.'
} finally {
    Stop-Transcript
}
