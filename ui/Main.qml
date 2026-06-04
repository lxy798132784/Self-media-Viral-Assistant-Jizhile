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
    function t(key) { appController.language; return appController.trText(key) }
    property string detailText: ""

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
                    Button { text: "中文"; highlighted: appController.language === "zh"; onClicked: appController.setLanguage("zh") }
                    Button { text: "English"; highlighted: appController.language === "en"; onClicked: appController.setLanguage("en") }
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
                                Button { text: root.t("load_samples"); onClicked: appController.loadMockArticles() }
                                Button { text: root.t("self_check"); onClicked: { appController.runFullSelfCheck("/tmp"); runHistory.model = appController.runRows(); } }
                            }
                            RowLayout {
                                Layout.fillWidth: true
                                TextField { id: dashKeyword; Layout.fillWidth: true; placeholderText: appController.language === "en" ? "Keyword, for example AI, parenting, career" : "采集关键词，例如 AI、育儿、职场"; text: "AI" }
                                Button { text: root.t("collect_now"); onClicked: appController.runCollection(dashKeyword.text) }
                            }
                            RowLayout {
                                Layout.fillWidth: true
                                TextField { id: endpointFilter; Layout.fillWidth: true; placeholderText: appController.language === "en" ? "Endpoint category filter" : "接口分类筛选"; text: appController.language === "en" ? "official account" : "公众号" }
                                Button { text: appController.language === "en" ? "Browse endpoints" : "浏览接口"; onClicked: root.detailText = appController.apiEndpointRows(endpointFilter.text).join("\n") }
                                Button { text: appController.language === "en" ? "Run first endpoint" : "运行首个接口"; onClicked: { const row = appController.apiEndpointRows(endpointFilter.text)[0]; root.detailText = appController.endpointPathFromRow(row); appController.runEndpointRow(row, dashKeyword.text); } }
                            }
                            TextArea { id: dashboardGuide; Layout.fillWidth: true; Layout.fillHeight: true; readOnly: true; text: appController.language === "en" ? "Use the Hot Articles API page for the target API endpoint. All documented request parameters have editable controls. Click this panel to refresh the guide status." : "重点使用公众号爆文 API 页面。文档里的所有请求参数都有对应控件可修改。点击本说明面板可刷新状态。"; color: textMain; background: Rectangle { color: panel2; radius: 12 } MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: appController.noteSelection(appController.language === "en" ? "Dashboard guide" : "仪表盘说明", dashboardGuide.text) } }
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
                            TextField { id: search; Layout.fillWidth: true; placeholderText: appController.language === "en" ? "Search title or account" : "搜索标题或公众号" }
                            RowLayout {
                                Button { text: appController.language === "en" ? "Refresh" : "刷新"; onClicked: list.model = appController.articleRows(search.text) }
                                Button { text: appController.language === "en" ? "Export Markdown" : "导出 Markdown"; onClicked: { appController.exportMarkdown("/tmp/media-hit-articles.md"); root.detailText = "/tmp/media-hit-articles.md" } }
                                Button { text: appController.language === "en" ? "Export XML" : "导出 XML"; onClicked: { appController.exportXml("/tmp/media-hit-articles.xml"); root.detailText = "/tmp/media-hit-articles.xml" } }
                                Button { text: appController.language === "en" ? "Recommend again" : "重新推荐"; onClicked: stack.currentIndex = 4 }
                            }
                            ListView { id: list; Layout.fillWidth: true; Layout.fillHeight: true; clip: true; model: appController.articleRows(search.text); delegate: Rectangle { width: ListView.view.width; height: 58; color: mouse.containsMouse ? "#1e3a8a" : (index % 2 ? "#111827" : "#172033"); radius: 8; Text { anchors.verticalCenter: parent.verticalCenter; anchors.left: parent.left; anchors.leftMargin: 16; text: modelData; color: textMain; elide: Text.ElideRight; width: parent.width - 32 } MouseArea { id: mouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: { root.detailText = appController.articleDetail(modelData); appController.noteSelection(appController.language === "en" ? "Article" : "内容", modelData) } } } }
                            TextArea { Layout.fillWidth: true; Layout.preferredHeight: 95; readOnly: true; wrapMode: TextArea.Wrap; text: root.detailText; color: textMain; background: Rectangle { color: panel2; radius: 10; border.color: "#334155" } }
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
                            Label { text: appController.language === "en" ? "POST /fbmain/monitor/v3/hot_typical_search · multipart/form-data · key, keyword, pub_type, category, page, start_time, end_time" : "POST /fbmain/monitor/v3/hot_typical_search · multipart/form-data · key、keyword、pub_type、category、page、start_time、end_time"; color: accent; Layout.fillWidth: true }
                            RowLayout { Layout.fillWidth: true
                                ComboBox { id: datePreset; Layout.fillWidth: true; textRole: "label"; valueRole: "value"; model: [ {value:"custom",label: appController.language === "en" ? "Custom range" : "自定义范围"}, {value:"last_7_days",label: appController.language === "en" ? "Last 7 days" : "最近7天"}, {value:"last_30_days",label: appController.language === "en" ? "Last 30 days" : "最近30天"}, {value:"this_month",label: appController.language === "en" ? "This month" : "本月"} ] }
                                Button { text: appController.language === "en" ? "Apply preset" : "应用预设"; onClicked: { const range = appController.dateRangeForPreset(datePreset.currentValue); hotStart.text = range[0]; hotEnd.text = range[1]; } }
                            }
                            GridLayout { Layout.fillWidth: true; columns: 2; columnSpacing: 12; rowSpacing: 8
                                TextField { id: hotKey; Layout.fillWidth: true; placeholderText: appController.language === "en" ? "key: API key" : "key：极致了 key"; echoMode: TextInput.Password }
                                TextField { id: hotKeyword; Layout.fillWidth: true; placeholderText: appController.language === "en" ? "keyword: empty means all" : "keyword：关键词，为空搜索全部"; text: "AI" }
                                ComboBox { id: hotPubType; Layout.fillWidth: true; textRole: "label"; valueRole: "value"; model: [ { value: "0", label: appController.language === "en" ? "0 Text + images" : "0 图文" }, { value: "5", label: appController.language === "en" ? "5 Video" : "5 纯视频" }, { value: "7", label: appController.language === "en" ? "7 Music" : "7 纯音乐" }, { value: "8", label: appController.language === "en" ? "8 Images" : "8 纯图片" }, { value: "10", label: appController.language === "en" ? "10 Text" : "10 纯文字" }, { value: "11", label: appController.language === "en" ? "11 Repost" : "11 转载文章" } ] }
ComboBox { id: hotCategory; Layout.fillWidth: true; textRole: "label"; valueRole: "value"; model: [ {value:"0",label:appController.language === "en" ? "0 All" : "0 全部"}, {value:"1",label:appController.language === "en" ? "1 International" : "1 国际"}, {value:"2",label:appController.language === "en" ? "2 Sports" : "2 体育"}, {value:"3",label:appController.language === "en" ? "3 Entertainment" : "3 娱乐"}, {value:"4",label:appController.language === "en" ? "4 Society" : "4 社会"}, {value:"5",label:appController.language === "en" ? "5 Finance" : "5 财经"}, {value:"6",label:appController.language === "en" ? "6 Current affairs" : "6 时事"}, {value:"7",label:appController.language === "en" ? "7 Tech" : "7 科技"}, {value:"8",label:appController.language === "en" ? "8 Emotion" : "8 情感"}, {value:"9",label:appController.language === "en" ? "9 Auto" : "9 汽车"}, {value:"10",label:appController.language === "en" ? "10 Education" : "10 教育"}, {value:"11",label:appController.language === "en" ? "11 Fashion" : "11 时尚"}, {value:"12",label:appController.language === "en" ? "12 Games" : "12 游戏"}, {value:"13",label:appController.language === "en" ? "13 Military" : "13 军事"}, {value:"14",label:appController.language === "en" ? "14 Travel" : "14 旅游"}, {value:"15",label:appController.language === "en" ? "15 Food" : "15 美食"}, {value:"16",label:appController.language === "en" ? "16 Culture" : "16 文化"}, {value:"17",label:appController.language === "en" ? "17 Health" : "17 健康"}, {value:"18",label:appController.language === "en" ? "18 Funny" : "18 搞笑"}, {value:"19",label:appController.language === "en" ? "19 Home" : "19 家居"}, {value:"20",label:appController.language === "en" ? "20 Anime" : "20 动漫"}, {value:"21",label:appController.language === "en" ? "21 Pets" : "21 宠物"}, {value:"22",label:appController.language === "en" ? "22 Maternal" : "22 母婴"}, {value:"23",label:appController.language === "en" ? "23 Zodiac" : "23 星座"}, {value:"24",label:appController.language === "en" ? "24 History" : "24 历史"}, {value:"25",label:appController.language === "en" ? "25 Music" : "25 音乐"}, {value:"26",label:appController.language === "en" ? "26 Unclassified" : "26 未分类"}, {value:"27",label:appController.language === "en" ? "27 General" : "27 综合"}, {value:"28",label:appController.language === "en" ? "28 Workplace" : "28 职场"}, {value:"29",label:appController.language === "en" ? "29 Agriculture" : "29 三农"}, {value:"30",label:appController.language === "en" ? "30 Elder care" : "30 养老"} ] }
                                SpinBox { id: hotPage; Layout.fillWidth: true; from: 1; to: 9999; value: 1; editable: true }
                                TextField { id: hotStart; Layout.fillWidth: true; placeholderText: appController.language === "en" ? "start_time YYYY-MM-DD" : "start_time 开始日期 YYYY-MM-DD"; text: "2026-05-15" }
                                TextField { id: hotEnd; Layout.fillWidth: true; placeholderText: appController.language === "en" ? "end_time YYYY-MM-DD" : "end_time 截止日期 YYYY-MM-DD"; text: "2026-05-17" }
                            }
                            RowLayout { Layout.fillWidth: true
                                Button { text: root.t("preview_payload"); onClicked: hotPreview.text = appController.hotTypicalPayloadPreview(hotKey.text, hotKeyword.text, hotPubType.currentValue, hotCategory.currentValue, hotPage.value, hotStart.text, hotEnd.text) }
                                Button { text: appController.language === "en" ? "Smoke plan" : "联调计划"; onClicked: hotPreview.text = appController.hotTypicalSmokePreview(hotKey.text, hotKeyword.text, hotPubType.currentValue, hotCategory.currentValue, hotPage.value, hotStart.text, hotEnd.text) }
                                Button { text: root.t("collect_hot"); onClicked: { appController.runHotTypicalCollection(hotKey.text, hotKeyword.text, hotPubType.currentValue, hotCategory.currentValue, hotPage.value, hotStart.text, hotEnd.text); hotPreview.text = appController.hotTypicalPayloadPreview(hotKey.text, hotKeyword.text, hotPubType.currentValue, hotCategory.currentValue, hotPage.value, hotStart.text, hotEnd.text); } }
                            }
                            Label { text: appController.language === "en" ? "Parameter coverage" : "参数覆盖"; color: textSub }
                            ListView { Layout.fillWidth: true; Layout.preferredHeight: 125; model: appController.hotTypicalParameterRows(); delegate: Rectangle { width: ListView.view.width; height: 25; color: hotParamMouse.containsMouse ? "#1e293b" : "transparent"; Text { anchors.verticalCenter: parent.verticalCenter; text: modelData; color: textMain; elide: Text.ElideRight; width: parent.width } MouseArea { id: hotParamMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: appController.noteSelection(appController.language === "en" ? "API parameter" : "接口参数", modelData) } } }
                            TextArea { id: hotPreview; Layout.fillWidth: true; Layout.fillHeight: true; readOnly: true; wrapMode: TextArea.Wrap; text: appController.hotTypicalPayloadPreview("[empty]", hotKeyword.text, hotPubType.currentValue, hotCategory.currentValue, hotPage.value, hotStart.text, hotEnd.text); color: textMain; background: Rectangle { color: panel2; radius: 12; border.color: "#334155" } }
                        }
                    }
                }
            }

            Rectangle {
                color: "#0f172a"
                ColumnLayout { anchors.fill: parent; anchors.margins: 24; spacing: 18
                    RowLayout { Layout.fillWidth: true; Label { text: root.t("report_title"); color: textMain; font.pixelSize: 30; font.bold: true; Layout.fillWidth: true } Button { text: appController.language === "en" ? "Export report" : "导出报告"; onClicked: { appController.exportReport("/tmp/media-hit-report.md"); root.detailText = "/tmp/media-hit-report.md" } } }
                    TextArea { id: reportView; Layout.fillWidth: true; Layout.fillHeight: true; text: appController.generateReport(); readOnly: true; wrapMode: TextArea.Wrap; color: textMain; background: Rectangle { color: panel2; radius: 12; border.color: "#334155" } MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: appController.noteSelection(appController.language === "en" ? "Report" : "报告", reportView.text.substring(0, 120)) } }
                }
            }

            Rectangle {
                color: "#0f172a"
                ColumnLayout { anchors.fill: parent; anchors.margins: 24; spacing: 18
                    Label { text: root.t("topics_title"); color: textMain; font.pixelSize: 30; font.bold: true }
                    ListView { Layout.fillWidth: true; Layout.fillHeight: true; model: appController.recommendTopics(); spacing: 10; delegate: Rectangle { width: ListView.view.width; height: 64; color: topicMouse.containsMouse ? "#1e3a8a" : panel; radius: 10; border.color: "#334155"; Text { anchors.centerIn: parent; text: modelData; color: textMain; font.pixelSize: 18 } MouseArea { id: topicMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: { root.detailText = appController.aiExtensionPayloadPreview(modelData, appController.generateReport().substring(0, 160)); appController.noteSelection(appController.language === "en" ? "Topic" : "选题", modelData) } } }
                }
            }

            Rectangle {
                color: "#0f172a"
                ColumnLayout { anchors.fill: parent; anchors.margins: 24; spacing: 18
                    Label { text: root.t("plugins_title"); color: textMain; font.pixelSize: 30; font.bold: true }
                    Rectangle { Layout.fillWidth: true; Layout.fillHeight: true; color: panel; radius: 18; border.color: "#334155"
                        ColumnLayout { anchors.fill: parent; anchors.margins: 18; spacing: 12
                            RowLayout { Button { text: appController.language === "en" ? "Refresh plugins" : "刷新插件"; onClicked: pluginList.model = appController.pluginRows() } Button { text: appController.language === "en" ? "Plugin analysis" : "插件分析"; onClicked: pluginReport.text = appController.pluginAnalysis() } Button { text: appController.language === "en" ? "Scan metadata" : "扫描元数据"; onClicked: pluginReport.text = appController.pluginScanReport("plugins") } }
                            ListView { id: pluginList; Layout.fillWidth: true; Layout.preferredHeight: 160; model: appController.pluginRows(); delegate: Rectangle { width: ListView.view.width; height: 34; color: pluginMouse.containsMouse ? "#1e293b" : "transparent"; Text { anchors.verticalCenter: parent.verticalCenter; text: modelData; color: textMain; elide: Text.ElideRight; width: parent.width } MouseArea { id: pluginMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: { pluginReport.text = appController.pluginDetail(modelData) + "\n\n" + appController.pluginExportPreview(modelData); appController.noteSelection(appController.language === "en" ? "Plugin" : "插件", modelData) } } } }
                            TextArea { id: pluginReport; Layout.fillWidth: true; Layout.fillHeight: true; readOnly: true; wrapMode: TextArea.Wrap; text: appController.pluginAnalysis(); color: textMain; background: Rectangle { color: panel2; radius: 12; border.color: "#334155" } MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: appController.noteSelection(appController.language === "en" ? "Plugin analysis" : "插件分析", pluginReport.text.substring(0, 120)) } }
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
                            TextField { id: taskName; Layout.fillWidth: true; placeholderText: appController.language === "en" ? "Task name" : "任务名称"; text: appController.language === "en" ? "AI hot article monitor" : "AI 爆文监控" }
                            TextField { id: taskKeyword; Layout.fillWidth: true; placeholderText: appController.language === "en" ? "Keyword" : "关键词"; text: "AI" }
                            RowLayout { SpinBox { id: taskInterval; from: 5; to: 86400; value: 300; editable: true } SpinBox { id: taskRuns; from: 1; to: 9999; value: 10; editable: true } Button { text: appController.language === "en" ? "Save collection task" : "保存采集任务"; onClicked: { appController.createCollectionTask(taskName.text, taskKeyword.text, taskInterval.value, taskRuns.value); tasks.model = appController.taskRows(); } } Button { text: root.t("collect_now"); onClicked: { appController.runCollection(taskKeyword.text); tasks.model = appController.taskRows(); } } }
                            ListView { id: tasks; Layout.fillWidth: true; Layout.preferredHeight: 100; model: appController.taskRows(); delegate: Rectangle { width: ListView.view.width; height: 32; color: taskMouse.containsMouse ? "#1e293b" : "transparent"; Text { anchors.verticalCenter: parent.verticalCenter; text: modelData; color: textMain; elide: Text.ElideRight; width: parent.width } MouseArea { id: taskMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: { root.detailText = appController.taskDetail(modelData); appController.runTaskRow(modelData); runHistory.model = appController.runRows(); appController.noteSelection(appController.language === "en" ? "Task" : "任务", modelData) } } } }
                            Label { text: appController.language === "en" ? "Run history" : "运行历史"; color: textSub; Layout.fillWidth: true }
                            ListView { id: runHistory; Layout.fillWidth: true; Layout.preferredHeight: 100; model: appController.runRows(); delegate: Rectangle { width: ListView.view.width; height: 30; color: runMouse.containsMouse ? "#1e293b" : "transparent"; Text { anchors.verticalCenter: parent.verticalCenter; text: modelData; color: textMain; elide: Text.ElideRight; width: parent.width } MouseArea { id: runMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: { root.detailText = appController.runDetail(modelData); appController.noteSelection(appController.language === "en" ? "Run history" : "运行历史", modelData) } } } }
                            TextField { id: apiKey; Layout.fillWidth: true; placeholderText: appController.language === "en" ? "Jizhilia API key" : "极致了 API Key"; echoMode: TextInput.Password }
                            TextField { id: verify; Layout.fillWidth: true; placeholderText: appController.language === "en" ? "Verify code" : "验证码" }
                            SpinBox { id: interval; from: 5; to: 86400; value: 300; editable: true }
                            SpinBox { id: runs; from: 1; to: 9999; value: 10; editable: true }
                            TextField { id: qps; Layout.fillWidth: true; placeholderText: appController.language === "en" ? "QPS limit, for example 1.5" : "QPS 限制，例如 1.5"; text: "1.5" }
                            Button { text: appController.language === "en" ? "Save settings" : "保存设置"; onClicked: appController.saveSettings(apiKey.text, verify.text, interval.value, runs.value, Number(qps.text)) }
                            Label { text: appController.language === "en" ? "The API key is stored only in local settings. Sample mode does not call the real API." : "API Key 只保存在本机设置中；示例模式不会调用真实接口。"; color: textSub; wrapMode: Text.WordWrap; Layout.fillWidth: true; MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.detailText = appController.hotTypicalSmokePreview(apiKey.text, taskKeyword.text, "0", "0", 1, "2026-05-01", "2026-05-02") } }
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
}
