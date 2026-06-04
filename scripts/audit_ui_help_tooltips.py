#!/usr/bin/env python3
from pathlib import Path
import re, sys
qml = Path('ui/Main.qml').read_text(encoding='utf-8')
problems = []
controls = len(re.findall(r'\b(Button|TextField|ComboBox|SpinBox|TextArea)\s*\{', qml))
tooltips = qml.count('ToolTip.text')
if tooltips < 34:
    problems.append(f'expected broad tooltip coverage, controls={controls}, tooltips={tooltips}')
for phrase in [
    '切换中文',
    'Switch to English',
    '预览请求参数',
    '打开日期选择器',
    '选择导出格式',
    '选择格式和路径',
    '保存采集任务',
    '保存设置',
]:
    if phrase not in qml:
        problems.append(f'missing expected help/tooltip phrase: {phrase}')
# Main params must have explicit labels, not placeholder-only inputs.
for label in ['key', 'keyword', 'pub_type', 'category', 'page', 'start_time', 'end_time']:
    if f'label: "{label}"' not in qml:
        problems.append(f'missing visible label: {label}')
if problems:
    print('UI help/tooltip audit failed:')
    for p in problems:
        print(p)
    sys.exit(1)
print(f'OK: help/tooltip audit passed with {controls} controls and {tooltips} tooltip texts')
