# 开发文档 / Developer Guide

## 模块说明 / Modules

### ConfigManager
管理 API Key、验证码、采集频率、次数、QPS 和导出目录。真实密钥只保存在本机设置或环境变量中。

Manages API key, verification code, interval, run count, QPS, and export directory. Real credentials stay in local settings or environment variables only.

### ApiCatalog
读取 `vendor/jizhilia-api-knowledge/api-index.json`，提供极致了 API 文档索引、分类查询和 endpoint path 查询。

Loads `vendor/jizhilia-api-knowledge/api-index.json` and provides Jizhilia API endpoint indexing, category search, and endpoint path lookup.

### DatabaseManager
负责 SQLite schema、文章表、采集任务表、运行历史表，以及统计、排序、推荐查询。

Owns the SQLite schema, article table, collection-task table, run-history table, statistics, sorting, and recommendation queries.

### JizhiliaClient
负责构造极致了 API 请求 payload、同步 HTTP 请求、响应解析、可重试状态判断、退避延迟和安全示例回退。

Builds Jizhilia request payloads, performs blocking HTTP requests, parses responses, classifies retryable errors, calculates backoff, and provides safe sample fallback.

### ExportService
导出 Markdown 和 XML。XML 会做实体转义，避免标题中的特殊字符破坏格式。

Exports Markdown and XML. XML output escapes entities so special title characters do not break the document.

### BuiltinPluginRegistry
提供 CTK 风格的 Provider、Exporter、Analyzer 扩展点。当前为内置注册表，后续可替换为动态 CTK 插件加载器。

Provides CTK-style Provider, Exporter, and Analyzer extension points. The current version is a built-in registry that can later be replaced by dynamic CTK loading.

### AppController
QML 门面层，连接 UI 与后端服务，负责采集、endpoint 调用、导出、自检、插件分析和运行历史读回。

QML-facing facade that connects UI and backend services for collection, endpoint calls, export, self-test, plugin analysis, and run-history readback.

## 开发原则 / Development rules

- 新功能先写 Qt Test。/ Write Qt tests before new behavior.
- 每个关键函数使用中英文双语注释。/ Document key functions with Chinese-English comments.
- 真实 API Key 不写源码、不写文档、不写 Git。/ Never write real API keys into source, docs, or Git.
- 所有网络请求必须经过错误处理和 fallback。/ Network calls must include error handling and fallback.
- 可见 UI 控件必须有动作闭环。/ Every visible UI control must produce a verifiable action.
- 打包与安装元数据必须通过脚本验证。/ Packaging and install metadata must be verified by scripts.

## 并发与限速 / Concurrency and rate limiting

当前桌面端采用保守串行请求策略，默认 QPS 为 1.5，避免误触发上游限流。`JizhiliaClient::retryDelayMs()` 使用指数退避；`isRetryableStatus()` 识别 429 与 5xx。

The desktop app currently uses conservative serialized requests with default QPS 1.5 to avoid upstream throttling. `JizhiliaClient::retryDelayMs()` uses exponential backoff, and `isRetryableStatus()` recognizes 429 and 5xx.

## 关键测试 / Key tests

```bash
cmake --build build -j2
ctest --test-dir build --output-on-failure
python3 scripts/audit_qml_controls.py
python3 scripts/audit_devprompt_alignment.py
QT_QPA_PLATFORM=offscreen ./build/media-hit-assistant --self-test
```

## 交付检查 / Delivery checklist

1. 本地 build/test/self-test 通过。/ Local build, tests, and self-test pass.
2. QML 控件审计通过。/ QML control audit passes.
3. DevPrompt 对齐审计通过。/ DevPrompt alignment audit passes.
4. `cmake --install` 能安装可执行文件、desktop、metainfo、icon。/ `cmake --install` installs executable, desktop, metainfo, and icon.
5. 远端仓库复扫无密钥、无 build/dist 产物。/ Remote repository scan has no secrets and no build/dist artifacts.
