# Developer Guide

This guide is for contributors who want to build, test, package, or extend Media Hit Assistant.

## Development setup

Ubuntu 24.04 example:

```bash
sudo apt-get update
sudo apt-get install -y cmake g++ python3 \
  qt6-base-dev qt6-declarative-dev qt6-tools-dev \
  qml6-module-qtquick qml6-module-qtquick-controls qml6-module-qtquick-layouts
```

Configure and build:

```bash
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build -j2
```

### Platform-specific setup

For exact install, uninstall, release-package, and architecture-specific instructions, read [Deployment and Development Guide](DEPLOYMENT.md). It covers Linux amd64, Linux arm64/aarch64, Windows x64, Docker/CI, and macOS source-build notes.

## Project structure

```text
include/        public C++ interfaces
src/            service implementations
ui/             QML interface
tests/          QtTest unit tests
scripts/        verification and packaging scripts
packaging/      desktop metadata
docs/           English docs, Chinese docs, and assets
vendor/         sanitized bundled API knowledge
plugins/        plugin contract and metadata examples
```

## Core modules

| Module | Responsibility |
|---|---|
| `ConfigManager` | API key, verify code, interval, run count, QPS, and export directory. |
| `ApiCatalog` | Bundled Content Data Service index loading and search. |
| `ContentDataClient` | Payload creation, HTTP call, JSON parsing, retry, and fallback. |
| `DatabaseManager` | SQLite schema, articles, tasks, and run history. |
| `ExportService` | Markdown and XML output. |
| `BuiltinPluginRegistry` | CTK-style Provider, Exporter, and Analyzer entries. |
| `AppController` | QML-facing orchestration. |

## Testing workflow

Fast checks while developing:

```bash
cmake --build build -j2
ctest --test-dir build --output-on-failure
```

Full gate before commit:

```bash
./scripts/verify-all.sh
```

The full gate includes:

- CMake build;
- QtTest suite;
- offscreen self-test;
- Markdown and XML artifact checks;
- QML control audit;
- documentation alignment audit;
- offscreen launch smoke.

## Adding a new API endpoint

1. Add or update the endpoint entry in `vendor/content-data/api-index.json`.
2. Use `ApiCatalog::findByCategory()` or `ApiCatalog::findByPath()` to expose it.
3. Use `ContentDataClient::callEndpointBlocking()` for collection.
4. Add a QtTest assertion covering the endpoint path or payload.
5. Run `./scripts/verify-all.sh`.

Do not use machine-specific absolute paths in tests or runtime code.

## Adding an exporter

1. Implement output behavior in `ExportService` or a plugin entry.
2. Add it to `BuiltinPluginRegistry` if it should appear in the plugin list.
3. Add tests for generated text and escaping behavior.
4. Add a QML button only if it has a real backend action and readback.

## Documentation rules

- Keep English docs in `README.md` and `docs/*.md`.
- Keep Chinese docs in `docs/README.zh-CN.md` and `docs/zh-CN/*.md`.
- Do not mix Chinese and English explanations in the same document body.
- Do not expose real credentials, private URLs, or internal implementation notes.
- Keep examples runnable and aligned with scripts.

## Commit checklist

```bash
git diff --check
./scripts/verify-all.sh
./scripts/package-linux.sh
cmake --install build --prefix /tmp/media-hit-install
```

Before pushing, confirm there are no build outputs, runtime databases, package outputs, or secrets in tracked files.
