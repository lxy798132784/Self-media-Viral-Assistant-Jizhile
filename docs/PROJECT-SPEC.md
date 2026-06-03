# 自媒体爆款助手项目规格 / Media Hit Assistant Specification

## 目标 / Goal

使用 C++20、CMake、Qt6、QML、SQLite 和 CTK-ready 插件化架构开发跨平台自媒体爆款助手。首版聚焦公众号爆款文章收集分析，接入极致了 API 本地文档资料库，并提供真实接口调用与安全示例回退。

Build a cross-platform media-hit assistant using C++20, CMake, Qt6, QML, SQLite, and CTK-ready plugin architecture. The first release focuses on collecting and analyzing public-account hit articles, uses the local Jizhilia API knowledge base, and supports both real endpoint calls and safe sample fallback.

## 功能范围 / Feature scope

- 仪表盘 / Dashboard：统计、快速采集、全流程自检。
- 内容库 / Content library：文章列表、刷新、Markdown/XML 导出。
- 接口库 / API catalog：API 分类查询、endpoint path 采集。
- 拆解报告 / Analysis report：阅读、点赞、爆款评分、结构化观察。
- 选题推荐 / Topic recommendation：基于内容库指标生成选题。
- 插件 / Plugins：Provider、Exporter、Analyzer 清单与插件分析。
- 设置 / Settings：API Key、verify code、采集频率、次数、QPS、导出目录、运行历史。

## 技术要求 / Technical requirements

- C++20 with Google-style naming where practical / C++20，尽量遵循 Google 风格命名。
- CMake project with Qt6 Widgets-free QML frontend / CMake 工程，Qt6 + QML 前端。
- SQLite local persistence / SQLite 本地持久化。
- CTK-style extension points / CTK 风格扩展点。
- Linux, Windows, Docker delivery scripts / Linux、Windows、Docker 交付脚本。
- Source-first GitHub delivery without secrets / 源码优先上传 GitHub，不含密钥。

## 安全 / Security

API Key 只从本地设置或运行环境读取，不提交到仓库。默认示例采集不需要密钥，避免误扣费。vendor API 文档中的示例 token 已脱敏为 `[REDACTED]`。

API keys are read only from local settings or runtime environment and are never committed. Default sample collection requires no credentials to avoid accidental charges. Sample tokens in vendor API docs are sanitized as `[REDACTED]`.

## 验收门禁 / Acceptance gates

```bash
cmake --build build -j2
ctest --test-dir build --output-on-failure
QT_QPA_PLATFORM=offscreen ./build/media-hit-assistant --self-test
python3 scripts/audit_qml_controls.py
python3 scripts/audit_devprompt_alignment.py
./scripts/package-linux.sh
cmake --install build --prefix /tmp/media-hit-install
```
