#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="${BUILD_DIR:-$ROOT/build}"
CMAKE_BUILD_TYPE="${CMAKE_BUILD_TYPE:-Release}"
cmake -S "$ROOT" -B "$BUILD_DIR" -DCMAKE_BUILD_TYPE="$CMAKE_BUILD_TYPE"
cmake --build "$BUILD_DIR" -j"${JOBS:-2}"
ctest --test-dir "$BUILD_DIR" --output-on-failure
QT_QPA_PLATFORM=offscreen "$BUILD_DIR/media-hit-assistant" --self-test
python3 "$ROOT/scripts/audit_qml_controls.py"
python3 "$ROOT/scripts/audit_devprompt_alignment.py"
rm -rf "$ROOT/dist"
mkdir -p "$ROOT/dist/docs" "$ROOT/dist/vendor/jizhilia-api-knowledge" "$ROOT/dist/plugins"
cp "$BUILD_DIR/media-hit-assistant" "$ROOT/dist/media-hit-assistant"
cp "$BUILD_DIR/unit_tests" "$ROOT/dist/unit_tests"
cp "$ROOT/README.md" "$ROOT/dist/README.md"
cp "$ROOT/LICENSE" "$ROOT/dist/LICENSE"
cp "$ROOT/CHANGELOG.md" "$ROOT/dist/CHANGELOG.md"
cp -R "$ROOT/docs/." "$ROOT/dist/docs/"
cp -R "$ROOT/plugins/." "$ROOT/dist/plugins/"
cp "$ROOT/vendor/jizhilia-api-knowledge/api-index.json" "$ROOT/dist/vendor/jizhilia-api-knowledge/api-index.json"
test -s "$ROOT/dist/docs/README.zh-CN.md"
test -s "$ROOT/dist/docs/zh-CN/PROJECT-SPEC.md"
test -s "$ROOT/dist/vendor/jizhilia-api-knowledge/api-index.json"
printf 'OK: dist/media-hit-assistant generated with docs, plugins, and bundled API index\n'
