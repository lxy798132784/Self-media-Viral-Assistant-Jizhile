# Architecture

Media Hit Assistant follows a small, testable desktop architecture. QML owns presentation, while C++ services own data, API access, export, and plugin behavior.

## System map

```text
QML UI
Dashboard | Library | API Catalog | Hot API | Report | Topics | Plugins | Settings
        |
        v
AppController
        |
        +-- ConfigManager       local configuration
        +-- ApiCatalog          bundled endpoint index
        +-- JizhiliaClient      payloads, HTTP, parsing, retry, fallback
        +-- DatabaseManager     SQLite schema and queries
        +-- ExportService       Markdown and XML output
        +-- BuiltinPluginRegistry
              +-- Provider
              +-- Exporter
              +-- Analyzer
```

## QML presentation layer

The visible interface is organized around user workflows rather than implementation classes. Every displayed action is backed by an `AppController` method or a readback state:

- collect or load sample data;
- inspect articles;
- browse and run API endpoints;
- preview Hot Articles API payloads;
- export reports;
- create and run tasks;
- inspect run receipts;
- inspect plugin descriptors and scan reports.

## AppController facade

`AppController` is the QML-facing facade. It keeps QML thin and makes desktop behavior testable from QtTest. QML should not parse databases, build API payloads, or perform file export directly.

## Service layer

| Service | Responsibility |
|---|---|
| `ConfigManager` | Local API and task settings. |
| `ApiCatalog` | Locate and parse the bundled Jizhilia endpoint index. |
| `JizhiliaClient` | Build payloads, run HTTP calls, parse JSON, classify errors, retry, and fallback. |
| `DatabaseManager` | Store articles, collection tasks, and run history in SQLite. |
| `ExportService` | Render Markdown and XML artifacts. |
| `BuiltinPluginRegistry` | Expose Provider, Exporter, and Analyzer entries. |

## Persistence

SQLite stores three durable concepts:

1. articles and engagement metrics;
2. collection tasks and scheduling parameters;
3. run history receipts for auditing user actions.

The database is local to the user's app data directory and is not part of source delivery.

## API catalog path strategy

The endpoint index is bundled under `vendor/jizhilia-api-knowledge/api-index.json`. Tests and runtime use repository-relative lookup first, then the compile-time source directory, then installed data paths. This avoids CI failures caused by absolute local paths.

## Error handling and fallback

- Missing API key uses safe sample collection.
- Retryable HTTP statuses are classified and backed off.
- Invalid responses are recorded in run history rather than crashing the UI.
- Dynamic plugin metadata errors are reported while the built-in registry remains available.
- Export failure returns `false` and updates the status message.

## Plugin strategy

The current release implements CTK-style extension boundaries and built-in registry entries. It does not claim runtime `.so` or `.dll` loading yet. Future dynamic loading should register into the same Provider, Exporter, and Analyzer concepts and fail closed when plugin metadata is invalid.

## Verification philosophy

Visible controls must have a real action, readback, or audit receipt. The project therefore combines QtTest coverage, QML control audits, documentation alignment checks, package smoke, and install smoke.
