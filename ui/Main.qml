import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ApplicationWindow {
    id: root
    width: 1360
    height: 860
    minimumWidth: 1180
    minimumHeight: 760
    visible: true
    title: appController.language === "en" ? "Media Hit Assistant" : "自媒体爆款助手"
    color: bg

    property color bg: "#0b1020"
    property color sidebar: "#080d1a"
    property color surface: "#111827"
    property color surface2: "#172033"
    property color card: "#0f172a"
    property color line: "#263244"
    property color lineStrong: "#3b4a62"
    property color accent: "#38bdf8"
    property color accent2: "#8b5cf6"
    property color good: "#22c55e"
    property color textMain: "#f8fafc"
    property color textSub: "#94a3b8"
    property color textMuted: "#64748b"
    property string detailText: ""
    property var hotRows: appController.hotTypicalResultRows()
    property int selectedHotRow: -1

    function t(key) { appController.language; return appController.trText(key) }
    function refreshHotRows() { hotRows = appController.hotTypicalResultRows(); hotTable.model = hotRows }
    function hotCell(rowText, column) {
        var cells = String(rowText).split("｜")
        return column < cells.length ? cells[column] : ""
    }
    function hotExportPath(format) {
        var ext = format === "xml" ? "xml" : (format === "xls" ? "xls" : "md")
        return (appController.language === "en" ? "hot-article-results" : "爆文解析结果") + "." + ext
    }
    function help(key) {
        appController.language
        var zh = {
            help_title: "使用说明",
            help_dashboard: "查看本地内容数量、阅读和点赞概览。按钮、统计卡片和列表都能点击并产生状态反馈。",
            help_library: "管理本地内容库：搜索、刷新、查看详情，并导出 Markdown 或 XML。",
            help_hot: "爆文采集页只负责参数设置和采集动作。每个参数都有明确名称、类型和说明；日期使用专门日期控件；结果在独立结果表页查看。",
            help_hot_results: "爆文解析结果以类似 Excel 的表格展示，支持行选择、横向/纵向滚动和导出弹窗。",
            help_report: "根据本地内容生成拆解报告，可导出综合报告。",
            help_topics: "从已采集内容生成选题方向，点击选题可查看后续处理输入预览。",
            help_plugins: "查看内置数据源、导出器和分析器，插件列表和报告区域都可交互。",
            help_settings: "保存采集任务、关键词、运行间隔、最大运行次数、密钥和限速。",
            help_troubleshooting: "Windows 双击无反应时，请运行包内 run-with-log.bat 查看日志。"
        }
        var en = {
            help_title: "Guide",
            help_dashboard: "Review local content count, reads, and likes. Buttons, stat cards, and lists are all clickable and produce status feedback.",
            help_library: "Manage the local content library: search, refresh, inspect details, and export Markdown or XML.",
            help_hot: "The hot-article collection page is for parameter setup and collection only. Every parameter has an explicit name, type, and help text; dates use dedicated date controls; results live on a separate table page.",
            help_hot_results: "Parsed hot-article results are shown in an Excel-like table with row selection, horizontal/vertical scrolling, and an export dialog.",
            help_report: "Generate an analysis report from local content and export the combined report.",
            help_topics: "Generate topic directions from collected content. Click a topic to preview the next-step processing input.",
            help_plugins: "Inspect built-in data sources, exporters, and analyzers. Plugin rows and report panels are interactive.",
            help_settings: "Save collection tasks, keywords, intervals, maximum runs, secrets, and rate limits.",
            help_troubleshooting: "If Windows double-click closes instantly, run run-with-log.bat from the package to inspect the log."
        }
        return appController.language === "en" ? en[key] : zh[key]
    }

    ExportDialog {
        id: exportDialog
        title: appController.language === "en" ? "Export parsed results" : "导出解析结果"
        modal: true
        standardButtons: Dialog.Ok | Dialog.Cancel
        width: Math.min(root.width - 96, 560)
        x: (root.width - width) / 2
        y: (root.height - height) / 2
        property string target: "hot"
        function openForHotResults() {
            target = "hot"
            exportFormat.currentIndex = 0
            exportPath.text = hotExportPath(exportFormat.currentValue)
            open()
        }
        onAccepted: {
            var ok = appController.exportHotTypicalResults(exportPath.text, exportFormat.currentValue)
            appController.noteSelection(appController.language === "en" ? "Export" : "导出", exportPath.text)
            detailText = (ok ? "OK: " : "Failed: ") + exportPath.text
        }
        background: Rectangle { color: surface; radius: 18; border.color: lineStrong }
        contentItem: ColumnLayout {
            spacing: 14
            Label { text: appController.language === "en" ? "Choose format and output location" : "选择导出格式和保存位置"; color: textMain; font.pixelSize: 18; font.bold: true; Layout.fillWidth: true }
            Label { text: appController.language === "en" ? "Enter a filename or absolute path. The selected format controls the file extension." : "可填写文件名或绝对路径。导出格式会决定文件扩展名。"; color: textSub; wrapMode: Text.WordWrap; Layout.fillWidth: true }
            RowLayout { Layout.fillWidth: true; spacing: 12
                Label { text: appController.language === "en" ? "Format" : "格式"; color: textSub; Layout.preferredWidth: 88 }
                ComboBox { id: exportFormat; Layout.fillWidth: true; textRole: "label"; valueRole: "value"; model: [{value:"md",label:"Markdown (.md)"},{value:"xml",label:"XML (.xml)"},{value:"xls",label:"Excel (.xls)"}]; ToolTip.visible: hovered; ToolTip.text: appController.language === "en" ? "Pick the output format" : "选择导出文件格式"; onActivated: exportPath.text = hotExportPath(currentValue) }
            }
            RowLayout { Layout.fillWidth: true; spacing: 12
                Label { text: appController.language === "en" ? "Location" : "位置"; color: textSub; Layout.preferredWidth: 88 }
                TextField { id: exportPath; Layout.fillWidth: true; placeholderText: appController.language === "en" ? "For example: C:/Users/you/Desktop/results.xls" : "例如：D:/桌面/爆文解析结果.xls"; color: textMain; selectedTextColor: "#020617"; selectionColor: accent; ToolTip.visible: hovered; ToolTip.text: appController.language === "en" ? "Output filename or absolute path" : "导出文件名或绝对路径"; background: Rectangle { color: card; radius: 10; border.color: exportPath.activeFocus ? accent : line } }
            }
        }
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            Layout.preferredWidth: 260
            Layout.fillHeight: true
            color: sidebar
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 18
                spacing: 12
                Label { text: root.t("app_title"); color: textMain; font.pixelSize: 25; font.bold: true; Layout.fillWidth: true }
                Label { text: root.t("subtitle"); color: textSub; wrapMode: Text.WordWrap; Layout.fillWidth: true }
                RowLayout { Layout.fillWidth: true
                    Button { text: "中文"; highlighted: appController.language === "zh"; ToolTip.visible: hovered; ToolTip.text: "切换界面语言为中文 / Switch interface language to Chinese"; onClicked: appController.setLanguage("zh") }
                    Button { text: "English"; highlighted: appController.language === "en"; ToolTip.visible: hovered; ToolTip.text: "Switch interface language to English / 切换界面语言为英文"; onClicked: appController.setLanguage("en") }
                }
                Repeater {
                    model: [
                        { key: "dashboard_title", index: 0 },
                        { key: "library_title", index: 1 },
                        { key: "hot_api_title", index: 2 },
                        { key: "hot_results_title", index: 3 },
                        { key: "report_title", index: 4 },
                        { key: "topics_title", index: 5 },
                        { key: "plugins_title", index: 6 },
                        { key: "settings_title", index: 7 }
                    ]
                    delegate: Button {
                        Layout.fillWidth: true
                        text: root.t(modelData.key)
                        highlighted: stack.currentIndex === modelData.index
                        ToolTip.visible: hovered
                        ToolTip.text: appController.language === "en" ? "Open this module" : "打开这个模块"
                        onClicked: stack.currentIndex = modelData.index
                    }
                }
                Item { Layout.fillHeight: true }
                Label { text: appController.status; color: accent; wrapMode: Text.WordWrap; Layout.fillWidth: true }
            }
        }

        StackLayout {
            id: stack
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: 2

            PageFrame {
                title: root.t("dashboard_title")
                guide: root.help("help_dashboard") + "\n" + root.help("help_troubleshooting")
                ColumnLayout { Layout.fillWidth: true; Layout.fillHeight: true; spacing: 16
                    RowLayout { Layout.fillWidth: true
                        StatCard { title: appController.language === "en" ? "Articles" : "内容数量"; value: appController.articleCount.toString(); desc: "SQLite" }
                        StatCard { title: appController.language === "en" ? "Reads" : "总阅读"; value: appController.totalReads.toString(); desc: appController.language === "en" ? "Local summary" : "本地汇总" }
                        StatCard { title: appController.language === "en" ? "Likes" : "总点赞"; value: appController.totalLikes.toString(); desc: appController.status }
                    }
                    RowLayout { Layout.fillWidth: true
                        FieldControl { id: dashKeyword; label: appController.language === "en" ? "Keyword" : "关键词"; hint: appController.language === "en" ? "Used for dashboard collection" : "用于仪表盘采集"; text: "AI" }
                        Button { text: root.t("load_samples"); ToolTip.visible: hovered; ToolTip.text: "Load built-in sample articles / 加载内置示例内容"; onClicked: appController.loadMockArticles() }
                        Button { text: root.t("self_check"); ToolTip.visible: hovered; ToolTip.text: appController.language === "en" ? "Run database, fallback, export, and report checks" : "运行数据库、采集兜底、导出和报告检查"; onClicked: appController.runFullSelfCheck(".") }
                        Button { text: root.t("collect_now"); ToolTip.visible: hovered; ToolTip.text: appController.language === "en" ? "Collect with the dashboard keyword" : "用仪表盘关键词采集"; onClicked: appController.runCollection(dashKeyword.text) }
                    }
                    TextArea { Layout.fillWidth: true; Layout.fillHeight: true; readOnly: true; wrapMode: TextArea.Wrap; text: root.detailText; color: textMain; ToolTip.visible: hovered; ToolTip.text: appController.language === "en" ? "Status details" : "状态详情"; background: Rectangle { color: card; radius: 14; border.color: line } }
                }
            }

            PageFrame {
                title: root.t("library_title")
                guide: root.help("help_library")
                ColumnLayout { Layout.fillWidth: true; Layout.fillHeight: true; spacing: 12
                    RowLayout { Layout.fillWidth: true
                        FieldControl { id: search; label: appController.language === "en" ? "Search" : "搜索"; hint: appController.language === "en" ? "Title or account" : "标题或账号"; Layout.fillWidth: true }
                        Button { text: appController.language === "en" ? "Refresh" : "刷新"; ToolTip.visible: hovered; ToolTip.text: appController.language === "en" ? "Reload local article rows" : "刷新本地内容列表"; onClicked: list.model = appController.articleRows(search.text) }
                        Button { text: appController.language === "en" ? "Export Markdown" : "导出 Markdown"; ToolTip.visible: hovered; ToolTip.text: appController.language === "en" ? "Export local content as Markdown" : "把本地内容导出为 Markdown"; onClicked: appController.exportMarkdown("media-hit-articles.md") }
                        Button { text: appController.language === "en" ? "Export XML" : "导出 XML"; ToolTip.visible: hovered; ToolTip.text: appController.language === "en" ? "Export local content as XML" : "把本地内容导出为 XML"; onClicked: appController.exportXml("media-hit-articles.xml") }
                    }
                    ListView { id: list; Layout.fillWidth: true; Layout.fillHeight: true; clip: true; model: appController.articleRows(search.text); delegate: RowCard { rowText: modelData; onPicked: { root.detailText = appController.articleDetail(modelData); appController.noteSelection(appController.language === "en" ? "Article" : "内容", modelData) } } }
                    TextArea { Layout.fillWidth: true; Layout.preferredHeight: 120; readOnly: true; wrapMode: TextArea.Wrap; text: root.detailText; color: textMain; ToolTip.visible: hovered; ToolTip.text: appController.language === "en" ? "Selected article details" : "已选内容详情"; background: Rectangle { color: card; radius: 14; border.color: line } }
                }
            }

            PageFrame {
                id: hotCollectPage
                title: root.t("hot_api_title")
                guide: root.help("help_hot")
                ColumnLayout { Layout.fillWidth: true; Layout.fillHeight: true; spacing: 16
                    SectionCard { title: appController.language === "en" ? "Request parameters" : "采集参数"; subtitle: appController.language === "en" ? "Choose the right control for each parameter type" : "每个参数按语义选择合适控件"
                        ColumnLayout { anchors.fill: parent; anchors.margins: 18; spacing: 14
                            GridLayout { Layout.fillWidth: true; columns: 2; columnSpacing: 16; rowSpacing: 14
                                FieldControl { id: hotKey; label: "key"; hint: appController.language === "en" ? "Secret key; leave empty for sample mode" : "密钥；留空使用本地示例"; password: true }
                                FieldControl { id: hotKeyword; label: "keyword"; hint: appController.language === "en" ? "Text keyword; empty means all" : "文本关键词；为空搜索全部"; text: "AI" }
                                LabeledCombo { id: hotPubTypeWrap; label: "pub_type"; hint: appController.language === "en" ? "Content type enum" : "内容类型枚举"
                                    ComboBox { id: hotPubType; Layout.fillWidth: true; textRole: "label"; valueRole: "value"; model: [{value:"0",label:"0 · 图文"},{value:"5",label:"5 · 纯视频"},{value:"7",label:"7 · 纯音乐"},{value:"8",label:"8 · 纯图片"},{value:"10",label:"10 · 纯文字"},{value:"11",label:"11 · 转载文章"}]; ToolTip.visible: hovered; ToolTip.text: appController.language === "en" ? "Select pub_type" : "选择 pub_type" }
                                }
                                LabeledCombo { id: hotCategoryWrap; label: "category"; hint: appController.language === "en" ? "Category enum 0-30" : "分类枚举 0-30"
                                    ComboBox { id: hotCategory; Layout.fillWidth: true; textRole: "label"; valueRole: "value"; model: [{value:"0",label:"0 · 全部"},{value:"1",label:"1 · 国际"},{value:"2",label:"2 · 体育"},{value:"3",label:"3 · 娱乐"},{value:"4",label:"4 · 社会"},{value:"5",label:"5 · 财经"},{value:"6",label:"6 · 时事"},{value:"7",label:"7 · 科技"},{value:"8",label:"8 · 情感"},{value:"9",label:"9 · 汽车"},{value:"10",label:"10 · 教育"},{value:"11",label:"11 · 时尚"},{value:"12",label:"12 · 游戏"},{value:"13",label:"13 · 军事"},{value:"14",label:"14 · 旅游"},{value:"15",label:"15 · 美食"},{value:"16",label:"16 · 文化"},{value:"17",label:"17 · 健康"},{value:"18",label:"18 · 搞笑"},{value:"19",label:"19 · 家居"},{value:"20",label:"20 · 动漫"},{value:"21",label:"21 · 宠物"},{value:"22",label:"22 · 母婴"},{value:"23",label:"23 · 星座"},{value:"24",label:"24 · 历史"},{value:"25",label:"25 · 音乐"},{value:"26",label:"26 · 未分类"},{value:"27",label:"27 · 综合"},{value:"28",label:"28 · 职场"},{value:"29",label:"29 · 三农"},{value:"30",label:"30 · 养老"}]; ToolTip.visible: hovered; ToolTip.text: appController.language === "en" ? "Select category" : "选择 category" }
                                }
                                LabeledCombo { label: "page"; hint: appController.language === "en" ? "Positive page number" : "正整数页码"
                                    SpinBox { id: hotPage; Layout.fillWidth: true; from: 1; to: 9999; value: 1; editable: true; ToolTip.visible: hovered; ToolTip.text: appController.language === "en" ? "Page number" : "页码" }
                                }
                                LabeledCombo { label: appController.language === "en" ? "Date preset" : "日期预设"; hint: appController.language === "en" ? "Quickly fill start/end" : "快速填入起止日期"
                                    RowLayout { Layout.fillWidth: true; ComboBox { id: datePreset; Layout.fillWidth: true; textRole: "label"; valueRole: "value"; model: [{value:"last_7_days",label:appController.language === "en" ? "Last 7 days" : "最近7天"},{value:"last_30_days",label:appController.language === "en" ? "Last 30 days" : "最近30天"},{value:"this_month",label:appController.language === "en" ? "This month" : "本月"},{value:"custom",label:appController.language === "en" ? "Custom" : "自定义"}]; ToolTip.visible: hovered; ToolTip.text: appController.language === "en" ? "Date range preset" : "日期范围预设" } Button { text: appController.language === "en" ? "Apply" : "应用"; ToolTip.visible: hovered; ToolTip.text: appController.language === "en" ? "Apply selected date preset" : "应用所选日期预设"; onClicked: { var r = appController.dateRangeForPreset(datePreset.currentValue); hotStart.text = r[0]; hotEnd.text = r[1] } } }
                                }
                                DateControl { id: hotStart; label: "start_time"; hint: appController.language === "en" ? "Start date" : "开始日期"; text: "2026-05-15" }
                                DateControl { id: hotEnd; label: "end_time"; hint: appController.language === "en" ? "End date" : "截止日期"; text: "2026-05-17" }
                            }
                            RowLayout { Layout.fillWidth: true
                                Button { text: root.t("preview_payload"); ToolTip.visible: hovered; ToolTip.text: "Preview the exact request payload / 预览本次请求参数"; onClicked: payloadPreview.text = appController.hotTypicalPayloadPreview(hotKey.text, hotKeyword.text, hotPubType.currentValue, hotCategory.currentValue, hotPage.value, hotStart.text, hotEnd.text) }
                                Button { text: appController.language === "en" ? "Collect and parse" : "采集并解析"; highlighted: true; ToolTip.visible: hovered; ToolTip.text: appController.language === "en" ? "Collect, parse, then open the result table" : "采集、解析，然后打开结果表"; onClicked: { appController.runHotTypicalCollection(hotKey.text, hotKeyword.text, hotPubType.currentValue, hotCategory.currentValue, hotPage.value, hotStart.text, hotEnd.text); refreshHotRows(); stack.currentIndex = 3 } }
                                Button { text: appController.language === "en" ? "Open result table" : "打开结果表"; ToolTip.visible: hovered; ToolTip.text: appController.language === "en" ? "Open the Excel-like parsed table" : "打开类似 Excel 的解析表格"; onClicked: { refreshHotRows(); stack.currentIndex = 3 } }
                            }
                        }
                    }
                    TextArea { id: payloadPreview; Layout.fillWidth: true; Layout.fillHeight: true; readOnly: true; wrapMode: TextArea.Wrap; text: appController.hotTypicalPayloadPreview("[empty]", hotKeyword.text, hotPubType.currentValue, hotCategory.currentValue, hotPage.value, hotStart.text, hotEnd.text); color: textMain; ToolTip.visible: hovered; ToolTip.text: appController.language === "en" ? "Request preview" : "请求参数预览"; background: Rectangle { color: card; radius: 14; border.color: line } }
                }
            }

            PageFrame {
                id: hotResultsPage
                title: root.t("hot_results_title")
                guide: root.help("help_hot_results")
                ColumnLayout { Layout.fillWidth: true; Layout.fillHeight: true; spacing: 12
                    RowLayout { Layout.fillWidth: true
                        Label { text: appController.language === "en" ? "Parsed result table" : "解析结果表"; color: textMain; font.pixelSize: 20; font.bold: true; Layout.fillWidth: true }
                        Button { text: appController.language === "en" ? "Refresh" : "刷新"; ToolTip.visible: hovered; ToolTip.text: appController.language === "en" ? "Refresh parsed rows" : "刷新解析结果"; onClicked: refreshHotRows() }
                        Button { text: appController.language === "en" ? "Export..." : "导出..."; ToolTip.visible: hovered; ToolTip.text: appController.language === "en" ? "Open export dialog for MD/XML/XLS" : "打开导出弹窗，选择 MD/XML/XLS 和路径"; onClicked: exportDialog.openForHotResults() }
                    }
                    DataGrid { id: hotTable; Layout.fillWidth: true; Layout.fillHeight: true; model: root.hotRows }
                    TextArea { Layout.fillWidth: true; Layout.preferredHeight: 92; readOnly: true; wrapMode: TextArea.Wrap; text: selectedHotRow >= 0 && selectedHotRow < hotRows.length ? hotRows[selectedHotRow] : root.help("help_hot_results"); color: textMain; ToolTip.visible: hovered; ToolTip.text: appController.language === "en" ? "Selected row details" : "已选行详情"; background: Rectangle { color: card; radius: 14; border.color: line } }
                }
            }

            PageFrame { title: root.t("report_title"); guide: root.help("help_report")
                ColumnLayout { Layout.fillWidth: true; Layout.fillHeight: true; Button { text: appController.language === "en" ? "Export report" : "导出报告"; ToolTip.visible: hovered; ToolTip.text: appController.language === "en" ? "Export combined report" : "导出综合报告"; onClicked: appController.exportReport("media-hit-report.md") } TextArea { id: reportView; Layout.fillWidth: true; Layout.fillHeight: true; readOnly: true; wrapMode: TextArea.Wrap; text: appController.generateReport(); color: textMain; ToolTip.visible: hovered; ToolTip.text: appController.language === "en" ? "Generated report" : "生成的报告"; background: Rectangle { color: card; radius: 14; border.color: line } MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: appController.noteSelection(appController.language === "en" ? "Report" : "Report", reportView.text.substring(0, 120)) } } }
            }

            PageFrame { title: root.t("topics_title"); guide: root.help("help_topics")
                ListView { Layout.fillWidth: true; Layout.fillHeight: true; model: appController.recommendTopics(); spacing: 10; delegate: RowCard { rowText: modelData; onPicked: { root.detailText = appController.aiExtensionPayloadPreview(modelData, appController.generateReport().substring(0,160)); appController.noteSelection(appController.language === "en" ? "Topic" : "Topic", modelData) } } }
            }

            PageFrame { title: root.t("plugins_title"); guide: root.help("help_plugins")
                ColumnLayout { Layout.fillWidth: true; Layout.fillHeight: true; RowLayout { Button { text: appController.language === "en" ? "Refresh plugins" : "刷新插件"; ToolTip.visible: hovered; ToolTip.text: appController.language === "en" ? "Reload plugin descriptors" : "刷新插件描述"; onClicked: pluginList.model = appController.pluginRows() } Button { text: appController.language === "en" ? "Plugin analysis" : "插件分析"; ToolTip.visible: hovered; ToolTip.text: appController.language === "en" ? "Run built-in analyzer" : "运行内置分析器"; onClicked: pluginReport.text = appController.pluginAnalysis() } Button { text: appController.language === "en" ? "Scan metadata" : "扫描元数据"; ToolTip.visible: hovered; ToolTip.text: appController.language === "en" ? "Scan plugin metadata" : "扫描插件元数据"; onClicked: pluginReport.text = appController.pluginScanReport("plugins") } } ListView { id: pluginList; Layout.fillWidth: true; Layout.preferredHeight: 180; model: appController.pluginRows(); delegate: RowCard { rowText: modelData; onPicked: { pluginReport.text = appController.pluginDetail(modelData) + "\n\n" + appController.pluginExportPreview(modelData); appController.noteSelection(appController.language === "en" ? "Plugin" : "Plugin", modelData) } } } TextArea { id: pluginReport; Layout.fillWidth: true; Layout.fillHeight: true; readOnly: true; wrapMode: TextArea.Wrap; text: appController.pluginAnalysis(); color: textMain; ToolTip.visible: hovered; ToolTip.text: appController.language === "en" ? "Plugin report" : "插件报告"; background: Rectangle { color: card; radius: 14; border.color: line } } }
            }

            PageFrame { title: root.t("settings_title"); guide: root.help("help_settings") + "\n" + root.help("help_troubleshooting")
                ColumnLayout { Layout.fillWidth: true; Layout.fillHeight: true; spacing: 12
                    RowLayout { Layout.fillWidth: true
                        FieldControl { id: taskName; label: appController.language === "en" ? "Task name" : "任务名称"; hint: appController.language === "en" ? "Saved with the task" : "随任务保存"; text: appController.language === "en" ? "AI hot article monitor" : "AI 爆文监控" }
                        FieldControl { id: taskKeyword; label: appController.language === "en" ? "Keyword" : "关键词"; hint: appController.language === "en" ? "Used by collection" : "采集使用"; text: "AI" }
                    }
                    RowLayout { SpinBox { id: taskInterval; from: 5; to: 86400; value: 300; editable: true; ToolTip.visible: hovered; ToolTip.text: appController.language === "en" ? "Task interval in seconds" : "任务运行间隔，单位秒" } SpinBox { id: taskRuns; from: 1; to: 9999; value: 10; editable: true; ToolTip.visible: hovered; ToolTip.text: appController.language === "en" ? "Maximum task runs" : "最大运行次数" } Button { text: appController.language === "en" ? "Save collection task" : "保存采集任务"; ToolTip.visible: hovered; ToolTip.text: appController.language === "en" ? "Save and refresh tasks" : "保存并刷新任务"; onClicked: { appController.createCollectionTask(taskName.text, taskKeyword.text, taskInterval.value, taskRuns.value); tasks.model = appController.taskRows() } } Button { text: root.t("collect_now"); ToolTip.visible: hovered; ToolTip.text: appController.language === "en" ? "Run collection now" : "立即运行采集"; onClicked: appController.runCollection(taskKeyword.text) } }
                    ListView { id: tasks; Layout.fillWidth: true; Layout.preferredHeight: 110; model: appController.taskRows(); delegate: RowCard { rowText: modelData; onPicked: { root.detailText = appController.taskDetail(modelData); appController.runTaskRow(modelData); appController.noteSelection(appController.language === "en" ? "Task" : "Task", modelData) } } }
                    RowLayout { Layout.fillWidth: true
                        FieldControl { id: apiKey; label: appController.language === "en" ? "Secret key" : "密钥"; hint: appController.language === "en" ? "Stored locally only" : "只保存在本机"; password: true }
                        FieldControl { id: verify; label: appController.language === "en" ? "Verify code" : "验证码"; hint: appController.language === "en" ? "Optional" : "可选" }
                    }
                    RowLayout { SpinBox { id: interval; from: 5; to: 86400; value: 300; editable: true; ToolTip.visible: hovered; ToolTip.text: appController.language === "en" ? "Default interval seconds" : "默认间隔秒数" } SpinBox { id: runs; from: 1; to: 9999; value: 10; editable: true; ToolTip.visible: hovered; ToolTip.text: appController.language === "en" ? "Default maximum runs" : "默认最大运行次数" } FieldControl { id: qps; label: appController.language === "en" ? "QPS limit" : "QPS 限制"; hint: "1.5"; text: "1.5" } Button { text: appController.language === "en" ? "Save settings" : "保存设置"; ToolTip.visible: hovered; ToolTip.text: appController.language === "en" ? "Persist local settings" : "保存本机设置"; onClicked: appController.saveSettings(apiKey.text, verify.text, interval.value, runs.value, Number(qps.text)) } }
                    TextArea { Layout.fillWidth: true; Layout.fillHeight: true; readOnly: true; wrapMode: TextArea.Wrap; text: root.detailText; color: textMain; ToolTip.visible: hovered; ToolTip.text: appController.language === "en" ? "Task and run details" : "任务和运行详情"; background: Rectangle { color: card; radius: 14; border.color: line } }
                }
            }
        }
    }

    component ExportDialog: Dialog {}
    component PageFrame: Rectangle {
        property string title: ""
        property string guide: ""
        default property alias content: bodyLayout.data
        color: bg
        ColumnLayout { anchors.fill: parent; anchors.margins: 24; spacing: 16
            RowLayout { Layout.fillWidth: true
                ColumnLayout { Layout.fillWidth: true; spacing: 4
                    Label { text: title; color: textMain; font.pixelSize: 30; font.bold: true }
                    Label { text: guide; color: textSub; wrapMode: Text.WordWrap; Layout.fillWidth: true }
                }
            }
            ColumnLayout { id: bodyLayout; Layout.fillWidth: true; Layout.fillHeight: true; spacing: 16 }
        }
    }

    component SectionCard: Rectangle {
        property string title: ""
        property string subtitle: ""
        default property alias content: inner.data
        Layout.fillWidth: true
        Layout.preferredHeight: 390
        color: surface
        radius: 20
        border.color: line
        ColumnLayout { anchors.fill: parent; anchors.margins: 18; spacing: 4
            Label { text: title; color: textMain; font.pixelSize: 20; font.bold: true }
            Label { text: subtitle; color: textSub; wrapMode: Text.WordWrap; Layout.fillWidth: true }
            Item { id: inner; Layout.fillWidth: true; Layout.fillHeight: true }
        }
    }

    component FieldControl: ColumnLayout {
        property alias text: input.text
        property string label: ""
        property string hint: ""
        property bool password: false
        Layout.fillWidth: true
        spacing: 6
        Label { text: label; color: textMain; font.pixelSize: 14; font.bold: true; Layout.fillWidth: true }
        RowLayout { Layout.fillWidth: true
            TextField { id: input; Layout.fillWidth: true; placeholderText: hint; echoMode: password && !show.checked ? TextInput.Password : TextInput.Normal; color: textMain; selectedTextColor: "#020617"; selectionColor: accent; ToolTip.visible: hovered; ToolTip.text: label + " · " + hint; background: Rectangle { color: card; radius: 12; border.color: input.activeFocus ? accent : line } }
            Button { id: show; visible: password; checkable: true; text: checked ? "隐藏" : "显示"; ToolTip.visible: hovered; ToolTip.text: appController.language === "en" ? "Show or hide secret" : "显示或隐藏密钥" }
        }
        Label { text: hint; color: textMuted; font.pixelSize: 12; wrapMode: Text.WordWrap; Layout.fillWidth: true }
    }

    component LabeledCombo: ColumnLayout {
        property string label: ""
        property string hint: ""
        default property alias content: slot.data
        Layout.fillWidth: true
        spacing: 6
        Label { text: label; color: textMain; font.pixelSize: 14; font.bold: true; Layout.fillWidth: true }
        Item { id: slot; Layout.fillWidth: true; Layout.preferredHeight: 42 }
        Label { text: hint; color: textMuted; font.pixelSize: 12; wrapMode: Text.WordWrap; Layout.fillWidth: true }
    }

    component DateControl: ColumnLayout {
        property alias text: dateText.text
        property string label: ""
        property string hint: ""
        Layout.fillWidth: true
        spacing: 6
        Label { text: label; color: textMain; font.pixelSize: 14; font.bold: true; Layout.fillWidth: true }
        RowLayout { Layout.fillWidth: true
            TextField { id: dateText; Layout.fillWidth: true; readOnly: true; text: "2026-05-15"; color: textMain; ToolTip.visible: hovered; ToolTip.text: label + " · YYYY-MM-DD"; background: Rectangle { color: card; radius: 12; border.color: line } }
            Button { text: appController.language === "en" ? "Pick" : "选择"; ToolTip.visible: hovered; ToolTip.text: appController.language === "en" ? "Open date picker" : "打开日期选择器"; onClicked: { var parts = dateText.text.split("-"); yearBox.value = Number(parts[0]); monthBox.value = Number(parts[1]); dayBox.value = Number(parts[2]); picker.open() } }
        }
        Label { text: hint; color: textMuted; font.pixelSize: 12; Layout.fillWidth: true }
        Dialog { id: picker; title: label; modal: true; standardButtons: Dialog.Ok | Dialog.Cancel; onAccepted: dateText.text = yearBox.value + "-" + (monthBox.value < 10 ? "0" : "") + monthBox.value + "-" + (dayBox.value < 10 ? "0" : "") + dayBox.value; background: Rectangle { color: surface; radius: 18; border.color: lineStrong } contentItem: ColumnLayout { spacing: 12; Label { text: appController.language === "en" ? "Choose year, month, and day" : "选择年、月、日"; color: textMain } RowLayout { SpinBox { id: yearBox; from: 2020; to: 2035; value: 2026; editable: true; ToolTip.visible: hovered; ToolTip.text: appController.language === "en" ? "Year" : "年份" } SpinBox { id: monthBox; from: 1; to: 12; value: 5; editable: true; ToolTip.visible: hovered; ToolTip.text: appController.language === "en" ? "Month" : "月份" } SpinBox { id: dayBox; from: 1; to: 31; value: 15; editable: true; ToolTip.visible: hovered; ToolTip.text: appController.language === "en" ? "Day" : "日期" } } RowLayout { Button { text: "-1"; ToolTip.visible: hovered; ToolTip.text: appController.language === "en" ? "Previous day" : "前一天"; onClicked: dayBox.value = Math.max(1, dayBox.value - 1) } Button { text: "+1"; ToolTip.visible: hovered; ToolTip.text: appController.language === "en" ? "Next day" : "后一天"; onClicked: dayBox.value = Math.min(31, dayBox.value + 1) } } } }
    }

    component DataGrid: Rectangle {
        property var model: []
        color: surface
        radius: 16
        border.color: line
        clip: true
        ColumnLayout { anchors.fill: parent; anchors.margins: 1; spacing: 0
            Row { Layout.fillWidth: true; height: 42
                TableHeaderCell { text: "#"; w: 52 }
                TableHeaderCell { text: appController.language === "en" ? "Title" : "标题"; w: 320 }
                TableHeaderCell { text: appController.language === "en" ? "Account" : "账号"; w: 180 }
                TableHeaderCell { text: appController.language === "en" ? "Published" : "发布时间"; w: 130 }
                TableHeaderCell { text: appController.language === "en" ? "Hot" : "爆值"; w: 100 }
                TableHeaderCell { text: appController.language === "en" ? "Reads" : "阅读"; w: 120 }
                TableHeaderCell { text: appController.language === "en" ? "Likes" : "点赞"; w: 120 }
                TableHeaderCell { text: appController.language === "en" ? "Avg reads" : "均读"; w: 120 }
                TableHeaderCell { text: appController.language === "en" ? "Fans" : "粉丝"; w: 120 }
                TableHeaderCell { text: appController.language === "en" ? "Link" : "链接"; w: 360 }
            }
            ScrollView { Layout.fillWidth: true; Layout.fillHeight: true; clip: true; ScrollBar.horizontal.policy: ScrollBar.AlwaysOn; ScrollBar.vertical.policy: ScrollBar.AlwaysOn
                Column { width: 1622
                    Repeater { model: root.hotRows
                        DataRow { rowIndex: index; rowText: modelData }
                    }
                }
            }
        }
    }

    component TableHeaderCell: Rectangle { property string text: ""; property int w: 120; width: w; height: 42; color: "#1e293b"; border.color: line; Label { anchors.centerIn: parent; text: parent.text; color: textMain; font.bold: true; elide: Text.ElideRight; width: parent.width - 12; horizontalAlignment: Text.AlignHCenter } }
    component DataRow: Rectangle { property int rowIndex: 0; property string rowText: ""; width: 1622; height: 38; color: root.selectedHotRow === rowIndex ? "#12375a" : "#0f172a"; Row { anchors.fill: parent; DataCell { text: String(rowIndex + 1); w: 52; selected: root.selectedHotRow === rowIndex } DataCell { text: root.hotCell(rowText, 0); w: 320; selected: root.selectedHotRow === rowIndex } DataCell { text: root.hotCell(rowText, 1); w: 180; selected: root.selectedHotRow === rowIndex } DataCell { text: root.hotCell(rowText, 2); w: 130; selected: root.selectedHotRow === rowIndex } DataCell { text: root.hotCell(rowText, 3); w: 100; selected: root.selectedHotRow === rowIndex } DataCell { text: root.hotCell(rowText, 4); w: 120; selected: root.selectedHotRow === rowIndex } DataCell { text: root.hotCell(rowText, 5); w: 120; selected: root.selectedHotRow === rowIndex } DataCell { text: root.hotCell(rowText, 6); w: 120; selected: root.selectedHotRow === rowIndex } DataCell { text: root.hotCell(rowText, 7); w: 120; selected: root.selectedHotRow === rowIndex } DataCell { text: root.hotCell(rowText, 8); w: 360; selected: root.selectedHotRow === rowIndex } } MouseArea { anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: { root.selectedHotRow = rowIndex; appController.noteSelection(appController.language === "en" ? "Hot article result" : "Hot article result", rowText) } } }
    component DataCell: Rectangle { property string text: ""; property int w: 120; property bool selected: false; width: w; height: 38; color: selected ? "#12375a" : "#0f172a"; border.color: line; Label { anchors.verticalCenter: parent.verticalCenter; anchors.left: parent.left; anchors.leftMargin: 8; text: parent.text; color: textMain; elide: Text.ElideRight; width: parent.width - 16 } }
    component RowCard: Rectangle { signal picked(); property string rowText: ""; width: ListView.view ? ListView.view.width : 800; height: 52; color: rowMouse.containsMouse ? "#1e3a8a" : card; radius: 12; border.color: line; Text { anchors.verticalCenter: parent.verticalCenter; anchors.left: parent.left; anchors.leftMargin: 14; text: rowText; color: textMain; elide: Text.ElideRight; width: parent.width - 28 } MouseArea { id: rowMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: picked() } }
    component StatCard: Rectangle { property string title: ""; property string value: ""; property string desc: ""; Layout.fillWidth: true; Layout.preferredHeight: 124; color: surface; radius: 18; border.color: line; Column { anchors.fill: parent; anchors.margins: 16; spacing: 8; Text { text: title; color: textSub; font.pixelSize: 14 } Text { text: value; color: textMain; font.pixelSize: 30; font.bold: true } Text { text: desc; color: textSub; wrapMode: Text.WordWrap; width: parent.width } } MouseArea { anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: appController.noteSelection(title, value + " " + desc) } }
}
