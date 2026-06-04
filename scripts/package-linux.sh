#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="${BUILD_DIR:-$ROOT/build}"
CMAKE_BUILD_TYPE="${CMAKE_BUILD_TYPE:-Release}"
cmake -S "$ROOT" -B "$BUILD_DIR" -DCMAKE_BUILD_TYPE="$CMAKE_BUILD_TYPE"
cmake --build "$BUILD_DIR" -j"${JOBS:-2}"
ctest --test-dir "$BUILD_DIR" --output-on-failure
QT_QPA_PLATFORM=offscreen "$BUILD_DIR/media-hit-assistant" --self-test
QT_QPA_PLATFORM=vnc QT_QUICK_BACKEND=software "$BUILD_DIR/media-hit-assistant" --qml-smoke
python3 "$ROOT/scripts/audit_qml_controls.py"
python3 "$ROOT/scripts/audit_ui_help_tooltips.py"
python3 "$ROOT/scripts/audit_devprompt_alignment.py"
python3 "$ROOT/scripts/audit_brand_privacy.py"
rm -rf "$ROOT/dist"
mkdir -p "$ROOT/dist/docs/zh-CN" "$ROOT/dist/vendor/content-data" "$ROOT/dist/plugins"
cp "$BUILD_DIR/media-hit-assistant" "$ROOT/dist/media-hit-assistant"
cp "$BUILD_DIR/unit_tests" "$ROOT/dist/unit_tests"
cp "$ROOT/README.md" "$ROOT/dist/README.md"
cp "$ROOT/LICENSE" "$ROOT/dist/LICENSE"
cp "$ROOT/CHANGELOG.md" "$ROOT/dist/CHANGELOG.md"
cp "$ROOT/docs/DEPLOYMENT.md" "$ROOT/dist/docs/DEPLOYMENT.md"
cp "$ROOT/docs/README.zh-CN.md" "$ROOT/dist/docs/README.zh-CN.md"
cp "$ROOT/docs/zh-CN/DEPLOYMENT.md" "$ROOT/dist/docs/zh-CN/DEPLOYMENT.md"
cp -R "$ROOT/plugins/." "$ROOT/dist/plugins/"
cp "$ROOT/vendor/content-data/api-index.json" "$ROOT/dist/vendor/content-data/api-index.json"
test -s "$ROOT/dist/docs/README.zh-CN.md"
test -s "$ROOT/dist/docs/zh-CN/DEPLOYMENT.md"
test -s "$ROOT/dist/vendor/content-data/api-index.json"
python3 "$ROOT/scripts/audit_brand_privacy.py"
printf 'OK: dist/media-hit-assistant generated with docs, plugins, and private content-data index\n'
