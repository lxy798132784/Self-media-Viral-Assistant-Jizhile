# 使用示例 / Examples

## 1. 创建采集任务

在设置页填写：

- 任务名称：AI 爆文监控
- 关键词：AI
- 频率：300 秒
- 次数：10

点击“保存采集任务”。

## 2. 运行 Mock 采集

点击“立即采集”或仪表盘的“Mock 采集闭环”。系统会生成 5 条样本文章并写入 SQLite。

## 3. 查看内容库

进入“内容库”，点击刷新，查看采集结果。

## 4. 导出

内容库支持：

- Markdown：`/tmp/media-hit-articles.md`
- XML：`/tmp/media-hit-articles.xml`

## 5. 命令行自检

```bash
QT_QPA_PLATFORM=offscreen ./build/media-hit-assistant --self-test
```
