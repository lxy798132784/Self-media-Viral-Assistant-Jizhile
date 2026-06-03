# Media Hit Assistant / 自媒体爆款助手

<p align="center">
  <strong>A local-first desktop workspace for collecting, reviewing, analyzing, and exporting public-account hit articles.</strong><br />
  <strong>一个本地优先的桌面工作台：采集公众号爆款文章，沉淀内容库，生成拆解报告和选题推荐，并导出 Markdown / XML。</strong>
</p>

<p align="center">
  <a href="https://github.com/lxy798132784/Self-media-Viral-Assistant-Jizhile/actions"><img alt="CI" src="https://img.shields.io/badge/CI-Qt6%20build%20%7C%20CTest%20%7C%20self--test-blue"></a>
  <img alt="C++20" src="https://img.shields.io/badge/C%2B%2B-20-00599C">
  <img alt="Qt6" src="https://img.shields.io/badge/Qt-6-41CD52">
  <img alt="SQLite" src="https://img.shields.io/badge/SQLite-local--first-003B57">
  <img alt="Platforms" src="https://img.shields.io/badge/Linux%20%7C%20Windows%20%7C%20Docker-ready-7A4DFF">
</p>

---

## Why this project exists / 为什么做这个项目

Most creator tools stop at either scraping or note-taking. **Media Hit Assistant** connects the whole loop:

多数自媒体工具要么只采集，要么只做笔记。**自媒体爆款助手**把完整流程串起来：

1. **Collect / 采集** — collect public-account articles through configurable Jizhilia endpoints or safe local samples.
2. **Store / 沉淀** — keep articles, tasks, and run history in SQLite.
3. **Analyze / 拆解** — calculate hit scores and produce structured observations.
4. **Recommend / 选题** — turn high-performing content patterns into topic ideas.
5. **Export / 交付** — export Markdown and XML artifacts for downstream workflows.

The app is built as a **C++20 + Qt6 + QML desktop application** with a CTK-style plugin surface, so provider APIs, exporters, and analyzers can evolve independently.

该项目是 **C++20 + Qt6 + QML 桌面应用**，并预留 CTK 风格插件扩展面，后续 Provider、Exporter、Analyzer 可以独立演进。

---

## Highlights / 功能亮点

| Area / 模块 | What it does / 能力 |
|---|---|
| Dashboard / 仪表盘 | Collection entry point, content statistics, full workflow self-check / 快速采集、统计概览、全流程自检 |
| Content Library / 内容库 | SQLite-backed article library with refresh and export actions / SQLite 内容库，支持刷新和导出 |
| API Catalog / 接口库 | Browse local Jizhilia API index, filter by category, collect by endpoint path / 浏览本地极致了 API 索引，按分类筛选，按 endpoint 采集 |
| Analysis Report / 拆解报告 | Hit score, read/like metrics, structured observations / 爆款评分、阅读点赞指标、结构化观察 |
| Topic Recommendation / 选题推荐 | Generate topic ideas from high-performing article patterns / 从高表现内容模式生成选题 |
| Plugins / 插件 | CTK-style Provider / Exporter / Analyzer registry / CTK 风格 Provider、Exporter、Analyzer 注册表 |
| Settings / 设置 | API key, verify code, endpoint path, frequency, run count, QPS, export directory, run history / API 参数、采集频率次数、QPS、导出目录、运行历史 |

---

## Screenshots / 界面预览

The repository currently ships source code and verification gates. Screenshots can be added under `docs/assets/` after packaging a release build.

当前仓库交付源码和验证门禁。正式发布包截图可放在 `docs/assets/`。

```text
┌──────────────────────────────────────────────────────────────┐
│ Dashboard | Library | API Catalog | Report | Topics | Plugins │
├──────────────────────────────────────────────────────────────┤
│  Quick collection  •  SQLite stats  •  Full workflow check    │
│  Endpoint catalog  •  Markdown/XML export  •  Hit analysis    │
└──────────────────────────────────────────────────────────────┘
```

---

## Quick start / 快速开始

### 1. Install dependencies / 安装依赖

Ubuntu 24.04 example:

```bash
sudo apt-get update
sudo apt-get install -y cmake g++ python3   qt6-base-dev qt6-declarative-dev qt6-tools-dev   qml6-module-qtquick qml6-module-qtquick-controls qml6-module-qtquick-layouts
```

### 2. Build and test / 构建与测试

```bash
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build -j2
ctest --test-dir build --output-on-failure
```

### 3. Run the desktop app / 启动桌面端

```bash
./build/media-hit-assistant
```

Headless self-test:

```bash
QT_QPA_PLATFORM=offscreen ./build/media-hit-assistant --self-test
```

### 4. Run the full verification gate / 运行全量门禁

```bash
./scripts/verify-all.sh
```

This checks build, CTest, self-test export artifacts, QML control coverage, DevPrompt alignment, and offscreen launch.

该脚本检查构建、CTest、自检导出、QML 控件覆盖、DevPrompt 对齐和 offscreen 启动。

---

## Configuration / 配置

Credentials are never required for local self-test. If no API key is configured, the app uses safe sample collection so the whole workflow remains testable without spending API quota.

本地自检不需要凭据。未配置 API Key 时，应用会使用安全示例采集，不消耗接口额度，也能完整验证采集、分析、导出链路。

Configurable fields:

可配置项：

- Jizhilia API key / 极致了 API Key
- Verify code / 验证码
- Endpoint path / 接口路径
- Collection interval / 采集频率
- Max run count / 采集次数
- QPS limit / QPS 限速
- Export directory / 导出目录

> Do not commit real credentials. Keep secrets in local settings or environment variables only.
>
> 不要提交真实凭据。密钥只能留在本机设置或环境变量中。

---

## Packaging / 打包

### Linux

```bash
./scripts/package-linux.sh
cmake --install build --prefix /tmp/media-hit-install
```

Installed files:

- `bin/media-hit-assistant`
- `share/applications/com.mediahit.Assistant.desktop`
- `share/metainfo/com.mediahit.Assistant.metainfo.xml`
- `share/icons/hicolor/scalable/apps/com.mediahit.Assistant.svg`

### Windows

```powershell
.\scripts\package-windows.ps1
```

### Docker

```bash
docker build -t media-hit-assistant .
docker run --rm media-hit-assistant
```

---

## Architecture / 架构

```text
QML UI
  └─ AppController (Q_INVOKABLE facade)
      ├─ ConfigManager       local API and task settings
      ├─ ApiCatalog          local Jizhilia endpoint index
      ├─ JizhiliaClient      payloads, HTTP, parsing, retry/fallback
      ├─ DatabaseManager     SQLite articles, tasks, run history
      ├─ ExportService       Markdown / XML artifacts
      └─ BuiltinPluginRegistry
           ├─ Provider       source integration point
           ├─ Exporter       export format extension point
           └─ Analyzer       hit-score and future analysis plugins
```

Design principles:

设计原则：

- **Local-first / 本地优先** — SQLite persistence and offline self-test.
- **Safe by default / 默认安全** — sample fallback when credentials are missing.
- **Plugin-ready / 插件可扩展** — CTK-style interfaces for providers, exporters, analyzers.
- **Verifiable / 可验证** — every visible QML button is checked by an audit script.
- **Cross-platform / 跨平台** — Linux, Windows, Docker, and architecture-neutral Qt builds.

---

## Repository layout / 仓库结构

```text
include/        C++ public headers / C++ 头文件
src/            C++ implementation / C++ 实现
ui/             QML desktop interface / QML 桌面界面
tests/          QtTest unit tests / QtTest 单元测试
scripts/        build, package, audit scripts / 构建、打包、审计脚本
packaging/      desktop entry, AppStream metadata, icon / 桌面入口、元数据、图标
docs/           user, developer, architecture docs / 用户、开发、架构文档
vendor/         sanitized local Jizhilia API knowledge / 已脱敏本地极致了 API 知识库
```

---

## Documentation / 文档

- [Project specification / 项目规格](docs/PROJECT-SPEC.md)
- [Architecture / 架构说明](docs/ARCHITECTURE.md)
- [Developer guide / 开发文档](docs/DEVELOPMENT.md)
- [Examples / 使用示例](docs/EXAMPLES.md)
- [Chinese overview / 中文说明](docs/README.zh-CN.md)

---

## Quality gates / 质量门禁

| Gate / 门禁 | Command / 命令 |
|---|---|
| Build / 构建 | `cmake --build build -j2` |
| Unit tests / 单元测试 | `ctest --test-dir build --output-on-failure` |
| Self-test / 自检 | `QT_QPA_PLATFORM=offscreen ./build/media-hit-assistant --self-test` |
| QML controls / QML 控件 | `python3 scripts/audit_qml_controls.py` |
| DevPrompt alignment / 需求对齐 | `python3 scripts/audit_devprompt_alignment.py` |
| Full verification / 全量验证 | `./scripts/verify-all.sh` |

---

## Roadmap / 路线图

- [x] SQLite content library, task table, run history / SQLite 内容库、任务表、运行历史
- [x] Markdown and XML export / Markdown 与 XML 导出
- [x] API catalog and endpoint collection / API 目录与 endpoint 采集
- [x] CTK-style plugin registry / CTK 风格插件注册表
- [x] Linux, Windows, Docker delivery scripts / Linux、Windows、Docker 交付脚本
- [ ] Dynamic CTK plugin loading / 动态 CTK 插件加载
- [ ] Release screenshots and signed installers / 发布截图和签名安装包
- [ ] More analyzers: title patterns, structure templates, topic clusters / 更多分析器：标题模式、结构模板、选题聚类

---

## Security / 安全

- No secrets are required for local tests.
- Real API keys must stay outside Git.
- Vendor API examples are sanitized.
- Build outputs, runtime databases, and generated packages are ignored.

- 本地测试不需要密钥。
- 真实 API Key 不进入 Git。
- vendor API 示例已脱敏。
- build、运行数据库、打包产物均被忽略。

---

## Contributing / 贡献

1. Write or update tests first.
2. Run `./scripts/verify-all.sh`.
3. Keep user-facing docs bilingual when the change affects behavior.
4. Never commit credentials, runtime databases, build outputs, or generated packages.

1. 先写或更新测试。
2. 运行 `./scripts/verify-all.sh`。
3. 行为变化时同步更新中英文用户文档。
4. 不提交密钥、运行数据库、build 产物或打包产物。

---

## License / 许可证

This repository does not currently declare a license. Add one before public reuse or redistribution.

当前仓库尚未声明许可证。公开复用或分发前应补充许可证。
