# Project Specification

## Product goal

Media Hit Assistant is a local-first desktop workspace for public-account content teams. It collects article data, stores it locally, helps users inspect hit signals, generates topic ideas, and exports reusable reports.

## Target workflow

```text
Configure API settings
  -> Collect by keyword, hot-article form, or endpoint catalog
  -> Store articles, tasks, and run history in SQLite
  -> Review article details in the content library
  -> Generate hit-score analysis
  -> Generate topic recommendations
  -> Export Markdown or XML
```

## Included modules

| Module | Included behavior |
|---|---|
| Dashboard | Statistics, quick collection, full workflow self-test. |
| Content Library | Article list, article details, refresh, Markdown export, XML export. |
| API Catalog | Bundled Content Data Service index, category filter, endpoint detail, endpoint collection. |
| Hot Articles API | Editable controls for `key`, `keyword`, `pub_type`, `category`, `page`, `start_time`, and `end_time`. |
| Analysis Report | Reads, likes, hit score, observations, export action. |
| Topic Recommendations | Topic ideas derived from the content library. |
| Plugins | Provider, Exporter, and Analyzer registry with descriptor details and scan report. |
| Settings | API key, verify code, endpoint path, interval, maximum run count, QPS limit, export directory, tasks, and run history. |

## Technical contract

- Language and build: C++20 and CMake.
- UI: Qt6 and QML.
- Persistence: SQLite.
- API: ContentData endpoint payloads and a bundled local API catalog.
- Extensibility: CTK-style Provider, Exporter, and Analyzer interfaces.
- Export: Markdown and XML.
- Platforms: Linux, Windows, Docker; source remains architecture-neutral for x86_64 and ARM64 Qt builds.

## Safety contract

- Local self-test requires no API key.
- Missing credentials trigger safe sample collection.
- Vendor API examples must remain sanitized.
- Runtime artifacts, local databases, package outputs, and build outputs must not be committed.
- Configuration must never require secrets in source files.

## Acceptance gates

```bash
cmake --build build -j2
ctest --test-dir build --output-on-failure
QT_QPA_PLATFORM=offscreen ./build/media-hit-assistant --self-test
python3 scripts/audit_qml_controls.py
python3 scripts/audit_devprompt_alignment.py
./scripts/package-linux.sh
cmake --install build --prefix /tmp/media-hit-install
```

A release candidate must pass every gate above before delivery.
