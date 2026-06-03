#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="${BUILD_DIR:-$ROOT/build}"
CMAKE_BUILD_TYPE="${CMAKE_BUILD_TYPE:-Release}"
cmake -S "$ROOT" -B "$BUILD_DIR" -DCMAKE_BUILD_TYPE="$CMAKE_BUILD_TYPE"
cmake --build "$BUILD_DIR" -j"${JOBS:-2}"
ctest --test-dir "$BUILD_DIR" --output-on-failure
QT_QPA_PLATFORM=offscreen "$BUILD_DIR/media-hit-assistant" --self-test
mkdir -p "$ROOT/dist"
cp "$BUILD_DIR/media-hit-assistant" "$ROOT/dist/media-hit-assistant"
cp "$BUILD_DIR/unit_tests" "$ROOT/dist/unit_tests"
printf 'OK: dist/media-hit-assistant generated\n'
