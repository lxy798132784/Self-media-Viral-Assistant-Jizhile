# 使用示例

自媒体爆款助手的常用工作流示例。

## 无凭据首次运行

不配置任何 API Key 也可以测试完整产品流程。

```bash
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build -j2
QT_QPA_PLATFORM=offscreen ./build/media-hit-assistant --self-test
```

预期产物：

- `/tmp/media-hit-self-test.md`
- `/tmp/media-hit-self-test.xml`
- `/tmp/media-hit-self-test-combined-report.md`

## 创建采集任务

打开“设置”并填写：

| 字段 | 示例 |
|---|---|
| 任务名称 | AI 爆文监控 |
| 关键词 | AI |
| 接口路径 | `/fbmain/monitor/v3/web_search` |
| 频率 | 300 秒 |
| 次数 | 10 |
| QPS | 1.5 |

点击保存任务后，任务会出现在任务列表中，并可从界面运行。

## 按 endpoint 采集

1. 打开“接口库”。
2. 输入分类关键词，例如 `公众号`。
3. 执行接口查询。
4. 选择一个 endpoint 行。
5. 输入内容关键词。
6. 按 endpoint 运行采集。
7. 在运行历史中查看回执。

## 查看和导出

打开“内容库”：

- 刷新文章列表；
- 选择文章查看详情；
- 导出 Markdown；
- 导出 XML。

默认自检产物会写入 `/tmp`。

## 使用公众号爆文 API 页面

1. 打开公众号爆文 API 页面。
2. 填写 `key`、`keyword`、`pub_type`、`category`、`page`、`start_time`、`end_time`。
3. 生成请求预览。
4. 运行采集。没有凭据时会进入安全示例回退。

## 查看插件

打开“插件”：

1. 刷新插件列表；
2. 查看 Provider、Exporter、Analyzer 描述；
3. 预览 Markdown 或 XML 导出；
4. 生成插件分析；
5. 查看动态插件扫描报告。

## 开发者全量验证

```bash
./scripts/verify-all.sh
```

每次交付前都应运行该命令。
