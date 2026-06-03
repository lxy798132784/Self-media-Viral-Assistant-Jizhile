# Examples / 使用示例

Practical workflows for Media Hit Assistant.

自媒体爆款助手的常用工作流示例。

## 1. First run without credentials / 无凭据首次运行

You can test the full product flow without configuring any API key.

不配置任何 API Key 也可以测试完整产品流程。

```bash
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build -j2
QT_QPA_PLATFORM=offscreen ./build/media-hit-assistant --self-test
```

Expected artifacts:

预期产物：

- `/tmp/media-hit-self-test.md`
- `/tmp/media-hit-self-test.xml`

## 2. Create a collection task / 创建采集任务

Open **Settings / 设置** and fill in:

打开 **设置** 页面并填写：

| Field / 字段 | Example / 示例 |
|---|---|
| Task name / 任务名称 | AI 爆文监控 |
| Keyword / 关键词 | AI |
| Endpoint path / 接口路径 | `/fbmain/monitor/v3/web_search` |
| Frequency / 频率 | 300 seconds / 300 秒 |
| Run count / 次数 | 10 |
| QPS | 1.5 |

Click **保存采集任务**.

点击 **保存采集任务**。

## 3. Collect by endpoint / 按 endpoint 采集

1. Open **API Catalog / 接口库**.
2. Enter a category keyword such as `公众号`.
3. Click **查询接口**.
4. Copy or type an endpoint path.
5. Enter a keyword.
6. Click **按接口采集**.

1. 打开 **接口库**。
2. 输入分类关键词，例如 `公众号`。
3. 点击 **查询接口**。
4. 复制或输入 endpoint path。
5. 输入关键词。
6. 点击 **按接口采集**。

## 4. Review and export / 查看与导出

Open **Content Library / 内容库**:

打开 **内容库**：

- Click **刷新** to reload articles.
- Click **导出 Markdown** to write `/tmp/media-hit-articles.md`.
- Click **导出 XML** to write `/tmp/media-hit-articles.xml`.

- 点击 **刷新** 重新读取文章。
- 点击 **导出 Markdown** 写入 `/tmp/media-hit-articles.md`。
- 点击 **导出 XML** 写入 `/tmp/media-hit-articles.xml`。

## 5. Generate plugin analysis / 生成插件分析

Open **Plugins / 插件**:

打开 **插件**：

1. Click **刷新插件**.
2. Confirm Provider, Exporter, and Analyzer entries are listed.
3. Click **插件分析** to generate the hit-score report.

1. 点击 **刷新插件**。
2. 确认 Provider、Exporter、Analyzer 已列出。
3. 点击 **插件分析** 生成爆款评分报告。

## 6. Full developer verification / 开发者全量验证

```bash
./scripts/verify-all.sh
```

This is the command to run before every delivery.

每次交付前都应运行该命令。
