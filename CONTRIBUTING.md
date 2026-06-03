# Contributing / 贡献指南

Thanks for improving Media Hit Assistant.

感谢你改进自媒体爆款助手。

## Development flow / 开发流程

1. Create a small focused change.
2. Add or update tests before changing behavior.
3. Run the full verification gate:

```bash
./scripts/verify-all.sh
```

4. Update bilingual docs when behavior or user workflow changes.
5. Do not commit credentials, runtime databases, build outputs, or package artifacts.

1. 保持改动小而聚焦。
2. 行为变化前先补测试。
3. 运行全量验证门禁：

```bash
./scripts/verify-all.sh
```

4. 用户流程变化时同步更新中英文文档。
5. 不提交密钥、运行数据库、构建产物或打包产物。

## Commit style / 提交风格

Use concise conventional-style messages when practical:

尽量使用简洁的 conventional 风格提交：

- `feat: add endpoint collection action`
- `fix: handle empty API response`
- `docs: improve quick start`
- `test: cover plugin analysis`

## Quality checklist / 质量清单

Before submitting, confirm:

提交前确认：

- [ ] Build passes / 构建通过
- [ ] QtTest passes / QtTest 通过
- [ ] QML control audit passes / QML 控件审计通过
- [ ] DevPrompt alignment audit passes / DevPrompt 对齐审计通过
- [ ] No secrets are committed / 无密钥入库
- [ ] User-facing docs are updated / 用户文档已更新
