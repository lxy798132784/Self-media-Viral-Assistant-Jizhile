#include <QtTest/QtTest>
#include <QTemporaryDir>
#include <QJsonObject>
#include "api_catalog.h"
#include "database_manager.h"
#include "export_service.h"
#include "jizhilia_client.h"
#include "plugin_interfaces.h"
#include "app_controller.h"

class CoreTest : public QObject {
  Q_OBJECT
 private slots:
  void apiCatalogLoadsLocalIndex();
  void databaseStoresAndQueriesArticles();
  void databaseStoresCollectionTasks();
  void exportServiceCreatesMarkdownAndXml();
  void clientBuildsSearchPayload();
  void clientBuildsHotTypicalPayload();
  void appControllerSupportsLanguageAndHotTypicalApi();
  void pluginRegistryExposesBuiltins();
  void appControllerExposesEndpointAndPluginRows();
};

void CoreTest::apiCatalogLoadsLocalIndex() {
  ApiCatalog catalog;
  const auto endpoints = catalog.loadFromFile("/home/pi/dev/jizhilia-api-knowledge/api-index.json");
  QVERIFY(endpoints.size() >= 48);
  QVERIFY(catalog.categories(endpoints).contains(QStringLiteral("公众号文章内容和互动数据等")));
}

void CoreTest::databaseStoresAndQueriesArticles() {
  QTemporaryDir dir;
  QVERIFY(dir.isValid());
  DatabaseManager db;
  QVERIFY(db.open(dir.filePath("test.sqlite")));
  QVERIFY(db.initialize());
  Article article;
  article.title = QStringLiteral("爆款标题测试");
  article.author = QStringLiteral("作者A");
  article.accountName = QStringLiteral("测试公众号");
  article.url = QStringLiteral("https://example.com/a");
  article.readCount = 100000;
  article.likeCount = 3000;
  QVERIFY(db.upsertArticle(article));
  QCOMPARE(db.articleCount(), 1);
  const auto rows = db.listArticles(QStringLiteral("爆款"));
  QCOMPARE(rows.size(), 1);
  QCOMPARE(rows.first().title, article.title);
  QCOMPARE(db.totalReads(), 100000);
  QCOMPARE(db.totalLikes(), 3000);
  const auto sorted = db.listArticlesSorted(QString(), QStringLiteral("likes"), 10);
  QCOMPARE(sorted.size(), 1);
}

void CoreTest::databaseStoresCollectionTasks() {
  QTemporaryDir dir;
  QVERIFY(dir.isValid());
  DatabaseManager db;
  QVERIFY(db.open(dir.filePath("tasks.sqlite")));
  QVERIFY(db.initialize());
  CollectionTask task;
  task.name = QStringLiteral("AI 爆文采集");
  task.keyword = QStringLiteral("AI");
  task.endpointPath = QStringLiteral("/fbmain/monitor/v3/web_search");
  task.intervalSeconds = 60;
  task.maxRuns = 3;
  const int id = db.saveTask(task);
  QVERIFY(id > 0);
  QVERIFY(db.recordCollectionRun(id, QStringLiteral("success"), 2, QStringLiteral("mock run")));
  QCOMPARE(db.runCount(id), 1);
  QVERIFY(!db.runRows(10).isEmpty());
  QVERIFY(db.incrementTaskRun(id));
  const auto tasks = db.listTasks();
  QCOMPARE(tasks.size(), 1);
  QCOMPARE(tasks.first().currentRuns, 1);
  QCOMPARE(tasks.first().keyword, QStringLiteral("AI"));
}

void CoreTest::exportServiceCreatesMarkdownAndXml() {
  Article article;
  article.title = QStringLiteral("标题 <测试>");
  article.accountName = QStringLiteral("公众号");
  article.url = QStringLiteral("https://example.com/a");
  article.readCount = 123;
  QVector<Article> articles{article};
  ExportService exporter;
  const auto md = exporter.toMarkdown(articles);
  QVERIFY(md.contains(QStringLiteral("# 自媒体爆款文章导出")));
  QVERIFY(md.contains(article.title));
  const auto xml = exporter.toXml(articles);
  QVERIFY(xml.contains(QStringLiteral("&lt;测试&gt;")));
  QVERIFY(xml.contains(QStringLiteral("<articles>")));
}

void CoreTest::clientBuildsSearchPayload() {
  JizhiliaClient client;
  QVERIFY(client.isConfigured(QStringLiteral("abc")));
  QVERIFY(!client.isConfigured(QString()));
  const auto payload = client.buildArticleSearchPayload(QStringLiteral("AI"), 2, QStringLiteral("key"), QStringLiteral("code"));
  const auto generic = client.buildGenericPayload(QStringLiteral("AI"), 3, QStringLiteral("key"), QStringLiteral("code"));
  QCOMPARE(generic.value("page").toInt(), 3);
  QCOMPARE(generic.value("keyword").toString(), QStringLiteral("AI"));
  QCOMPARE(payload.value("keyword").toString(), QStringLiteral("AI"));
  QCOMPARE(payload.value("currentPage").toInt(), 2);
  QCOMPARE(payload.value("key").toString(), QStringLiteral("key"));
  QCOMPARE(payload.value("verifycode").toString(), QStringLiteral("code"));
  const auto mockRows = client.mockSearchArticles(QStringLiteral("AI"), 1);
  QCOMPARE(mockRows.size(), 5);
  QVERIFY(mockRows.first().title.contains(QStringLiteral("AI")));
  const auto endpointRows = client.mockEndpointArticles(QStringLiteral("/fbmain/search/video"), QStringLiteral("AI"), 1);
  QCOMPARE(endpointRows.size(), 5);
  QVERIFY(endpointRows.first().summary.contains(QStringLiteral("/fbmain/search/video")));
  const QByteArray sample = R"({"data":[{"title":"样本标题","url":"https://example.com","wx_name":"账号","read_num":1000,"like_num":50}]})";
  const auto parsed = client.parseArticlesFromJson(sample, QStringLiteral("AI"));
  QCOMPARE(parsed.size(), 1);
  QCOMPARE(parsed.first().title, QStringLiteral("样本标题"));
  QCOMPARE(parsed.first().readCount, 1000);
  QVERIFY(client.isRetryableStatus(500));
  QVERIFY(client.retryDelayMs(3) >= 4000);
}

void CoreTest::clientBuildsHotTypicalPayload() {
  JizhiliaClient client;
  const auto payload = client.buildHotTypicalSearchPayload(
      QStringLiteral("key-1"), QStringLiteral("AI"), QStringLiteral("5"), QStringLiteral("7"), 2,
      QStringLiteral("2026-05-15"), QStringLiteral("2026-05-17"));
  QCOMPARE(payload.value("key").toString(), QStringLiteral("key-1"));
  QCOMPARE(payload.value("keyword").toString(), QStringLiteral("AI"));
  QCOMPARE(payload.value("pub_type").toString(), QStringLiteral("5"));
  QCOMPARE(payload.value("category").toString(), QStringLiteral("7"));
  QCOMPARE(payload.value("page").toString(), QStringLiteral("2"));
  QCOMPARE(payload.value("start_time").toString(), QStringLiteral("2026-05-15"));
  QCOMPARE(payload.value("end_time").toString(), QStringLiteral("2026-05-17"));
  QVERIFY(client.hotTypicalParameterNames().contains(QStringLiteral("pub_type")));
  QVERIFY(client.hotTypicalParameterNames().contains(QStringLiteral("end_time")));
}

void CoreTest::appControllerSupportsLanguageAndHotTypicalApi() {
  AppController controller;
  QVERIFY(controller.initialize());
  QCOMPARE(controller.language(), QStringLiteral("zh"));
  controller.setLanguage(QStringLiteral("en"));
  QCOMPARE(controller.language(), QStringLiteral("en"));
  QVERIFY(controller.trText(QStringLiteral("dashboard_title")).contains(QStringLiteral("Dashboard")));
  controller.setLanguage(QStringLiteral("zh"));
  QVERIFY(controller.trText(QStringLiteral("dashboard_title")).contains(QStringLiteral("仪表盘")));
  QVERIFY(controller.hotTypicalParameterRows().join("\n").contains(QStringLiteral("pub_type")));
  QVERIFY(controller.hotTypicalParameterRows().join("\n").contains(QStringLiteral("start_time")));
  const QString preview = controller.hotTypicalPayloadPreview(
      QStringLiteral("key-1"), QStringLiteral("AI"), QStringLiteral("0"), QStringLiteral("7"), 1,
      QStringLiteral("2026-05-15"), QStringLiteral("2026-05-17"));
  QVERIFY(preview.contains(QStringLiteral("hot_typical_search")));
  QVERIFY(preview.contains(QStringLiteral("\"category\": \"7\"")));
  QVERIFY(preview.contains(QStringLiteral("\"end_time\": \"2026-05-17\"")));
}

void CoreTest::pluginRegistryExposesBuiltins() {
  BuiltinPluginRegistry registry;
  const auto plugins = registry.plugins();
  QVERIFY(plugins.contains(QStringLiteral("provider:jizhilia")));
  QVERIFY(plugins.contains(QStringLiteral("exporter:markdown")));
  QVERIFY(plugins.contains(QStringLiteral("exporter:xml")));
  QVERIFY(plugins.contains(QStringLiteral("analyzer:hit-score")));
  QVERIFY(!registry.dynamicPluginHints(QStringLiteral("plugins")).isEmpty());
  Article article;
  article.title = QStringLiteral("强共鸣标题");
  article.accountName = QStringLiteral("测试号");
  article.url = QStringLiteral("https://example.com/x");
  article.readCount = 120000;
  article.likeCount = 4000;
  const QString report = registry.analyze(QVector<Article>{article});
  QVERIFY(report.contains(QStringLiteral("爆款评分")));
}

void CoreTest::appControllerExposesEndpointAndPluginRows() {
  ApiCatalog catalog;
  const auto endpoints = catalog.loadFromFile("/home/pi/dev/jizhilia-api-knowledge/api-index.json");
  const auto mp = catalog.findByCategory(endpoints, QStringLiteral("公众号"));
  QVERIFY(!mp.isEmpty());
  QVERIFY(catalog.findByPath(endpoints, mp.first().path).path == mp.first().path);
  AppController controller;
  QVERIFY(controller.initialize());
  QVERIFY(!controller.apiEndpointRows(QStringLiteral("公众号")).isEmpty());
  QVERIFY(controller.pluginRows().contains(QStringLiteral("analyzer:hit-score")));
  controller.loadMockArticles();
  QVERIFY(controller.pluginAnalysis().contains(QStringLiteral("爆款评分")));
  QVERIFY(controller.runFullSelfCheck(QDir::tempPath()));
  QVERIFY(!controller.runRows().isEmpty());
}

QTEST_MAIN(CoreTest)
#include "test_core.moc"
