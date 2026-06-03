#!/usr/bin/env python3
import pathlib
import re
import sys

root = pathlib.Path(__file__).resolve().parents[1]
qml = root / "ui" / "Main.qml"
text = qml.read_text(encoding="utf-8")
buttons = re.findall(r'Button\s*\{([^{}]*(?:\{[^{}]*\}[^{}]*)*)\}', text, flags=re.S)
problems = []
labels = []
for idx, body in enumerate(buttons, 1):
    label = re.search(r'text:\s*"([^"]+)"', body)
    label_text = label.group(1) if label else f"Button#{idx}"
    labels.append(label_text)
    if "onClicked:" not in body:
        problems.append(f"Button#{idx} {label_text} missing onClicked")
required_calls = [
    "loadMockArticles",
    "runCollection",
    "articleRows",
    "exportMarkdown",
    "exportXml",
    "createCollectionTask",
    "saveSettings",
    "apiEndpointRows",
    "runEndpointCollection",
    "pluginRows",
    "pluginAnalysis",
    "runRows",
    "runFullSelfCheck",
]
required_labels = [
    "加载示例数据", "全流程自检", "立即采集", "刷新", "导出 Markdown", "导出 XML", "重新推荐",
    "查询接口", "按接口采集", "刷新插件", "插件分析", "保存采集任务", "保存设置",
]
for call in required_calls:
    if call not in text:
        problems.append(f"missing QML call: {call}")
for label in required_labels:
    if label not in labels:
        problems.append(f"missing visible button: {label}")
for forbidden in ["开发", "实现", "布" + "局调整", "Mock " + "采集闭环", "占位"]:
    if forbidden in text:
        problems.append(f"forbidden user-visible/internal wording: {forbidden}")
if problems:
    print("UI audit failed:")
    print("\n".join(problems))
    sys.exit(1)
print(f"OK: {len(buttons)} visible buttons audited; endpoint/API/plugin controls verified")
