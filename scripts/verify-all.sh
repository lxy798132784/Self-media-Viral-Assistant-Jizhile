#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
cmake --build build -j"${JOBS:-2}"
ctest --test-dir build --output-on-failure
QT_QPA_PLATFORM=offscreen ./build/media-hit-assistant --self-test
python3 scripts/audit_qml_controls.py
test -s /tmp/media-hit-self-test.md
test -s /tmp/media-hit-self-test.xml
timeout 8s env QT_QPA_PLATFORM=offscreen ./build/media-hit-assistant || code=$?
if [[ "${code:-124}" != "124" ]]; then exit "${code:-1}"; fi
printf 'OK: build, tests, self-test, export artifacts, offscreen launch\n'
