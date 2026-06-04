#!/usr/bin/env python3
import pathlib
import sys
import zipfile

root = pathlib.Path(__file__).resolve().parents[1]
problems = []
# Keep this list split so the audit script does not match itself.
forbidden = ["极" + "致了", "Jiz" + "hilia", "jiz" + "hilia", "爆文 " + "API", "爆文" + "API", "公众号爆文 " + "API", "公众号爆文" + "API"]
text_suffixes = {".md", ".txt", ".qml", ".cpp", ".h", ".hpp", ".py", ".ps1", ".sh", ".yml", ".yaml", ".json", ".xml", ".desktop"}
exclude_dirs = {".git", "build", "dist", "release-out", "dist-windows-x64"}
exclude_files = {"scripts/audit_brand_privacy.py"}
# Raw research/vendor corpus may exist in source for developers, but must not be copied to user packages.
exclude_prefixes = {"vendor/jizhilia-api-knowledge", "vendor/apifox-hot-typical-search.md"}

def rel(path: pathlib.Path) -> str:
    return path.relative_to(root).as_posix()

def is_excluded(path: pathlib.Path) -> bool:
    r = rel(path)
    if r in exclude_files:
        return True
    if any(r == p or r.startswith(p + "/") for p in exclude_prefixes):
        return True
    if any(part in exclude_dirs for part in path.parts):
        return True
    return False

for path in root.rglob("*"):
    if not path.is_file() or is_excluded(path):
        continue
    if path.suffix.lower() not in text_suffixes and path.name != "CMakeLists.txt":
        continue
    try:
        text = path.read_text(encoding="utf-8", errors="ignore")
    except Exception:
        continue
    for word in forbidden:
        if word in text:
            problems.append(f"{rel(path)} contains forbidden packaged/provider wording: {word}")

for zip_path in list(root.glob("*.zip")) + list((root / "release-out").glob("*.zip") if (root / "release-out").exists() else []):
    try:
        with zipfile.ZipFile(zip_path) as zf:
            for name in zf.namelist():
                # Source archives are allowed to contain developer-only raw corpus; user docs/app assets are not.
                if "source" in zip_path.name:
                    continue
                for word in forbidden:
                    if word.lower() in name.lower():
                        problems.append(f"{zip_path.name} contains forbidden filename: {name}")
                if pathlib.Path(name).suffix.lower() in text_suffixes:
                    try:
                        text = zf.read(name).decode("utf-8", errors="ignore")
                    except Exception:
                        continue
                    for word in forbidden:
                        if word in text:
                            problems.append(f"{zip_path.name}:{name} contains forbidden wording: {word}")
    except zipfile.BadZipFile:
        continue

if problems:
    print("Brand/privacy audit failed:")
    print("\n".join(problems[:200]))
    if len(problems) > 200:
        print(f"... {len(problems) - 200} more")
    sys.exit(1)
print("OK: no forbidden provider/brand wording found in user-facing text/package surfaces")
