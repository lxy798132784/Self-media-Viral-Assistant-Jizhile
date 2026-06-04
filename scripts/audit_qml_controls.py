#!/usr/bin/env python3
import pathlib, sys
root = pathlib.Path(__file__).resolve().parents[1]
text = (root / 'ui' / 'Main.qml').read_text(encoding='utf-8')
problems = []
required_calls = [
    'loadMockArticles','runCollection','articleRows','exportMarkdown','exportXml','createCollectionTask','saveSettings',
    'pluginRows','pluginAnalysis','runFullSelfCheck','setLanguage','trText','hotTypicalPayloadPreview','runHotTypicalCollection',
    'articleDetail','pluginDetail','pluginScanReport','pluginExportPreview','taskDetail','runTaskRow','exportReport','noteSelection',
    'exportHotTypicalResults','hotTypicalResultRows','dateRangeForPreset'
]
required_controls = [
    'text: "中文"','text: "English"','id: hotKey','id: hotKeyword','id: hotPubType','id: hotCategory','id: hotPage','id: hotStart','id: hotEnd',
    'component FieldControl','component DateControl','component ExportDialog','id: exportDialog','openForHotResults','id: hotResultsPage',
    'component DataGrid','component TableHeaderCell','component DataCell','ScrollBar.horizontal','ScrollBar.vertical','root.t("preview_payload")','采集并解析'
]
required_params = ['key','keyword','pub_type','category','page','start_time','end_time']
for call in required_calls:
    if call not in text:
        problems.append(f'missing QML call: {call}')
for item in required_controls:
    if item not in text:
        problems.append(f'missing QML control/expression: {item}')
for param in required_params:
    if param not in text:
        problems.append(f'missing hot article parameter in QML: {param}')
if '/tmp/media-hit-hot-results.' in text:
    problems.append('hot result export still hard-codes /tmp paths')
if 'id: hotResultList' in text:
    problems.append('old inline hotResultList remains')
button_count = text.count('Button {')
click_count = text.count('onClicked:')
if button_count < 21:
    problems.append(f'expected at least 21 buttons, found {button_count}')
if click_count < 18:
    problems.append(f'expected at least 18 click handlers, found {click_count}')
for forbidden in ['开发','实现','布'+'局调整','占位','公众号爆文 '+'API','爆文 '+'API','极'+'致了','Jiz'+'hilia','jiz'+'hilia']:
    if forbidden in text:
        problems.append(f'forbidden mixed/internal wording: {forbidden}')
if problems:
    print('UI audit failed:')
    print('\n'.join(problems))
    sys.exit(1)
print(f'OK: polished QML controls audited; {button_count} buttons, {click_count} click handlers')
