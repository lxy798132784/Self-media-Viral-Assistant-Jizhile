# Developer Guide / 开发文档

This guide is for contributors who want to build, test, package, or extend Media Hit Assistant.

本文面向希望构建、测试、打包或扩展自媒体爆款助手的开发者。

## Development setup / 开发环境

Ubuntu 24.04 example:

```bash
sudo apt-get update
sudo apt-get install -y cmake g++ python3   qt6-base-dev qt6-declarative-dev qt6-tools-dev   qml6-module-qtquick qml6-module-qtquick-controls qml6-module-qtquick-layouts
```

Configure and build:

```bash
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build -j2
```

## Project structure / 项目结构

```text
include/        public C++ interfaces / C++ 公开接口
src/            service implementations / 服务实现
ui/             QML interface / QML 界面
tests/          QtTest unit tests / QtTest 单元测试
scripts/        verification and packaging scripts / 验证与打包脚本
packaging/      desktop metadata / 桌面元数据
docs/           product and developer docs / 产品与开发文档
vendor/         sanitized API knowledge / 已脱敏 API 知识库
```

## Core modules / 核心模块

| Module / 模块 | Responsibility / 职责 |
|---|---|
| `ConfigManager` | API key, verify code, interval, run count, QPS, export directory / API 参数、频率、次数、QPS、导出目录 |
| `ApiCatalog` | Local Jizhilia API index loading and search / 本地极致了 API 索引加载和查询 |
| `JizhiliaClient` | Payload creation, HTTP call, JSON parsing, retry/fallback / 请求体、HTTP、JSON 解析、重试与回退 |
| `DatabaseManager` | SQLite schema, articles, tasks, run history / SQLite schema、文章、任务、运行历史 |
| `ExportService` | Markdown and XML output / Markdown 与 XML 输出 |
| `BuiltinPluginRegistry` | CTK-style Provider, Exporter, Analyzer entries / CTK 风格插件入口 |
| `AppController` | QML-facing orchestration / 面向 QML 的编排 |

## Testing workflow / 测试流程

Run fast checks while developing:

开发中先跑快速检查：

```bash
cmake --build build -j2
ctest --test-dir build --output-on-failure
```

Run full gates before committing:

提交前跑全量门禁：

```bash
./scripts/verify-all.sh
```

The full gate includes:

全量门禁包含：

- CMake build / CMake 构建
- QtTest suite / QtTest 测试
- offscreen self-test / offscreen 自检
- Markdown and XML artifact checks / Markdown 与 XML 产物检查
- QML control audit / QML 控件审计
- DevPrompt alignment audit / DevPrompt 对齐审计

## Adding a new API endpoint / 新增 API endpoint

1. Add or update the endpoint entry in the local API index.
2. Use `ApiCatalog::findByCategory()` or `findByPath()` to expose it.
3. Use `JizhiliaClient::callEndpointBlocking()` for collection.
4. Add a QtTest assertion covering the endpoint path or payload.
5. Run `./scripts/verify-all.sh`.

1. 在本地 API 索引中新增或更新 endpoint。
2. 通过 `ApiCatalog::findByCategory()` 或 `findByPath()` 暴露。
3. 通过 `JizhiliaClient::callEndpointBlocking()` 采集。
4. 添加 QtTest 断言覆盖 endpoint path 或 payload。
5. 运行 `./scripts/verify-all.sh`。

## Adding an exporter / 新增导出器

1. Implement export behavior in `ExportService` or a plugin entry.
2. Add it to `BuiltinPluginRegistry` if it should appear in the plugin list.
3. Add tests for generated text and escaping behavior.
4. Add a QML button only if it has a real backend action.

1. 在 `ExportService` 或插件入口实现导出行为。
2. 如果需要出现在插件列表中，把它加入 `BuiltinPluginRegistry`。
3. 添加生成文本与转义行为测试。
4. 只有存在真实后端动作时才添加 QML 按钮。

## Documentation rules / 文档规则

- README should explain value, quick start, architecture, quality gates, and roadmap.
- User-facing docs should be bilingual where practical.
- Do not expose real credentials, private URLs, or internal implementation notes.
- Keep examples runnable and aligned with scripts.

- README 要讲清价值、快速开始、架构、质量门禁和路线图。
- 用户可见文档尽量中英文双语。
- 不暴露真实凭据、私有 URL 或内部实现备注。
- 示例必须可运行，并与脚本保持一致。
