# Security Policy

## Supported use

This project is a local-first desktop application. Security reports should focus on source code, local configuration handling, export behavior, packaging scripts, dependency hygiene, and GitHub delivery hygiene.

## Secrets

- Do not commit API keys, GitHub tokens, private URLs, runtime databases, generated packages, or build outputs.
- Keep ContentData credentials in local settings or environment variables.
- Vendor API examples must remain sanitized.
- CI and local tests must pass without real credentials.

## Reporting

Open a GitHub issue without including secrets. If a report requires sensitive details, redact them first.
