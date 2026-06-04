#!/usr/bin/env python3
import pathlib
import re
import sys

root = pathlib.Path(__file__).resolve().parents[1]
qml = root / "ui" / "Main.qml"
text = qml.read_text(encoding="utf-8")
problems = []

control_tokens = ["Button {", "TextField {", "ComboBox {", "SpinBox {", "TextArea {"]
control_count = sum(text.count(token) for token in control_tokens)
tooltip_count = text.count("ToolTip.text")
if tooltip_count < control_count:
    problems.append(f"expected every visible control to define ToolTip.text: controls={control_count}, tooltips={tooltip_count}")

required_help_markers = [
    "help_title",
    "help_dashboard",
    "help_library",
    "help_hot",
    "help_report",
    "help_topics",
    "help_plugins",
    "help_settings",
    "help_troubleshooting",
]
for marker in required_help_markers:
    if marker not in text:
        problems.append(f"missing in-app bilingual help marker: {marker}")

required_tooltip_phrases = [
    "Load built-in sample articles",
    "加载内置示例内容",
    "Switch interface language to English",
    "切换界面语言为中文",
    "Preview the exact request payload",
    "预览本次请求参数",
]
for phrase in required_tooltip_phrases:
    if phrase not in text:
        problems.append(f"missing expected tooltip phrase: {phrase}")

for forbidden in ["公众号爆文 " + "API", "公众号爆文" + "API", "爆文 " + "API", "爆文" + "API", "极" + "致了", "Jiz" + "hilia", "jiz" + "hilia"]:
    if forbidden in text:
        problems.append(f"forbidden visible/provider wording in QML: {forbidden}")

# Chinese visible strings should not mix the requested title with API wording.
if re.search(r"爆文\s*(API|api)", text):
    problems.append("forbidden mixed hot-article API wording remains")

if problems:
    print("UI help/tooltip audit failed:")
    print("\n".join(problems))
    sys.exit(1)
print(f"OK: tooltip/help audit passed with {control_count} visible controls and {tooltip_count} tooltips")
