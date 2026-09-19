param(
    [string]$AltarRepository = '',
    [string]$Revision = '7ab85c3997789661e9f0b9a13dafaedb2bfc89d1'
)
$ErrorActionPreference = 'Stop'
$worldRoot = Split-Path -Parent $PSScriptRoot
if (-not $AltarRepository) { $AltarRepository = Join-Path $worldRoot '.compatibility/AltarAppsReborn' }
$altarRoot = (Resolve-Path -LiteralPath $AltarRepository).Path
$harnessRoot = Join-Path $worldRoot '.compatibility/harness'
New-Item -ItemType Directory -Force -Path $harnessRoot, (Join-Path $harnessRoot 'lib'), (Join-Path $harnessRoot 'test') | Out-Null
$archivePath = Join-Path $harnessRoot 'transport.tar'
# Read-only git archive: no checkout, commit or modification of AltarAppsReborn.
git -C $altarRoot archive --format=tar -o $archivePath $Revision packages/api_client/generated/altar_tabletop_api
if ($LASTEXITCODE -ne 0) { throw 'Unable to read Altar transport at requested commit.' }
tar -xf $archivePath -C $harnessRoot
if ($LASTEXITCODE -ne 0) { throw 'Unable to extract compatibility fixture.' }
@'
name: world_altar_compatibility
publish_to: none
environment:
  sdk: '>=3.12.2 <4.0.0'
dependencies:
  flutter:
    sdk: flutter
  world:
    path: ../..
  altar_tabletop_api_transport:
    path: packages/api_client/generated/altar_tabletop_api
dev_dependencies:
  flutter_test:
    sdk: flutter
flutter:
  uses-material-design: true
'@ | Set-Content -LiteralPath (Join-Path $harnessRoot 'pubspec.yaml') -Encoding utf8
Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'compatibility/organization_world_mapper.dart.template') -Destination (Join-Path $harnessRoot 'lib/organization_world_mapper.dart')
Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'compatibility/altar_contract_test.dart.template') -Destination (Join-Path $harnessRoot 'test/altar_contract_test.dart')
Push-Location $harnessRoot
try {
    flutter pub get
    if ($LASTEXITCODE -ne 0) { throw 'Compatibility dependency resolution failed.' }
    flutter test --reporter expanded
    if ($LASTEXITCODE -ne 0) { throw 'Altar compatibility test failed.' }
} finally { Pop-Location }
