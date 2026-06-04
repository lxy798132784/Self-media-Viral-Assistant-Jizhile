param(
  [string]$BuildDir = "build-win",
  [string]$Config = "Release",
  [string]$DistDir = "dist-windows-x64"
)
$ErrorActionPreference = "Stop"

cmake -S . -B $BuildDir -DCMAKE_BUILD_TYPE=$Config
cmake --build $BuildDir --config $Config --parallel 2
ctest --test-dir $BuildDir -C $Config --output-on-failure

$exe = Join-Path $BuildDir "media-hit-assistant.exe"
if (!(Test-Path $exe)) {
  $exe = Join-Path $BuildDir "$Config\media-hit-assistant.exe"
}
if (!(Test-Path $exe)) {
  throw "media-hit-assistant.exe was not produced"
}

$env:QT_QPA_PLATFORM = "offscreen"
& $exe --self-test
python scripts/audit_qml_controls.py
python scripts/audit_devprompt_alignment.py

if (Test-Path $DistDir) { Remove-Item -Recurse -Force $DistDir }
New-Item -ItemType Directory -Force -Path $DistDir | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $DistDir "docs") | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $DistDir "plugins") | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $DistDir "vendor\jizhilia-api-knowledge") | Out-Null

Copy-Item $exe (Join-Path $DistDir "media-hit-assistant.exe") -Force
Copy-Item README.md (Join-Path $DistDir "README.md") -Force
Copy-Item LICENSE (Join-Path $DistDir "LICENSE") -Force
Copy-Item CHANGELOG.md (Join-Path $DistDir "CHANGELOG.md") -Force
Copy-Item docs\* (Join-Path $DistDir "docs") -Recurse -Force
Copy-Item plugins\* (Join-Path $DistDir "plugins") -Recurse -Force
Copy-Item vendor\jizhilia-api-knowledge\api-index.json (Join-Path $DistDir "vendor\jizhilia-api-knowledge\api-index.json") -Force

if (Get-Command windeployqt -ErrorAction SilentlyContinue) {
  windeployqt (Join-Path $DistDir "media-hit-assistant.exe")
} else {
  Write-Warning "windeployqt not found; package may require Qt runtime on PATH"
}

if (!(Test-Path (Join-Path $DistDir "docs\README.zh-CN.md"))) { throw "Chinese docs missing from Windows dist" }
if (!(Test-Path (Join-Path $DistDir "vendor\jizhilia-api-knowledge\api-index.json"))) { throw "API index missing from Windows dist" }

$zip = "$DistDir.zip"
if (Test-Path $zip) { Remove-Item -Force $zip }
Compress-Archive -Path (Join-Path $DistDir "*") -DestinationPath $zip -Force
Write-Host "OK: $zip generated with exe, Qt runtime deployment when available, docs, plugins, and bundled API index"
