#!/usr/bin/env python3
import pathlib
import re
import sys

root = pathlib.Path(__file__).resolve().parents[1]

def read(rel):
    path = root / rel
    if not path.exists():
        print(f"DevPrompt alignment failed: missing {rel}")
        sys.exit(1)
    return path.read_text(encoding="utf-8", errors="ignore")

english_docs = [
    "README.md",
    "docs/PROJECT-SPEC.md",
    "docs/ARCHITECTURE.md",
    "docs/DEVELOPMENT.md",
    "docs/EXAMPLES.md",
    "docs/PLUGIN_GUIDE.md",
    "CONTRIBUTING.md",
    "SECURITY.md",
    "CHANGELOG.md",
]
chinese_docs = [
    "docs/README.zh-CN.md",
    "docs/zh-CN/PROJECT-SPEC.md",
    "docs/zh-CN/ARCHITECTURE.md",
    "docs/zh-CN/DEVELOPMENT.md",
    "docs/zh-CN/EXAMPLES.md",
    "docs/zh-CN/PLUGIN_GUIDE.md",
]

for rel in english_docs:
    text = read(rel)
    chinese_chars = re.findall(r"[\u4e00-\u9fff]", text)
    if chinese_chars:
        print(f"DevPrompt alignment failed: English doc {rel} contains Chinese text")
        sys.exit(1)

for rel in chinese_docs:
    text = read(rel)
    if len(re.findall(r"[\u4e00-\u9fff]", text)) < 80:
        print(f"DevPrompt alignment failed: Chinese doc {rel} is missing substantial Chinese content")
        sys.exit(1)

combined = "\n".join(read(p) for p in english_docs + chinese_docs + [
    "include/jizhilia_client.h",
    "include/config_manager.h",
    "include/plugin_interfaces.h",
    "include/api_catalog.h",
    "ui/Main.qml",
    "Dockerfile",
    "CMakeLists.txt",
    ".github/workflows/desktop-ci.yml",
])
required_terms = {
    "C++20": r"C\+\+20",
    "CMake": r"CMake|cmake",
    "Qt6": r"Qt6|qt6",
    "QML": r"QML",
    "CTK": r"CTK",
    "SQLite": r"SQLite",
    "Jizhilia API": r"Jizhilia|极致了",
    "frequency": r"frequency|频率|interval",
    "run count": r"run count|次数|maxRuns",
    "API params": r"verify|verifycode|验证码|api key|API Key",
    "XML export": r"XML",
    "Markdown export": r"Markdown",
    "dashboard": r"Dashboard|仪表盘",
    "library": r"library|内容库",
    "report": r"report|拆解报告",
    "topics": r"Topic|选题",
    "settings": r"Settings|设置",
    "Linux": r"Linux",
    "Windows": r"Windows",
    "Docker": r"Docker",
    "Fallback": r"fallback|Fallback|回退",
    "plugin guide": r"Plugin Guide|插件指南",
    "governance": r"MIT|Contributing|Security|Code of Conduct|Changelog|贡献|安全|行为准则|更新",
    "install docs and plugins": r"CMAKE_INSTALL_DOCDIR|media-hit-assistant/plugins|PLUGIN_GUIDE|api-index.json",
    "CI full gate": r"Package smoke|Install smoke|audit_devprompt_alignment|package-linux",
    "English docs": r"docs/PROJECT-SPEC.md|Developer Guide|Architecture|Examples",
    "Chinese docs": r"docs/zh-CN/PROJECT-SPEC.md|开发指南|架构说明|使用示例",
    "language switch": r"setLanguage|Language Switch|语言切换|language",
    "hot typical API": r"hot_typical_search|pub_type|category|start_time|end_time",
    "bundled catalog": r"vendor/jizhilia-api-knowledge/api-index.json|defaultIndexPath|loadDefault",
}
missing = [name for name, pattern in required_terms.items() if not re.search(pattern, combined, re.I)]
if missing:
    print("DevPrompt alignment failed: missing " + ", ".join(missing))
    sys.exit(1)

for rel in ["include/jizhilia_client.h", "include/config_manager.h", "include/plugin_interfaces.h", "include/api_catalog.h"]:
    text = read(rel)
    if text.count("@brief") < 1 or not re.search(r"[\u4e00-\u9fff]", text) or not re.search(r"[A-Za-z]", text):
        print(f"DevPrompt alignment failed: {rel} lacks bilingual brief comments")
        sys.exit(1)

for rel in ["tests/test_core.cpp", "src/app_controller.cpp"]:
    text = read(rel)
    if "/home/pi/dev/jizhilia-api-knowledge" in text:
        print(f"DevPrompt alignment failed: machine-specific API catalog path remains in {rel}")
        sys.exit(1)

for rel in ["README.md", "docs/README.zh-CN.md"]:
    text = read(rel)
    for target in ["PROJECT-SPEC.md", "ARCHITECTURE.md", "DEVELOPMENT.md", "EXAMPLES.md", "PLUGIN_GUIDE.md"]:
        if target not in text:
            print(f"DevPrompt alignment failed: {rel} does not link {target}")
            sys.exit(1)

for left, right in [("github", "_pat_"), ("gh", "p_"), ("sk", "-"), ("token", "=czt"), ("token", "=Axric"), ("token", "=o3K"), ("token", "=DA8A")]:
    forbidden = left + right
    if forbidden in combined:
        print(f"DevPrompt alignment failed: forbidden secret-like text {forbidden}")
        sys.exit(1)
print("OK: DevPrompt alignment verified")
