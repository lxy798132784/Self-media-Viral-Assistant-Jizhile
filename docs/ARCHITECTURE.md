# 架构说明 / Architecture

## 分层 / Layers
1. QML Presentation：五大页面，负责展示和触发动作。
2. AppController：暴露给 QML 的门面，聚合配置、数据库、导出、API。
3. Services：ConfigManager、JizhiliaClient、DatabaseManager、ExportService、ApiCatalog。
4. Persistence：SQLite 存储文章、任务配置、采集记录。
5. Plugin-ready：后续可接 CTK 插件，供应商 API、导出格式、分析器都可拆插件。

## 并发与限速 / Concurrency and Rate Limit
首版保守使用串行请求和 QTimer 调度；默认 QPS <= 1.5，后续可换 QThreadPool + token bucket。
