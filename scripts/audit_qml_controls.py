#!/usr/bin/env python3
import pathlib
import re
import sys

root = pathlib.Path(__file__).resolve().parents[1]
qml = root / "ui" / "Main.qml"
text = qml.read_text(encoding="utf-8")
problems = []
required_calls = [
    "loadMockArticles",
    "runCollection",
    "articleRows",
    "exportMarkdown",
    "exportXml",
    "createCollectionTask",
    "saveSettings",
    "pluginRows",
    "pluginAnalysis",
    "runRows",
    "runFullSelfCheck",
    "setLanguage",
    "trText",
    "hotTypicalParameterRows",
    "hotTypicalPayloadPreview",
    "runHotTypicalCollection",
]
required_controls = [
    'text: "中文"', 'text: "English"',
    "id: hotKey", "id: hotKeyword", "id: hotPubType", "id: hotCategory", "id: hotPage", "id: hotStart", "id: hotEnd",
    "root.t(\"preview_payload\")", "root.t(\"collect_hot\")",
    "appController.language === \"en\"", "appController.language === \"zh\"",
]
required_hot_params = ["key", "keyword", "pub_type", "category", "page", "start_time", "end_time"]
for call in required_calls:
    if call not in text:
        problems.append(f"missing QML call: {call}")
for item in required_controls:
    if item not in text:
        problems.append(f"missing QML control/expression: {item}")
for param in required_hot_params:
    if param not in text:
        problems.append(f"missing hot API parameter in QML: {param}")
button_count = text.count("Button {")
if button_count < 17:
    problems.append(f"expected at least 17 buttons, found {button_count}")
for forbidden in [" / Dashboard", " / Content Library", " / Analysis Report", " / Topic Recommendations", " / Plugins", " / Settings", "开发", "实现", "布" + "局调整", "占位"]:
    if forbidden in text:
        problems.append(f"forbidden mixed/internal wording: {forbidden}")
if problems:
    print("UI audit failed:")
    print("\n".join(problems))
    sys.exit(1)
print(f"OK: {button_count} visible buttons audited; language switch and hot API controls verified")
