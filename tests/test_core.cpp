#include <QtTest/QtTest>
#include <QTemporaryDir>
#include <QJsonObject>
#include <QDir>
#include <QFile>
#include "api_catalog.h"
#include "database_manager.h"
#include "export_service.h"
#include "content_data_client.h"
#include "plugin_interfaces.h"
#include "app_controller.h"

class CoreTest : public QObject {
  Q_OBJECT
 private slots:
  void apiCatalogLoadsLocalIndex();
  void databaseStoresAndQueriesArticles();
  void databaseStoresCollectionTasks();
  void exportServiceCreatesMarkdownXmlAndSpreadsheet();
  void clientBuildsSearchPayload();
  void clientBuildsHotTypicalPayload();
  void clientValidatesOfficialHotTypicalModel();
  void clientParsesOfficialHotTypicalResponseForVisualization();
  void clientParsesHotTypicalEnvelopeRealData();
  void clientParsesHotTypicalEnvelopeRealEmptyNeverFabricates();
  void clientParsesHotTypicalEnvelopeApiErrorNeverFabricates();
  void clientFetchHotTypicalUsesSampleOnlyWhenNoKey();
  void clientFetchHotTypicalValidationErrorDoesNotSpend();
  void appControllerExposesHotTypicalMetadata();
  void appControllerCollectsHotTypicalAndExportsMultipleFormats();
  void pluginRegistryExposesBuiltins();
  void pluginRegistryScansDynamicPluginsFailClosed();
  void clientClassifiesApiErrorsAndSupportsSmokePlan();
  void appControllerExposesDatePickersAndAiExtensionSlot();
  void appControllerExposesEndpointAndPluginRows();
  void appControllerClosesInteractiveDetailsAndExports();
  void clientBuildsEmotionRecentMonthCollectionPlan();
  void clientFiltersHotTypicalArticlesByReadWindowAndLimit();
};

void CoreTest::apiCatalogLoadsLocalIndex() {
  ApiCatalog catalog;
  QVERIFY(QFile::exists(catalog.defaultIndexPath()));
  const auto endpoints = catalog.loadDefault();
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
  article.hotScore = 77.7;
  article.avgReadCount = 8800;
  article.fansCount = 23000;
  article.position = 1;
  article.category = QStringLiteral("科技");
  article.isOriginal = QStringLiteral("原创");
  article.publishType = QStringLiteral("图文");
  article.wxid = QStringLiteral("gh_db_full_001");
  article.coverUrl = QStringLiteral("https://example.com/cover-db.jpg");
  QVERIFY(db.upsertArticle(article));
  QCOMPARE(db.articleCount(), 1);
  const auto rows = db.listArticles(QStringLiteral("爆款"));
  QCOMPARE(rows.size(), 1);
  QCOMPARE(rows.first().title, article.title);
  QCOMPARE(rows.first().hotScore, 77.7);
  QCOMPARE(rows.first().avgReadCount, 8800);
  QCOMPARE(rows.first().fansCount, 23000);
  QCOMPARE(rows.first().position, 1);
  QCOMPARE(rows.first().category, QStringLiteral("科技"));
  QCOMPARE(rows.first().isOriginal, QStringLiteral("原创"));
  QCOMPARE(rows.first().publishType, QStringLiteral("图文"));
  QCOMPARE(rows.first().wxid, QStringLiteral("gh_db_full_001"));
  QCOMPARE(rows.first().coverUrl, QStringLiteral("https://example.com/cover-db.jpg"));
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

void CoreTest::exportServiceCreatesMarkdownXmlAndSpreadsheet() {
  Article article;
  article.title = QStringLiteral("标题 <测试>");
  article.accountName = QStringLiteral("公众号");
  article.author = QStringLiteral("作者A");
  article.url = QStringLiteral("https://example.com/a");
  article.publishTime = QStringLiteral("2026-05-17");
  article.hotScore = 98.5;
  article.readCount = 123;
  article.likeCount = 45;
  article.avgReadCount = 100;
  article.fansCount = 1000;
  article.position = 1;
  article.wxid = QStringLiteral("gh_test_001");
  article.category = QStringLiteral("科技");
  article.isOriginal = QStringLiteral("是");
  article.publishType = QStringLiteral("图文");
  article.coverUrl = QStringLiteral("https://example.com/cover.jpg");
  QVector<Article> articles{article};
  ExportService exporter;
  const auto md = exporter.toMarkdown(articles);
  QVERIFY(md.contains(QStringLiteral("# 自媒体爆款文章导出")));
  QVERIFY(md.contains(article.title));
  QVERIFY(md.contains(QStringLiteral("98.5")));
  const auto xml = exporter.toXml(articles);
  QVERIFY(xml.contains(QStringLiteral("&lt;测试&gt;")));
  QVERIFY(xml.contains(QStringLiteral("<hotScore>98.5</hotScore>")));
  QVERIFY(xml.contains(QStringLiteral("<articles>")));
  const auto xls = exporter.toSpreadsheetXml(articles);
  QVERIFY(xls.contains(QStringLiteral("Workbook")));
  QVERIFY(xls.contains(QStringLiteral("标题 &lt;测试&gt;")));
  QVERIFY(xls.contains(QStringLiteral("98.5")));
  QVERIFY(xls.contains(QStringLiteral("gh_test_001")));
  QVERIFY(xls.contains(QStringLiteral("原创")) || xls.contains(QStringLiteral("是")));
  QVERIFY(xls.contains(QStringLiteral("图文")));
}

void CoreTest::clientBuildsSearchPayload() {
  ContentDataClient client;
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
  ContentDataClient client;
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

void CoreTest::clientValidatesOfficialHotTypicalModel() {
  ContentDataClient client;
  HotTypicalRequest request;
  request.key = QStringLiteral("official-key");
  request.keyword = QStringLiteral("AI");
  request.pub_type = PubType::Repost;
  request.category = QStringLiteral("30");
  request.page = QStringLiteral("2");
  request.start_time = QStringLiteral("2025-08-15");
  request.end_time = QStringLiteral("2025-08-16");
  QString error;
  QVERIFY(client.validateHotTypicalRequest(request, &error));
  QCOMPARE(client.pubTypeToApiValue(PubType::TextImage), QStringLiteral("0"));
  QCOMPARE(client.pubTypeToApiValue(PubType::Video), QStringLiteral("5"));
  QCOMPARE(client.pubTypeToApiValue(PubType::Music), QStringLiteral("7"));
  QCOMPARE(client.pubTypeToApiValue(PubType::Image), QStringLiteral("8"));
  QCOMPARE(client.pubTypeToApiValue(PubType::Text), QStringLiteral("10"));
  QCOMPARE(client.pubTypeToApiValue(PubType::Repost), QStringLiteral("11"));
  QVERIFY(client.pubTypeFromApiValue(QStringLiteral("11")).has_value());
  QCOMPARE(client.pubTypeFromApiValue(QStringLiteral("11")).value(), PubType::Repost);
  QVERIFY(!client.pubTypeFromApiValue(QStringLiteral("9")).has_value());
  const auto payload = client.buildHotTypicalSearchPayload(request);
  QCOMPARE(payload.value("key").toString(), QStringLiteral("official-key"));
  QCOMPARE(payload.value("keyword").toString(), QStringLiteral("AI"));
  QCOMPARE(payload.value("pub_type").toString(), QStringLiteral("11"));
  QCOMPARE(payload.value("category").toString(), QStringLiteral("30"));
  QCOMPARE(payload.value("page").toString(), QStringLiteral("2"));
  QCOMPARE(payload.value("start_time").toString(), QStringLiteral("2025-08-15"));
  QCOMPARE(payload.value("end_time").toString(), QStringLiteral("2025-08-16"));
  request.keyword.reset();
  QVERIFY(!client.buildHotTypicalSearchPayload(request).contains("keyword"));
  request.category = QStringLiteral("31");
  QVERIFY(!client.validateHotTypicalRequest(request, &error));
  QVERIFY(error.contains(QStringLiteral("category")));
  request.category = QStringLiteral("0");
  request.page = QStringLiteral("0");
  QVERIFY(!client.validateHotTypicalRequest(request, &error));
  QVERIFY(error.contains(QStringLiteral("page")));
  request.page = QStringLiteral("1");
  request.start_time = QStringLiteral("2025-8-15");
  QVERIFY(!client.validateHotTypicalRequest(request, &error));
  QVERIFY(error.contains(QStringLiteral("start_time")));
}

void CoreTest::clientParsesOfficialHotTypicalResponseForVisualization() {
  ContentDataClient client;
  const QByteArray official = R"({"code":0,"msg":"success","note":"fee note","cost":0.4,"remain_money":9797.39,"total":28,"total_page":2,"data":[{"url":"https://example.com/hot","mp_nickname":"作者号","title":"爆文标题","pub_time":"2026-05-17","wxid":"wx123","hot":98.5,"read_num":120000,"zan_num":4500,"cover":"https://example.com/cover.jpg","avg":30000,"category":"科技","fans":900000,"position":1,"is_original":"是","publish_type":"图文"}]})";
  const auto parsed = client.parseArticlesFromJson(official, QStringLiteral("AI"));
  QCOMPARE(parsed.size(), 1);
  const auto& row = parsed.first();
  QCOMPARE(row.title, QStringLiteral("爆文标题"));
  QCOMPARE(row.accountName, QStringLiteral("作者号"));
  QCOMPARE(row.author, QStringLiteral("作者号"));
  QCOMPARE(row.url, QStringLiteral("https://example.com/hot"));
  QCOMPARE(row.publishTime, QStringLiteral("2026-05-17"));
  QCOMPARE(row.readCount, 120000);
  QCOMPARE(row.likeCount, 4500);
  QCOMPARE(row.avgReadCount, 30000);
  QCOMPARE(row.fansCount, 900000);
  QCOMPARE(row.position, 1);
  QCOMPARE(row.wxid, QStringLiteral("wx123"));
  QCOMPARE(row.category, QStringLiteral("科技"));
  QCOMPARE(row.isOriginal, QStringLiteral("是"));
  QCOMPARE(row.publishType, QStringLiteral("图文"));
  QCOMPARE(row.coverUrl, QStringLiteral("https://example.com/cover.jpg"));
  QCOMPARE(row.hotScore, 98.5);
  QVERIFY(row.summary.contains(QStringLiteral("爆值")));
}

void CoreTest::clientParsesHotTypicalEnvelopeRealData() {
  ContentDataClient client;
  const QByteArray official = R"({"code":0,"msg":"success","note":"本接口单条数据为0.02，本次共获取20条数据，共消费0.4！","cost":0.4,"remain_money":9797.39,"total":28,"total_page":2,"data":[{"url":"https://example.com/hot","mp_nickname":"作者号","title":"爆文标题","pub_time":"2026-05-17","wxid":"wx123","hot":98.5,"read_num":120000,"zan_num":4500,"cover":"https://example.com/cover.jpg","avg":30000,"category":"科技","fans":900000,"position":1,"is_original":"是","publish_type":"图文"}]})";
  const auto resp = client.parseHotTypicalResponse(official, QStringLiteral("AI"));
  QCOMPARE(resp.status, HotTypicalStatus::RealData);
  QCOMPARE(resp.code, 0);
  QCOMPARE(resp.cost, 0.4);
  QCOMPARE(resp.remain_money, 9797.39);
  QCOMPARE(resp.total, 28);
  QCOMPARE(resp.total_page, 2);
  QCOMPARE(resp.articles.size(), 1);
  QVERIFY(resp.isReal());
  QVERIFY(!resp.isSample());
  QVERIFY(resp.note.contains(QStringLiteral("消费")));
}

void CoreTest::clientParsesHotTypicalEnvelopeRealEmptyNeverFabricates() {
  ContentDataClient client;
  // code:0 但 data 为空 —— 真实空结果，绝不能伪造文章。
  const QByteArray empty = R"({"code":0,"msg":"success","note":"查询数据为空时默认算1条数据","cost":0.02,"remain_money":100.5,"total":0,"total_page":0,"data":[]})";
  const auto resp = client.parseHotTypicalResponse(empty, QStringLiteral("不存在的关键词"));
  QCOMPARE(resp.status, HotTypicalStatus::RealEmpty);
  QCOMPARE(resp.code, 0);
  QCOMPARE(resp.cost, 0.02);
  QCOMPARE(resp.remain_money, 100.5);
  QVERIFY(resp.articles.isEmpty());  // 关键：不补任何假数据 / never fabricated
  QVERIFY(resp.isReal());
  QVERIFY(!resp.isSample());
}

void CoreTest::clientParsesHotTypicalEnvelopeApiErrorNeverFabricates() {
  ContentDataClient client;
  // code!=0（余额不足等）—— 真实接口错误，绝不能用示例数据冒充。
  const QByteArray err = R"({"code":108,"msg":"余额不足，请充值","cost":0,"remain_money":0,"total":0,"total_page":0})";
  const auto resp = client.parseHotTypicalResponse(err, QStringLiteral("AI"));
  QCOMPARE(resp.status, HotTypicalStatus::ApiError);
  QCOMPARE(resp.code, 108);
  QVERIFY(resp.articles.isEmpty());  // 关键：错误时绝不伪造数据 / no fabrication on error
  QVERIFY(!resp.isReal());
  QVERIFY(!resp.isSample());
  QVERIFY(resp.msg.contains(QStringLiteral("余额不足")));
  QVERIFY(resp.error_text.contains(QStringLiteral("余额不足")));
}

void CoreTest::clientFetchHotTypicalUsesSampleOnlyWhenNoKey() {
  ContentDataClient client;
  // 未配置 key：唯一允许示例兜底的情形，且必须明确标记为 SampleFallback。
  const auto resp = client.fetchHotTypical(QString(), QString(), QStringLiteral("AI"), QStringLiteral("0"),
                                           QStringLiteral("7"), 1, QStringLiteral("2026-05-15"), QStringLiteral("2026-05-17"));
  QCOMPARE(resp.status, HotTypicalStatus::SampleFallback);
  QVERIFY(!resp.articles.isEmpty());  // 有示例数据 / has sample rows
  QVERIFY(resp.isSample());
  QVERIFY(!resp.isReal());  // 关键：示例数据绝不被当作真实数据 / sample never counted as real
}

void CoreTest::clientFetchHotTypicalValidationErrorDoesNotSpend() {
  ContentDataClient client;
  // 配置了 key 但参数非法（日期格式错误）—— 本地校验失败，绝不发请求烧钱。
  const auto resp = client.fetchHotTypical(QString(), QStringLiteral("JZLfaketestkey123"), QStringLiteral("AI"),
                                           QStringLiteral("0"), QStringLiteral("7"), 1,
                                           QStringLiteral("bad-date"), QStringLiteral("2026-05-17"));
  QCOMPARE(resp.status, HotTypicalStatus::ValidationError);
  QVERIFY(resp.articles.isEmpty());  // 不发请求、不返回数据 / no request, no data
  QVERIFY(!resp.isReal());
  QVERIFY(!resp.isSample());
  QVERIFY(!resp.error_text.isEmpty());
}

void CoreTest::appControllerExposesHotTypicalMetadata() {
  AppController controller;
  QVERIFY(controller.initialize());
  // 未配置 key 时跑采集 —— 应得到示例数据并通过元数据属性诚实暴露状态。
  controller.runHotTypicalCollection(QString(), QStringLiteral("AI"), QStringLiteral("0"), QStringLiteral("7"), 1,
                                     QStringLiteral("2026-05-15"), QStringLiteral("2026-05-17"));
  QVERIFY(controller.hotResultCount() > 0);
  QVERIFY(controller.hotIsSample());            // 明确标记为示例 / flagged as sample
  QVERIFY(!controller.hotIsReal());             // 关键：示例不冒充真实 / sample is not real
  QVERIFY(!controller.hotIsError());
  QVERIFY(!controller.hotStatus().isEmpty());
}

void CoreTest::appControllerCollectsHotTypicalAndExportsMultipleFormats() {
  QTemporaryDir dir;
  QVERIFY(dir.isValid());
  AppController controller;
  QVERIFY(controller.initialize());
  QCOMPARE(controller.language(), QStringLiteral("zh"));
  QVERIFY(controller.runHotTypicalCollection(QString(), QStringLiteral("AI"), QStringLiteral("0"), QStringLiteral("7"), 1,
                                             QStringLiteral("2026-05-15"), QStringLiteral("2026-05-17")) > 0);
  const auto rows = controller.hotTypicalResultRows();
  QVERIFY(!rows.isEmpty());
  QVERIFY(rows.join("\n").contains(QStringLiteral("AI")));
  QVERIFY(rows.join("\n").contains(QStringLiteral("原创")));
  QVERIFY(rows.join("\n").contains(QStringLiteral("图文")));
  QVERIFY(rows.first().split(QStringLiteral("｜")).size() >= 15);
  const QString md = dir.filePath(QStringLiteral("hot.md"));
  const QString xml = dir.filePath(QStringLiteral("hot.xml"));
  const QString xls = dir.filePath(QStringLiteral("hot.xls"));
  QVERIFY(controller.exportHotTypicalResults(md, QStringLiteral("md")));
  QVERIFY(controller.exportHotTypicalResults(xml, QStringLiteral("xml")));
  QVERIFY(controller.exportHotTypicalResults(xls, QStringLiteral("xls")));
  QVERIFY(QFile::exists(md));
  QVERIFY(QFile::exists(xml));
  QVERIFY(QFile::exists(xls));
  QFile xlsFile(xls);
  QVERIFY(xlsFile.open(QIODevice::ReadOnly | QIODevice::Text));
  QVERIFY(QString::fromUtf8(xlsFile.readAll()).contains(QStringLiteral("Workbook")));
}

void CoreTest::pluginRegistryExposesBuiltins() {
  BuiltinPluginRegistry registry;
  const auto plugins = registry.plugins();
  QVERIFY(plugins.contains(QStringLiteral("provider:content-data")));
  QVERIFY(plugins.contains(QStringLiteral("exporter:markdown")));
  QVERIFY(plugins.contains(QStringLiteral("exporter:xml")));
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

void CoreTest::pluginRegistryScansDynamicPluginsFailClosed() {
  QTemporaryDir dir;
  QVERIFY(dir.isValid());
  QDir root(dir.path());
  QVERIFY(root.mkpath("providers"));
  QVERIFY(root.mkpath("exporters"));
  QVERIFY(root.mkpath("analyzers"));
  QFile provider(root.filePath("providers/content-data-provider.json"));
  QVERIFY(provider.open(QIODevice::WriteOnly | QIODevice::Text));
  provider.write(R"({"id":"provider:demo","name":"Demo Provider","kind":"provider"})");
  provider.close();
  QFile invalid(root.filePath("analyzers/broken.json"));
  QVERIFY(invalid.open(QIODevice::WriteOnly | QIODevice::Text));
  invalid.write("not json");
  invalid.close();
  BuiltinPluginRegistry registry;
  const auto rows = registry.plugins(dir.path());
  QVERIFY(rows.contains(QStringLiteral("provider:content-data")));
  QVERIFY(rows.contains(QStringLiteral("provider:demo")));
  QVERIFY(registry.dynamicPluginScanReport(dir.path()).join("\n").contains(QStringLiteral("blocked")));
}

void CoreTest::clientClassifiesApiErrorsAndSupportsSmokePlan() {
  ContentDataClient client;
  QCOMPARE(client.classifyApiError(401, QString()), QStringLiteral("authentication_error"));
  QCOMPARE(client.classifyApiError(429, QString()), QStringLiteral("rate_limited"));
  QCOMPARE(client.classifyApiError(402, QStringLiteral("余额不足")), QStringLiteral("quota_or_balance_error"));
  QCOMPARE(client.classifyApiError(400, QStringLiteral("category")), QStringLiteral("parameter_error"));
  QCOMPARE(client.classifyApiError(500, QString()), QStringLiteral("server_error"));
  QCOMPARE(client.classifyApiError(-1, QStringLiteral("timeout")), QStringLiteral("network_timeout"));
  const QString plan = client.hotTypicalSmokePlan(QStringLiteral("[configured]"), QStringLiteral("AI"), QStringLiteral("0"), QStringLiteral("0"), 1, QStringLiteral("2025-08-15"), QStringLiteral("2025-08-16"));
  QVERIFY(plan.contains(QStringLiteral("hot_typical_search")));
  QVERIFY(plan.contains(QStringLiteral("multipart/form-data")));
  QVERIFY(!plan.contains(QStringLiteral("official-key")));
}

void CoreTest::appControllerExposesDatePickersAndAiExtensionSlot() {
  AppController controller;
  QVERIFY(controller.initialize());
  QVERIFY(controller.datePresetRows().join("\n").contains(QStringLiteral("Last 7 days")) || controller.datePresetRows().join("\n").contains(QStringLiteral("最近7天")));
  const auto range = controller.dateRangeForPreset(QStringLiteral("last_7_days"));
  QCOMPARE(range.size(), 2);
  QVERIFY(range.first().contains("-"));
  QVERIFY(controller.aiExtensionRows().join("\n").contains(QStringLiteral("disabled")) || controller.aiExtensionRows().join("\n").contains(QStringLiteral("未启用")));
  QVERIFY(controller.aiExtensionPayloadPreview(QStringLiteral("title"), QStringLiteral("summary")).contains(QStringLiteral("future_ai_extension")));
  controller.noteSelection(QStringLiteral("Article"), QStringLiteral("row-1"));
  QVERIFY(controller.status().contains(QStringLiteral("row-1")));
}

void CoreTest::appControllerExposesEndpointAndPluginRows() {
  ApiCatalog catalog;
  const auto endpoints = catalog.loadDefault();
  const auto mp = catalog.findByCategory(endpoints, QStringLiteral("公众号"));
  QVERIFY(!mp.isEmpty());
  QVERIFY(catalog.findByPath(endpoints, mp.first().path).path == mp.first().path);
  AppController controller;
  QVERIFY(controller.initialize());
  QVERIFY(!controller.apiEndpointRows(QStringLiteral("公众号")).isEmpty());
  QVERIFY(controller.pluginRows().join("\n").contains(QStringLiteral("analyzer:hit-score")));
  controller.loadMockArticles();
  QVERIFY(controller.pluginAnalysis().contains(QStringLiteral("爆款评分")));
  QVERIFY(controller.runFullSelfCheck(QDir::tempPath()));
  QVERIFY(!controller.runRows().isEmpty());
}

void CoreTest::appControllerClosesInteractiveDetailsAndExports() {
  QTemporaryDir dir;
  QVERIFY(dir.isValid());
  AppController controller;
  QVERIFY(controller.initialize());
  controller.loadMockArticles();
  const QString article_row = controller.articleRows(QStringLiteral("爆文")).value(0);
  QVERIFY(!article_row.isEmpty());
  QVERIFY(controller.articleDetail(article_row).contains(QStringLiteral("summary")));
  const QString endpoint_row = controller.apiEndpointRows(QStringLiteral("公众号")).value(0);
  QVERIFY(!endpoint_row.isEmpty());
  QVERIFY(controller.endpointPathFromRow(endpoint_row).startsWith(QStringLiteral("/")));
  QVERIFY(controller.runEndpointRow(endpoint_row, QStringLiteral("AI")) > 0);
  const QString plugin_row = controller.pluginRows().join("\n");
  QVERIFY(plugin_row.contains(QStringLiteral("exporter:markdown")));
  QVERIFY(controller.pluginDetail(QStringLiteral("exporter:markdown")).contains(QStringLiteral("Markdown")));
  QVERIFY(controller.pluginExportPreview(QStringLiteral("exporter:xml")).contains(QStringLiteral("<articles>")));
  QVERIFY(controller.pluginScanReport(QString()).contains(QStringLiteral("metadata")));
  const int task_id = controller.createCollectionTask(QStringLiteral("AI task"), QStringLiteral("AI"), 5, 2);
  QVERIFY(task_id > 0);
  const QString task_row = controller.taskRows().value(0);
  QVERIFY(controller.taskDetail(task_row).contains(QStringLiteral("AI task")));
  QVERIFY(controller.runTaskRow(task_row) > 0);
  const QString run_row = controller.runRows().value(0);
  QVERIFY(controller.runDetail(run_row).contains(QStringLiteral("Run receipt")) || controller.runDetail(run_row).contains(QStringLiteral("运行记录")));
  QVERIFY(controller.hotTypicalSmokePreview(QStringLiteral("[configured]"), QStringLiteral("AI"), QStringLiteral("0"), QStringLiteral("0"), 1, QStringLiteral("2026-05-01"), QStringLiteral("2026-05-02")).contains(QStringLiteral("preview_only")));
  const QString emotion_preview = controller.emotionRecentMonthCollectionPreview(30000, 50000, 20);
  QVERIFY(emotion_preview.contains(QStringLiteral("category=8")));
  QVERIFY(emotion_preview.contains(QStringLiteral("30000")));
  QVERIFY(controller.runEmotionRecentMonthCollection(QString(), 30000, 50000, 20) >= 0);
  QVERIFY(controller.hotNote().contains(QStringLiteral("read_num=30000..50000")) || controller.hotResultCount() == 0);
  const QString report_path = dir.filePath(QStringLiteral("report.md"));
  QVERIFY(controller.exportReport(report_path));
  QVERIFY(QFile::exists(report_path));
  QFile report(report_path);
  QVERIFY(report.open(QIODevice::ReadOnly | QIODevice::Text));
  QVERIFY(QString::fromUtf8(report.readAll()).contains(QStringLiteral("爆款评分")));
}

void CoreTest::clientBuildsEmotionRecentMonthCollectionPlan() {
  ContentDataClient client;
  const auto plan = client.buildEmotionRecentMonthCollectionPlan(QDate(2026, 6, 8), 30000, 50000, 20);
  QCOMPARE(plan.targetCount, 20);
  QCOMPARE(plan.minRead, 30000);
  QCOMPARE(plan.maxRead, 50000);
  QCOMPARE(plan.category, QStringLiteral("8"));
  QCOMPARE(plan.pubType, QStringLiteral("0"));
  QCOMPARE(plan.startTime, QStringLiteral("2026-05-08"));
  QCOMPARE(plan.endTime, QStringLiteral("2026-06-08"));
  QVERIFY(plan.keywords.contains(QStringLiteral("情感")));
  QVERIFY(plan.keywords.contains(QStringLiteral("婚姻")));
  QVERIFY(plan.keywords.contains(QStringLiteral("亲密关系")));
  QVERIFY(plan.maxScanCandidates >= 20);
  QVERIFY(plan.maxPagesPerKeyword >= 1);
  const QString summary = client.hotTypicalCollectionPlanSummary(plan);
  QVERIFY(summary.contains(QStringLiteral("30000")));
  QVERIFY(summary.contains(QStringLiteral("50000")));
  QVERIFY(summary.contains(QStringLiteral("category=8")));
  QVERIFY(summary.contains(QStringLiteral("2026-05-08")));
}

void CoreTest::clientFiltersHotTypicalArticlesByReadWindowAndLimit() {
  ContentDataClient client;
  QVector<Article> input;
  for (int i = 0; i < 25; ++i) {
    Article a;
    a.title = QStringLiteral("情感样本 %1").arg(i + 1);
    a.url = QStringLiteral("https://example.com/emotion/%1").arg(i + 1);
    a.category = i % 2 == 0 ? QStringLiteral("情感") : QStringLiteral("科技");
    a.publishTime = QStringLiteral("2026-05-%1").arg(QString::number(10 + (i % 10)).rightJustified(2, QLatin1Char('0')));
    a.readCount = 30000 + i * 1000;
    input.push_back(a);
  }
  Article low;
  low.title = QStringLiteral("低阅读");
  low.url = QStringLiteral("https://example.com/low");
  low.readCount = 29999;
  input.push_back(low);
  Article high;
  high.title = QStringLiteral("高阅读");
  high.url = QStringLiteral("https://example.com/high");
  high.readCount = 50001;
  input.push_back(high);
  Article duplicate = input.first();
  input.push_back(duplicate);

  const auto filtered = client.filterHotTypicalArticles(input, 30000, 50000, 20);
  QCOMPARE(filtered.size(), 20);
  QSet<QString> urls;
  for (const auto& a : filtered) {
    QVERIFY(a.readCount >= 30000);
    QVERIFY(a.readCount <= 50000);
    QVERIFY(!urls.contains(a.url));
    urls.insert(a.url);
  }
  QCOMPARE(filtered.first().readCount, 30000);
  QCOMPARE(filtered.last().readCount, 49000);
}

QTEST_MAIN(CoreTest)
#include "test_core.moc"
