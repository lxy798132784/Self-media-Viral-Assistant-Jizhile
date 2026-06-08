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
    property int hotSortColumn: -1
    property bool hotSortAscending: true
    property bool hotResizeActive: false
    property bool hotResizeMoved: false
    property int hotResizeColumn: -1
    property real hotResizeStartX: 0
    property real hotResizeStartWidth: 0

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
    property var hotWidths: [52, 380, 170, 150, 88, 108, 92, 108, 108, 110, 92, 112, 112, 150, 240, 360]
    function hotTableWidth() { var n = 0; for (var i = 0; i < hotWidths.length; ++i) n += hotWidths[i]; return n }
    function resizeHotColumn(column, delta) { var next = hotWidths.slice(); next[column] = Math.max(column === 1 ? 220 : 72, next[column] + delta); hotWidths = next }
    function setHotColumnWidth(column, width) { var next = hotWidths.slice(); next[column] = Math.max(column === 1 ? 220 : 72, width); hotWidths = next }
    function beginHotResize(column, sceneX) {
        hotResizeActive = true
        hotResizeMoved = false
        hotResizeColumn = column
        hotResizeStartX = sceneX
        hotResizeStartWidth = hotWidths[column]
    }
    function updateHotResize(sceneX) {
        if (!hotResizeActive || hotResizeColumn < 0) return
        var delta = sceneX - hotResizeStartX
        if (Math.abs(delta) > 1) hotResizeMoved = true
        setHotColumnWidth(hotResizeColumn, hotResizeStartWidth + delta)
    }
    function endHotResize() {
        hotResizeActive = false
        hotResizeColumn = -1
    }
    function compactNumber(value) {
        var n = Number(String(value).replace(/[^0-9.\-]/g, ""))
        if (!isFinite(n)) return value
        if (n >= 100000000) return (n / 100000000).toFixed(1).replace(/\.0$/, "") + (appController.language === "en" ? "B" : "亿")
        if (n >= 10000) return (n / 10000).toFixed(1).replace(/\.0$/, "") + (appController.language === "en" ? "w" : "万")
        return Math.round(n).toString()
    }
    function hotDisplayCell(rowText, column) {
        var v = hotCell(rowText, column)
        if (column >= 4 && column <= 7) return compactNumber(v)
        return v
    }
    function hotSortValue(rowText, displayColumn) {
        if (displayColumn <= 0) return 0
        var rawColumn = displayColumn - 1
        var v = hotCell(rowText, rawColumn)
        if (displayColumn >= 4 && displayColumn <= 8) {
            var n = Number(String(v).replace(/[^0-9.\-]/g, ""))
            return isFinite(n) ? n : -1
        }
        if (displayColumn === 3) {
            var t = Date.parse(String(v).replace(/-/g, "/"))
            return isFinite(t) ? t : 0
        }
        return String(v).toLowerCase()
    }
    function sortHotRows(column) {
        if (column <= 0) return
        if (hotSortColumn === column) hotSortAscending = !hotSortAscending
        else { hotSortColumn = column; hotSortAscending = true }
        var sorted = hotRows.slice()
        sorted.sort(function(a, b) {
            var av = root.hotSortValue(a, column)
            var bv = root.hotSortValue(b, column)
            var cmp = 0
            if (typeof av === "number" && typeof bv === "number") cmp = av === bv ? 0 : (av < bv ? -1 : 1)
            else cmp = String(av).localeCompare(String(bv))
            return hotSortAscending ? cmp : -cmp
        })
        hotRows = sorted
        selectedHotRow = -1
    }
    function hotRowDetail(rowText) {
        var title = hotCell(rowText, 0)
        var account = hotCell(rowText, 1)
        var published = hotCell(rowText, 2)
        var hot = hotCell(rowText, 3)
        var reads = hotCell(rowText, 4)
        var likes = hotCell(rowText, 5)
        var avg = hotCell(rowText, 6)
        var fans = hotCell(rowText, 7)
        var url = hotCell(rowText, 14)
        var category = hotCell(rowText, 8)
        var position = hotCell(rowText, 9)
        var original = hotCell(rowText, 10)
        var publishType = hotCell(rowText, 11)
        var wxid = hotCell(rowText, 12)
        var cover = hotCell(rowText, 13)
        if (appController.language === "en") {
            return "Title: " + title + "\nAccount: " + account + "\nPublished: " + published + "\nHot score: " + hot + "\nReads: " + compactNumber(reads) + " (" + reads + ")\nLikes: " + compactNumber(likes) + " (" + likes + ")\nAvg reads: " + compactNumber(avg) + " (" + avg + ")\nFans: " + compactNumber(fans) + " (" + fans + ")\nCategory: " + category + "\nPosition: " + position + "\nOriginal: " + original + "\nPublish type: " + publishType + "\nWeChat ID: " + wxid + "\nCover: " + cover + "\nLink: " + url
        }
        return "标题：" + title + "\n账号：" + account + "\n发布时间：" + published + "\n爆值：" + hot + "\n阅读：" + compactNumber(reads) + "（" + reads + "）\n点赞：" + compactNumber(likes) + "（" + likes + "）\n均读：" + compactNumber(avg) + "（" + avg + "）\n粉丝：" + compactNumber(fans) + "（" + fans + "）\n分类：" + category + "\n发文位置：" + position + "\n是否原创：" + original + "\n爆文类型：" + publishType + "\n微信ID：" + wxid + "\n封面：" + cover + "\n链接：" + url
    }
    function hotExportPath(format) {
        var ext = format === "xml" ? "xml" : (format === "xls" ? "xls" : "md")
        return (appController.language === "en" ? "hot-article-results" : "爆文解析结果") + "." + ext
    }
    function guide(key) {
        appController.language
        var zh = {
            dashboard: "查看内容数量、阅读点赞汇总和最近操作状态，适合快速确认当前数据情况。",
            library: "搜索本地内容库，查看文章详情并导出结果。列表区域可独立滚动。",
            hot: "设置关键词、类型、分类、页码和日期范围后采集真实爆文数据；也可一键执行情感类最近30天、阅读3万-5万、目标20篇的定向采集。",
            results: "按标题、账号、时间和完整 API 字段查看解析结果：爆值、阅读、点赞、均读、粉丝、分类、发文位置、是否原创、爆文类型、微信ID、封面和链接。表格支持横向滚动、纵向滚动、选中行查看详情，并可拖动表头分隔线调整列宽。",
            report: "查看可复制、可导出的内容拆解摘要。",
            topics: "查看选题建议，点击卡片可预览后续处理内容。",
            plugins: "查看当前可用能力与分析结果。",
            api_browser: "按分类筛选内容数据接口，选中接口后用关键词运行采集。先选中再运行，避免误触发请求。",
            runs: "查看每次采集的时间、状态、新增条数和返回信息。点击任意记录可查看该次回执。",
            settings: "管理采集任务、密钥和运行限制。"
        }
        var en = {
            dashboard: "View content counts, read/like summaries, and the latest operation status.",
            library: "Search the local content library, view details, and export results. The list scrolls independently.",
            hot: "Collect real hot-article data with keyword, type, category, page, and date filters.",
            results: "Review parsed results with all API fields: hot score, reads, likes, avg reads, fans, category, position, original flag, publish type, WeChat ID, cover, and link. The table supports horizontal/vertical scrolling, row details, and draggable column dividers.",
            report: "View copyable and exportable content breakdown summaries.",
            topics: "Review topic ideas and click cards to preview next-step content.",
            plugins: "View available capabilities and analysis output.",
            api_browser: "Filter content-data endpoints by category, select one, then run it with a keyword. Select first to avoid accidental requests.",
            runs: "Review each collection time, status, inserted count, and response message. Click any record to see its receipt.",
            settings: "Manage collection tasks, credentials, and runtime limits."
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
                Card { cardHeight: 270; cardTitle: appController.language === "en" ? "Quick actions" : "快捷操作"; cardSubtitle: appController.language === "en" ? "Start from keyword collection or review the latest status." : "从关键词采集开始，或查看最近状态。"
                    ColumnLayout { anchors.fill: parent; anchors.margins: 16; spacing: 12
                        FormText { id: dashKeyword; label: appController.language === "en" ? "Keyword" : "关键词"; hint: appController.language === "en" ? "Used by quick collection" : "用于快速采集"; text: "AI" }
                        RowLayout { Layout.fillWidth: true; spacing: 10
                            AppButton { text: root.t("load_samples"); ToolTip.visible: hovered; ToolTip.text: "加载本地示例"; onClicked: { appController.loadMockArticles(); setDetail(text, appController.status) } }
                            AppButton { text: root.t("collect_now"); highlighted: true; ToolTip.visible: hovered; ToolTip.text: "按关键词立即采集"; onClicked: { appController.runCollection(dashKeyword.text); setDetail(text, appController.status) } }
                            AppButton { text: root.t("self_check"); ToolTip.visible: hovered; ToolTip.text: appController.language === "en" ? "View current application status" : "查看当前应用状态"; onClicked: setDetail(text, appController.status) }
                        }
                    }
                }
                Card { cardHeight: 240; cardTitle: appController.language === "en" ? "Status details" : "状态详情"; cardSubtitle: appController.language === "en" ? "Latest interaction feedback" : "最近一次交互反馈"
                    DetailBox { text: root.detailText }
                }
            }

            PageFrame { pageTitle: root.t("library_title"); pageGuide: root.guide("library")
                Card { cardHeight: 250; cardTitle: appController.language === "en" ? "Search and actions" : "搜索与操作"; cardSubtitle: appController.language === "en" ? "Search by title or account, then export results." : "按标题或账号搜索，并导出结果。"
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
                Card { cardHeight: 760; cardTitle: appController.language === "en" ? "Request parameters" : "采集参数"; cardSubtitle: appController.language === "en" ? "Set every control parameter before requesting data." : "关键词和所有控制参数都可修改，再发起请求。"
                    ColumnLayout { anchors.fill: parent; anchors.margins: 16; spacing: 14
                        GridLayout { Layout.fillWidth: true; columns: root.width > 1240 ? 2 : 1; columnSpacing: 18; rowSpacing: 14
                            FormText { id: hotKey; label: appController.language === "en" ? "Secret key" : "密钥"; hint: appController.language === "en" ? "Secret key; blank uses local sample" : "密钥；留空使用本地示例"; password: true }
                            FormText { id: hotKeyword; label: appController.language === "en" ? "Keywords" : "关键词"; hint: appController.language === "en" ? "Multiple keywords: comma, semicolon, pipe, or newline separated" : "可输入多个关键词，用逗号、分号、竖线或换行分隔"; text: "情感,婚姻,恋爱,亲密关系" }
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
                            FormSpin { id: hotMinRead; label: appController.language === "en" ? "Min reads" : "最低阅读数"; hint: appController.language === "en" ? "Local read_num lower bound" : "本地 read_num 下限"; fromValue: 0; toValue: 100000000; currentValue: 30000 }
                            FormSpin { id: hotMaxRead; label: appController.language === "en" ? "Max reads" : "最高阅读数"; hint: appController.language === "en" ? "Local read_num upper bound" : "本地 read_num 上限"; fromValue: 0; toValue: 100000000; currentValue: 50000 }
                            FormSpin { id: hotTargetCount; label: appController.language === "en" ? "Target count" : "目标篇数"; hint: appController.language === "en" ? "Stop when enough accepted articles are collected" : "达到合格篇数后停止"; fromValue: 1; toValue: 1000; currentValue: 20 }
                            FormSpin { id: hotMaxPages; label: appController.language === "en" ? "Max pages / keyword" : "每关键词最大页数"; hint: appController.language === "en" ? "Cost control per keyword" : "每个关键词最多请求几页，用于控费"; fromValue: 1; toValue: 100; currentValue: 3 }
                            FormSpin { id: hotMaxScan; label: appController.language === "en" ? "Max scan requests" : "最大扫描请求数"; hint: appController.language === "en" ? "Global stop limit across all keywords/pages" : "跨全部关键词/页码的总请求上限"; fromValue: 1; toValue: 10000; currentValue: 200 }
                        }
                        RowLayout { Layout.fillWidth: true; spacing: 10
                            AppButton { text: root.t("preview_payload"); ToolTip.visible: hovered; ToolTip.text: "预览单页原始接口参数"; onClicked: payloadPreview.text = appController.hotTypicalPayloadPreview(hotKey.text, hotKeyword.text, hotPubType.currentValue, hotCategory.currentValue, hotPage.value, hotStart.text, hotEnd.text) }
                            AppButton { text: appController.language === "en" ? "Preview targeted plan" : "预览定向计划"; ToolTip.visible: hovered; ToolTip.text: appController.language === "en" ? "Preview all user-controlled filters and limits" : "预览关键词、分类、类型、时间、阅读区间、目标和上限"; onClicked: payloadPreview.text = appController.targetedHotTypicalCollectionPreview(hotKeyword.text, hotPubType.currentValue, hotCategory.currentValue, hotStart.text, hotEnd.text, hotMinRead.value, hotMaxRead.value, hotTargetCount.value, hotMaxPages.value, hotMaxScan.value) }
                            AppButton { text: appController.language === "en" ? "Collect one page" : "采集单页"; highlighted: true; ToolTip.visible: hovered; ToolTip.text: "按上方基础参数采集单页"; onClicked: { appController.runHotTypicalCollection(hotKey.text, hotKeyword.text, hotPubType.currentValue, hotCategory.currentValue, hotPage.value, hotStart.text, hotEnd.text); refreshHotRows(); stack.currentIndex = 3 } }
                            AppButton { text: appController.language === "en" ? "Run targeted collection" : "运行定向采集"; highlighted: true; ToolTip.visible: hovered; ToolTip.text: appController.language === "en" ? "Loop over user keywords/pages and locally filter read_num" : "轮询用户关键词和页码，并按阅读数本地过滤"; onClicked: { payloadPreview.text = appController.targetedHotTypicalCollectionPreview(hotKeyword.text, hotPubType.currentValue, hotCategory.currentValue, hotStart.text, hotEnd.text, hotMinRead.value, hotMaxRead.value, hotTargetCount.value, hotMaxPages.value, hotMaxScan.value); appController.runTargetedHotTypicalCollection(hotKey.text, hotKeyword.text, hotPubType.currentValue, hotCategory.currentValue, hotStart.text, hotEnd.text, hotMinRead.value, hotMaxRead.value, hotTargetCount.value, hotMaxPages.value, hotMaxScan.value); refreshHotRows(); stack.currentIndex = 3 } }
                            AppButton { text: appController.language === "en" ? "Open result table" : "打开结果表"; ToolTip.visible: hovered; ToolTip.text: "打开结果表页面"; onClicked: { refreshHotRows(); stack.currentIndex = 3 } }
                        }
                    }
                }
                Card { cardHeight: 280; cardTitle: appController.language === "en" ? "Request preview" : "请求预览"; cardSubtitle: appController.language === "en" ? "Review the request that will be sent." : "查看即将发送的请求内容。"
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
            TextField { id: input; Layout.fillWidth: true; Layout.preferredHeight: 40; placeholderText: placeholder || hint; echoMode: password && !show.checked ? TextInput.Password : TextInput.Normal; color: textMain; selectedTextColor: "#020617"; selectionColor: accent; ToolTip.visible: hovered; ToolTip.text: label + " · " + hint; background: Rectangle { color: fieldBg; radius: 10; border.color: input.activeFocus ? accent : lineStrong } }
            AppButton { id: show; visible: password; Layout.preferredHeight: 40; checkable: true; text: checked ? (appController.language === "en" ? "Hide" : "隐藏") : (appController.language === "en" ? "Show" : "显示"); ToolTip.visible: hovered; ToolTip.text: "显示或隐藏" }
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
        SpinBox {
            id: spin
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            from: fromValue
            to: toValue
            value: currentValue
            editable: true
            font.pixelSize: 14
            hoverEnabled: true
            ToolTip.visible: hovered
            ToolTip.text: label + " · " + hint
            contentItem: TextInput {
                z: 2
                text: spin.textFromValue(spin.value, spin.locale)
                font: spin.font
                color: textMain
                selectedTextColor: "#020617"
                selectionColor: accent
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                readOnly: !spin.editable
                validator: spin.validator
                inputMethodHints: Qt.ImhFormattedNumbersOnly
            }
            up.indicator: Rectangle {
                x: spin.width - width
                height: spin.height / 2
                width: 34
                color: spin.up.pressed ? "#24ffffff" : (spin.hovered ? "#14ffffff" : "transparent")
                border.color: line
                Text { anchors.centerIn: parent; text: "+"; color: textSub; font.bold: true }
            }
            down.indicator: Rectangle {
                x: spin.width - width
                y: spin.height / 2
                height: spin.height / 2
                width: 34
                color: spin.down.pressed ? "#24ffffff" : (spin.hovered ? "#14ffffff" : "transparent")
                border.color: line
                Text { anchors.centerIn: parent; text: "−"; color: textSub; font.bold: true }
            }
            background: Rectangle { color: fieldBg; radius: 10; border.color: spin.activeFocus || spin.hovered ? accent : lineStrong }
        }
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
            TextField { id: dateText; Layout.fillWidth: true; Layout.preferredHeight: 40; readOnly: true; color: textMain; ToolTip.visible: hovered; ToolTip.text: label + " · YYYY-MM-DD"; background: Rectangle { color: fieldBg; radius: 10; border.color: lineStrong } }
            AppButton { text: appController.language === "en" ? "Pick" : "选择"; Layout.preferredHeight: 40; ToolTip.visible: hovered; ToolTip.text: "打开日期选择器"; onClicked: { var p = dateText.text.split("-"); yearBox.value = Number(p[0]); monthBox.value = Number(p[1]); dayBox.value = Number(p[2]); picker.open() } }
        }
        Label { text: hint; color: textMuted; font.pixelSize: 12; wrapMode: Text.WordWrap; Layout.fillWidth: true }
        Dialog { id: picker; modal: true; title: label; standardButtons: Dialog.Ok | Dialog.Cancel; onAccepted: dateText.text = yearBox.value + "-" + (monthBox.value < 10 ? "0" : "") + monthBox.value + "-" + (dayBox.value < 10 ? "0" : "") + dayBox.value; background: Rectangle { color: panel; radius: 18; border.color: lineStrong } contentItem: ColumnLayout { spacing: 12; Label { text: appController.language === "en" ? "Choose date" : "选择日期"; color: textMain; font.bold: true } RowLayout { SpinBox { id: yearBox; from: 2020; to: 2035; value: 2026; editable: true; ToolTip.visible: hovered; ToolTip.text: "年份" } SpinBox { id: monthBox; from: 1; to: 12; value: 5; editable: true; ToolTip.visible: hovered; ToolTip.text: "月份" } SpinBox { id: dayBox; from: 1; to: 31; value: 15; editable: true; ToolTip.visible: hovered; ToolTip.text: "日期" } } } }
    }

    component DetailBox: Rectangle {
        id: detailBox
        property string text: ""
        anchors.fill: parent
        anchors.margins: 16
        color: fieldBg
        radius: 12
        border.color: line
        clip: true
        Flickable {
            id: detailFlick
            anchors.fill: parent
            anchors.margins: 12
            clip: true
            contentWidth: width
            contentHeight: detailText.height
            boundsBehavior: Flickable.StopAtBounds
            ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
            Text {
                id: detailText
                width: detailFlick.width
                text: detailBox.text
                color: textMain
                wrapMode: Text.WordWrap
                textFormat: Text.PlainText
                font.pixelSize: 14
            }
        }
        MouseArea { anchors.fill: parent; acceptedButtons: Qt.NoButton; cursorShape: Qt.IBeamCursor }
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
                AppButton { text: appController.language === "en" ? "Copy details" : "复制详情"; enabled: selectedHotRow >= 0 && selectedHotRow < hotRows.length; highlighted: selectedHotRow >= 0 && selectedHotRow < hotRows.length; ToolTip.visible: hovered; ToolTip.text: appController.language === "en" ? "Copy selected row details" : "复制选中行详情"; onClicked: appController.copyTextToClipboard(root.hotRowDetail(hotRows[selectedHotRow])) }
                AppButton { text: appController.language === "en" ? "Refresh" : "刷新"; ToolTip.visible: hovered; ToolTip.text: "刷新解析结果"; onClicked: refreshHotRows() }
                AppButton { text: appController.language === "en" ? "Export..." : "导出..."; ToolTip.visible: hovered; ToolTip.text: "选择格式和路径"; onClicked: exportDialog.openForHotResults() }
            }
            DataGrid { Layout.fillWidth: true; Layout.fillHeight: true }
            DetailPanel { Layout.fillWidth: true; Layout.preferredHeight: 230; text: selectedHotRow >= 0 && selectedHotRow < hotRows.length ? root.hotRowDetail(hotRows[selectedHotRow]) : (appController.language === "en" ? "Select a row to view full API fields: original flag, type, position, category, WeChat ID, cover, metrics, and link." : "选择一行后查看完整 API 字段：是否原创、爆文类型、发文位置、分类、微信ID、封面、指标和链接。") }
        }
    }

    component DataGrid: Rectangle {
        color: card
        radius: 16
        border.color: line
        clip: true
        ScrollView {
            anchors.fill: parent
            clip: true
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOn
            ScrollBar.vertical.policy: ScrollBar.AsNeeded
            Column {
                width: root.hotTableWidth()
                Row { width: root.hotTableWidth(); height: 44
                    HeaderCell { text: "#"; column: 0 }
                    HeaderCell { text: appController.language === "en" ? "Title" : "标题"; column: 1 }
                    HeaderCell { text: appController.language === "en" ? "Account" : "账号"; column: 2 }
                    HeaderCell { text: appController.language === "en" ? "Published" : "发布时间"; column: 3 }
                    HeaderCell { text: appController.language === "en" ? "Hot" : "爆值"; column: 4 }
                    HeaderCell { text: appController.language === "en" ? "Reads" : "阅读"; column: 5 }
                    HeaderCell { text: appController.language === "en" ? "Likes" : "点赞"; column: 6 }
                    HeaderCell { text: appController.language === "en" ? "Avg" : "均读"; column: 7 }
                    HeaderCell { text: appController.language === "en" ? "Fans" : "粉丝"; column: 8 }
                    HeaderCell { text: appController.language === "en" ? "Category" : "分类"; column: 9 }
                    HeaderCell { text: appController.language === "en" ? "Position" : "位置"; column: 10 }
                    HeaderCell { text: appController.language === "en" ? "Original" : "是否原创"; column: 11 }
                    HeaderCell { text: appController.language === "en" ? "Type" : "爆文类型"; column: 12 }
                    HeaderCell { text: appController.language === "en" ? "WeChat ID" : "微信ID"; column: 13 }
                    HeaderCell { text: appController.language === "en" ? "Cover" : "封面"; column: 14 }
                    HeaderCell { text: appController.language === "en" ? "Link" : "链接"; column: 15 }
                }
                Repeater { model: root.hotRows
                    DataRow { rowIndex: index; rowText: modelData }
                }
            }
        }
        MouseArea {
            anchors.fill: parent
            z: 1000
            visible: root.hotResizeActive
            enabled: root.hotResizeActive
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton
            preventStealing: true
            cursorShape: Qt.SizeHorCursor
            onPositionChanged: {
                mouse.accepted = true
                root.updateHotResize(mapToGlobal(mouse.x, mouse.y).x)
            }
            onReleased: {
                mouse.accepted = true
                root.endHotResize()
            }
            onCanceled: root.endHotResize()
        }
    }

    component HeaderCell: Rectangle {
        property string text: ""
        property int column: 0
        property bool sortable: column > 0
        width: root.hotWidths[column]
        height: 44
        color: hotSortColumn === column ? "#1b1d24" : card2
        border.color: line
        Label {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 8
            anchors.right: parent.right
            anchors.rightMargin: column < root.hotWidths.length - 1 ? 18 : 8
            text: parent.text + (hotSortColumn === column ? (hotSortAscending ? " ↑" : " ↓") : (sortable ? " ⇅" : ""))
            color: textMain
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
        }
        MouseArea {
            anchors.fill: parent
            anchors.rightMargin: column < root.hotWidths.length - 1 ? 14 : 0
            hoverEnabled: true
            cursorShape: sortable ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: if (sortable) root.sortHotRows(column)

        }
        Rectangle {
            visible: column < root.hotWidths.length - 1
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: 6
            color: (root.hotResizeActive && root.hotResizeColumn === column) || dragger.containsMouse ? accent : "transparent"
        }
        MouseArea {
            id: dragger
            visible: column < root.hotWidths.length - 1
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: 18
            hoverEnabled: true
            preventStealing: true
            acceptedButtons: Qt.LeftButton
            cursorShape: Qt.SizeHorCursor
            onPressed: {
                mouse.accepted = true
                root.beginHotResize(column, mapToGlobal(mouse.x, mouse.y).x)
            }
            onPositionChanged: if (pressed || root.hotResizeActive) {
                mouse.accepted = true
                root.updateHotResize(mapToGlobal(mouse.x, mouse.y).x)
            }
            onReleased: {
                mouse.accepted = true
                root.endHotResize()
            }
            onCanceled: root.endHotResize()

        }
    }
    component Cell: Rectangle {
        property string text: ""
        property int column: 0
        property bool selected: false
        property bool alt: false
        property int align: Text.AlignLeft
        width: root.hotWidths[column]
        height: 42
        color: selected ? rowSel : (alt ? rowAlt : fieldBg)
        border.color: line
        Label { anchors.verticalCenter: parent.verticalCenter; anchors.left: parent.left; anchors.leftMargin: 8; anchors.right: parent.right; anchors.rightMargin: 8; text: parent.text; color: textMain; horizontalAlignment: parent.align; elide: Text.ElideRight }
    }
    component DataRow: Rectangle {
        property int rowIndex: 0
        property string rowText: ""
        width: root.hotTableWidth()
        height: 42
        color: "transparent"
        Row { anchors.fill: parent
            Cell { text: String(rowIndex + 1); column: 0; selected: root.selectedHotRow === rowIndex; alt: rowIndex % 2 === 1; align: Text.AlignHCenter }
            Cell { text: root.hotDisplayCell(rowText, 0); column: 1; selected: root.selectedHotRow === rowIndex; alt: rowIndex % 2 === 1 }
            Cell { text: root.hotDisplayCell(rowText, 1); column: 2; selected: root.selectedHotRow === rowIndex; alt: rowIndex % 2 === 1 }
            Cell { text: root.hotDisplayCell(rowText, 2); column: 3; selected: root.selectedHotRow === rowIndex; alt: rowIndex % 2 === 1; align: Text.AlignHCenter }
            Cell { text: root.hotDisplayCell(rowText, 3); column: 4; selected: root.selectedHotRow === rowIndex; alt: rowIndex % 2 === 1; align: Text.AlignRight }
            Cell { text: root.hotDisplayCell(rowText, 4); column: 5; selected: root.selectedHotRow === rowIndex; alt: rowIndex % 2 === 1; align: Text.AlignRight }
            Cell { text: root.hotDisplayCell(rowText, 5); column: 6; selected: root.selectedHotRow === rowIndex; alt: rowIndex % 2 === 1; align: Text.AlignRight }
            Cell { text: root.hotDisplayCell(rowText, 6); column: 7; selected: root.selectedHotRow === rowIndex; alt: rowIndex % 2 === 1; align: Text.AlignRight }
            Cell { text: root.hotDisplayCell(rowText, 7); column: 8; selected: root.selectedHotRow === rowIndex; alt: rowIndex % 2 === 1; align: Text.AlignRight }
            Cell { text: root.hotDisplayCell(rowText, 8); column: 9; selected: root.selectedHotRow === rowIndex; alt: rowIndex % 2 === 1; align: Text.AlignHCenter }
            Cell { text: root.hotDisplayCell(rowText, 9); column: 10; selected: root.selectedHotRow === rowIndex; alt: rowIndex % 2 === 1; align: Text.AlignHCenter }
            Cell { text: root.hotDisplayCell(rowText, 10); column: 11; selected: root.selectedHotRow === rowIndex; alt: rowIndex % 2 === 1; align: Text.AlignHCenter }
            Cell { text: root.hotDisplayCell(rowText, 11); column: 12; selected: root.selectedHotRow === rowIndex; alt: rowIndex % 2 === 1; align: Text.AlignHCenter }
            Cell { text: root.hotDisplayCell(rowText, 12); column: 13; selected: root.selectedHotRow === rowIndex; alt: rowIndex % 2 === 1 }
            Cell { text: root.hotDisplayCell(rowText, 13); column: 14; selected: root.selectedHotRow === rowIndex; alt: rowIndex % 2 === 1 }
            Cell { text: root.hotDisplayCell(rowText, 14); column: 15; selected: root.selectedHotRow === rowIndex; alt: rowIndex % 2 === 1 }
        }
        MouseArea { anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: { root.selectedHotRow = rowIndex; setDetail(appController.language === "en" ? "Hot result" : "爆文结果", root.hotRowDetail(rowText)) } }
    }

    component DetailPanel: Rectangle {
        id: detailPanel
        property string text: ""
        color: fieldBg
        radius: 12
        border.color: line
        clip: true
        Flickable {
            id: rowDetailFlick
            anchors.fill: parent
            anchors.margins: 10
            clip: true
            contentWidth: width
            contentHeight: rowDetailText.height
            boundsBehavior: Flickable.StopAtBounds
            ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
            Text {
                id: rowDetailText
                width: rowDetailFlick.width
                text: detailPanel.text
                color: textMain
                wrapMode: Text.WordWrap
                textFormat: Text.PlainText
                font.pixelSize: 14
            }
        }
    }

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
        Card { cardHeight: 150; cardTitle: appController.language === "en" ? "Plugin actions" : "插件操作"; cardSubtitle: appController.language === "en" ? "Refresh and review available capabilities." : "刷新并查看当前可用能力。"
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
        Card { cardHeight: 360; cardTitle: appController.language === "en" ? "Plugin report" : "插件报告"; cardSubtitle: appController.language === "en" ? "Capability analysis output" : "能力分析结果"
            DetailBox { id: pluginReport; text: appController.pluginAnalysis() }
        }
    }

    component SettingsPage: PageFrame {
        pageTitle: root.t("settings_title")
        pageGuide: root.guide("settings")
        Card { cardHeight: 440; cardTitle: appController.language === "en" ? "Collection task" : "采集任务"; cardSubtitle: appController.language === "en" ? "Create a reusable collection task." : "创建可重复运行的采集任务。"
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
        Card { cardHeight: 200; cardTitle: appController.language === "en" ? "Selected endpoint" : "选中接口"; cardSubtitle: appController.language === "en" ? "Selection and run receipt" : "选择结果与运行回执"
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
        Card { cardHeight: 200; cardTitle: appController.language === "en" ? "Run receipt" : "运行回执"; cardSubtitle: appController.language === "en" ? "Selected run details" : "选中记录详情"
            DetailBox { id: runReceipt; text: root.guide("runs") }
        }
    }
}
