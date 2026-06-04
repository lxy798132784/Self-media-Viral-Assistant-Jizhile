# Changelog

All notable changes to this project are summarized here.

## Unreleased

### Added

- Local-first C++20, Qt6, and QML desktop workspace.
- SQLite content library, collection tasks, and run history.
- Bundled Content Data Service catalog browsing and data path collection.
- Safe sample fallback when credentials are not configured.
- Markdown and XML export.
- CTK-style Provider, Exporter, and Analyzer registry.
- Interactive details for articles, data paths, plugins, tasks, and run receipts.
- Linux, Windows, and Docker delivery scripts.
- QML control audit and documentation alignment audit.
- Open-source documentation set with separate English and Chinese docs.
- Native GitHub Actions release workflow for Linux amd64 and Windows x64 packages.
- Release workflow audit gate for multi-platform assets and checksums.

### Fixed

- Removed machine-specific absolute data service catalog lookup from tests and runtime code.
- Added installed data-path lookup for the bundled data service index.
