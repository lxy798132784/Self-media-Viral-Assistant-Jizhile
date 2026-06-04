#!/usr/bin/env python3
from pathlib import Path
import re
qml = Path('ui/Main.qml').read_text(encoding='utf-8')
problems = []
required = {
    'semantic text input wrapper': 'component FormText',
    'semantic combo wrapper': 'component FormCombo',
    'semantic spin wrapper': 'component FormSpin',
    'date picker wrapper': 'component DateField',
    'export dialog': 'component ExportDialog',
    'separate result page': 'component ResultPage',
    'excel table grid': 'component DataGrid',
    'table header cell': 'component HeaderCell',
    'table data cell': 'component Cell',
    'fixed-height card layout': 'property int cardHeight',
    'scrollable page frame': 'ScrollView { Layout.fillWidth: true; Layout.fillHeight: true',
    'no synchronous full self-check on dashboard': '完整诊断请运行 run-with-log.bat 或 --self-test',
}
for name, needle in required.items():
    if needle not in qml:
        problems.append(f'missing {name}: {needle}')
for forbidden in ['FieldControl', 'DateControl', 'delegate: RowCard', 'runFullSelfCheck(".")', 'runTaskRow(modelData)', '/tmp/media-hit-hot-results']:
    if forbidden in qml:
        problems.append(f'forbidden unstable/legacy pattern remains: {forbidden}')
# All main API params must have a dedicated, labelled semantic control.
# Verified by control id presence (label text is localized zh/en, so we must
# NOT hardcode raw English field names — that would force i18n regressions).
param_controls = {
    'key': 'id: hotKey',
    'keyword': 'id: hotKeyword',
    'pub_type': 'id: hotPubType',
    'category': 'id: hotCategory',
    'page': 'id: hotPage',
    'start_time': 'id: hotStart',
    'end_time': 'id: hotEnd',
}
for param, needle in param_controls.items():
    if needle not in qml:
        problems.append(f'missing dedicated control for API param {param}: {needle}')
# Forbid raw English field names leaking into user-visible labels (i18n hygiene).
for raw in ['key', 'keyword', 'pub_type', 'category', 'start_time', 'end_time']:
    if f'label: "{raw}"' in qml:
        problems.append(f'raw field name used as visible label (i18n leak): {raw}')
# Guard against accidental border property-group name collision.
if 'property color border:' in qml or 'property color border2:' in qml:
    problems.append('do not name color properties border/border2; it collides with Rectangle.border')
if problems:
    print('UX audit failed:')
    for p in problems:
        print('-', p)
    raise SystemExit(1)
print('OK: polished stable UX audit passed')
