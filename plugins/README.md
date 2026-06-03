# Plugin drop-in directory / 插件投放目录

This directory is reserved for future CTK dynamic plugin loading.

该目录预留给后续 CTK 动态插件加载。

Current release behavior:

当前版本行为：

- Built-in plugins are always available.
- Dynamic libraries are not loaded automatically yet.
- The app exposes `dynamicPluginHints()` so the UI and docs share the same future contract.

- 内置插件始终可用。
- 当前尚不自动加载动态库。
- 应用暴露 `dynamicPluginHints()`，使 UI 和文档共享同一未来契约。

Suggested future layout:

建议后续目录：

```text
plugins/
  providers/
  exporters/
  analyzers/
```
