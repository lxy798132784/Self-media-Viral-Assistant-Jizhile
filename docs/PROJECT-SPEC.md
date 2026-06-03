# 自媒体爆款助手项目规格 / Media Hit Assistant Specification

## 目标 / Goal
使用 C++20、CMake、Qt6、QML、SQLite 和 CTK-ready 插件化架构开发跨平台自媒体爆款助手。首版聚焦公众号爆款文章收集分析，接入极致了 API 本地文档资料库。

## MVP 范围 / MVP Scope
- 仪表盘：采集状态、内容数量、平均阅读、爆款候选。
- 内容库：文章列表、关键词搜索、Markdown/XML 导出。
- 拆解报告：标题、作者、阅读点赞、爆款评分、结构化观察。
- 选题推荐：基于内容库关键词和阅读/点赞指标生成选题。
- 设置：API Key、verifycode、采集频率、次数、QPS、导出目录。

## 安全 / Security
API Key 只从环境变量或本地设置读取，不提交到仓库。默认示例使用 mock 数据，避免误扣费。
