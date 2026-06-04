# Plugin Guide

Media Hit Assistant exposes CTK-style extension points for providers, exporters, and analyzers. The current release uses a built-in registry so the desktop app remains portable across Linux, Windows, and Docker without shipping platform-specific dynamic libraries.

## Current extension points

| Extension point | Purpose | Current built-ins |
|---|---|---|
| Provider | Content source integration. | `provider:content-data` |
| Exporter | Output format generation. | `exporter:markdown`, `exporter:xml` |
| Analyzer | Report and scoring logic. | `analyzer:hit-score` |

## Dynamic metadata scan

The registry can inspect plugin metadata folders and report invalid entries without loading executable code. This makes the current plugin surface safe and testable while preserving a future runtime loader path.

Recommended layout:

```text
plugins/
  providers/
  exporters/
  analyzers/
```

Metadata files should describe an `id`, `name`, and `kind`. Invalid metadata is reported as blocked and must not break built-in plugins.

## Stability contract

- Keep QML calls stable: `pluginRows()`, `pluginDetail()`, `pluginExportPreview()`, `pluginScanReport()`, and `pluginAnalysis()`.
- Keep documented provider, exporter, and analyzer IDs stable.
- Dynamic plugins must fail closed.
- Runtime `.so` and `.dll` loading is a future item, not a current release claim.

## Adding a built-in analyzer

1. Add the analyzer ID to `BuiltinPluginRegistry`.
2. Implement the report text using article data only.
3. Add a QtTest assertion for the generated analysis.
4. Expose descriptor text through `pluginDescriptor()`.
5. Run `./scripts/verify-all.sh`.
