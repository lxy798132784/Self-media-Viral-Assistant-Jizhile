# Media Hit Assistant / 自媒体爆款助手

A cross-platform C++20 / Qt6 / QML desktop workspace for collecting, analyzing, and exporting creator-content intelligence.

一个跨平台 C++20 / Qt6 / QML 桌面工作台，用于公众号爆款文章采集、拆解分析、选题推荐和多格式导出。

## DevPrompt alignment / DevPrompt 对齐

| Requirement / 要求 | Status / 状态 |
|---|---|
| C++20 + CMake + Qt6 + QML | Done / 已完成 |
| SQLite local persistence / SQLite 本地持久化 | Done / 已完成 |
| Jizhilia API integration / 极致了 API 接入 | Done with safe fallback / 已接入并带安全示例回退 |
| Adjustable frequency and run count / 频率和次数可调 | Done / 已完成 |
| API parameters configurable / API 参数可配置 | Done: key, verify code, QPS, interval, run count, endpoint path / 已完成：key、验证码、QPS、频率、次数、接口路径 |
| Export XML and Markdown / 导出 XML、Markdown | Done / 已完成 |
| Dashboard, library, report, topics, settings / 仪表盘、内容库、拆解报告、选题推荐、设置 | Done / 已完成 |
| Plugin-friendly enterprise architecture / 企业级可扩展插件架构 | Done: CTK-style interfaces and registry / 已完成：CTK 风格接口和注册表 |
| Linux, Windows, Docker / Linux、Windows、Docker | Done: scripts, Dockerfile, CI / 已完成：脚本、Dockerfile、CI |
| ARM64/AArch64 and x86/AMD64 awareness / ARM64 与 x86/AMD64 支持 | Source and Docker are architecture-neutral Qt builds / 源码与 Docker 为架构中立 Qt 构建 |
| Bilingual docs and comments / 中英文文档和注释 | Done for public docs and key interfaces / 公开文档和关键接口已完成 |
| UI interaction and ergonomics / UI 交互与人体工学 | Dark workspace, left navigation, large controls, QML audit / 深色工作台、左侧导航、大控件、QML 审计 |

## Build / 构建

```bash
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build -j2
ctest --test-dir build --output-on-failure
QT_QPA_PLATFORM=offscreen ./build/media-hit-assistant --self-test
```

## Verify all / 全量验证

```bash
./scripts/verify-all.sh
```

The verification command checks build, QtTest, self-test exports, QML control coverage, and offscreen launch.

该命令会检查构建、QtTest、自检导出、QML 控件覆盖和 offscreen 启动。

## Package on Linux / Linux 打包

```bash
./scripts/package-linux.sh
```

Install metadata is available through CMake:

安装元数据可通过 CMake 安装：

```bash
cmake --install build --prefix /tmp/media-hit-install
```

## Windows / Windows 构建

```powershell
.\scripts\package-windows.ps1
```

## Docker / Docker 构建

```bash
docker build -t media-hit-assistant .
docker run --rm media-hit-assistant
```

## Configure API credentials / 配置 API 凭据

Credentials are saved only in local settings through the Settings page. Do not commit keys.

凭据只通过“设置”页保存在本机设置中，不应提交到仓库。

When no API key is configured, the app uses safe local sample collection so the analysis and export workflow remains testable without spending API quota.

未配置 API Key 时，应用会使用安全示例采集，保证分析和导出流程可验证且不消耗接口额度。

## Main modules / 主要模块

- `ConfigManager`: local API and collection settings / 本地 API 与采集配置
- `DatabaseManager`: SQLite article, task, and run-history persistence / SQLite 文章、任务和运行历史持久化
- `JizhiliaClient`: endpoint payloads, HTTP calls, parsing, retry/fallback / endpoint 请求、HTTP 调用、解析、重试与回退
- `ExportService`: Markdown and XML export / Markdown 与 XML 导出
- `BuiltinPluginRegistry`: CTK-style provider/exporter/analyzer extension points / CTK 风格 Provider、Exporter、Analyzer 扩展点
- `AppController`: QML-facing orchestration layer / 面向 QML 的编排层

## Safety / 安全边界

- No API token is required for local self-test. / 本地自检不需要 API token。
- Build and runtime outputs are ignored. / 构建和运行产物不入库。
- Vendor API examples are sanitized. / vendor API 示例已脱敏。
- GitHub delivery uses process-local credentials only when needed. / GitHub 上传只在需要时使用进程内临时凭据。
