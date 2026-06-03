## Summary / 摘要

What changed and why?

本次改动是什么，为什么需要？

## Verification / 验证

Paste command output or summarize:

粘贴命令输出或摘要：

- [ ] `cmake --build build -j2`
- [ ] `ctest --test-dir build --output-on-failure`
- [ ] `QT_QPA_PLATFORM=offscreen ./build/media-hit-assistant --self-test`
- [ ] `python3 scripts/audit_qml_controls.py`
- [ ] `python3 scripts/audit_devprompt_alignment.py`
- [ ] `./scripts/verify-all.sh`

## Documentation / 文档

- [ ] README or docs updated if user behavior changed / 用户行为变化时已更新 README 或 docs
- [ ] No credentials, private URLs, runtime databases, or build artifacts added / 未加入密钥、私有 URL、运行数据库或构建产物
