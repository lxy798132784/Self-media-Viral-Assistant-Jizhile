#!/usr/bin/env python3
"""Audit the GitHub Release workflow for native multi-platform desktop assets."""
from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
WORKFLOW = ROOT / ".github" / "workflows" / "release.yml"

REQUIRED_SNIPPETS = {
    "tag trigger": r"on:\s*(?:\n|.)*push:\s*(?:\n|.)*tags:\s*(?:\n|.)*- ['\"]?v\*",
    "release permissions": r"contents:\s*write",
    "linux amd64 job": r"runs-on:\s*ubuntu-24\.04",
    "windows x64 job": r"runs-on:\s*windows-2022",
    "linux asset name": r"linux-amd64",
    "windows asset name": r"windows-x64",
    "checksum artifact": r"SHA256SUMS",
    "release upload": r"softprops/action-gh-release@v2|gh release upload|actions/upload-release-asset",
}


def main() -> int:
    failures: list[str] = []
    if not WORKFLOW.exists():
        failures.append(f"missing workflow: {WORKFLOW.relative_to(ROOT)}")
        print("FAIL: release workflow audit")
        for failure in failures:
            print(f"- {failure}")
        return 1

    text = WORKFLOW.read_text(encoding="utf-8")
    for name, pattern in REQUIRED_SNIPPETS.items():
        if not re.search(pattern, text, re.IGNORECASE):
            failures.append(f"missing {name}: /{pattern}/")

    if "package-windows.ps1" not in text:
        failures.append("Windows job must invoke scripts/package-windows.ps1")
    windows_packager = (ROOT / "scripts" / "package-windows.ps1").read_text(encoding="utf-8")
    for required in ["run-with-log.bat", "media-hit-assistant.log", "--self-test", "audit_ui_help_tooltips.py"]:
        if required not in windows_packager:
            failures.append(f"Windows packager must include diagnostic/self-test gate: {required}")
    if "package-linux.sh" not in text and "cmake --install" not in text:
        failures.append("Linux job must package installed tree")
    if "actions/upload-artifact@v4" not in text:
        failures.append("workflow must retain build artifacts for inspection")

    if failures:
        print("FAIL: release workflow audit")
        for failure in failures:
            print(f"- {failure}")
        return 1

    print("OK: release workflow builds Linux amd64 and Windows x64 assets, checksums them, and uploads to GitHub Releases")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
