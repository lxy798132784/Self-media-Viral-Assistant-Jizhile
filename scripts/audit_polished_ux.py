#!/usr/bin/env python3
from pathlib import Path
import re, sys
qml = Path('ui/Main.qml').read_text(encoding='utf-8')
problems = []
required = {
    'FieldControl component for explicit labels before inputs': 'component FieldControl',
    'DateControl component for date interaction': 'component DateControl',
    'ExportDialog component for user-selected path/format': 'component ExportDialog',
    'export dialog path field': 'id: exportPath',
    'hot results independent navigation item': 'hot_results_title',
    'hot results stack page': 'id: hotResultsPage',
    'Excel-like table component': 'component DataGrid',
    'table header row': 'component TableHeaderCell',
    'table data cell': 'component DataCell',
    'horizontal table scrolling': 'ScrollBar.horizontal',
    'vertical table scrolling': 'ScrollBar.vertical',
    'export dialog opened from results': 'exportDialog.openForHotResults',
    'no hard-coded /tmp hot result export': 'NO_LITERAL_TMP_HOT_EXPORT',
}
for label, needle in required.items():
    if needle == 'NO_LITERAL_TMP_HOT_EXPORT':
        if '/tmp/media-hit-hot-results.' in qml:
            problems.append('hot result export still hard-codes /tmp paths')
    elif needle not in qml:
        problems.append(f'missing {label}: {needle}')
# Each original hot parameter input should be inside explicit FieldControl/DateControl, not naked TextField-only UX.
for qid in ['hotKey', 'hotKeyword', 'hotPubType', 'hotCategory', 'hotPage', 'hotStart', 'hotEnd']:
    if f'id: {qid}' not in qml:
        problems.append(f'missing control id {qid}')
# Prevent cramped old result list in the collection page.
if 'id: hotResultList' in qml:
    problems.append('old inline hotResultList remains; results must live on independent table page')
# Guard against common overlap-prone fixed tiny result table heights.
if 'id: hotResultList' in qml or 'Layout.preferredHeight: 110; clip: true; model: appController.hotTypicalResultRows' in qml:
    problems.append('old cramped inline hot result table remains')
if problems:
    print('UX audit failed:')
    for p in problems:
        print('-', p)
    sys.exit(1)
print('OK: polished UX audit passed')
