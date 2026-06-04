import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ApplicationWindow {
    id: root
    width: 1220
    height: 800
    visible: true
    title: appController.language === "en" ? "Media Hit Assistant" : "自媒体爆款助手"
    color: "#0f172a"

    property color panel: "#111827"
    property color panel2: "#1f2937"
    property color accent: "#38bdf8"
    property color textMain: "#e5e7eb"
    property color textSub: "#94a3b8"
    property string detailText: ""
    function t(key) { appController.language; return appController.trText(key) }
    function help(key) {
        appController.language
        var zh = {
            help_title: "内置使用说明",
            help_dashboard: "仪表盘：查看内容数量、总阅读、总点赞。可加载示例、做全流程自检、按关键词采集、浏览并运行数据端点。点击统计卡片或说明区会把当前含义写入底部状态，证明展示项可交互。",
            help_library: "内容库：搜索标题或账号，刷新列表，点击任意内容查看结构化详情；可导出 Markdown 或 XML，导出路径会显示在详情区。",
            help_hot: "爆文：这里是重点工作区。key、keyword、pub_type、category、page、start_time、end_time 每个请求参数都有独立控件，可先预览请求参数，再执行采集；未配置 key 时走本地示例兜底。",
            help_report: "拆解报告：根据本地内容生成标题、账号、爆款评分和观察结论；可导出综合报告。点击报告区域会记录当前选择。",
            help_topics: "选题推荐：从已采集内容中生成选题方向。点击任意选题会生成预留 AI 扩展输入预览，便于后续接入改写、评分和标题变体。",
            help_plugins: "插件：展示内置数据源、导出器和分析器；可刷新、查看插件详情、扫描插件元数据，并把插件输出预览到右侧文本区。",
            help_settings: "设置：保存采集任务、关键词、运行间隔、最大运行次数、密钥和限速。任务列表和运行历史都可点击查看详情或再次执行。",
            help_troubleshooting: "故障排查：Windows 双击无反应时，请优先运行包内 run-with-log.bat；它会把错误写入 media-hit-assistant.log，避免窗口一闪而过。"
        }
        var en = {
            help_title: "Built-in user guide",
            help_dashboard: "Dashboard: review article count, reads, and likes. Load samples, run the full self-test, collect by keyword, browse data paths, and run the first data path. Click stat cards or the guide panel to write a status receipt, proving displayed surfaces are interactive.",
            help_library: "Content Library: search by title or account, refresh the list, click any row for structured details, and export Markdown or XML. Export paths are shown in the detail panel.",
            help_hot: "Hot Articles: this is the main workspace. key, keyword, pub_type, category, page, start_time, and end_time each have editable controls. Preview the request parameters before collection; when no key is configured, the app uses local sample fallback.",
            help_report: "Analysis Report: generate title, account, hit score, and observations from local content. Export a combined report. Click the report area to record the current selection.",
            help_topics: "Topic Recommendations: generate topic directions from collected content. Click any topic to preview reserved AI-extension inputs for future rewrite, scoring, and headline variants.",
            help_plugins: "Plugins: inspect built-in providers, exporters, and analyzers. Refresh, inspect details, scan metadata, and preview plugin output in the text panel.",
            help_settings: "Settings: save collection tasks, keywords, intervals, maximum runs, secrets, and rate limits. Task rows and run-history rows are clickable for details or reruns.",
            help_troubleshooting: "Troubleshooting: if Windows double-click closes instantly, run run-with-log.bat from the package first; it writes media-hit-assistant.log so errors are not lost."
        }
        return appController.language === "en" ? en[key] : zh[key]
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            Layout.preferredWidth: 250
            Layout.fillHeight: true
            color: "#020617"
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 18
                spacing: 12
                Label { text: root.t("app_title"); color: textMain; font.pixelSize: 26; font.bold: true }
                Label { text: root.t("subtitle"); color: textSub; wrapMode: Text.WordWrap; Layout.fillWidth: true }
                RowLayout {
                    Layout.fillWidth: true
                    Button { text: "中文"; highlighted: appController.language === "zh"; ToolTip.visible: hovered; ToolTip.text: "切换界面语言为中文 / Switch interface language to Chinese"; onClicked: appController.setLanguage("zh") }
                    Button { text: "English"; highlighted: appController.language === "en"; ToolTip.visible: hovered; ToolTip.text: "Switch interface language to English / 切换界面语言为英文"; onClicked: appController.setLanguage("en") }
                }
                Repeater {
                    model: [
                        { key: "dashboard_title", index: 0 },
                        { key: "library_title", index: 1 },
                        { key: "hot_api_title", index: 2 },
                        { key: "report_title", index: 3 },
                        { key: "topics_title", index: 4 },
                        { key: "plugins_title", index: 5 },
                        { key: "settings_title", index: 6 }
                    ]
                    delegate: Button {
                        Layout.fillWidth: true
                        text: root.t(modelData.key)
                        highlighted: stack.currentIndex === modelData.index
                        ToolTip.visible: hovered
                        ToolTip.text: appController.language === "en" ? "Open this module and show its controls" : "打开此模块并显示对应控件"
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
            currentIndex: 0

            Rectangle {
                color: "#0f172a"
                ColumnLayout { anchors.fill: parent; anchors.margins: 24; spacing: 18
                    Label { text: root.t("dashboard_title"); color: textMain; font.pixelSize: 30; font.bold: true }
                    Rectangle { Layout.fillWidth: true; Layout.fillHeight: true; color: panel; radius: 18; border.color: "#334155"
                        ColumnLayout { anchors.fill: parent; anchors.margins: 18; spacing: 16
                            RowLayout { Layout.fillWidth: true
                                StatCard { title: appController.language === "en" ? "Articles" : "内容数量"; value: appController.articleCount.toString(); desc: "SQLite" }
                                StatCard { title: appController.language === "en" ? "Reads" : "总阅读"; value: appController.totalReads.toString(); desc: appController.language === "en" ? "Local summary" : "本地汇总" }
                                StatCard { title: appController.language === "en" ? "Likes" : "总点赞"; value: appController.totalLikes.toString(); desc: appController.status }
                            }
                            RowLayout { Layout.fillWidth: true
                                Button { text: root.t("load_samples"); ToolTip.visible: hovered; ToolTip.text: "Load built-in sample articles / 加载内置示例内容"; onClicked: appController.loadMockArticles() }
                                Button { text: root.t("self_check"); ToolTip.visible: hovered; ToolTip.text: appController.language === "en" ? "Run database, collection fallback, export, and report checks" : "运行数据库、采集兜底、导出和报告检查"; onClicked: { appController.runFullSelfCheck("/tmp"); runHistory.model = appController.runRows(); } }
                            }
                            RowLayout {
                                Layout.fillWidth: true
                                TextField { id: dashKeyword; Layout.fillWidth: true; placeholderText: appController.language === "en" ? "Keyword, for example AI, parenting, career" : "采集关键词，例如 AI、育儿、职场"; text: "AI"; ToolTip.visible: hovered; ToolTip.text: appController.language === "en" ? "Keyword used by dashboard collection actions" : "仪表盘采集动作使用的关键词" }
                                Button { text: root.t("collect_now"); ToolTip.visible: hovered; ToolTip.text: appController.language === "en" ? "Collect content with the current keyword" : "用当前关键词采集内容"; onClicked: appController.runCollection(dashKeyword.text) }
                            }
                            RowLayout {
                                Layout.fillWidth: true
                                TextField { id: endpointFilter; Layout.fillWidth: true; placeholderText: appController.language === "en" ? "Data path category filter" : "数据路径分类筛选"; text: appController.language === "en" ? "official account" : "公众号"; ToolTip.visible: hovered; ToolTip.text: appController.language === "en" ? "Filter bundled data path catalog by category" : "按分类筛选内置数据路径目录" }
                                Button { text: appController.language === "en" ? "Browse data paths" : "浏览数据路径"; ToolTip.visible: hovered; ToolTip.text: appController.language === "en" ? "Show matching data path rows in the detail panel" : "在详情区显示匹配的数据路径"; onClicked: root.detailText = appController.apiEndpointRows(endpointFilter.text).join("\n") }
                                Button { text: appController.language === "en" ? "Run first data path" : "运行首个路径"; ToolTip.visible: hovered; ToolTip.text: appController.language === "en" ? "Run the first matched data path with the dashboard keyword" : "用仪表盘关键词运行首个匹配端点"; onClicked: { const row = appController.apiEndpointRows(endpointFilter.text)[0]; root.detailText = appController.endpointPathFromRow(row); appController.runEndpointRow(row, dashKeyword.text); } }
                            }
                            TextArea { id: dashboardGuide; Layout.fillWidth: true; Layout.fillHeight: true; readOnly: true; wrapMode: TextArea.Wrap; text: root.help("help_title") + "\n\n" + root.help("help_dashboard") + "\n\n" + root.help("help_troubleshooting"); color: textMain; ToolTip.visible: hovered; ToolTip.text: appController.language === "en" ? "Click to record that you read the dashboard guide" : "点击记录已阅读仪表盘说明"; background: Rectangle { color: panel2; radius: 12 } MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: appController.noteSelection(appController.language === "en" ? "Dashboard guide" : "仪表盘说明", dashboardGuide.text) } }
                        }
                    }
                }
            }

            Rectangle {
                color: "#0f172a"
                ColumnLayout { anchors.fill: parent; anchors.margins: 24; spacing: 18
                    Label { text: root.t("library_title"); color: textMain; font.pixelSize: 30; font.bold: true }
                    Rectangle { Layout.fillWidth: true; Layout.fillHeight: true; color: panel; radius: 18; border.color: "#334155"
                        ColumnLayout { anchors.fill: parent; anchors.margins: 18; spacing: 12
                            TextArea { Layout.fillWidth: true; Layout.preferredHeight: 78; readOnly: true; wrapMode: TextArea.Wrap; text: root.help("help_library"); color: textMain; ToolTip.visible: hovered; ToolTip.text: appController.language === "en" ? "Module guide: content library" : "模块说明：内容库"; background: Rectangle { color: panel2; radius: 10 } }
                            TextField { id: search; Layout.fillWidth: true; placeholderText: appController.language === "en" ? "Search title or account" : "搜索标题或公众号"; ToolTip.visible: hovered; ToolTip.text: appController.language === "en" ? "Filter the local article list" : "筛选本地内容列表" }
                            RowLayout {
                                Button { text: appController.language === "en" ? "Refresh" : "刷新"; ToolTip.visible: hovered; ToolTip.text: appController.language === "en" ? "Reload the list using the search text" : "按搜索文本刷新列表"; onClicked: list.model = appController.articleRows(search.text) }
                                Button { text: appController.language === "en" ? "Export Markdown" : "导出 Markdown"; ToolTip.visible: hovered; ToolTip.text: appController.language === "en" ? "Export local content as Markdown" : "把本地内容导出为 Markdown"; onClicked: { appController.exportMarkdown("/tmp/media-hit-articles.md"); root.detailText = "/tmp/media-hit-articles.md" } }
                                Button { text: appController.language === "en" ? "Export XML" : "导出 XML"; ToolTip.visible: hovered; ToolTip.text: appController.language === "en" ? "Export local content as XML" : "把本地内容导出为 XML"; onClicked: { appController.exportXml("/tmp/media-hit-articles.xml"); root.detailText = "/tmp/media-hit-articles.xml" } }
                                Button { text: appController.language === "en" ? "Recommend again" : "重新推荐"; ToolTip.visible: hovered; ToolTip.text: appController.language === "en" ? "Open topic recommendations" : "打开选题推荐模块"; onClicked: stack.currentIndex = 4 }
                            }
                            ListView { id: list; Layout.fillWidth: true; Layout.fillHeight: true; clip: true; model: appController.articleRows(search.text); delegate: Rectangle { width: ListView.view.width; height: 58; color: mouse.containsMouse ? "#1e3a8a" : (index % 2 ? "#111827" : "#172033"); radius: 8; Text { anchors.verticalCenter: parent.verticalCenter; anchors.left: parent.left; anchors.leftMargin: 16; text: modelData; color: textMain; elide: Text.ElideRight; width: parent.width - 32 } MouseArea { id: mouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: { root.detailText = appController.articleDetail(modelData); appController.noteSelection(appController.language === "en" ? "Article" : "内容", modelData) } } } }
                            TextArea { Layout.fillWidth: true; Layout.preferredHeight: 95; readOnly: true; wrapMode: TextArea.Wrap; text: root.detailText; color: textMain; ToolTip.visible: hovered; ToolTip.text: appController.language === "en" ? "Selected article detail or export path" : "已选内容详情或导出路径"; background: Rectangle { color: panel2; radius: 10; border.color: "#334155" } }
                        }
                    }
                }
            }

            Rectangle {
                color: "#0f172a"
                ColumnLayout { anchors.fill: parent; anchors.margins: 24; spacing: 14
                    Label { text: root.t("hot_api_title"); color: textMain; font.pixelSize: 30; font.bold: true }
                    Rectangle { Layout.fillWidth: true; Layout.fillHeight: true; color: panel; radius: 18; border.color: "#334155"
                        ColumnLayout { anchors.fill: parent; anchors.margins: 18; spacing: 10
                            TextArea { Layout.fillWidth: true; Layout.preferredHeight: 72; readOnly: true; wrapMode: TextArea.Wrap; text: root.help("help_hot"); color: textMain; ToolTip.visible: hovered; ToolTip.text: appController.language === "en" ? "Module guide: hot articles" : "模块说明：爆文"; background: Rectangle { color: panel2; radius: 10 } }
                            Label { text: appController.language === "en" ? "Hot article collection parameters · key, keyword, pub_type, category, page, start_time, end_time" : "爆文采集参数 · key、keyword、pub_type、category、page、start_time、end_time"; color: accent; Layout.fillWidth: true }
                            RowLayout { Layout.fillWidth: true
                                ComboBox { id: datePreset; Layout.fillWidth: true; textRole: "label"; valueRole: "value"; model: [ {value:"custom",label: appController.language === "en" ? "Custom range" : "自定义范围"}, {value:"last_7_days",label: appController.language === "en" ? "Last 7 days" : "最近7天"}, {value:"last_30_days",label: appController.language === "en" ? "Last 30 days" : "最近30天"}, {value:"this_month",label: appController.language === "en" ? "This month" : "本月"} ]; ToolTip.visible: hovered; ToolTip.text: appController.language === "en" ? "Choose a date range preset" : "选择日期范围预设" }
                                Button { text: appController.language === "en" ? "Apply preset" : "应用预设"; ToolTip.visible: hovered; ToolTip.text: appController.language === "en" ? "Fill start_time and end_time from the preset" : "按预设填入 start_time 和 end_time"; onClicked: { const range = appController.dateRangeForPreset(datePreset.currentValue); hotStart.text = range[0]; hotEnd.text = range[1]; } }
                            }
                            GridLayout { Layout.fillWidth: true; columns: 2; columnSpacing: 12; rowSpacing: 8
                                TextField { id: hotKey; Layout.fillWidth: true; placeholderText: appController.language === "en" ? "key: secret key" : "key：密钥"; echoMode: TextInput.Password; ToolTip.visible: hovered; ToolTip.text: appController.language === "en" ? "Optional secret key. Empty value uses local fallback." : "可选密钥。为空时使用本地示例兜底。" }
                                TextField { id: hotKeyword; Layout.fillWidth: true; placeholderText: appController.language === "en" ? "keyword: empty means all" : "keyword：关键词，为空搜索全部"; text: "AI"; ToolTip.visible: hovered; ToolTip.text: appController.language === "en" ? "Search keyword sent with the request" : "随请求发送的搜索关键词" }
                                ComboBox { id: hotPubType; Layout.fillWidth: true; textRole: "label"; valueRole: "value"; model: [ { value: "0", label: appController.language === "en" ? "0 Text + images" : "0 图文" }, { value: "5", label: appController.language === "en" ? "5 Video" : "5 纯视频" }, { value: "7", label: appController.language === "en" ? "7 Music" : "7 纯音乐" }, { value: "8", label: appController.language === "en" ? "8 Images" : "8 纯图片" }, { value: "10", label: appController.language === "en" ? "10 Text" : "10 纯文字" }, { value: "11", label: appController.language === "en" ? "11 Repost" : "11 转载文章" } ]; ToolTip.visible: hovered; ToolTip.text: appController.language === "en" ? "Content type parameter pub_type" : "内容类型参数 pub_type" }
                                ComboBox { id: hotCategory; Layout.fillWidth: true; textRole: "label"; valueRole: "value"; model: [ {value:"0",label:appController.language === "en" ? "0 All" : "0 全部"}, {value:"1",label:appController.language === "en" ? "1 International" : "1 国际"}, {value:"2",label:appController.language === "en" ? "2 Sports" : "2 体育"}, {value:"3",label:appController.language === "en" ? "3 Entertainment" : "3 娱乐"}, {value:"4",label:appController.language === "en" ? "4 Society" : "4 社会"}, {value:"5",label:appController.language === "en" ? "5 Finance" : "5 财经"}, {value:"6",label:appController.language === "en" ? "6 Current affairs" : "6 时事"}, {value:"7",label:appController.language === "en" ? "7 Tech" : "7 科技"}, {value:"8",label:appController.language === "en" ? "8 Emotion" : "8 情感"}, {value:"9",label:appController.language === "en" ? "9 Auto" : "9 汽车"}, {value:"10",label:appController.language === "en" ? "10 Education" : "10 教育"}, {value:"11",label:appController.language === "en" ? "11 Fashion" : "11 时尚"}, {value:"12",label:appController.language === "en" ? "12 Games" : "12 游戏"}, {value:"13",label:appController.language === "en" ? "13 Military" : "13 军事"}, {value:"14",label:appController.language === "en" ? "14 Travel" : "14 旅游"}, {value:"15",label:appController.language === "en" ? "15 Food" : "15 美食"}, {value:"16",label:appController.language === "en" ? "16 Culture" : "16 文化"}, {value:"17",label:appController.language === "en" ? "17 Health" : "17 健康"}, {value:"18",label:appController.language === "en" ? "18 Funny" : "18 搞笑"}, {value:"19",label:appController.language === "en" ? "19 Home" : "19 家居"}, {value:"20",label:appController.language === "en" ? "20 Anime" : "20 动漫"}, {value:"21",label:appController.language === "en" ? "21 Pets" : "21 宠物"}, {value:"22",label:appController.language === "en" ? "22 Maternal" : "22 母婴"}, {value:"23",label:appController.language === "en" ? "23 Zodiac" : "23 星座"}, {value:"24",label:appController.language === "en" ? "24 History" : "24 历史"}, {value:"25",label:appController.language === "en" ? "25 Music" : "25 音乐"}, {value:"26",label:appController.language === "en" ? "26 Uncategorized" : "26 未分类"}, {value:"27",label:appController.language === "en" ? "27 General" : "27 综合"}, {value:"28",label:appController.language === "en" ? "28 Career" : "28 职场"}, {value:"29",label:appController.language === "en" ? "29 Agriculture" : "29 三农"}, {value:"30",label:appController.language === "en" ? "30 Elderly care" : "30 养老"} ]; ToolTip.visible: hovered; ToolTip.text: appController.language === "en" ? "Category parameter category" : "分类参数 category" }
                                SpinBox { id: hotPage; Layout.fillWidth: true; from: 1; to: 9999; value: 1; editable: true; ToolTip.visible: hovered; ToolTip.text: appController.language === "en" ? "Page number parameter page" : "页码参数 page" }
                                TextField { id: hotStart; Layout.fillWidth: true; placeholderText: appController.language === "en" ? "start_time YYYY-MM-DD" : "start_time 开始日期 YYYY-MM-DD"; text: "2026-05-15"; ToolTip.visible: hovered; ToolTip.text: appController.language === "en" ? "Start date in YYYY-MM-DD format" : "开始日期，格式 YYYY-MM-DD" }
                                TextField { id: hotEnd; Layout.fillWidth: true; placeholderText: appController.language === "en" ? "end_time YYYY-MM-DD" : "end_time 截止日期 YYYY-MM-DD"; text: "2026-05-17"; ToolTip.visible: hovered; ToolTip.text: appController.language === "en" ? "End date in YYYY-MM-DD format" : "截止日期，格式 YYYY-MM-DD" }
                            }
                            RowLayout { Layout.fillWidth: true
                                Button { text: root.t("preview_payload"); ToolTip.visible: hovered; ToolTip.text: "Preview the exact request payload / 预览本次请求参数"; onClicked: hotPreview.text = appController.hotTypicalPayloadPreview(hotKey.text, hotKeyword.text, hotPubType.currentValue, hotCategory.currentValue, hotPage.value, hotStart.text, hotEnd.text) }
                                Button { text: appController.language === "en" ? "Collect and parse" : "采集并解析"; ToolTip.visible: hovered; ToolTip.text: appController.language === "en" ? "Collect hot articles, parse the response, and refresh the result table" : "按当前参数采集爆文，解析响应并刷新结果表"; onClicked: { appController.runHotTypicalCollection(hotKey.text, hotKeyword.text, hotPubType.currentValue, hotCategory.currentValue, hotPage.value, hotStart.text, hotEnd.text); hotResultList.model = appController.hotTypicalResultRows(); hotPreview.text = appController.hotTypicalResultRows().join("\n"); } }
                                Button { text: "MD"; ToolTip.visible: hovered; ToolTip.text: appController.language === "en" ? "Export current hot article results as Markdown" : "导出当前爆文结果为 Markdown"; onClicked: { appController.exportHotTypicalResults("/tmp/media-hit-hot-results.md", "md"); hotPreview.text = "/tmp/media-hit-hot-results.md" } }
                                Button { text: "XML"; ToolTip.visible: hovered; ToolTip.text: appController.language === "en" ? "Export current hot article results as XML" : "导出当前爆文结果为 XML"; onClicked: { appController.exportHotTypicalResults("/tmp/media-hit-hot-results.xml", "xml"); hotPreview.text = "/tmp/media-hit-hot-results.xml" } }
                                Button { text: "XLS"; ToolTip.visible: hovered; ToolTip.text: appController.language === "en" ? "Export current hot article results as Excel-compatible XLS" : "导出当前爆文结果为 Excel 可打开的 XLS"; onClicked: { appController.exportHotTypicalResults("/tmp/media-hit-hot-results.xls", "xls"); hotPreview.text = "/tmp/media-hit-hot-results.xls" } }
                            }
                            Label { text: appController.language === "en" ? "Parsed result table" : "解析结果表"; color: textSub }
                            ListView { id: hotResultList; Layout.fillWidth: true; Layout.preferredHeight: 110; clip: true; model: appController.hotTypicalResultRows(); delegate: Rectangle { width: ListView.view.width; height: 28; color: hotRowMouse.containsMouse ? "#1e3a8a" : (index % 2 ? "#111827" : "#172033"); Text { anchors.verticalCenter: parent.verticalCenter; anchors.left: parent.left; anchors.leftMargin: 8; text: modelData; color: textMain; elide: Text.ElideRight; width: parent.width - 16 } MouseArea { id: hotRowMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: { hotPreview.text = modelData; appController.noteSelection(appController.language === "en" ? "Hot article result" : "爆文结果", modelData) } } } }
                            Label { text: appController.language === "en" ? "Parameter coverage" : "参数覆盖"; color: textSub }
                            ListView { Layout.fillWidth: true; Layout.preferredHeight: 80; model: appController.hotTypicalParameterRows(); delegate: Rectangle { width: ListView.view.width; height: 25; color: hotParamMouse.containsMouse ? "#1e293b" : "transparent"; Text { anchors.verticalCenter: parent.verticalCenter; text: modelData; color: textMain; elide: Text.ElideRight; width: parent.width } MouseArea { id: hotParamMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: appController.noteSelection(appController.language === "en" ? "Data parameter" : "数据路径参数", modelData) } } }
                            TextArea { id: hotPreview; Layout.fillWidth: true; Layout.fillHeight: true; readOnly: true; wrapMode: TextArea.Wrap; text: appController.hotTypicalPayloadPreview("[empty]", hotKeyword.text, hotPubType.currentValue, hotCategory.currentValue, hotPage.value, hotStart.text, hotEnd.text); color: textMain; ToolTip.visible: hovered; ToolTip.text: appController.language === "en" ? "Preview, parsed rows, selected row, or export path" : "显示参数预览、解析结果、已选行或导出路径"; background: Rectangle { color: panel2; radius: 12; border.color: "#334155" } }
                        }
                    }
                }
            }

            Rectangle {
                color: "#0f172a"
                ColumnLayout { anchors.fill: parent; anchors.margins: 24; spacing: 18
                    RowLayout { Layout.fillWidth: true; Label { text: root.t("report_title"); color: textMain; font.pixelSize: 30; font.bold: true; Layout.fillWidth: true } Button { text: appController.language === "en" ? "Export report" : "导出报告"; ToolTip.visible: hovered; ToolTip.text: appController.language === "en" ? "Export a combined analysis report" : "导出综合拆解报告"; onClicked: { appController.exportReport("/tmp/media-hit-report.md"); root.detailText = "/tmp/media-hit-report.md" } } }
                    TextArea { Layout.fillWidth: true; Layout.preferredHeight: 80; readOnly: true; wrapMode: TextArea.Wrap; text: root.help("help_report"); color: textMain; ToolTip.visible: hovered; ToolTip.text: appController.language === "en" ? "Module guide: report" : "模块说明：报告"; background: Rectangle { color: panel; radius: 10 } }
                    TextArea { id: reportView; Layout.fillWidth: true; Layout.fillHeight: true; text: appController.generateReport(); readOnly: true; wrapMode: TextArea.Wrap; color: textMain; ToolTip.visible: hovered; ToolTip.text: appController.language === "en" ? "Generated report; click to record a receipt" : "生成的报告，点击可记录回执"; background: Rectangle { color: panel2; radius: 12; border.color: "#334155" } MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: appController.noteSelection(appController.language === "en" ? "Report" : "报告", reportView.text.substring(0, 120)) } }
                }
            }

            Rectangle {
                color: "#0f172a"
                ColumnLayout { anchors.fill: parent; anchors.margins: 24; spacing: 18
                    Label { text: root.t("topics_title"); color: textMain; font.pixelSize: 30; font.bold: true }
                    TextArea { Layout.fillWidth: true; Layout.preferredHeight: 82; readOnly: true; wrapMode: TextArea.Wrap; text: root.help("help_topics"); color: textMain; ToolTip.visible: hovered; ToolTip.text: appController.language === "en" ? "Module guide: topics" : "模块说明：选题推荐"; background: Rectangle { color: panel; radius: 10 } }
                    ListView { Layout.fillWidth: true; Layout.fillHeight: true; model: appController.recommendTopics(); spacing: 10; delegate: Rectangle { width: ListView.view.width; height: 64; color: topicMouse.containsMouse ? "#1e3a8a" : panel; radius: 10; border.color: "#334155"; Text { anchors.centerIn: parent; text: modelData; color: textMain; font.pixelSize: 18 } MouseArea { id: topicMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: { root.detailText = appController.aiExtensionPayloadPreview(modelData, appController.generateReport().substring(0, 160)); appController.noteSelection(appController.language === "en" ? "Topic" : "选题", modelData) } } } }
                }
            }

            Rectangle {
                color: "#0f172a"
                ColumnLayout { anchors.fill: parent; anchors.margins: 24; spacing: 18
                    Label { text: root.t("plugins_title"); color: textMain; font.pixelSize: 30; font.bold: true }
                    Rectangle { Layout.fillWidth: true; Layout.fillHeight: true; color: panel; radius: 18; border.color: "#334155"
                        ColumnLayout { anchors.fill: parent; anchors.margins: 18; spacing: 12
                            TextArea { Layout.fillWidth: true; Layout.preferredHeight: 78; readOnly: true; wrapMode: TextArea.Wrap; text: root.help("help_plugins"); color: textMain; ToolTip.visible: hovered; ToolTip.text: appController.language === "en" ? "Module guide: plugins" : "模块说明：插件"; background: Rectangle { color: panel2; radius: 10 } }
                            RowLayout { Button { text: appController.language === "en" ? "Refresh plugins" : "刷新插件"; ToolTip.visible: hovered; ToolTip.text: appController.language === "en" ? "Reload plugin descriptors" : "刷新插件描述"; onClicked: pluginList.model = appController.pluginRows() } Button { text: appController.language === "en" ? "Plugin analysis" : "插件分析"; ToolTip.visible: hovered; ToolTip.text: appController.language === "en" ? "Run built-in analyzer on local content" : "用内置分析器分析本地内容"; onClicked: pluginReport.text = appController.pluginAnalysis() } Button { text: appController.language === "en" ? "Scan metadata" : "扫描元数据"; ToolTip.visible: hovered; ToolTip.text: appController.language === "en" ? "Scan plugin metadata files safely" : "安全扫描插件元数据文件"; onClicked: pluginReport.text = appController.pluginScanReport("plugins") } }
                            ListView { id: pluginList; Layout.fillWidth: true; Layout.preferredHeight: 150; model: appController.pluginRows(); delegate: Rectangle { width: ListView.view.width; height: 34; color: pluginMouse.containsMouse ? "#1e293b" : "transparent"; Text { anchors.verticalCenter: parent.verticalCenter; text: modelData; color: textMain; elide: Text.ElideRight; width: parent.width } MouseArea { id: pluginMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: { pluginReport.text = appController.pluginDetail(modelData) + "\n\n" + appController.pluginExportPreview(modelData); appController.noteSelection(appController.language === "en" ? "Plugin" : "插件", modelData) } } } }
                            TextArea { id: pluginReport; Layout.fillWidth: true; Layout.fillHeight: true; readOnly: true; wrapMode: TextArea.Wrap; text: appController.pluginAnalysis(); color: textMain; ToolTip.visible: hovered; ToolTip.text: appController.language === "en" ? "Plugin report and preview output" : "插件报告和预览输出"; background: Rectangle { color: panel2; radius: 12; border.color: "#334155" } MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: appController.noteSelection(appController.language === "en" ? "Plugin analysis" : "插件分析", pluginReport.text.substring(0, 120)) } }
                        }
                    }
                }
            }

            Rectangle {
                color: "#0f172a"
                ColumnLayout { anchors.fill: parent; anchors.margins: 24; spacing: 18
                    Label { text: root.t("settings_title"); color: textMain; font.pixelSize: 30; font.bold: true }
                    Rectangle { Layout.fillWidth: true; Layout.fillHeight: true; color: panel; radius: 18; border.color: "#334155"
                        ColumnLayout { anchors.fill: parent; anchors.margins: 18; spacing: 12
                            TextArea { Layout.fillWidth: true; Layout.preferredHeight: 76; readOnly: true; wrapMode: TextArea.Wrap; text: root.help("help_settings") + "\n" + root.help("help_troubleshooting"); color: textMain; ToolTip.visible: hovered; ToolTip.text: appController.language === "en" ? "Module guide: settings and troubleshooting" : "模块说明：设置与故障排查"; background: Rectangle { color: panel2; radius: 10 } }
                            TextField { id: taskName; Layout.fillWidth: true; placeholderText: appController.language === "en" ? "Task name" : "任务名称"; text: appController.language === "en" ? "AI hot article monitor" : "AI 爆文监控"; ToolTip.visible: hovered; ToolTip.text: appController.language === "en" ? "Name saved with the collection task" : "随采集任务保存的名称" }
                            TextField { id: taskKeyword; Layout.fillWidth: true; placeholderText: appController.language === "en" ? "Keyword" : "关键词"; text: "AI"; ToolTip.visible: hovered; ToolTip.text: appController.language === "en" ? "Keyword saved with the task and used by collection" : "任务保存和采集使用的关键词" }
                            RowLayout { SpinBox { id: taskInterval; from: 5; to: 86400; value: 300; editable: true; ToolTip.visible: hovered; ToolTip.text: appController.language === "en" ? "Task interval in seconds" : "任务运行间隔，单位秒" } SpinBox { id: taskRuns; from: 1; to: 9999; value: 10; editable: true; ToolTip.visible: hovered; ToolTip.text: appController.language === "en" ? "Maximum runs for this task" : "该任务最大运行次数" } Button { text: appController.language === "en" ? "Save collection task" : "保存采集任务"; ToolTip.visible: hovered; ToolTip.text: appController.language === "en" ? "Save the task and refresh the task list" : "保存任务并刷新任务列表"; onClicked: { appController.createCollectionTask(taskName.text, taskKeyword.text, taskInterval.value, taskRuns.value); tasks.model = appController.taskRows(); } } Button { text: root.t("collect_now"); ToolTip.visible: hovered; ToolTip.text: appController.language === "en" ? "Run collection immediately with the task keyword" : "立即用任务关键词执行采集"; onClicked: { appController.runCollection(taskKeyword.text); tasks.model = appController.taskRows(); } } }
                            ListView { id: tasks; Layout.fillWidth: true; Layout.preferredHeight: 80; model: appController.taskRows(); delegate: Rectangle { width: ListView.view.width; height: 32; color: taskMouse.containsMouse ? "#1e293b" : "transparent"; Text { anchors.verticalCenter: parent.verticalCenter; text: modelData; color: textMain; elide: Text.ElideRight; width: parent.width } MouseArea { id: taskMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: { root.detailText = appController.taskDetail(modelData); appController.runTaskRow(modelData); runHistory.model = appController.runRows(); appController.noteSelection(appController.language === "en" ? "Task" : "任务", modelData) } } } }
                            Label { text: appController.language === "en" ? "Run history" : "运行历史"; color: textSub; Layout.fillWidth: true }
                            ListView { id: runHistory; Layout.fillWidth: true; Layout.preferredHeight: 80; model: appController.runRows(); delegate: Rectangle { width: ListView.view.width; height: 30; color: runMouse.containsMouse ? "#1e293b" : "transparent"; Text { anchors.verticalCenter: parent.verticalCenter; text: modelData; color: textMain; elide: Text.ElideRight; width: parent.width } MouseArea { id: runMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: { root.detailText = appController.runDetail(modelData); appController.noteSelection(appController.language === "en" ? "Run history" : "运行历史", modelData) } } } }
                            TextField { id: apiKey; Layout.fillWidth: true; placeholderText: appController.language === "en" ? "Secret key" : "密钥"; echoMode: TextInput.Password; ToolTip.visible: hovered; ToolTip.text: appController.language === "en" ? "Stored only in local settings" : "只保存在本机设置中" }
                            TextField { id: verify; Layout.fillWidth: true; placeholderText: appController.language === "en" ? "Verify code" : "验证码"; ToolTip.visible: hovered; ToolTip.text: appController.language === "en" ? "Optional verification code" : "可选验证码" }
                            SpinBox { id: interval; from: 5; to: 86400; value: 300; editable: true; ToolTip.visible: hovered; ToolTip.text: appController.language === "en" ? "Default interval in seconds" : "默认运行间隔，单位秒" }
                            SpinBox { id: runs; from: 1; to: 9999; value: 10; editable: true; ToolTip.visible: hovered; ToolTip.text: appController.language === "en" ? "Default maximum runs" : "默认最大运行次数" }
                            TextField { id: qps; Layout.fillWidth: true; placeholderText: appController.language === "en" ? "QPS limit, for example 1.5" : "QPS 限制，例如 1.5"; text: "1.5"; ToolTip.visible: hovered; ToolTip.text: appController.language === "en" ? "Rate limit used between requests" : "请求之间使用的限速值" }
                            Button { text: appController.language === "en" ? "Save settings" : "保存设置"; ToolTip.visible: hovered; ToolTip.text: appController.language === "en" ? "Persist local settings" : "保存本机设置"; onClicked: appController.saveSettings(apiKey.text, verify.text, interval.value, runs.value, Number(qps.text)) }
                            Label { text: appController.language === "en" ? "The secret key is stored only in local settings. Sample mode does not call the remote service." : "密钥只保存在本机设置中；示例模式不会调用远端服务。"; color: textSub; wrapMode: Text.WordWrap; Layout.fillWidth: true; MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.detailText = appController.hotTypicalSmokePreview(apiKey.text, taskKeyword.text, "0", "0", 1, "2026-05-01", "2026-05-02") } }
                        }
                    }
                }
            }
        }
    }

    component StatCard: Rectangle {
        property string title: ""
        property string value: ""
        property string desc: ""
        Layout.fillWidth: true
        Layout.preferredHeight: 130
        color: panel2
        radius: 16
        border.color: "#334155"
        Column { anchors.fill: parent; anchors.margins: 16; spacing: 8; Text { text: title; color: textSub; font.pixelSize: 14 } Text { text: value; color: textMain; font.pixelSize: 30; font.bold: true } Text { text: desc; color: textSub; wrapMode: Text.WordWrap; width: parent.width } }
        MouseArea { anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: appController.noteSelection(title, value + " " + desc) }
    }
}
