param(
  [string]$BuildDir = "build-win",
  [string]$Config = "Release"
)
$ErrorActionPreference = "Stop"
cmake -S . -B $BuildDir -DCMAKE_BUILD_TYPE=$Config
cmake --build $BuildDir --config $Config
ctest --test-dir $BuildDir --output-on-failure
$exe = Join-Path $BuildDir "media-hit-assistant.exe"
if (Test-Path $exe) { & $exe --self-test }
python3 scripts/audit_qml_controls.py
python3 scripts/audit_devprompt_alignment.py
New-Item -ItemType Directory -Force -Path dist | Out-Null
Copy-Item $exe dist\media-hit-assistant.exe -Force
Copy-Item README.md dist\README.md -Force
Copy-Item LICENSE dist\LICENSE -Force
Copy-Item CHANGELOG.md dist\CHANGELOG.md -Force
Write-Host "OK: dist\media-hit-assistant.exe generated with README, LICENSE, CHANGELOG"
