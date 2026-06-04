# Contributing

Thanks for improving Media Hit Assistant.

## Development flow

1. Keep each change small and focused.
2. Add or update tests before changing behavior.
3. Run the full verification gate:

```bash
./scripts/verify-all.sh
```

4. Update English and Chinese docs when user behavior changes.
5. Do not commit credentials, runtime databases, build outputs, or package artifacts.

## Commit style

Use concise conventional-style messages when practical:

- `feat: add endpoint collection action`
- `fix: handle empty API response`
- `docs: improve quick start`
- `test: cover plugin analysis`

## Quality checklist

Before submitting, confirm:

- [ ] build passes;
- [ ] QtTest passes;
- [ ] QML control audit passes;
- [ ] documentation alignment audit passes;
- [ ] no secrets are committed;
- [ ] English docs are updated;
- [ ] Chinese docs are updated when the user workflow changes.
