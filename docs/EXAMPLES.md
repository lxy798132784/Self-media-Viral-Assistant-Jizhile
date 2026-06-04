# Examples

Practical workflows for Media Hit Assistant.

## First run without credentials

You can test the full product flow without configuring any API key.

```bash
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build -j2
QT_QPA_PLATFORM=offscreen ./build/media-hit-assistant --self-test
```

Expected artifacts:

- `/tmp/media-hit-self-test.md`
- `/tmp/media-hit-self-test.xml`
- `/tmp/media-hit-self-test-combined-report.md`

## Create a collection task

Open **Settings** and fill in:

| Field | Example |
|---|---|
| Task name | AI article monitor |
| Keyword | AI |
| Endpoint path | `/fbmain/monitor/v3/web_search` |
| Frequency | 300 seconds |
| Run count | 10 |
| QPS | 1.5 |

Click the task save action. The task appears in the task list and can be run from the UI.

## Collect by endpoint

1. Open **API Catalog**.
2. Enter a category keyword such as `official account`.
3. Run the endpoint query.
4. Select an endpoint row.
5. Enter a content keyword.
6. Run collection by endpoint.
7. Inspect the run receipt in the run history list.

## Review and export

Open **Content Library**:

- refresh the article list;
- select an article to inspect details;
- export Markdown;
- export XML.

Default self-test artifacts are written under `/tmp`.

## Use the Hot Articles API page

1. Open the Hot Articles API page.
2. Fill in `key`, `keyword`, `pub_type`, `category`, `page`, `start_time`, and `end_time`.
3. Generate the request preview.
4. Run collection. Without credentials the app uses safe sample fallback.

## Inspect plugins

Open **Plugins**:

1. refresh the plugin list;
2. inspect Provider, Exporter, and Analyzer descriptors;
3. preview Markdown or XML exporter output;
4. generate plugin analysis;
5. review the dynamic plugin scan report.

## Full developer verification

```bash
./scripts/verify-all.sh
```

Run this command before every delivery.
