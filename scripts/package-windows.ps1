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
if (!(Test-Path $exe)) { $exe = Join-Path $BuildDir "$Config\media-hit-assistant.exe" }
if (!(Test-Path $exe)) { throw "media-hit-assistant.exe was not produced" }

$env:QT_QPA_PLATFORM = "offscreen"
& $exe --self-test
if ($LASTEXITCODE -ne 0) { throw "Build-tree self-test failed with exit code $LASTEXITCODE" }
& $exe --qml-smoke
if ($LASTEXITCODE -ne 0) { throw "Build-tree QML smoke failed with exit code $LASTEXITCODE" }
python scripts/audit_qml_controls.py
python scripts/audit_ui_help_tooltips.py
python scripts/audit_devprompt_alignment.py
python scripts/audit_brand_privacy.py

if (Test-Path $DistDir) { Remove-Item -Recurse -Force $DistDir }
New-Item -ItemType Directory -Force -Path $DistDir | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $DistDir "docs") | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $DistDir "plugins") | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $DistDir "vendor\content-data") | Out-Null

Copy-Item $exe (Join-Path $DistDir "media-hit-assistant.exe") -Force
Copy-Item README.md (Join-Path $DistDir "README.md") -Force
Copy-Item LICENSE (Join-Path $DistDir "LICENSE") -Force
Copy-Item CHANGELOG.md (Join-Path $DistDir "CHANGELOG.md") -Force
Copy-Item docs\DEPLOYMENT.md (Join-Path $DistDir "docs\DEPLOYMENT.md") -Force
Copy-Item docs\README.zh-CN.md (Join-Path $DistDir "docs\README.zh-CN.md") -Force
New-Item -ItemType Directory -Force -Path (Join-Path $DistDir "docs\zh-CN") | Out-Null
Copy-Item docs\zh-CN\DEPLOYMENT.md (Join-Path $DistDir "docs\zh-CN\DEPLOYMENT.md") -Force
Copy-Item plugins\* (Join-Path $DistDir "plugins") -Recurse -Force
Copy-Item vendor\content-data\api-index.json (Join-Path $DistDir "vendor\content-data\api-index.json") -Force

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

中文：如果双击 `media-hit-assistant.exe` 后没有反应或窗口一闪而过，请运行 `run-with-log.bat`。
它会把错误写入本目录的 `media-hit-assistant.log`，启动失败时不会立刻关闭窗口。
'@
Set-Content -Path (Join-Path $DistDir "WINDOWS-RUN-HELP.md") -Value $readmeRun -Encoding UTF8

if (Get-Command windeployqt -ErrorAction SilentlyContinue) {
  $qmlDir = Join-Path (Get-Location) "ui"
  windeployqt --release --compiler-runtime --qmldir $qmlDir (Join-Path $DistDir "media-hit-assistant.exe")
} else {
  throw "windeployqt not found; refusing to create a Windows package without Qt runtime deployment"
}

if (!(Test-Path (Join-Path $DistDir "run-with-log.bat"))) { throw "Windows diagnostic launcher missing" }
if (!(Test-Path (Join-Path $DistDir "docs\README.zh-CN.md"))) { throw "Chinese docs missing from Windows dist" }
if (!(Test-Path (Join-Path $DistDir "vendor\content-data\api-index.json"))) { throw "Content data index missing from Windows dist" }
$legacyVendorDir = "jiz" + "hilia-api-knowledge"
if (Test-Path (Join-Path $DistDir "vendor\$legacyVendorDir")) { throw "Forbidden provider vendor directory leaked into Windows dist" }
if (!(Test-Path (Join-Path $DistDir "Qt6Core.dll"))) { throw "Qt6Core.dll missing after windeployqt" }
if (!(Test-Path (Join-Path $DistDir "qml"))) { throw "Qt QML runtime folder missing after windeployqt" }

$env:QT_QPA_PLATFORM = "offscreen"
$distExe = Join-Path $DistDir "media-hit-assistant.exe"
& $distExe --self-test
if ($LASTEXITCODE -ne 0) { throw "Packaged Windows dist self-test failed with exit code $LASTEXITCODE" }
& $distExe --qml-smoke
if ($LASTEXITCODE -ne 0) { throw "Packaged Windows dist QML smoke failed with exit code $LASTEXITCODE" }
python scripts/audit_brand_privacy.py

$zip = "$DistDir.zip"
if (Test-Path $zip) { Remove-Item -Force $zip }
Compress-Archive -Path (Join-Path $DistDir "*") -DestinationPath $zip -Force
Write-Host "OK: $zip generated with exe, Qt/QML runtime, diagnostic launcher, docs, plugins, private content-data index, and packaged QML smoke"
