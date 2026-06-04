# 架构说明

自媒体爆款助手采用小而清晰、可测试的桌面架构。QML 负责展示，C++ 服务负责数据、API、导出和插件行为。

## 系统图

```text
QML 界面
仪表盘 | 内容库 | 接口库 | 爆文 | 报告 | 选题 | 插件 | 设置
        |
        v
AppController
        |
        +-- ConfigManager       本地配置
        +-- ApiCatalog          内置接口索引
        +-- ContentDataClient      请求体、HTTP、解析、重试、回退
        +-- DatabaseManager     SQLite schema 与查询
        +-- ExportService       Markdown 与 XML 输出
        +-- BuiltinPluginRegistry
              +-- Provider
              +-- Exporter
              +-- Analyzer
```

## QML 展示层

可见界面围绕用户工作流组织，而不是围绕实现类组织。每个展示出来的动作都必须对应 `AppController` 方法或可读回执：

- 采集或加载示例数据；
- 查看文章详情；
- 浏览并运行 API endpoint；
- 预览公众号爆文 请求；
- 导出报告；
- 创建和运行任务；
- 查看运行回执；
- 查看插件描述和扫描报告。

## AppController 门面层

`AppController` 是面向 QML 的门面。它让 QML 保持轻量，同时让桌面端行为可以通过 QtTest 验证。QML 不直接解析数据库、不直接构造 API 请求体，也不直接负责文件导出。

## 服务层

| 服务 | 职责 |
|---|---|
| `ConfigManager` | 本地 API 与任务设置。 |
| `ApiCatalog` | 定位和解析仓库内置内容数据 endpoint 索引。 |
| `ContentDataClient` | 构造请求体、执行 HTTP、解析 JSON、分类错误、重试和回退。 |
| `DatabaseManager` | 将文章、采集任务和运行历史写入 SQLite。 |
| `ExportService` | 生成 Markdown 与 XML 产物。 |
| `BuiltinPluginRegistry` | 暴露 Provider、Exporter、Analyzer 条目。 |

## 持久化

SQLite 保存三类持久概念：文章与互动指标、采集任务与调度参数、运行历史回执。数据库位于用户本机应用数据目录，不属于源码交付内容。

## API 目录路径策略

endpoint 索引放在 `vendor/content-data/api-index.json`。测试和运行时优先使用仓库相对路径，其次使用编译期源码目录，再使用安装后的 data 路径。这样可以避免 GitHub Actions 因本机绝对路径不存在而失败。

## 错误处理与回退

- 缺少 API Key 时使用安全示例采集。
- 可重试 HTTP 状态会被分类并退避。
- 非法响应会写入运行历史，而不是让界面崩溃。
- 动态插件元数据错误只生成报告，内置插件仍可用。
- 导出失败返回 `false` 并更新状态消息。

## 插件策略

当前版本实现 CTK 风格扩展边界和内置注册表，不声明已经支持运行时 `.so` 或 `.dll` 加载。后续动态加载应注册到相同的 Provider、Exporter、Analyzer 概念，并在插件元数据非法时 fail closed。

## 验证策略

可见控件必须有真实动作、读回状态或审计回执。因此项目同时使用 QtTest、QML 控件审计、文档对齐检查、打包烟测和安装烟测。
