# Plugin Guide / 插件指南

Media Hit Assistant exposes CTK-style extension points for providers, exporters, and analyzers. The first release uses a built-in registry so the desktop app remains portable across Linux, Windows, and Docker without shipping platform-specific dynamic libraries.

自媒体爆款助手提供 CTK 风格的 Provider、Exporter、Analyzer 扩展点。首版使用内置注册表，避免在 Linux、Windows、Docker 之间分发平台相关动态库。

## Current extension points / 当前扩展点

| Extension point / 扩展点 | Purpose / 用途 | Current built-ins / 当前内置项 |
|---|---|---|
| Provider | Content source integration / 内容源接入 | `provider:jizhilia` |
| Exporter | Output format generation / 输出格式生成 | `exporter:markdown`, `exporter:xml` |
| Analyzer | Report and scoring logic / 报告与评分逻辑 | `analyzer:hit-score` |

## Dynamic loading path / 动态加载路径

`BuiltinPluginRegistry::dynamicPluginHints()` documents the intended `plugins/` directory contract. A future CTK runtime loader can scan this directory and register dynamic libraries into the same QML-facing registry.

`BuiltinPluginRegistry::dynamicPluginHints()` 记录了预期的 `plugins/` 目录契约。后续真实 CTK runtime loader 可扫描该目录，并把动态库注册到同一个面向 QML 的 registry。

Recommended future layout:

建议后续目录：

```text
plugins/
  providers/
  exporters/
  analyzers/
```

## Stability contract / 稳定性契约

- Keep QML calls stable: `pluginRows()` and `pluginAnalysis()` should not change.
- Keep provider/exporter/analyzer IDs stable once documented.
- Dynamic plugins must fail closed: if a plugin fails to load, the built-in registry should still work.

- 保持 QML 调用稳定：`pluginRows()` 和 `pluginAnalysis()` 不应随意变化。
- Provider、Exporter、Analyzer 的 ID 一旦文档化，应保持稳定。
- 动态插件必须 fail closed：插件加载失败时，内置注册表仍应可用。
