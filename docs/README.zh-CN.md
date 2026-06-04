# 自媒体爆款助手

一个本地优先的 C++20、Qt6、QML 桌面端内容分析工作台，面向公众号爆款文章采集、内容库沉淀、拆解报告、选题推荐和 Markdown/XML 导出。

## 语言说明

- 英文文档：仓库根目录 `README.md` 与 `docs/*.md`。
- 中文文档：本文档与 `docs/zh-CN/*.md`。

## 为什么做这个项目

内容团队经常在采集工具、表格、笔记软件和报告模板之间切换。自媒体爆款助手把这些步骤收敛到一个本地桌面端：

1. 按关键词、爆文 API 表单或 endpoint 采集文章；
2. 用 SQLite 保存文章、采集任务和运行历史；
3. 查看阅读、点赞和爆款评分；
4. 从高表现文章提炼选题方向；
5. 导出 Markdown 和 XML 产物。

## 功能亮点

| 模块 | 能力 |
|---|---|
| 仪表盘 | 快速采集、统计概览、全流程自检。 |
| 内容库 | 文章列表、详情查看、刷新、Markdown/XML 导出。 |
| 接口库 | 使用仓库内置极致了 API 索引，支持分类筛选、endpoint 详情和按 endpoint 采集。 |
| 公众号爆文 API | 独立页面覆盖 `key`、`keyword`、`pub_type`、`category`、`page`、`start_time`、`end_time` 参数控件。 |
| 语言切换 | 软件界面可切换中文或英文，避免同一个控件里混杂两种语言。 |
| 拆解报告 | 生成阅读、点赞、爆款评分和结构化观察。 |
| 选题推荐 | 根据内容库里的高表现内容生成选题。 |
| 插件 | 提供 Provider、Exporter、Analyzer 注册表、详情、导出预览和扫描报告。 |
| 设置 | 配置 API Key、验证码、endpoint、采集频率、采集次数、QPS、导出目录、任务和运行历史。 |

## 快速开始

```bash
sudo apt-get update
sudo apt-get install -y cmake g++ python3 \
  qt6-base-dev qt6-declarative-dev qt6-tools-dev \
  qml6-module-qtquick qml6-module-qtquick-controls qml6-module-qtquick-layouts
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build -j2
ctest --test-dir build --output-on-failure
QT_QPA_PLATFORM=offscreen ./build/media-hit-assistant --self-test
```

## 全量验证

```bash
./scripts/verify-all.sh
```

该门禁会运行构建、CTest、自检、导出产物检查、QML 控件审计、文档对齐审计和 offscreen 启动烟测。

## 配置与安全

本地测试不需要真实密钥。没有配置 API Key 时，软件会使用安全示例采集，保证完整流程可以验证且不消耗接口额度。

可配置项包括：极致了 API Key、验证码、endpoint 路径、公众号爆文 API 参数、界面语言、采集频率、最大运行次数、QPS 限速和导出目录。

真实密钥不要提交到 Git，只能保存在本机设置或环境变量中。

## 文档索引

- [项目规格](zh-CN/PROJECT-SPEC.md)
- [架构说明](zh-CN/ARCHITECTURE.md)
- [开发指南](zh-CN/DEVELOPMENT.md)
- [使用示例](zh-CN/EXAMPLES.md)
- [插件指南](zh-CN/PLUGIN_GUIDE.md)

## 许可证

MIT。详见仓库根目录 `LICENSE`。
