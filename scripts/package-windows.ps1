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
python scripts/audit_ui_help_tooltips.py
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

$launcher = @'
@echo off
setlocal
set APP_DIR=%~dp0
set LOG=%APP_DIR%media-hit-assistant.log
echo [%date% %time%] Starting Media Hit Assistant > "%LOG%"
"%APP_DIR%media-hit-assistant.exe" %* >> "%LOG%" 2>&1
set CODE=%ERRORLEVEL%
echo [%date% %time%] Exit code: %CODE% >> "%LOG%"
if not "%CODE%"=="0" (
  echo.
  echo Media Hit Assistant failed to start. See:
  echo   %LOG%
  echo.
  type "%LOG%"
  echo.
  pause
)
exit /b %CODE%
'@
Set-Content -Path (Join-Path $DistDir "run-with-log.bat") -Value $launcher -Encoding ASCII

$readmeRun = @'
# Windows startup help

If double-clicking media-hit-assistant.exe closes immediately, run `run-with-log.bat` instead.
It writes `media-hit-assistant.log` in this folder and keeps the console open when startup fails.

中文：如果双击 `media-hit-assistant.exe` 后窗口一闪而过，请运行 `run-with-log.bat`。
它会把错误写入本目录的 `media-hit-assistant.log`，启动失败时不会立刻关闭窗口。
'@
Set-Content -Path (Join-Path $DistDir "WINDOWS-RUN-HELP.md") -Value $readmeRun -Encoding UTF8

if (Get-Command windeployqt -ErrorAction SilentlyContinue) {
  windeployqt --release --compiler-runtime (Join-Path $DistDir "media-hit-assistant.exe")
} else {
  Write-Warning "windeployqt not found; package may require Qt runtime on PATH"
}

if (!(Test-Path (Join-Path $DistDir "run-with-log.bat"))) { throw "Windows diagnostic launcher missing" }
if (!(Test-Path (Join-Path $DistDir "docs\README.zh-CN.md"))) { throw "Chinese docs missing from Windows dist" }
if (!(Test-Path (Join-Path $DistDir "vendor\jizhilia-api-knowledge\api-index.json"))) { throw "API index missing from Windows dist" }

$env:QT_QPA_PLATFORM = "offscreen"
$distExe = Join-Path $DistDir "media-hit-assistant.exe"
& $distExe --self-test
if ($LASTEXITCODE -ne 0) { throw "Packaged Windows dist self-test failed with exit code $LASTEXITCODE" }

$zip = "$DistDir.zip"
if (Test-Path $zip) { Remove-Item -Force $zip }
Compress-Archive -Path (Join-Path $DistDir "*") -DestinationPath $zip -Force
Write-Host "OK: $zip generated with exe, Qt runtime, diagnostic launcher, docs, plugins, API index, and packaged self-test"
