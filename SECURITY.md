# Security Policy / 安全策略

## Supported use / 支持范围

This project is a local-first desktop application. Security reports should focus on source code, local configuration handling, export behavior, packaging scripts, and GitHub delivery hygiene.

本项目是本地优先桌面应用。安全报告可聚焦源码、本地配置处理、导出行为、打包脚本和 GitHub 交付卫生。

## Secrets / 密钥

- Do not commit API keys, GitHub tokens, private URLs, runtime databases, or generated packages.
- Keep Jizhilia credentials in local settings or environment variables.
- Vendor API examples must remain sanitized as `[REDACTED]`.

- 不提交 API Key、GitHub token、私有 URL、运行数据库或生成包。
- 极致了凭据只放在本机设置或环境变量中。
- vendor API 示例必须保持 `[REDACTED]` 脱敏。

## Reporting / 报告方式

For now, open a GitHub issue without including secrets. If a report requires sensitive details, redact them first.

当前可通过 GitHub issue 报告，但不要包含密钥。若必须说明敏感细节，请先脱敏。
