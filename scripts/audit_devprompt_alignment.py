#!/usr/bin/env python3
import pathlib
import re
import sys

root = pathlib.Path(__file__).resolve().parents[1]
checks = []

def read(rel):
    return (root / rel).read_text(encoding="utf-8", errors="ignore")

combined = "\n".join(read(p) for p in [
    "README.md",
    "docs/PROJECT-SPEC.md",
    "docs/ARCHITECTURE.md",
    "docs/DEVELOPMENT.md",
    "docs/EXAMPLES.md",
    "docs/PLUGIN_GUIDE.md",
    "CONTRIBUTING.md",
    "SECURITY.md",
    "CHANGELOG.md",
    "include/jizhilia_client.h",
    "include/config_manager.h",
    "include/plugin_interfaces.h",
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
    "dashboard": r"仪表盘|Dashboard",
    "library": r"内容库|library",
    "report": r"拆解报告|report",
    "topics": r"选题推荐|Topic",
    "settings": r"设置|Settings",
    "Linux": r"Linux",
    "Windows": r"Windows",
    "Docker": r"Docker",
    "Fallback": r"fallback|Fallback|回退",
    "plugin guide": r"Plugin guide|插件指南",
    "open-source governance": r"MIT License|Contributing|Security Policy|Code of Conduct|Changelog|贡献指南|安全策略|行为准则|更新日志",
    "install docs and plugins": r"CMAKE_INSTALL_DOCDIR|media-hit-assistant/plugins|PLUGIN_GUIDE",
    "CI full gate": r"Package smoke|Install smoke|audit_devprompt_alignment|package-linux",
    "English docs": r"Build|Architecture|Developer|Examples",
    "Chinese docs": r"构建|架构|开发|示例",
    "language switch": r"setLanguage|中文|English|language",
    "hot typical API": r"hot_typical_search|pub_type|category|start_time|end_time",
}
missing = [name for name, pattern in required_terms.items() if not re.search(pattern, combined, re.I)]
if missing:
    print("DevPrompt alignment failed: missing " + ", ".join(missing))
    sys.exit(1)
# Key headers should expose bilingual Doxygen-style comments.
for rel in ["include/jizhilia_client.h", "include/config_manager.h", "include/plugin_interfaces.h"]:
    text = read(rel)
    if text.count("@brief") < 1 or not re.search(r"[\u4e00-\u9fff]", text) or not re.search(r"[A-Za-z]", text):
        print(f"DevPrompt alignment failed: {rel} lacks bilingual brief comments")
        sys.exit(1)
forbidden_parts = [("github", "_pat_"), ("gh", "p_"), ("sk", "-"), ("token", "=czt"), ("token", "=Axric"), ("token", "=o3K"), ("token", "=DA8A")]
for left, right in forbidden_parts:
    forbidden = left + right
    if forbidden in combined:
        print(f"DevPrompt alignment failed: forbidden secret-like text {forbidden}")
        sys.exit(1)
print("OK: DevPrompt alignment verified")
