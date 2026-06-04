# 插件指南

自媒体爆款助手提供 CTK 风格 Provider、Exporter、Analyzer 扩展点。当前版本使用内置注册表，避免在 Linux、Windows、Docker 之间分发平台相关动态库。

## 当前扩展点

| 扩展点 | 用途 | 当前内置项 |
|---|---|---|
| Provider | 内容源接入。 | `provider:jizhilia` |
| Exporter | 输出格式生成。 | `exporter:markdown`、`exporter:xml` |
| Analyzer | 报告与评分逻辑。 | `analyzer:hit-score` |

## 动态元数据扫描

注册表可以检查插件元数据目录，并在不加载可执行代码的情况下报告非法条目。这样当前插件面保持安全、可测试，同时保留未来 runtime loader 路径。

建议目录：

```text
plugins/
  providers/
  exporters/
  analyzers/
```

元数据文件应描述 `id`、`name` 和 `kind`。非法元数据会被标记为 blocked，但不能影响内置插件。

## 稳定性契约

- 保持 QML 调用稳定：`pluginRows()`、`pluginDetail()`、`pluginExportPreview()`、`pluginScanReport()`、`pluginAnalysis()`。
- 已文档化的 Provider、Exporter、Analyzer ID 应保持稳定。
- 动态插件必须 fail closed。
- 运行时 `.so` 与 `.dll` 加载是未来事项，不是当前版本声明。

## 新增内置分析器

1. 在 `BuiltinPluginRegistry` 中增加 analyzer ID。
2. 只使用文章数据实现报告文本。
3. 添加 QtTest 断言覆盖生成的分析内容。
4. 通过 `pluginDescriptor()` 暴露描述文本。
5. 运行 `./scripts/verify-all.sh`。
