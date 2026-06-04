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

    property color bg: "#08090a"
    property color sideBg: "#0c0d0f"
    property color panel: "#191a1b"
    property color card: "#141516"
    property color card2: "#101113"
    property color fieldBg: "#0e0f11"
    property color line: "#14ffffff"
    property color lineStrong: "#24ffffff"
    property color accent: "#7170ff"
    property color accentSoft: "#5e6ad2"
    property color accentHover: "#828fff"
    property color rowAlt: "#06ffffff"
    property color rowHover: "#1a7170ff"
    property color rowSel: "#385e6ad2"
    property color textMain: "#f7f8f8"
    property color textSub: "#d0d6e0"
    property color textMuted: "#8a8f98"
    property color danger: "#fb7185"
    property color ok: "#27a644"
    property int pagePad: 28
    property string detailText: appController.language === "en" ? "Ready." : "就绪。"
    property var hotRows: appController.hotTypicalResultRows()
    property int selectedHotRow: -1
    property var libraryRows: appController.articleRows("")
    property var pluginRows: appController.pluginRows()
    property var taskRows: appController.taskRows()
    property var endpointRows: appController.apiEndpointRows("")
    property string selectedEndpointRow: ""
    property string selectedTaskRow: ""
    property var runRows: appController.runRows()
    property alias currentPageIndex: stack.currentIndex

    function t(key) { appController.language; return appController.trText(key) }
    function setDetail(title, body) {
        detailText = title + "\n" + body
        appController.noteSelection(title, body)
    }
    function refreshHotRows() {
        hotRows = appController.hotTypicalResultRows()
    }
    function hotCell(rowText, column) {
        var cells = String(rowText).split("｜")
        return column < cells.length ? cells[column] : ""
    }
    function hotExportPath(format) {
        var ext = format === "xml" ? "xml" : (format === "xls" ? "xls" : "md")
        return (appController.language === "en" ? "hot-article-results" : "爆文解析结果") + "." + ext
    }
    function guide(key) {
        appController.language
        var zh = {
            dashboard: "总览页只放关键状态和轻量操作，避免点击后卡住。所有卡片、列表、按钮都有明确反馈。",
            library: "本地内容库支持搜索、刷新、查看详情和导出。列表区域独立滚动，不会压住底部详情。",
            hot: "参数按类型选择控件：密钥用密码框，枚举用下拉框，页码用数字框，日期用日期选择器。",
            results: "解析结果独立成表格页，类似 Excel：固定表头、单元格、行选择、横向和纵向滚动。",
            report: "报告页展示可导出的内容拆解结果。",
            topics: "选题推荐以卡片列表展示，点击可查看后续处理输入预览。",
            plugins: "插件页展示内置能力，分析区和列表分区显示，避免文字压到控件下方。",
            api_browser: "接口浏览器列出内容数据全部可用接口，可按分类筛选、选中一行后用当前关键词直接采集。先在列表里选接口，再点运行，避免误触发付费请求。",
            runs: "运行历史记录每次采集的时间、状态、新增条数和返回信息。点任意一行可查看该次运行回执。",
            settings: "设置页用分组表单，所有输入都有 label 和说明。"
        }
        var en = {
            dashboard: "The overview keeps only key status and light actions so clicks do not freeze the UI. Every card, list, and button has feedback.",
            library: "The local library supports search, refresh, details, and export. The list scrolls independently.",
            hot: "Parameters use semantic controls: password for secret, combo boxes for enums, spin boxes for pages, and date pickers for dates.",
            results: "Parsed results live on a separate Excel-like table page with fixed headers, cells, row selection, and two-axis scrolling.",
            report: "The report page shows exportable content analysis.",
            topics: "Topic ideas are displayed as cards. Click one to preview the next-step input.",
            plugins: "The plugin page separates capability lists and analysis text to avoid text under controls.",
            api_browser: "The API browser lists every available Jizhile endpoint. Filter by category, select a row, then collect with the current keyword. Select first, then run, to avoid accidental paid requests.",
            runs: "Run history records the time, status, inserted count, and message of each collection. Click any row to see that run receipt.",
            settings: "Settings use grouped forms; every input has a label and help text."
        }
        return appController.language === "en" ? en[key] : zh[key]
    }

    ExportDialog {
        id: exportDialog
        title: appController.language === "en" ? "Export parsed results" : "导出解析结果"
        modal: true
        width: 580
        x: (root.width - width) / 2
        y: Math.max(80, (root.height - height) / 2)
        standardButtons: Dialog.Ok | Dialog.Cancel
        background: Rectangle { color: panel; radius: 18; border.color: lineStrong }
        function openForHotResults() {
            exportFormat.currentIndex = 0
            exportPath.text = hotExportPath(exportFormat.currentValue)
            open()
        }
        onAccepted: {
            var ok = appController.exportHotTypicalResults(exportPath.text, exportFormat.currentValue)
            setDetail(ok ? (appController.language === "en" ? "Export complete" : "导出完成") : (appController.language === "en" ? "Export failed" : "导出失败"), exportPath.text)
        }
        contentItem: ColumnLayout {
            spacing: 14
            Label { text: appController.language === "en" ? "Choose format and location" : "选择格式和保存位置"; color: textMain; font.pixelSize: 20; font.bold: true; Layout.fillWidth: true }
            Label { text: appController.language === "en" ? "Enter a filename or absolute path. Example: D:/Desktop/results.xls" : "填写文件名或绝对路径。例如：D:/桌面/爆文解析结果.xls"; color: textSub; wrapMode: Text.WordWrap; Layout.fillWidth: true }
            FormCombo { id: exportFormatWrap; label: appController.language === "en" ? "Format" : "格式"; hint: appController.language === "en" ? "Output file type" : "导出文件类型"
                DarkCombo { id: exportFormat; anchors.fill: parent; textRole: "label"; valueRole: "value"; model: [{value:"md",label:"Markdown (.md)"},{value:"xml",label:"XML (.xml)"},{value:"xls",label:"Excel (.xls)"}]; ToolTip.visible: hovered; ToolTip.text: appController.language === "en" ? "Select output format" : "选择导出格式"; onActivated: exportPath.text = hotExportPath(currentValue) }
            }
            FormText { id: exportPath; label: appController.language === "en" ? "Save to" : "保存到"; hint: appController.language === "en" ? "Filename or absolute path" : "文件名或绝对路径"; placeholder: appController.language === "en" ? "D:/Desktop/results.xls" : "D:/桌面/爆文解析结果.xls" }
        }
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            Layout.preferredWidth: 248
            Layout.fillHeight: true
            color: sideBg
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 18
                spacing: 10
                Label { text: root.t("app_title"); color: textMain; font.pixelSize: 22; font.bold: true; Layout.fillWidth: true; wrapMode: Text.WordWrap }
                Label { text: root.t("subtitle"); color: textSub; font.pixelSize: 13; wrapMode: Text.WordWrap; Layout.fillWidth: true }
                RowLayout { Layout.fillWidth: true; spacing: 8
                    AppButton { Layout.fillWidth: true; text: "中文"; highlighted: appController.language === "zh"; ToolTip.visible: hovered; ToolTip.text: "切换中文"; onClicked: appController.setLanguage("zh") }
                    AppButton { Layout.fillWidth: true; text: "EN"; highlighted: appController.language === "en"; ToolTip.visible: hovered; ToolTip.text: "Switch to English"; onClicked: appController.setLanguage("en") }
                }
                Rectangle { Layout.fillWidth: true; height: 1; color: line }
                NavButton { label: root.t("dashboard_title"); index: 0 }
                NavButton { label: root.t("library_title"); index: 1 }
                NavButton { label: root.t("hot_api_title"); index: 2 }
                NavButton { label: root.t("hot_results_title"); index: 3 }
                NavButton { label: root.t("report_title"); index: 4 }
                NavButton { label: root.t("topics_title"); index: 5 }
                NavButton { label: root.t("plugins_title"); index: 6 }
                NavButton { label: root.t("api_browser_title"); index: 8 }
                NavButton { label: root.t("runs_title"); index: 9 }
                NavButton { label: root.t("settings_title"); index: 7 }
                Item { Layout.fillHeight: true }
                Label { text: appController.status; color: accent; font.pixelSize: 12; wrapMode: Text.WordWrap; Layout.fillWidth: true }
            }
        }

        StackLayout {
            id: stack
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: 2

            PageFrame { pageTitle: root.t("dashboard_title"); pageGuide: root.guide("dashboard")
                Flow { Layout.fillWidth: true; spacing: 14
                    StatCard { title: appController.language === "en" ? "Articles" : "内容数量"; value: appController.articleCount.toString(); desc: "SQLite" }
                    StatCard { title: appController.language === "en" ? "Reads" : "总阅读"; value: appController.totalReads.toString(); desc: appController.language === "en" ? "Local summary" : "本地汇总" }
                    StatCard { title: appController.language === "en" ? "Likes" : "总点赞"; value: appController.totalLikes.toString(); desc: appController.language === "en" ? "Local summary" : "本地汇总" }
                }
                Card { cardHeight: 270; cardTitle: appController.language === "en" ? "Quick actions" : "快捷操作"; cardSubtitle: appController.language === "en" ? "Lightweight actions only. Heavy diagnostics stay in self-test/package scripts." : "这里只放轻量操作，避免仪表盘点击卡住。"
                    ColumnLayout { anchors.fill: parent; anchors.margins: 16; spacing: 12
                        FormText { id: dashKeyword; label: appController.language === "en" ? "Keyword" : "关键词"; hint: appController.language === "en" ? "Used by quick collection" : "用于快速采集"; text: "AI" }
                        RowLayout { Layout.fillWidth: true; spacing: 10
                            AppButton { text: root.t("load_samples"); ToolTip.visible: hovered; ToolTip.text: "加载本地示例"; onClicked: { appController.loadMockArticles(); setDetail(text, appController.status) } }
                            AppButton { text: root.t("collect_now"); highlighted: true; ToolTip.visible: hovered; ToolTip.text: "按关键词立即采集"; onClicked: { appController.runCollection(dashKeyword.text); setDetail(text, appController.status) } }
                            AppButton { text: root.t("self_check"); ToolTip.visible: hovered; ToolTip.text: "查看自检入口说明，不在仪表盘同步跑重任务"; onClicked: setDetail(text, appController.language === "en" ? "Use run-with-log.bat or --self-test for full diagnostics." : "完整诊断请运行 run-with-log.bat 或 --self-test，避免界面卡住。") }
                        }
                    }
                }
                Card { cardHeight: 240; cardTitle: appController.language === "en" ? "Status details" : "状态详情"; cardSubtitle: appController.language === "en" ? "Latest interaction feedback" : "最近一次交互反馈"
                    DetailBox { text: root.detailText }
                }
            }

            PageFrame { pageTitle: root.t("library_title"); pageGuide: root.guide("library")
                Card { cardHeight: 250; cardTitle: appController.language === "en" ? "Search and actions" : "搜索与操作"; cardSubtitle: appController.language === "en" ? "Clear labels and separated action buttons" : "输入和按钮分区显示，不挤在一行"
                    ColumnLayout { anchors.fill: parent; anchors.margins: 16; spacing: 12
                        FormText { id: search; label: appController.language === "en" ? "Search" : "搜索"; hint: appController.language === "en" ? "Title or account" : "标题或账号" }
                        RowLayout { Layout.fillWidth: true; spacing: 10
                            AppButton { text: appController.language === "en" ? "Refresh" : "刷新"; ToolTip.visible: hovered; ToolTip.text: "刷新列表"; onClicked: root.libraryRows = appController.articleRows(search.text) }
                            AppButton { text: appController.language === "en" ? "Export MD" : "导出 MD"; ToolTip.visible: hovered; ToolTip.text: "导出本地内容 Markdown"; onClicked: appController.exportMarkdown("media-hit-articles.md") }
                            AppButton { text: appController.language === "en" ? "Export XML" : "导出 XML"; ToolTip.visible: hovered; ToolTip.text: "导出本地内容 XML"; onClicked: appController.exportXml("media-hit-articles.xml") }
                        }
                    }
                }
                Card { cardHeight: 360; cardTitle: appController.language === "en" ? "Content list" : "内容列表"; cardSubtitle: appController.language === "en" ? "Independent scroll area" : "独立滚动区域"
                    ScrollView { anchors.fill: parent; anchors.margins: 16; clip: true
                        Column { width: parent.width; spacing: 8
                            Repeater { model: root.libraryRows
                                RowCard { rowText: modelData; onPicked: { root.detailText = appController.articleDetail(modelData); setDetail(appController.language === "en" ? "Article" : "内容", modelData) } }
                            }
                        }
                    }
                }
                Card { cardHeight: 220; cardTitle: appController.language === "en" ? "Details" : "详情"; cardSubtitle: appController.language === "en" ? "Selected row details" : "选中内容详情"
                    DetailBox { text: root.detailText }
                }
            }

            PageFrame { pageTitle: root.t("hot_api_title"); pageGuide: root.guide("hot")
                Card { cardHeight: 680; cardTitle: appController.language === "en" ? "Request parameters" : "采集参数"; cardSubtitle: appController.language === "en" ? "Every field has a label, type, and help text" : "每个字段都有名称、类型和说明"
                    ColumnLayout { anchors.fill: parent; anchors.margins: 16; spacing: 14
                        GridLayout { Layout.fillWidth: true; columns: root.width > 1240 ? 2 : 1; columnSpacing: 18; rowSpacing: 14
                            FormText { id: hotKey; label: appController.language === "en" ? "Secret key" : "密钥"; hint: appController.language === "en" ? "Secret key; blank uses local sample" : "密钥；留空使用本地示例"; password: true }
                            FormText { id: hotKeyword; label: appController.language === "en" ? "Keyword" : "关键词"; hint: appController.language === "en" ? "Text keyword; blank means all" : "文本关键词；为空搜索全部"; text: "AI" }
                            FormCombo { label: appController.language === "en" ? "Content type" : "内容类型"; hint: appController.language === "en" ? "Content type enum" : "内容类型枚举"
                                DarkCombo { id: hotPubType; anchors.fill: parent; textRole: "label"; valueRole: "value"; model: [{value:"0",label:"0 · 图文"},{value:"5",label:"5 · 纯视频"},{value:"7",label:"7 · 纯音乐"},{value:"8",label:"8 · 纯图片"},{value:"10",label:"10 · 纯文字"},{value:"11",label:"11 · 转载文章"}]; ToolTip.visible: hovered; ToolTip.text: "pub_type" }
                            }
                            FormCombo { label: appController.language === "en" ? "Category" : "分类"; hint: appController.language === "en" ? "Category enum 0-30" : "分类枚举 0-30"
                                DarkCombo { id: hotCategory; anchors.fill: parent; textRole: "label"; valueRole: "value"; model: [{value:"0",label:"0 · 全部"},{value:"1",label:"1 · 国际"},{value:"2",label:"2 · 体育"},{value:"3",label:"3 · 娱乐"},{value:"4",label:"4 · 社会"},{value:"5",label:"5 · 财经"},{value:"6",label:"6 · 时事"},{value:"7",label:"7 · 科技"},{value:"8",label:"8 · 情感"},{value:"9",label:"9 · 汽车"},{value:"10",label:"10 · 教育"},{value:"11",label:"11 · 时尚"},{value:"12",label:"12 · 游戏"},{value:"13",label:"13 · 军事"},{value:"14",label:"14 · 旅游"},{value:"15",label:"15 · 美食"},{value:"16",label:"16 · 文化"},{value:"17",label:"17 · 健康"},{value:"18",label:"18 · 搞笑"},{value:"19",label:"19 · 家居"},{value:"20",label:"20 · 动漫"},{value:"21",label:"21 · 宠物"},{value:"22",label:"22 · 母婴"},{value:"23",label:"23 · 星座"},{value:"24",label:"24 · 历史"},{value:"25",label:"25 · 音乐"},{value:"26",label:"26 · 未分类"},{value:"27",label:"27 · 综合"},{value:"28",label:"28 · 职场"},{value:"29",label:"29 · 三农"},{value:"30",label:"30 · 养老"}]; ToolTip.visible: hovered; ToolTip.text: "category" }
                            }
                            FormSpin { id: hotPage; label: appController.language === "en" ? "Page" : "页码"; hint: appController.language === "en" ? "Positive page number" : "正整数页码"; fromValue: 1; toValue: 9999; currentValue: 1 }
                            FormCombo { label: appController.language === "en" ? "Date preset" : "日期预设"; hint: appController.language === "en" ? "Quickly fill start/end" : "快速填入起止日期"
                                RowLayout { anchors.fill: parent; spacing: 8
                                    DarkCombo { id: datePreset; Layout.fillWidth: true; textRole: "label"; valueRole: "value"; model: [{value:"last_7_days",label:appController.language === "en" ? "Last 7 days" : "最近7天"},{value:"last_30_days",label:appController.language === "en" ? "Last 30 days" : "最近30天"},{value:"this_month",label:appController.language === "en" ? "This month" : "本月"},{value:"custom",label:appController.language === "en" ? "Custom" : "自定义"}]; ToolTip.visible: hovered; ToolTip.text: "date preset" }
                                    AppButton { text: appController.language === "en" ? "Apply" : "应用"; ToolTip.visible: hovered; ToolTip.text: "应用日期预设"; onClicked: { var r = appController.dateRangeForPreset(datePreset.currentValue); hotStart.text = r[0]; hotEnd.text = r[1] } }
                                }
                            }
                            DateField { id: hotStart; label: appController.language === "en" ? "Start date" : "开始日期"; hint: appController.language === "en" ? "Start date" : "开始日期"; text: "2026-05-15" }
                            DateField { id: hotEnd; label: appController.language === "en" ? "End date" : "截止日期"; hint: appController.language === "en" ? "End date" : "截止日期"; text: "2026-05-17" }
                        }
                        RowLayout { Layout.fillWidth: true; spacing: 10
                            AppButton { text: root.t("preview_payload"); ToolTip.visible: hovered; ToolTip.text: "预览请求参数"; onClicked: payloadPreview.text = appController.hotTypicalPayloadPreview(hotKey.text, hotKeyword.text, hotPubType.currentValue, hotCategory.currentValue, hotPage.value, hotStart.text, hotEnd.text) }
                            AppButton { text: appController.language === "en" ? "Collect and parse" : "采集并解析"; highlighted: true; ToolTip.visible: hovered; ToolTip.text: "采集后打开结果表"; onClicked: { appController.runHotTypicalCollection(hotKey.text, hotKeyword.text, hotPubType.currentValue, hotCategory.currentValue, hotPage.value, hotStart.text, hotEnd.text); refreshHotRows(); stack.currentIndex = 3 } }
                            AppButton { text: appController.language === "en" ? "Open result table" : "打开结果表"; ToolTip.visible: hovered; ToolTip.text: "打开结果表页面"; onClicked: { refreshHotRows(); stack.currentIndex = 3 } }
                        }
                    }
                }
                Card { cardHeight: 280; cardTitle: appController.language === "en" ? "Request preview" : "请求预览"; cardSubtitle: appController.language === "en" ? "Readonly parameter preview" : "只读参数预览"
                    DetailBox { id: payloadPreview; text: appController.hotTypicalPayloadPreview("[empty]", hotKeyword.text, hotPubType.currentValue, hotCategory.currentValue, hotPage.value, hotStart.text, hotEnd.text) }
                }
            }

            ResultPage { }
            SimpleTextPage { titleText: root.t("report_title"); guideText: root.guide("report"); bodyText: appController.generateReport(); buttonText: appController.language === "en" ? "Export report" : "导出报告"; onAction: appController.exportReport("media-hit-report.md") }
            ListPage { titleText: root.t("topics_title"); guideText: root.guide("topics"); rows: appController.recommendTopics() }
            PluginPage { }
            SettingsPage { }
            ApiBrowserPage { }
            RunHistoryPage { }
        }
    }

    component ExportDialog: Dialog {}

    component AppButton: Button {
        id: ctl
        property bool primary: highlighted
        implicitHeight: 40
        leftPadding: 18
        rightPadding: 18
        topPadding: 8
        bottomPadding: 8
        font.pixelSize: 14
        font.bold: primary
        hoverEnabled: true
        contentItem: Text {
            text: ctl.text
            font: ctl.font
            color: ctl.primary ? "#ffffff" : (ctl.checked ? accentHover : textSub)
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }
        background: Rectangle {
            radius: 10
            color: ctl.primary
                ? (ctl.down ? accentSoft : (ctl.hovered ? accentHover : accent))
                : (ctl.down ? "#1effffff" : (ctl.hovered ? "#14ffffff" : "#0affffff"))
            border.width: ctl.primary ? 0 : 1
            border.color: ctl.checked ? accent : lineStrong
            Behavior on color { ColorAnimation { duration: 120 } }
        }
    }

    component DarkCombo: ComboBox {
        id: combo
        implicitHeight: 40
        font.pixelSize: 14
        hoverEnabled: true
        contentItem: Text {
            leftPadding: 12
            rightPadding: 30
            text: combo.displayText
            font: combo.font
            color: textMain
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }
        background: Rectangle {
            radius: 10
            color: fieldBg
            border.width: 1
            border.color: combo.activeFocus || combo.hovered ? accent : lineStrong
            Behavior on border.color { ColorAnimation { duration: 120 } }
        }
        indicator: Canvas {
            x: combo.width - width - 12
            y: (combo.height - height) / 2
            width: 11
            height: 7
            contextType: "2d"
            onPaint: {
                var ctx = getContext("2d");
                ctx.reset();
                ctx.moveTo(0, 0);
                ctx.lineTo(width, 0);
                ctx.lineTo(width / 2, height);
                ctx.closePath();
                ctx.fillStyle = combo.hovered ? "#f7f8f8" : "#8a8f98";
                ctx.fill();
            }
        }
    }

    component NavButton: Button {
        id: nav
        property string label: ""
        property int index: 0
        Layout.fillWidth: true
        text: label
        highlighted: stack.currentIndex === index
        hoverEnabled: true
        implicitHeight: 42
        ToolTip.visible: hovered
        ToolTip.text: appController.language === "en" ? "Open page" : "打开页面"
        onClicked: stack.currentIndex = index
        contentItem: Text {
            text: nav.text
            color: nav.highlighted ? "#ffffff" : textSub
            font.pixelSize: 14
            font.bold: nav.highlighted
            verticalAlignment: Text.AlignVCenter
            leftPadding: 12
            elide: Text.ElideRight
        }
        background: Rectangle {
            radius: 10
            color: nav.highlighted ? accentSoft : (nav.hovered ? "#12ffffff" : "transparent")
            Behavior on color { ColorAnimation { duration: 120 } }
        }
    }

    component PageFrame: Rectangle {
        property string pageTitle: ""
        property string pageGuide: ""
        default property alias content: body.data
        color: bg
        ColumnLayout { anchors.fill: parent; anchors.margins: pagePad; spacing: 14
            Label { text: pageTitle; color: textMain; font.pixelSize: 28; font.bold: true; Layout.fillWidth: true; elide: Text.ElideRight }
            Label { text: pageGuide; color: textSub; font.pixelSize: 14; wrapMode: Text.WordWrap; Layout.fillWidth: true }
            ScrollView { Layout.fillWidth: true; Layout.fillHeight: true; clip: true; ScrollBar.vertical.policy: ScrollBar.AsNeeded; ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                ColumnLayout { id: body; width: Math.min(1040, parent.width); spacing: 14 }
            }
        }
    }

    component Card: Rectangle {
        property string cardTitle: ""
        property string cardSubtitle: ""
        property int cardHeight: 220
        default property alias content: slot.data
        Layout.fillWidth: true
        Layout.preferredHeight: cardHeight
        Layout.minimumHeight: cardHeight
        color: card
        radius: 18
        border.color: line
        ColumnLayout { anchors.fill: parent; anchors.margins: 16; spacing: 8
            Label { text: cardTitle; color: textMain; font.pixelSize: 18; font.bold: true; Layout.fillWidth: true; elide: Text.ElideRight }
            Label { text: cardSubtitle; color: textSub; font.pixelSize: 13; wrapMode: Text.WordWrap; Layout.fillWidth: true }
            Item { id: slot; Layout.fillWidth: true; Layout.fillHeight: true; Layout.minimumHeight: Math.max(70, childrenRect.height) }
        }
    }

    component FormText: ColumnLayout {
        property alias text: input.text
        property string label: ""
        property string hint: ""
        property string placeholder: ""
        property bool password: false
        Layout.fillWidth: true
        Layout.minimumWidth: 320
        spacing: 6
        Label { text: label; color: textMain; font.pixelSize: 14; font.bold: true; Layout.fillWidth: true }
        RowLayout { Layout.fillWidth: true; spacing: 8
            TextField { id: input; Layout.fillWidth: true; placeholderText: placeholder || hint; echoMode: password && !show.checked ? TextInput.Password : TextInput.Normal; color: textMain; selectedTextColor: "#020617"; selectionColor: accent; ToolTip.visible: hovered; ToolTip.text: label + " · " + hint; background: Rectangle { color: fieldBg; radius: 10; border.color: input.activeFocus ? accent : lineStrong } }
            AppButton { id: show; visible: password; checkable: true; text: checked ? (appController.language === "en" ? "Hide" : "隐藏") : (appController.language === "en" ? "Show" : "显示"); ToolTip.visible: hovered; ToolTip.text: "显示或隐藏" }
        }
        Label { text: hint; color: textMuted; font.pixelSize: 12; wrapMode: Text.WordWrap; Layout.fillWidth: true }
    }

    component FormCombo: ColumnLayout {
        property string label: ""
        property string hint: ""
        default property alias content: slot.data
        Layout.fillWidth: true
        Layout.minimumWidth: 320
        spacing: 6
        Label { text: label; color: textMain; font.pixelSize: 14; font.bold: true; Layout.fillWidth: true }
        Rectangle { id: slot; Layout.fillWidth: true; height: 42; color: fieldBg; radius: 10; border.color: lineStrong }
        Label { text: hint; color: textMuted; font.pixelSize: 12; wrapMode: Text.WordWrap; Layout.fillWidth: true }
    }

    component FormSpin: ColumnLayout {
        property string label: ""
        property string hint: ""
        property int fromValue: 1
        property int toValue: 9999
        property alias value: spin.value
        property int currentValue: 1
        Layout.fillWidth: true
        Layout.minimumWidth: 320
        spacing: 6
        Label { text: label; color: textMain; font.pixelSize: 14; font.bold: true; Layout.fillWidth: true }
        SpinBox { id: spin; Layout.fillWidth: true; from: fromValue; to: toValue; value: currentValue; editable: true; ToolTip.visible: hovered; ToolTip.text: label + " · " + hint }
        Label { text: hint; color: textMuted; font.pixelSize: 12; wrapMode: Text.WordWrap; Layout.fillWidth: true }
    }

    component DateField: ColumnLayout {
        property alias text: dateText.text
        property string label: ""
        property string hint: ""
        Layout.fillWidth: true
        Layout.minimumWidth: 320
        spacing: 6
        Label { text: label; color: textMain; font.pixelSize: 14; font.bold: true; Layout.fillWidth: true }
        RowLayout { Layout.fillWidth: true; spacing: 8
            TextField { id: dateText; Layout.fillWidth: true; readOnly: true; color: textMain; ToolTip.visible: hovered; ToolTip.text: label + " · YYYY-MM-DD"; background: Rectangle { color: fieldBg; radius: 10; border.color: lineStrong } }
            AppButton { text: appController.language === "en" ? "Pick" : "选择"; ToolTip.visible: hovered; ToolTip.text: "打开日期选择器"; onClicked: { var p = dateText.text.split("-"); yearBox.value = Number(p[0]); monthBox.value = Number(p[1]); dayBox.value = Number(p[2]); picker.open() } }
        }
        Label { text: hint; color: textMuted; font.pixelSize: 12; wrapMode: Text.WordWrap; Layout.fillWidth: true }
        Dialog { id: picker; modal: true; title: label; standardButtons: Dialog.Ok | Dialog.Cancel; onAccepted: dateText.text = yearBox.value + "-" + (monthBox.value < 10 ? "0" : "") + monthBox.value + "-" + (dayBox.value < 10 ? "0" : "") + dayBox.value; background: Rectangle { color: panel; radius: 18; border.color: lineStrong } contentItem: ColumnLayout { spacing: 12; Label { text: appController.language === "en" ? "Choose date" : "选择日期"; color: textMain; font.bold: true } RowLayout { SpinBox { id: yearBox; from: 2020; to: 2035; value: 2026; editable: true; ToolTip.visible: hovered; ToolTip.text: "年份" } SpinBox { id: monthBox; from: 1; to: 12; value: 5; editable: true; ToolTip.visible: hovered; ToolTip.text: "月份" } SpinBox { id: dayBox; from: 1; to: 31; value: 15; editable: true; ToolTip.visible: hovered; ToolTip.text: "日期" } } } }
    }

    component DetailBox: TextArea {
        readOnly: true
        wrapMode: TextArea.Wrap
        color: textMain
        selectedTextColor: "#020617"
        selectionColor: accent
        ToolTip.visible: hovered
        ToolTip.text: appController.language === "en" ? "Readonly details" : "只读详情"
        background: Rectangle { color: fieldBg; radius: 12; border.color: line }
        anchors.fill: parent
        anchors.margins: 16
    }

    component RowCard: Rectangle {
        signal picked()
        property string rowText: ""
        width: ListView.view ? ListView.view.width : 760
        height: 48
        color: hover.containsMouse ? rowHover : card2
        radius: 12
        border.color: line
        Label { anchors.verticalCenter: parent.verticalCenter; anchors.left: parent.left; anchors.leftMargin: 14; anchors.right: parent.right; anchors.rightMargin: 14; text: rowText; color: textMain; elide: Text.ElideRight }
        MouseArea { id: hover; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: picked() }
    }

    component StatCard: Rectangle {
        property string title: ""
        property string value: ""
        property string desc: ""
        width: 320
        height: 128
        color: card
        radius: 18
        border.color: line
        Column { anchors.fill: parent; anchors.margins: 16; spacing: 8
            Label { text: title; color: textSub; font.pixelSize: 13; width: parent.width; elide: Text.ElideRight }
            Label { text: value; color: textMain; font.pixelSize: 30; font.bold: true; width: parent.width; elide: Text.ElideRight }
            Label { text: desc; color: textMuted; font.pixelSize: 12; width: parent.width; elide: Text.ElideRight }
        }
        MouseArea { anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: setDetail(title, value + " · " + desc) }
    }

    component ResultPage: Rectangle {
        color: bg
        ColumnLayout { anchors.fill: parent; anchors.margins: pagePad; spacing: 12
            Label { text: root.t("hot_results_title"); color: textMain; font.pixelSize: 28; font.bold: true; Layout.fillWidth: true }
            Label { text: root.guide("results"); color: textSub; wrapMode: Text.WordWrap; Layout.fillWidth: true }
            // 诚实状态横幅：真实数据=绿，示例=黄，错误/空=红/灰，并显示花费/余额/总数。
            // Honest status banner: real=green, sample=amber, error/empty=red/grey; shows cost/balance/total.
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: hotStatusCol.implicitHeight + 20
                radius: 12
                visible: appController.hotResultCount > 0 || appController.hotIsError || appController.hotStatus !== "-"
                color: appController.hotIsReal ? "#1f3326" : (appController.hotIsSample ? "#3a3320" : (appController.hotIsError ? "#3a2222" : fieldBg))
                border.color: appController.hotIsReal ? "#3fb950" : (appController.hotIsSample ? "#d29922" : (appController.hotIsError ? "#f85149" : line))
                ColumnLayout {
                    id: hotStatusCol
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 4
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12
                        Label {
                            text: (appController.hotIsReal ? "● " : (appController.hotIsSample ? "▲ " : "■ ")) + appController.hotStatus
                            color: appController.hotIsReal ? "#3fb950" : (appController.hotIsSample ? "#d29922" : (appController.hotIsError ? "#f85149" : textSub))
                            font.bold: true
                            font.pixelSize: 15
                        }
                        Label {
                            text: (appController.language === "en" ? "Parsed " : "已解析 ") + appController.hotResultCount + (appController.language === "en" ? " rows" : " 条")
                            color: textMain; font.pixelSize: 14
                        }
                        Label {
                            visible: appController.hotIsReal && appController.hotTotal > 0
                            text: (appController.language === "en" ? "Total " : "共 ") + appController.hotTotal + (appController.language === "en" ? " / " : " 条 / ") + appController.hotTotalPage + (appController.language === "en" ? " pages" : " 页")
                            color: textSub; font.pixelSize: 14
                        }
                        Label {
                            visible: appController.hotCost > 0
                            text: (appController.language === "en" ? "Cost ¥" : "花费 ¥") + appController.hotCost.toFixed(2)
                            color: "#d29922"; font.pixelSize: 14
                        }
                        Label {
                            visible: appController.hotRemainMoney > 0
                            text: (appController.language === "en" ? "Balance ¥" : "余额 ¥") + appController.hotRemainMoney.toFixed(2)
                            color: "#3fb950"; font.pixelSize: 14
                        }
                        Item { Layout.fillWidth: true }
                    }
                    Label {
                        Layout.fillWidth: true
                        visible: appController.hotMessage !== "" || appController.hotNote !== ""
                        text: appController.hotNote !== "" ? appController.hotNote : appController.hotMessage
                        color: appController.hotIsError ? "#f85149" : textSub
                        font.pixelSize: 13
                        wrapMode: Text.WordWrap
                    }
                }
            }
            RowLayout { Layout.fillWidth: true; spacing: 10
                Label { text: appController.language === "en" ? "Parsed result table" : "解析结果表"; color: textMain; font.pixelSize: 18; font.bold: true; Layout.fillWidth: true }
                AppButton { text: appController.language === "en" ? "Refresh" : "刷新"; ToolTip.visible: hovered; ToolTip.text: "刷新解析结果"; onClicked: refreshHotRows() }
                AppButton { text: appController.language === "en" ? "Export..." : "导出..."; ToolTip.visible: hovered; ToolTip.text: "选择格式和路径"; onClicked: exportDialog.openForHotResults() }
            }
            DataGrid { Layout.fillWidth: true; Layout.fillHeight: true }
            TextArea { Layout.fillWidth: true; Layout.preferredHeight: 86; readOnly: true; wrapMode: TextArea.Wrap; text: selectedHotRow >= 0 && selectedHotRow < hotRows.length ? hotRows[selectedHotRow] : root.guide("results"); color: textMain; ToolTip.visible: hovered; ToolTip.text: "选中行详情"; background: Rectangle { color: fieldBg; radius: 12; border.color: line } }
        }
    }

    component DataGrid: Rectangle {
        color: card
        radius: 16
        border.color: line
        clip: true
        ColumnLayout { anchors.fill: parent; spacing: 0
            Row { Layout.fillWidth: true; height: 42
                HeaderCell { text: "#"; w: 52 }
                HeaderCell { text: appController.language === "en" ? "Title" : "标题"; w: 340 }
                HeaderCell { text: appController.language === "en" ? "Account" : "账号"; w: 170 }
                HeaderCell { text: appController.language === "en" ? "Published" : "发布时间"; w: 130 }
                HeaderCell { text: appController.language === "en" ? "Hot" : "爆值"; w: 90 }
                HeaderCell { text: appController.language === "en" ? "Reads" : "阅读"; w: 110 }
                HeaderCell { text: appController.language === "en" ? "Likes" : "点赞"; w: 110 }
                HeaderCell { text: appController.language === "en" ? "Avg" : "均读"; w: 110 }
                HeaderCell { text: appController.language === "en" ? "Fans" : "粉丝"; w: 110 }
                HeaderCell { text: appController.language === "en" ? "Link" : "链接"; w: 340 }
            }
            ScrollView { Layout.fillWidth: true; Layout.fillHeight: true; clip: true; ScrollBar.horizontal.policy: ScrollBar.AlwaysOn; ScrollBar.vertical.policy: ScrollBar.AsNeeded
                Column { width: 1562
                    Repeater { model: root.hotRows
                        DataRow { rowIndex: index; rowText: modelData }
                    }
                }
            }
        }
    }

    component HeaderCell: Rectangle { property string text: ""; property int w: 120; width: w; height: 44; color: card2; border.color: line; Label { anchors.centerIn: parent; width: parent.width - 12; text: parent.text; color: textMain; font.bold: true; horizontalAlignment: Text.AlignHCenter; elide: Text.ElideRight } }
    component Cell: Rectangle { property string text: ""; property int w: 120; property bool selected: false; property bool alt: false; width: w; height: 40; color: selected ? rowSel : (alt ? rowAlt : fieldBg); border.color: line; Label { anchors.verticalCenter: parent.verticalCenter; anchors.left: parent.left; anchors.leftMargin: 8; width: parent.width - 16; text: parent.text; color: textMain; elide: Text.ElideRight } }
    component DataRow: Rectangle { property int rowIndex: 0; property string rowText: ""; width: 1562; height: 40; color: "transparent"; Row { anchors.fill: parent; Cell { text: String(rowIndex + 1); w: 52; selected: root.selectedHotRow === rowIndex; alt: rowIndex % 2 === 1 } Cell { text: root.hotCell(rowText, 0); w: 340; selected: root.selectedHotRow === rowIndex; alt: rowIndex % 2 === 1 } Cell { text: root.hotCell(rowText, 1); w: 170; selected: root.selectedHotRow === rowIndex; alt: rowIndex % 2 === 1 } Cell { text: root.hotCell(rowText, 2); w: 130; selected: root.selectedHotRow === rowIndex; alt: rowIndex % 2 === 1 } Cell { text: root.hotCell(rowText, 3); w: 90; selected: root.selectedHotRow === rowIndex; alt: rowIndex % 2 === 1 } Cell { text: root.hotCell(rowText, 4); w: 110; selected: root.selectedHotRow === rowIndex; alt: rowIndex % 2 === 1 } Cell { text: root.hotCell(rowText, 5); w: 110; selected: root.selectedHotRow === rowIndex; alt: rowIndex % 2 === 1 } Cell { text: root.hotCell(rowText, 6); w: 110; selected: root.selectedHotRow === rowIndex; alt: rowIndex % 2 === 1 } Cell { text: root.hotCell(rowText, 7); w: 110; selected: root.selectedHotRow === rowIndex; alt: rowIndex % 2 === 1 } Cell { text: root.hotCell(rowText, 8); w: 340; selected: root.selectedHotRow === rowIndex; alt: rowIndex % 2 === 1 } } MouseArea { anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: { root.selectedHotRow = rowIndex; setDetail(appController.language === "en" ? "Hot result" : "爆文结果", rowText) } } }

    component SimpleTextPage: PageFrame {
        property string titleText: ""
        property string guideText: ""
        property string bodyText: ""
        property string buttonText: ""
        signal action()
        pageTitle: titleText
        pageGuide: guideText
        Card { cardHeight: 620; cardTitle: titleText; cardSubtitle: guideText
            ColumnLayout { anchors.fill: parent; anchors.margins: 16; spacing: 12
                AppButton { text: buttonText; ToolTip.visible: hovered; ToolTip.text: buttonText; onClicked: action() }
                Item { Layout.fillWidth: true; Layout.fillHeight: true; DetailBox { text: bodyText } }
            }
        }
    }

    component ListPage: PageFrame {
        property string titleText: ""
        property string guideText: ""
        property var rows: []
        pageTitle: titleText
        pageGuide: guideText
        Card { cardHeight: 620; cardTitle: titleText; cardSubtitle: guideText
            ScrollView { anchors.fill: parent; anchors.margins: 16; clip: true
                Column { width: parent.width; spacing: 8
                    Repeater { model: rows
                        RowCard { rowText: modelData; onPicked: setDetail(appController.language === "en" ? "Selected" : "已选择", modelData) }
                    }
                }
            }
        }
    }

    component PluginPage: PageFrame {
        pageTitle: root.t("plugins_title")
        pageGuide: root.guide("plugins")
        Card { cardHeight: 150; cardTitle: appController.language === "en" ? "Plugin actions" : "插件操作"; cardSubtitle: appController.language === "en" ? "Separated controls" : "操作区单独分组"
            RowLayout { anchors.fill: parent; anchors.margins: 16; spacing: 10
                AppButton { text: appController.language === "en" ? "Refresh" : "刷新"; ToolTip.visible: hovered; ToolTip.text: "刷新插件"; onClicked: root.pluginRows = appController.pluginRows() }
                AppButton { text: appController.language === "en" ? "Analysis" : "插件分析"; ToolTip.visible: hovered; ToolTip.text: "运行分析"; onClicked: pluginReport.text = appController.pluginAnalysis() }
                AppButton { text: appController.language === "en" ? "Scan metadata" : "扫描元数据"; ToolTip.visible: hovered; ToolTip.text: "扫描元数据"; onClicked: pluginReport.text = appController.pluginScanReport("plugins") }
            }
        }
        Card { cardHeight: 300; cardTitle: appController.language === "en" ? "Plugin list" : "插件列表"; cardSubtitle: appController.language === "en" ? "Click rows for details" : "点击行查看详情"
            ScrollView { anchors.fill: parent; anchors.margins: 16; clip: true
                Column { width: parent.width; spacing: 8
                    Repeater { model: root.pluginRows
                        RowCard { rowText: modelData; onPicked: { pluginReport.text = appController.pluginDetail(modelData) + "\n\n" + appController.pluginExportPreview(modelData); setDetail(appController.language === "en" ? "Plugin" : "插件", modelData) } }
                    }
                }
            }
        }
        Card { cardHeight: 360; cardTitle: appController.language === "en" ? "Plugin report" : "插件报告"; cardSubtitle: appController.language === "en" ? "Readonly result" : "只读结果"
            DetailBox { id: pluginReport; text: appController.pluginAnalysis() }
        }
    }

    component SettingsPage: PageFrame {
        pageTitle: root.t("settings_title")
        pageGuide: root.guide("settings")
        Card { cardHeight: 440; cardTitle: appController.language === "en" ? "Collection task" : "采集任务"; cardSubtitle: appController.language === "en" ? "All controls have labels" : "所有控件都有说明"
            ColumnLayout { anchors.fill: parent; anchors.margins: 16; spacing: 14
                GridLayout { Layout.fillWidth: true; columns: root.width > 1240 ? 2 : 1; columnSpacing: 18; rowSpacing: 14
                    FormText { id: taskName; label: appController.language === "en" ? "Task name" : "任务名称"; hint: appController.language === "en" ? "Saved with the task" : "随任务保存"; text: appController.language === "en" ? "AI hot article monitor" : "AI 爆文监控" }
                    FormText { id: taskKeyword; label: appController.language === "en" ? "Keyword" : "关键词"; hint: appController.language === "en" ? "Used by collection" : "采集使用"; text: "AI" }
                    FormSpin { id: taskInterval; label: appController.language === "en" ? "Interval seconds" : "运行间隔秒"; hint: appController.language === "en" ? "Minimum 5 seconds" : "最小 5 秒"; fromValue: 5; toValue: 86400; currentValue: 300 }
                    FormSpin { id: taskRuns; label: appController.language === "en" ? "Maximum runs" : "最大运行次数"; hint: appController.language === "en" ? "Stop after this count" : "达到次数后停止"; fromValue: 1; toValue: 9999; currentValue: 10 }
                }
                RowLayout { Layout.fillWidth: true; AppButton { text: appController.language === "en" ? "Save task" : "保存任务"; ToolTip.visible: hovered; ToolTip.text: "保存采集任务"; onClicked: { appController.createCollectionTask(taskName.text, taskKeyword.text, taskInterval.value, taskRuns.value); root.taskRows = appController.taskRows() } } AppButton { text: root.t("collect_now"); ToolTip.visible: hovered; ToolTip.text: "立即采集"; onClicked: appController.runCollection(taskKeyword.text) } }
            }
        }
        Card { cardHeight: 340; cardTitle: appController.language === "en" ? "Saved tasks" : "已保存任务"; cardSubtitle: appController.language === "en" ? "Select a task, then run it" : "选中一条任务后即可运行"
            ColumnLayout { anchors.fill: parent; anchors.margins: 16; spacing: 12
                RowLayout { Layout.fillWidth: true; spacing: 10
                    AppButton { text: appController.language === "en" ? "Refresh" : "刷新"; ToolTip.visible: hovered; ToolTip.text: appController.language === "en" ? "Reload saved tasks" : "重新加载已保存任务"; onClicked: root.taskRows = appController.taskRows() }
                    AppButton { text: root.t("run_task"); highlighted: true; enabled: root.selectedTaskRow !== ""; ToolTip.visible: hovered; ToolTip.text: appController.language === "en" ? "Run the selected saved task" : "运行选中的已保存任务"; onClicked: { var n = appController.runTaskRow(root.selectedTaskRow); root.detailText = appController.taskDetail(root.selectedTaskRow) + "\n\n" + (appController.language === "en" ? "Inserted rows: " : "新增条数：") + n + "\n" + appController.status; setDetail(root.t("run_task"), root.selectedTaskRow) } }
                }
                ScrollView { Layout.fillWidth: true; Layout.fillHeight: true; clip: true
                    Column { width: parent.width; spacing: 8
                        Repeater { model: root.taskRows
                            RowCard { rowText: modelData; color: root.selectedTaskRow === modelData ? rowSel : card2; onPicked: { root.selectedTaskRow = modelData; root.detailText = appController.taskDetail(modelData); setDetail(appController.language === "en" ? "Task" : "任务", modelData) } }
                        }
                    }
                }
            }
        }
        Card { cardHeight: 440; cardTitle: appController.language === "en" ? "Credentials and limits" : "密钥与限速"; cardSubtitle: appController.language === "en" ? "Local settings only" : "只保存本机设置"
            ColumnLayout { anchors.fill: parent; anchors.margins: 16; spacing: 14
                GridLayout { Layout.fillWidth: true; columns: root.width > 1240 ? 2 : 1; columnSpacing: 18; rowSpacing: 14
                    FormText { id: apiKey; label: appController.language === "en" ? "Secret key" : "密钥"; hint: appController.language === "en" ? "Stored locally only" : "只保存在本机"; password: true }
                    FormText { id: verify; label: appController.language === "en" ? "Verify code" : "验证码"; hint: appController.language === "en" ? "Optional" : "可选" }
                    FormSpin { id: defaultInterval; label: appController.language === "en" ? "Default interval" : "默认间隔"; hint: appController.language === "en" ? "Seconds" : "秒"; fromValue: 5; toValue: 86400; currentValue: 300 }
                    FormText { id: qps; label: appController.language === "en" ? "QPS limit" : "QPS 限制"; hint: appController.language === "en" ? "Example: 1.5" : "例如：1.5"; text: "1.5" }
                }
                AppButton { text: appController.language === "en" ? "Save settings" : "保存设置"; ToolTip.visible: hovered; ToolTip.text: "保存设置"; onClicked: appController.saveSettings(apiKey.text, verify.text, defaultInterval.value, taskRuns.value, Number(qps.text)) }
            }
        }
    }

    component ApiBrowserPage: PageFrame {
        pageTitle: root.t("api_browser_title")
        pageGuide: root.guide("api_browser")
        Card { cardHeight: 230; cardTitle: appController.language === "en" ? "Filter and run" : "筛选与运行"; cardSubtitle: appController.language === "en" ? "Select an endpoint first, then run with the keyword" : "先在下方列表选中接口，再用关键词运行"
            ColumnLayout { anchors.fill: parent; anchors.margins: 16; spacing: 12
                GridLayout { Layout.fillWidth: true; columns: root.width > 1240 ? 2 : 1; columnSpacing: 18; rowSpacing: 14
                    FormText { id: endpointFilter; label: appController.language === "en" ? "Category filter" : "分类筛选"; hint: appController.language === "en" ? "Blank lists all endpoints" : "留空列出全部接口" }
                    FormText { id: endpointKeyword; label: appController.language === "en" ? "Keyword" : "关键词"; hint: appController.language === "en" ? "Used by the collection call" : "采集调用使用"; text: "AI" }
                }
                RowLayout { Layout.fillWidth: true; spacing: 10
                    AppButton { text: appController.language === "en" ? "Filter" : "筛选"; ToolTip.visible: hovered; ToolTip.text: appController.language === "en" ? "Refresh endpoint list" : "刷新接口列表"; onClicked: root.endpointRows = appController.apiEndpointRows(endpointFilter.text) }
                    AppButton { text: root.t("run_endpoint"); highlighted: true; enabled: root.selectedEndpointRow !== ""; ToolTip.visible: hovered; ToolTip.text: appController.language === "en" ? "Run the selected endpoint" : "运行已选中的接口"; onClicked: { var n = appController.runEndpointRow(root.selectedEndpointRow, endpointKeyword.text); endpointReceipt.text = (appController.language === "en" ? "Endpoint: " : "接口：") + appController.endpointPathFromRow(root.selectedEndpointRow) + "\n" + (appController.language === "en" ? "Inserted rows: " : "新增条数：") + n + "\n" + appController.status; setDetail(root.t("run_endpoint"), root.selectedEndpointRow) } }
                }
            }
        }
        Card { cardHeight: 320; cardTitle: appController.language === "en" ? "Endpoints" : "接口列表"; cardSubtitle: appController.language === "en" ? "Click a row to select it" : "点击一行进行选中"
            ScrollView { anchors.fill: parent; anchors.margins: 16; clip: true
                Column { width: parent.width; spacing: 8
                    Repeater { model: root.endpointRows
                        RowCard { rowText: modelData; color: root.selectedEndpointRow === modelData ? rowSel : card2; onPicked: { root.selectedEndpointRow = modelData; endpointReceipt.text = (appController.language === "en" ? "Selected path: " : "已选路径：") + appController.endpointPathFromRow(modelData); setDetail(appController.language === "en" ? "Endpoint" : "接口", modelData) } }
                    }
                }
            }
        }
        Card { cardHeight: 200; cardTitle: appController.language === "en" ? "Selected endpoint" : "选中接口"; cardSubtitle: appController.language === "en" ? "Readonly receipt" : "只读回执"
            DetailBox { id: endpointReceipt; text: root.selectedEndpointRow === "" ? root.guide("api_browser") : (appController.language === "en" ? "Selected path: " : "已选路径：") + appController.endpointPathFromRow(root.selectedEndpointRow) }
        }
    }

    component RunHistoryPage: PageFrame {
        pageTitle: root.t("runs_title")
        pageGuide: root.guide("runs")
        Card { cardHeight: 120; cardTitle: appController.language === "en" ? "Actions" : "操作"; cardSubtitle: appController.language === "en" ? "Refresh the latest runs" : "刷新最近的运行记录"
            RowLayout { anchors.fill: parent; anchors.margins: 16; spacing: 10
                AppButton { text: root.t("refresh_runs"); highlighted: true; ToolTip.visible: hovered; ToolTip.text: appController.language === "en" ? "Reload run history" : "重新加载运行历史"; onClicked: root.runRows = appController.runRows() }
            }
        }
        Card { cardHeight: 360; cardTitle: appController.language === "en" ? "Run records" : "运行记录"; cardSubtitle: appController.language === "en" ? "Click a row for the receipt" : "点击一行查看回执"
            ScrollView { anchors.fill: parent; anchors.margins: 16; clip: true
                Column { width: parent.width; spacing: 8
                    Repeater { model: root.runRows
                        RowCard { rowText: modelData; onPicked: { runReceipt.text = appController.runDetail(modelData); setDetail(appController.language === "en" ? "Run" : "运行", modelData) } }
                    }
                }
            }
        }
        Card { cardHeight: 200; cardTitle: appController.language === "en" ? "Run receipt" : "运行回执"; cardSubtitle: appController.language === "en" ? "Readonly result" : "只读结果"
            DetailBox { id: runReceipt; text: root.guide("runs") }
        }
    }
}
