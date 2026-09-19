param(
    [ValidateSet('start', 'stop', 'status', 'logs', 'pull', 'check')]
    [string]$Action = 'status'
)
$ErrorActionPreference = 'Stop'
$worldFluxerDir = Join-Path $env:USERPROFILE 'develop\fluxer-local'
$worldDockerCandidates = @(
    (Join-Path $env:LOCALAPPDATA 'Programs\DockerDesktop\resources\bin'),
    'C:\Program Files\Docker\Docker\resources\bin'
)
foreach ($worldDockerPath in $worldDockerCandidates) {
    if (Test-Path -LiteralPath (Join-Path $worldDockerPath 'docker.exe')) {
        $env:Path = $worldDockerPath + ';' + $env:Path
        break
    }
}
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    throw 'Docker CLI is unavailable. Finish installing Docker Desktop first.'
}
$worldComposeArgs = @('compose', '-p', 'world-fluxer',
    '-f', 'docker-compose.yml', '-f', 'docker-compose.proxy.yml', '-f', 'docker-compose.local.yml')
Push-Location -LiteralPath $worldFluxerDir
try {
    switch ($Action) {
        'start' { & docker @worldComposeArgs up -d }
        'stop' { & docker @worldComposeArgs stop }
        'status' { & docker @worldComposeArgs ps }
        'logs' { & docker @worldComposeArgs logs --tail 80 api gateway edge }
        'pull' { & docker @worldComposeArgs pull }
        'check' { & docker @worldComposeArgs config --quiet }
    }
    if ($LASTEXITCODE -ne 0) { throw "Docker Compose failed ($LASTEXITCODE). Check Docker Desktop and WSL 2." }
} finally {
    Pop-Location
}
