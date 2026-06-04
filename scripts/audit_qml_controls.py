#!/usr/bin/env python3
import pathlib, sys
root = pathlib.Path(__file__).resolve().parents[1]
text = (root / 'ui' / 'Main.qml').read_text(encoding='utf-8')
problems = []
required = [
    'loadMockArticles',
    'runCollection',
    'articleRows',
    'articleDetail',
    'exportMarkdown',
    'exportXml',
    'generateReport',
    'recommendTopics',
    'pluginRows',
    'pluginDetail',
    'pluginAnalysis',
    'pluginScanReport',
    'createCollectionTask',
    'taskRows',
    'taskDetail',
    'saveSettings',
    'runHotTypicalCollection',
    'hotTypicalPayloadPreview',
    'hotTypicalResultRows',
    'exportHotTypicalResults',
    'dateRangeForPreset',
    'FormText',
    'FormCombo',
    'FormSpin',
    'DateField',
    'ResultPage',
    'DataGrid',
    'ExportDialog',
]
for needle in required:
    if needle not in text:
        problems.append(f'missing QML call/control: {needle}')
button_count = text.count('Button {')
click_count = text.count('onClicked:')
label_count = text.count('Label { text: label')
if button_count < 20:
    problems.append(f'expected at least 20 buttons, found {button_count}')
if click_count < 20:
    problems.append(f'expected at least 20 click handlers, found {click_count}')
if label_count < 4:
    problems.append(f'expected reusable labeled controls, found {label_count}')
for forbidden in ['delegate: RowCard', 'property color border:', 'property color border2:', 'Layout.preferredHeight: 110']:
    if forbidden in text:
        problems.append(f'forbidden layout/stability pattern remains: {forbidden}')
if problems:
    print('UI audit failed:')
    for p in problems:
        print(p)
    sys.exit(1)
print(f'OK: stable QML controls audited; {button_count} buttons, {click_count} click handlers')
