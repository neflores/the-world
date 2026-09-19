# Dot-source this file to refresh tools in an already open PowerShell:
# . .\tools\dev-shell.ps1
$env:FLUTTER_ROOT = Join-Path $env:USERPROFILE 'develop\flutter'
$env:JAVA_HOME = Join-Path $env:USERPROFILE 'develop\jdk-21.0.12.1+1'
$env:ANDROID_HOME = Join-Path $env:LOCALAPPDATA 'Android\Sdk'
$worldToolPaths = @(
    (Join-Path $env:FLUTTER_ROOT 'bin'),
    (Join-Path $env:USERPROFILE 'develop\node-v24.21.0-win-x64'),
    (Join-Path $env:APPDATA 'npm'),
    (Join-Path $env:JAVA_HOME 'bin'),
    (Join-Path $env:ANDROID_HOME 'platform-tools'),
    (Join-Path $env:ANDROID_HOME 'cmdline-tools\latest\bin'),
    (Join-Path $env:LOCALAPPDATA 'Programs\DockerDesktop\resources\bin')
)
foreach ($worldToolPath in $worldToolPaths) {
    if ((Test-Path -LiteralPath $worldToolPath) -and (($env:Path -split ';') -notcontains $worldToolPath)) {
        $env:Path = $worldToolPath + ';' + $env:Path
    }
}
