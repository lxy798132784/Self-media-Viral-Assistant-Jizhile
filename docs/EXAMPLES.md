# 使用示例 / Examples

## 1. 创建采集任务 / Create a collection task

在“设置”页填写：

Fill in the Settings page:

- 任务名称 / Task name：AI 爆文监控
- 关键词 / Keyword：AI
- 接口路径 / Endpoint path：`/fbmain/monitor/v3/web_search`
- 频率 / Frequency：300 秒 / seconds
- 次数 / Run count：10
- QPS：1.5

点击“保存采集任务”。

Click "保存采集任务" to save the task.

## 2. 运行示例采集 / Run sample collection

点击“立即采集”或仪表盘的“全流程自检”。系统会生成样本文章并写入 SQLite。

Click "立即采集" or "全流程自检". The app writes sample articles into SQLite when no API key is configured.

## 3. 按接口采集 / Collect through a chosen endpoint

进入“接口库”，输入分类关键词（例如“公众号”）后点击“查询接口”。复制或输入 endpoint path，再输入关键词，点击“按接口采集”。

Open "接口库", enter a category keyword such as "公众号", click "查询接口", then enter an endpoint path and keyword and click "按接口采集".

## 4. 查看内容库 / Review the content library

进入“内容库”，点击“刷新”，查看采集结果。内容会按综合热度排序显示。

Open "内容库" and click "刷新". Articles are displayed by combined popularity score.

## 5. 导出 / Export

内容库支持：

The content library supports:

- Markdown：`/tmp/media-hit-articles.md`
- XML：`/tmp/media-hit-articles.xml`

## 6. 插件分析 / Plugin analysis

进入“插件”，点击“刷新插件”查看 Provider、Exporter、Analyzer。点击“插件分析”生成爆款评分报告。

Open "插件", click "刷新插件" to view Provider, Exporter, and Analyzer entries. Click "插件分析" to generate the hit-score report.

## 7. 命令行自检 / Command-line self-test

```bash
QT_QPA_PLATFORM=offscreen ./build/media-hit-assistant --self-test
```

产物 / Artifacts:

- `/tmp/media-hit-self-test.md`
- `/tmp/media-hit-self-test.xml`

## 8. 全流程验证 / Full verification

```bash
./scripts/verify-all.sh
```

该脚本验证构建、单元测试、自检导出、QML 控件审计、DevPrompt 对齐关键词和 offscreen 启动。

The script verifies build, unit tests, self-test exports, QML control audit, DevPrompt alignment keywords, and offscreen launch.
