# 开发文档 / Developer Guide

## 模块说明

### ConfigManager
管理 API Key、验证码、采集频率、次数、QPS 和导出目录。真实密钥只保存在本机设置或环境变量中。

### ApiCatalog
读取 `vendor/jizhilia-api-knowledge/api-index.json`，提供极致了 API 文档索引。

### DatabaseManager
负责 SQLite schema、文章表、采集任务表和采集记录表。

### JizhiliaClient
负责构造极致了 API 请求 payload、判断可重试状态、计算退避延迟，并提供 mock fallback 数据。

### ExportService
导出 Markdown 和 XML。

### AppController
QML 门面层，连接 UI 与后端服务。

## 开发原则

- 新功能先写 Qt Test。
- 每个关键函数使用中英文双语注释。
- 真实 API Key 不写源码、不写文档、不写 Git。
- 所有网络请求必须经过限速和重试策略。
- 扣费接口必须先查缓存再请求。

## 下一阶段任务

1. 增加真实异步 HTTP 请求：`QNetworkAccessManager` + request queue。
2. 将极致了 API 响应解析成标准 Article。
3. 增加内容库排序/过滤字段。
4. 增加 CTK 插件接口：ProviderPlugin、ExporterPlugin、AnalyzerPlugin。
5. 增加 Windows/Linux/Docker 打包流水线。
