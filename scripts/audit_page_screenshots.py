#!/usr/bin/env python3
from pathlib import Path
import subprocess, os, sys, tempfile
root = Path(__file__).resolve().parents[1]
exe = root / 'build' / 'media-hit-assistant'
out = Path(tempfile.mkdtemp(prefix='mha-ui-pages-'))
problems=[]
for i in range(8):
    shot = out / f'page-{i}.png'
    env = os.environ.copy()
    env['QT_QPA_PLATFORM'] = 'vnc'
    env['QT_QUICK_BACKEND'] = 'software'
    proc = subprocess.run([str(exe), '--screenshot-page', str(i), str(shot)], cwd=root, env=env, text=True, capture_output=True, timeout=30)
    stderr = '\n'.join(line for line in proc.stderr.splitlines() if 'QVncServer created' not in line)
    if proc.returncode != 0:
        problems.append(f'page {i} screenshot failed: exit {proc.returncode} {stderr[:200]}')
    if stderr.strip():
        problems.append(f'page {i} emitted QML warnings: {stderr[:300]}')
    if not shot.exists() or shot.stat().st_size < 20000:
        problems.append(f'page {i} screenshot missing or too small')
if problems:
    print('Screenshot audit failed:')
    for p in problems:
        print('-', p)
    print('screenshots:', out)
    raise SystemExit(1)
print('OK: all 8 page screenshots captured with no QML warnings:', out)
