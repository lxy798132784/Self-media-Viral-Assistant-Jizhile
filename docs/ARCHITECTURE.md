# 架构说明 / Architecture

## 分层 / Layers

1. QML Presentation：仪表盘、内容库、接口库、拆解报告、选题推荐、插件、设置。
   QML presentation: dashboard, library, API catalog, report, topic recommendation, plugins, and settings.
2. AppController：暴露给 QML 的门面，聚合配置、数据库、导出、API 和插件。
   AppController: QML-facing facade that orchestrates configuration, database, export, API, and plugins.
3. Services：ConfigManager、JizhiliaClient、DatabaseManager、ExportService、ApiCatalog。
   Services: configuration, API client, SQLite manager, exporter, and API catalog.
4. Persistence：SQLite 存储文章、任务配置、采集记录。
   Persistence: SQLite stores articles, task configuration, and run history.
5. Plugin-ready：CTK 风格扩展点覆盖供应商 API、导出格式、分析器。
   Plugin-ready: CTK-style extension points cover provider APIs, export formats, and analyzers.

## 数据流 / Data flow

```text
QML Button
  -> AppController Q_INVOKABLE
  -> ConfigManager / ApiCatalog / JizhiliaClient
  -> DatabaseManager SQLite
  -> ExportService / BuiltinPluginRegistry
  -> QML ListView or exported artifact
```

## 并发与限速 / Concurrency and rate limit

首版保守使用串行请求和可配置 QPS，避免桌面端一次性压垮 API 或误扣费。真实接口调用失败时，错误会记录到运行历史，并进入安全示例回退，保证内容库、导出和分析链路仍可验证。

The first release uses serialized requests and configurable QPS to avoid overloading APIs or spending quota accidentally. When a real endpoint fails, the error is written into run history and safe sample fallback keeps the library, export, and analysis pipeline verifiable.

## Fallback 机制 / Fallback mechanism

- 未配置 API Key：直接示例采集。/ Missing API key: use sample collection directly.
- HTTP 错误：记录错误并返回示例数据。/ HTTP error: record the error and return sample data.
- 空响应：返回可验证样本，避免 UI 空转。/ Empty response: return verifiable samples to avoid a dead UI.
- 导出失败：返回 false，并由 QML 保持当前状态。/ Export failure: return false and keep the current QML state.

## 插件策略 / Plugin strategy

当前 `BuiltinPluginRegistry` 提供 CTK 风格接口与动态插件提示，避免第一版引入平台相关 `.so/.dll` 加载风险。后续可把接口迁移到真正 CTK plugin framework，并保持 QML 调用面不变。

`BuiltinPluginRegistry` currently provides CTK-style interfaces and dynamic plugin hints without introducing first-release `.so/.dll` loading risk. Later versions can migrate to a real CTK plugin framework while keeping the QML-facing API stable.
