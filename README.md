# Media Hit Assistant

A local desktop workspace for collecting, reviewing, analyzing, and exporting creator-content intelligence.

## Build

```bash
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build -j2
ctest --test-dir build --output-on-failure
QT_QPA_PLATFORM=offscreen ./build/media-hit-assistant --self-test
```

## Verify all

```bash
./scripts/verify-all.sh
```

## Package on Linux

```bash
./scripts/package-linux.sh
```

## Configure API credentials

Credentials are read from local settings or environment-backed launch configuration. Do not commit keys. When no API key is configured, the app uses safe local sample collection so the analysis and export workflow remains testable.
