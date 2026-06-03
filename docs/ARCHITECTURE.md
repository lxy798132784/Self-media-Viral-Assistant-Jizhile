# Architecture / 架构说明

Media Hit Assistant follows a small, testable desktop architecture: QML is kept as a presentation layer, while C++ services own data, API access, export, and plugin behavior.

自媒体爆款助手采用小而清晰、可测试的桌面架构：QML 只负责展示和触发动作，C++ 服务负责数据、API、导出和插件能力。

## System map / 系统图

```text
┌──────────────────────────────────────────────────────────────┐
│ QML UI                                                       │
│ Dashboard · Library · API Catalog · Report · Topics · Plugin │
└───────────────────────────────┬──────────────────────────────┘
                                │ Q_INVOKABLE
┌───────────────────────────────▼──────────────────────────────┐
│ AppController                                                  │
│ Orchestrates collection, export, reports, self-test, plugins   │
└───────┬──────────┬───────────┬──────────┬───────────┬────────┘
        │          │           │          │           │
        ▼          ▼           ▼          ▼           ▼
 ConfigManager  ApiCatalog  JizhiliaClient  DatabaseManager  ExportService
        │          │           │          │           │
        │          │           │          ▼           ▼
        │          │           │       SQLite      Markdown/XML
        │          │           │
        └──────────┴───────────┴──── BuiltinPluginRegistry
                                      Provider / Exporter / Analyzer
```

## Layers / 分层

### 1. QML presentation / QML 展示层

Seven pages are exposed to users: Dashboard, Content Library, API Catalog, Analysis Report, Topic Recommendation, Plugins, and Settings.

用户可见七个页面：仪表盘、内容库、接口库、拆解报告、选题推荐、插件、设置。

### 2. AppController facade / AppController 门面层

`AppController` exposes stable `Q_INVOKABLE` methods. This keeps QML simple and makes behavior testable from QtTest.

`AppController` 暴露稳定的 `Q_INVOKABLE` 方法，让 QML 保持简单，也让行为可以通过 QtTest 测试。

### 3. Services / 服务层

- `ConfigManager`: local settings.
- `ApiCatalog`: local Jizhilia endpoint index.
- `JizhiliaClient`: payloads, HTTP, parsing, retry, fallback.
- `DatabaseManager`: schema, articles, tasks, run history.
- `ExportService`: Markdown and XML.
- `BuiltinPluginRegistry`: CTK-style extension points.

### 4. Persistence / 持久化层

SQLite stores article rows, collection tasks, and run history. This keeps the app local-first and easy to back up.

SQLite 保存文章、采集任务和运行历史，使应用保持本地优先，也方便备份。

## Error handling and fallback / 错误处理与回退

- Missing API key: use safe sample collection.
- HTTP retryable status: classify 429 and 5xx, then apply backoff.
- Empty or invalid response: record the issue and keep the workflow testable with samples.
- Export failure: return false and keep UI state stable.

- 缺少 API Key：使用安全示例采集。
- HTTP 可重试状态：识别 429 和 5xx，并应用退避。
- 空响应或非法响应：记录问题，并用样本保持流程可验证。
- 导出失败：返回 false，保持 UI 状态稳定。

## Plugin strategy / 插件策略

The current release uses CTK-style interfaces without loading external dynamic libraries. This avoids platform-specific `.so/.dll` risk in the first delivery while preserving extension boundaries.

当前版本使用 CTK 风格接口，但不加载外部动态库。这样可以避免首版交付中的平台相关 `.so/.dll` 风险，同时保留扩展边界。

Future migration path:

后续迁移路径：

1. Keep Provider / Exporter / Analyzer interfaces stable.
2. Add CTK runtime discovery under `plugins/`.
3. Register dynamic plugins into the same QML-facing registry.

## Verification philosophy / 验证策略

Every visible control should have a backend action and a script-level audit. The project therefore includes both C++ unit tests and QML control audits.

每个可见控件都应该有后端动作和脚本级审计。因此项目同时包含 C++ 单元测试和 QML 控件审计。
