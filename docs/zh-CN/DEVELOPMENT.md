# 开发指南

本文面向希望构建、测试、打包或扩展自媒体爆款助手的开发者。

## 开发环境

Ubuntu 24.04 示例：

```bash
sudo apt-get update
sudo apt-get install -y cmake g++ python3 \
  qt6-base-dev qt6-declarative-dev qt6-tools-dev \
  qml6-module-qtquick qml6-module-qtquick-controls qml6-module-qtquick-layouts
```

配置并构建：

```bash
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build -j2
```

### 分平台部署

具体安装、卸载、Release 包使用和不同 CPU 架构的说明见 [部署与开发指南](DEPLOYMENT.md)。该文档覆盖 Linux amd64、Linux arm64/aarch64、Windows x64、Docker/CI 和 macOS 源码构建注意事项。

## 项目结构

```text
include/        C++ 公开接口
src/            服务实现
ui/             QML 界面
tests/          QtTest 单元测试
scripts/        验证与打包脚本
packaging/      桌面元数据
docs/           英文文档、中文文档与资源
vendor/         已脱敏内置 API 知识库
plugins/        插件契约与元数据示例
```

## 核心模块

| 模块 | 职责 |
|---|---|
| `ConfigManager` | API Key、验证码、频率、次数、QPS 和导出目录。 |
| `ApiCatalog` | 内置极致了 API 索引加载和查询。 |
| `JizhiliaClient` | 请求体创建、HTTP 调用、JSON 解析、重试和回退。 |
| `DatabaseManager` | SQLite schema、文章、任务和运行历史。 |
| `ExportService` | Markdown 与 XML 输出。 |
| `BuiltinPluginRegistry` | CTK 风格 Provider、Exporter、Analyzer 条目。 |
| `AppController` | 面向 QML 的编排。 |

## 测试流程

开发中的快速检查：

```bash
cmake --build build -j2
ctest --test-dir build --output-on-failure
```

提交前全量门禁：

```bash
./scripts/verify-all.sh
```

全量门禁包含：CMake 构建、QtTest、offscreen 自检、Markdown/XML 产物检查、QML 控件审计、文档对齐审计和 offscreen 启动烟测。

## 新增 API endpoint

1. 在 `vendor/jizhilia-api-knowledge/api-index.json` 中新增或更新 endpoint。
2. 通过 `ApiCatalog::findByCategory()` 或 `ApiCatalog::findByPath()` 暴露。
3. 通过 `JizhiliaClient::callEndpointBlocking()` 采集。
4. 添加 QtTest 断言覆盖 endpoint path 或请求体。
5. 运行 `./scripts/verify-all.sh`。

不要在测试或运行时代码中使用机器相关的绝对路径。

## 新增导出器

1. 在 `ExportService` 或插件条目中实现输出行为。
2. 如果需要出现在插件列表中，把它加入 `BuiltinPluginRegistry`。
3. 添加生成文本和转义行为测试。
4. 只有存在真实后端动作和读回状态时，才添加 QML 按钮。

## 文档规则

- 英文文档放在 `README.md` 和 `docs/*.md`。
- 中文文档放在 `docs/README.zh-CN.md` 和 `docs/zh-CN/*.md`。
- 不要在同一篇文档正文中混写中英文解释。
- 不暴露真实凭据、私有 URL 或内部实现备注。
- 示例必须可运行，并与脚本保持一致。

## 提交清单

```bash
git diff --check
./scripts/verify-all.sh
./scripts/package-linux.sh
cmake --install build --prefix /tmp/media-hit-install
```

推送前确认没有构建产物、运行数据库、打包产物或密钥进入 tracked 文件。
