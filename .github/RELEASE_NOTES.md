# Media Hit Assistant release notes / 自媒体爆款助手发布说明

## Verification / 验证

Before publishing a release, run:

发布前运行：

```bash
./scripts/verify-all.sh
./scripts/package-linux.sh
cmake --install build --prefix /tmp/media-hit-install
```

## Source assets / 源码资产

A complete source release should include:

完整源码发布应包含：

- C++20 / Qt6 / QML source code.
- SQLite schema and local-first workflow.
- Sanitized Content Data Service knowledge under `vendor/`.
- Linux desktop metadata and icon under `packaging/`.
- Open-source governance files.
- Documentation under `docs/`.

## Binary assets / 二进制资产

Binary installers are intentionally not committed to Git. Attach release binaries as GitHub Release assets after local verification.

二进制安装包不提交到 Git。完成本地验证后，可作为 GitHub Release assets 上传。
