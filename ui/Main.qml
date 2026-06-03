import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ApplicationWindow {
    id: root
    width: 1180
    height: 760
    visible: true
    title: "自媒体爆款助手 / Media Hit Assistant"
    color: "#0f172a"

    property color panel: "#111827"
    property color panel2: "#1f2937"
    property color accent: "#38bdf8"
    property color textMain: "#e5e7eb"
    property color textSub: "#94a3b8"

    RowLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            Layout.preferredWidth: 240
            Layout.fillHeight: true
            color: "#020617"
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 18
                spacing: 12
                Label { text: "爆款助手"; color: textMain; font.pixelSize: 26; font.bold: true }
                Label { text: "公众号内容情报工作台"; color: textSub; wrapMode: Text.WordWrap; Layout.fillWidth: true }
                Repeater {
                    model: ["仪表盘", "内容库", "接口库", "拆解报告", "选题推荐", "插件", "设置"]
                    delegate: Button { Layout.fillWidth: true; text: modelData; highlighted: stack.currentIndex === index; onClicked: stack.currentIndex = index }
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
                    Label { text: "仪表盘 / Dashboard"; color: textMain; font.pixelSize: 30; font.bold: true }
                    Rectangle { Layout.fillWidth: true; Layout.fillHeight: true; color: panel; radius: 18; border.color: "#334155"
                        ColumnLayout { anchors.fill: parent; anchors.margins: 18; spacing: 16
                            RowLayout { Layout.fillWidth: true
                                StatCard { title: "内容数量"; value: appController.articleCount.toString(); desc: "SQLite 本地库" }
                                StatCard { title: "总阅读"; value: appController.totalReads.toString(); desc: "按已入库内容汇总" }
                                StatCard { title: "总点赞"; value: appController.totalLikes.toString(); desc: appController.status }
                            }
                            RowLayout { Layout.fillWidth: true
                                Button { text: "加载示例数据"; onClicked: appController.loadMockArticles() }
                                Button { text: "全流程自检"; onClicked: { appController.runFullSelfCheck("/tmp"); runHistory.model = appController.runRows(); } }
                            }
                            RowLayout {
                                Layout.fillWidth: true
                                TextField { id: dashKeyword; Layout.fillWidth: true; placeholderText: "采集关键词，例如 AI/育儿/职场"; text: "AI" }
                                Button { text: "立即采集"; onClicked: appController.runCollection(dashKeyword.text) }
                            }
                            TextArea { Layout.fillWidth: true; Layout.fillHeight: true; readOnly: true; text: "可配置关键词、采集次数、限速和导出格式。没有 API Key 时自动使用示例采集，方便先完成本地分析和导出闭环。"; color: textMain; background: Rectangle { color: panel2; radius: 12 } }
                        }
                    }
                }
            }

            Rectangle {
                color: "#0f172a"
                ColumnLayout { anchors.fill: parent; anchors.margins: 24; spacing: 18
                    Label { text: "内容库 / Content Library"; color: textMain; font.pixelSize: 30; font.bold: true }
                    Rectangle { Layout.fillWidth: true; Layout.fillHeight: true; color: panel; radius: 18; border.color: "#334155"
                        ColumnLayout { anchors.fill: parent; anchors.margins: 18; spacing: 12
                            TextField { id: search; Layout.fillWidth: true; placeholderText: "搜索标题或公众号" }
                            RowLayout { Button { text: "刷新"; onClicked: list.model = appController.articleRows(search.text) } Button { text: "导出 Markdown"; onClicked: appController.exportMarkdown("/tmp/media-hit-articles.md") } Button { text: "导出 XML"; onClicked: appController.exportXml("/tmp/media-hit-articles.xml") } Button { text: "重新推荐"; onClicked: stack.currentIndex = 4 } }
                            ListView { id: list; Layout.fillWidth: true; Layout.fillHeight: true; clip: true; model: appController.articleRows(search.text); delegate: Rectangle { width: ListView.view.width; height: 58; color: index % 2 ? "#111827" : "#172033"; radius: 8; Text { anchors.verticalCenter: parent.verticalCenter; anchors.left: parent.left; anchors.leftMargin: 16; text: modelData; color: textMain; elide: Text.ElideRight; width: parent.width - 32 } } }
                        }
                    }
                }
            }

            Rectangle {
                color: "#0f172a"
                ColumnLayout { anchors.fill: parent; anchors.margins: 24; spacing: 18
                    Label { text: "接口库 / API Catalog"; color: textMain; font.pixelSize: 30; font.bold: true }
                    Rectangle { Layout.fillWidth: true; Layout.fillHeight: true; color: panel; radius: 18; border.color: "#334155"
                        ColumnLayout { anchors.fill: parent; anchors.margins: 18; spacing: 12
                            RowLayout { Layout.fillWidth: true
                                TextField { id: endpointCategory; Layout.fillWidth: true; placeholderText: "按分类筛选，例如 公众号/视频号/搜一搜"; text: "公众号" }
                                Button { text: "查询接口"; onClicked: endpointList.model = appController.apiEndpointRows(endpointCategory.text) }
                            }
                            RowLayout { Layout.fillWidth: true
                                TextField { id: endpointPath; Layout.fillWidth: true; placeholderText: "接口路径，例如 /fbmain/monitor/v3/web_search"; text: "/fbmain/monitor/v3/web_search" }
                                TextField { id: endpointKeyword; Layout.fillWidth: true; placeholderText: "关键词"; text: "AI" }
                                Button { text: "按接口采集"; onClicked: appController.runEndpointCollection(endpointPath.text, endpointKeyword.text) }
                            }
                            ListView { id: endpointList; Layout.fillWidth: true; Layout.fillHeight: true; clip: true; model: appController.apiEndpointRows(endpointCategory.text); delegate: Rectangle { width: ListView.view.width; height: 54; color: index % 2 ? "#111827" : "#172033"; radius: 8; Text { anchors.verticalCenter: parent.verticalCenter; anchors.left: parent.left; anchors.leftMargin: 16; text: modelData; color: textMain; elide: Text.ElideRight; width: parent.width - 32 } } }
                        }
                    }
                }
            }

            Rectangle {
                color: "#0f172a"
                ColumnLayout { anchors.fill: parent; anchors.margins: 24; spacing: 18
                    Label { text: "拆解报告 / Analysis Report"; color: textMain; font.pixelSize: 30; font.bold: true }
                    TextArea { Layout.fillWidth: true; Layout.fillHeight: true; text: appController.generateReport(); readOnly: true; wrapMode: TextArea.Wrap; color: textMain; background: Rectangle { color: panel2; radius: 12; border.color: "#334155" } }
                }
            }

            Rectangle {
                color: "#0f172a"
                ColumnLayout { anchors.fill: parent; anchors.margins: 24; spacing: 18
                    Label { text: "选题推荐 / Topic Recommendations"; color: textMain; font.pixelSize: 30; font.bold: true }
                    ListView { Layout.fillWidth: true; Layout.fillHeight: true; model: appController.recommendTopics(); spacing: 10; delegate: Rectangle { width: ListView.view.width; height: 64; color: panel; radius: 10; border.color: "#334155"; Text { anchors.centerIn: parent; text: modelData; color: textMain; font.pixelSize: 18 } } }
                }
            }

            Rectangle {
                color: "#0f172a"
                ColumnLayout { anchors.fill: parent; anchors.margins: 24; spacing: 18
                    Label { text: "插件 / Plugins"; color: textMain; font.pixelSize: 30; font.bold: true }
                    Rectangle { Layout.fillWidth: true; Layout.fillHeight: true; color: panel; radius: 18; border.color: "#334155"
                        ColumnLayout { anchors.fill: parent; anchors.margins: 18; spacing: 12
                            RowLayout { Button { text: "刷新插件"; onClicked: pluginList.model = appController.pluginRows() } Button { text: "插件分析"; onClicked: pluginReport.text = appController.pluginAnalysis() } }
                            ListView { id: pluginList; Layout.fillWidth: true; Layout.preferredHeight: 160; model: appController.pluginRows(); delegate: Text { width: ListView.view.width; height: 34; text: modelData; color: textMain; elide: Text.ElideRight } }
                            TextArea { id: pluginReport; Layout.fillWidth: true; Layout.fillHeight: true; readOnly: true; wrapMode: TextArea.Wrap; text: appController.pluginAnalysis(); color: textMain; background: Rectangle { color: panel2; radius: 12; border.color: "#334155" } }
                        }
                    }
                }
            }

            Rectangle {
                color: "#0f172a"
                ColumnLayout { anchors.fill: parent; anchors.margins: 24; spacing: 18
                    Label { text: "设置 / Settings"; color: textMain; font.pixelSize: 30; font.bold: true }
                    Rectangle { Layout.fillWidth: true; Layout.fillHeight: true; color: panel; radius: 18; border.color: "#334155"
                        ColumnLayout { anchors.fill: parent; anchors.margins: 18; spacing: 12
                            TextField { id: taskName; Layout.fillWidth: true; placeholderText: "任务名称"; text: "AI 爆文监控" }
                            TextField { id: taskKeyword; Layout.fillWidth: true; placeholderText: "关键词"; text: "AI" }
                            RowLayout { SpinBox { id: taskInterval; from: 5; to: 86400; value: 300; editable: true } SpinBox { id: taskRuns; from: 1; to: 9999; value: 10; editable: true } Button { text: "保存采集任务"; onClicked: { appController.createCollectionTask(taskName.text, taskKeyword.text, taskInterval.value, taskRuns.value); tasks.model = appController.taskRows(); } } Button { text: "立即采集"; onClicked: { appController.runCollection(taskKeyword.text); tasks.model = appController.taskRows(); } } }
                            ListView { id: tasks; Layout.fillWidth: true; Layout.preferredHeight: 100; model: appController.taskRows(); delegate: Text { width: ListView.view.width; height: 32; text: modelData; color: textMain; elide: Text.ElideRight } }
                            Label { text: "运行历史"; color: textSub; Layout.fillWidth: true }
                            ListView { id: runHistory; Layout.fillWidth: true; Layout.preferredHeight: 100; model: appController.runRows(); delegate: Text { width: ListView.view.width; height: 30; text: modelData; color: textMain; elide: Text.ElideRight } }
                            TextField { id: apiKey; Layout.fillWidth: true; placeholderText: "极致了 API Key"; echoMode: TextInput.Password }
                            TextField { id: verify; Layout.fillWidth: true; placeholderText: "Verify Code" }
                            SpinBox { id: interval; from: 5; to: 86400; value: 300; editable: true }
                            SpinBox { id: runs; from: 1; to: 9999; value: 10; editable: true }
                            TextField { id: qps; Layout.fillWidth: true; placeholderText: "QPS 限制，建议 1.5"; text: "1.5" }
                            Button { text: "保存设置"; onClicked: appController.saveSettings(apiKey.text, verify.text, interval.value, runs.value, Number(qps.text)) }
                            Label { text: "API Key 只保存在本机设置中；示例模式不会调用真实接口。"; color: textSub; wrapMode: Text.WordWrap; Layout.fillWidth: true }
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
    }
}
