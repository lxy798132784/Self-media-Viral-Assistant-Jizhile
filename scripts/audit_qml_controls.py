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
    "hotTypicalSmokePreview",
    "runHotTypicalCollection",
    "articleDetail",
    "endpointPathFromRow",
    "runEndpointRow",
    "pluginDetail",
    "pluginScanReport",
    "pluginExportPreview",
    "taskDetail",
    "runTaskRow",
    "runDetail",
    "exportReport",
    "noteSelection",
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
if button_count < 21:
    problems.append(f"expected at least 21 buttons, found {button_count}")
mouse_count = text.count("MouseArea {")
if mouse_count < 11:
    problems.append(f"expected at least 11 clickable displayed surfaces, found {mouse_count}")
if "SpinBox { id: hotPage" in text and text.count("id: hotPage") != 1:
    problems.append("duplicate hotPage control id found")
if "id: hotStart" in text and text.count("id: hotStart") != 1:
    problems.append("duplicate hotStart control id found")
if "id: hotEnd" in text and text.count("id: hotEnd") != 1:
    problems.append("duplicate hotEnd control id found")
interactive_surfaces = ["StatCard", "Article", "API parameter", "Report", "Topic", "Plugin", "Task", "Run history"]
for surface in interactive_surfaces:
    if surface not in text:
        problems.append(f"missing interactive surface marker: {surface}")
for forbidden in [" / Dashboard", " / Content Library", " / Analysis Report", " / Topic Recommendations", " / Plugins", " / Settings", "开发", "实现", "布" + "局调整", "占位"]:
    if forbidden in text:
        problems.append(f"forbidden mixed/internal wording: {forbidden}")
if problems:
    print("UI audit failed:")
    print("\n".join(problems))
    sys.exit(1)
print(f"OK: {button_count} visible buttons audited; language switch and hot API controls verified")
