# Project Specification / 项目规格

> Product contract for Media Hit Assistant. This document maps the original DevPrompt into concrete user-facing modules, technical decisions, and acceptance gates.
>
> 自媒体爆款助手的产品契约。本文把原始 DevPrompt 拆成可交付的用户模块、技术决策和验收门禁。

## 1. Product goal / 产品目标

Media Hit Assistant is a desktop workspace for public-account content teams that need to collect hit articles, inspect engagement signals, derive topic ideas, and export reusable reports.

自媒体爆款助手面向公众号内容团队：采集爆款文章、查看互动指标、拆解内容结构、生成选题方向，并导出可复用报告。

## 2. Target workflow / 目标流程

```text
Configure API / 配置 API
  -> Collect by keyword or endpoint / 按关键词或 endpoint 采集
  -> Store in SQLite / 写入 SQLite
  -> Review library / 查看内容库
  -> Analyze hit score / 生成爆款评分
  -> Recommend topics / 推荐选题
  -> Export Markdown or XML / 导出 Markdown 或 XML
```

## 3. Scope / 范围

| Module / 模块 | Included / 已包含 |
|---|---|
| Dashboard / 仪表盘 | Statistics, quick collection, full workflow self-check / 统计、快速采集、全流程自检 |
| Content Library / 内容库 | Article list, refresh, Markdown/XML export / 文章列表、刷新、Markdown/XML 导出 |
| API Catalog / 接口库 | Local Jizhilia API index, category filter, endpoint collection / 本地极致了 API 索引、分类筛选、endpoint 采集 |
| Hot Articles API / 公众号爆文 API | Dedicated `/fbmain/monitor/v3/hot_typical_search` page; every documented parameter has an editable control / 独立的 `/fbmain/monitor/v3/hot_typical_search` 页面；文档内每个参数都有可编辑控件 |
| Language Switch / 语言切换 | UI can switch Chinese/English without mixing both languages in one label / 界面可中英文切换，不在一个标签里混杂两种语言 |
| Analysis Report / 拆解报告 | Reads, likes, hit score, structured summary / 阅读、点赞、爆款评分、结构化摘要 |
| Topic Recommendation / 选题推荐 | Topic ideas from high-performing articles / 从高表现文章生成选题 |
| Plugins / 插件 | Provider, Exporter, Analyzer registry / Provider、Exporter、Analyzer 注册表 |
| Settings / 设置 | API key, verify code, interval, run count, QPS, export dir, run history / API 参数、频率、次数、QPS、导出目录、运行历史 |

## 4. Technical contract / 技术契约

- Language and build: C++20 + CMake.
- UI: Qt6 + QML.
- Persistence: SQLite.
- API: Jizhilia endpoint payloads and local API catalog.
- Extensibility: CTK-style plugin interfaces.
- Platforms: Linux, Windows, Docker; source is architecture-neutral for x86/AMD64 and ARM64/AArch64 Qt builds.
- Export: Markdown and XML.

- 语言与构建：C++20 + CMake。
- UI：Qt6 + QML。
- 持久化：SQLite。
- API：极致了 endpoint 请求与本地 API 目录。
- 扩展性：CTK 风格插件接口。
- 平台：Linux、Windows、Docker；源码对 x86/AMD64 与 ARM64/AArch64 Qt 构建保持架构中立。
- 导出：Markdown 与 XML。

## 5. Configuration contract / 配置契约

The user can configure:

用户可配置：

- API key / API Key
- Verify code / 验证码
- Endpoint path / 接口路径
- Hot article API parameters: `key`, `keyword`, `pub_type`, `category`, `page`, `start_time`, `end_time` / 公众号爆文 API 参数：`key`、`keyword`、`pub_type`、`category`、`page`、`start_time`、`end_time`
- UI language / 界面语言
- Collection interval / 采集频率
- Maximum run count / 最大采集次数
- QPS limit / QPS 限速
- Export directory / 导出目录

## 6. Safety contract / 安全契约

- No key is needed for local self-test.
- Missing credentials trigger safe sample collection.
- API examples in vendor docs are sanitized as `[REDACTED]`.
- Runtime artifacts and databases are not committed.

- 本地自检不需要密钥。
- 缺少凭据时进入安全示例采集。
- vendor API 示例中的 token 已脱敏为 `[REDACTED]`。
- 运行产物和数据库不提交。

## 7. Acceptance gates / 验收门禁

```bash
cmake --build build -j2
ctest --test-dir build --output-on-failure
QT_QPA_PLATFORM=offscreen ./build/media-hit-assistant --self-test
python3 scripts/audit_qml_controls.py
python3 scripts/audit_devprompt_alignment.py
./scripts/package-linux.sh
cmake --install build --prefix /tmp/media-hit-install
```

A release candidate must pass every gate above.

候选交付版本必须通过以上全部门禁。
