# 自媒体爆款助手

一个本地优先的 C++20 / Qt6 / QML 桌面端内容分析工作台，面向公众号爆款文章采集、拆解、选题和导出。

## 它解决什么问题

内容团队通常需要在多个工具之间切换：采集文章、保存素材、看阅读点赞、整理选题、导出报告。自媒体爆款助手把这些步骤收敛到一个本地桌面端里：

- 按关键词或 endpoint 采集内容。
- SQLite 本地保存文章、任务和运行历史。
- 生成爆款评分和拆解报告。
- 基于高表现内容生成选题建议。
- 导出 Markdown 和 XML。

## 页面

- 仪表盘：统计、快速采集、全流程自检。
- 内容库：文章列表、刷新、Markdown/XML 导出。
- 接口库：极致了 API 分类查询和 endpoint 采集。
- 拆解报告：阅读、点赞、爆款评分、结构化观察。
- 选题推荐：根据内容库生成选题。
- 插件：Provider、Exporter、Analyzer 清单和插件分析。
- 设置：API 参数、采集频率、采集次数、QPS、导出目录、运行历史。

## 快速开始

```bash
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build -j2
ctest --test-dir build --output-on-failure
QT_QPA_PLATFORM=offscreen ./build/media-hit-assistant --self-test
```

## 全量验证

```bash
./scripts/verify-all.sh
```

该脚本会检查构建、单元测试、自检导出、QML 控件、DevPrompt 对齐和 offscreen 启动。

## 安全说明

- 本地自检不需要 API Key。
- 未配置 API Key 时使用安全示例采集。
- 真实密钥不要提交到 Git。
- vendor API 示例已经脱敏。
