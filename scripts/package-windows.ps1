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
New-Item -ItemType Directory -Force -Path dist | Out-Null
Copy-Item $exe dist\media-hit-assistant.exe -Force
Write-Host "OK: dist\media-hit-assistant.exe generated"
