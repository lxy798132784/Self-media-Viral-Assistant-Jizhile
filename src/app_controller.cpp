#include "app_controller.h"
#include <QCoreApplication>
#include <QDir>
#include <QFile>
#include <QStandardPaths>
#include <QThread>

AppController::AppController(QObject* parent) : QObject(parent) {}

QString AppController::status() const { return status_; }
int AppController::articleCount() const { return database_.articleCount(); }
int AppController::totalReads() const { return database_.totalReads(); }
int AppController::totalLikes() const { return database_.totalLikes(); }

bool AppController::initialize() {
  if (status_ != QStringLiteral("Ready")) {
    return true;
  }
  config_.load();
  const QString dir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
  QDir().mkpath(dir);
  if (!database_.open(dir + "/media-hit-assistant.sqlite")) {
    setStatus(QStringLiteral("数据库打开失败 / Database open failed"));
    return false;
  }
  if (!database_.initialize()) {
    setStatus(QStringLiteral("数据库初始化失败 / Database initialization failed"));
    return false;
  }
  setStatus(QStringLiteral("已就绪 / Ready"));
  emit dataChanged();
  return true;
}

void AppController::loadMockArticles() {
  Article a;
  a.title = QStringLiteral("10万+爆文标题：普通选题如何变成强共鸣内容");
  a.author = QStringLiteral("内容研究员");
  a.accountName = QStringLiteral("增长样本库");
  a.url = QStringLiteral("https://example.com/hit-article-1");
  a.publishTime = QStringLiteral("2026-06-03");
  a.readCount = 128000;
  a.likeCount = 5200;
  a.watchCount = 3100;
  a.summary = QStringLiteral("强情绪标题、明确人群、故事化开头、可转发结论。");
  database_.upsertArticle(a);

  Article b;
  b.title = QStringLiteral("公众号冷启动：7天搭建稳定选题库");
  b.author = QStringLiteral("运营助手");
  b.accountName = QStringLiteral("自媒体方法论");
  b.url = QStringLiteral("https://example.com/hit-article-2");
  b.publishTime = QStringLiteral("2026-06-02");
  b.readCount = 76000;
  b.likeCount = 2100;
  b.watchCount = 1300;
  b.summary = QStringLiteral("用历史爆文、实时搜一搜和评论高频词组合选题。");
  database_.upsertArticle(b);
  setStatus(QStringLiteral("已加载示例数据 / Mock articles loaded"));
  emit dataChanged();
}

QStringList AppController::articleRows(const QString& keyword) const {
  QStringList rows;
  for (const auto& a : database_.listArticles(keyword)) {
    rows << QStringLiteral("%1｜%2｜阅读 %3｜点赞 %4").arg(a.title, a.accountName).arg(a.readCount).arg(a.likeCount);
  }
  return rows;
}

QString AppController::generateReport() const {
  const auto rows = database_.listArticles();
  if (rows.isEmpty()) return QStringLiteral("暂无内容。请先加载示例数据或配置 API 后采集。\nNo content yet. Load mock data or configure API collection first.");
  QString report = QStringLiteral("# 拆解报告 / Analysis Report\n\n");
  for (const auto& a : rows) {
    const int score = a.readCount / 1000 + a.likeCount / 100;
    report += QStringLiteral("## %1\n- 账号：%2\n- 爆款评分：%3\n- 观察：%4\n\n").arg(a.title, a.accountName).arg(score).arg(a.summary);
  }
  return report;
}

QStringList AppController::recommendTopics() const {
  QStringList topics;
  const auto rows = database_.listArticlesSorted(QString(), QStringLiteral("likes"), 6);
  for (const auto& a : rows) {
    const QString base = a.title.left(28);
    topics << QStringLiteral("复盘：%1 的标题钩子、情绪承诺和转发理由").arg(base)
           << QStringLiteral("延展：面向 %1 读者的清单式解决方案").arg(a.accountName.isEmpty() ? QStringLiteral("目标") : a.accountName);
    if (topics.size() >= 8) break;
  }
  if (topics.isEmpty()) {
    topics << QStringLiteral("普通经验如何变成可复制方法论")
           << QStringLiteral("用评论区高频问题反推下一篇爆文")
           << QStringLiteral("热点事件 + 垂直人群 + 可执行清单")
           << QStringLiteral("失败案例复盘：为什么读者愿意转发");
  }
  return topics;
}

bool AppController::exportMarkdown(const QString& path) {
  const bool ok = export_service_.writeTextFile(path, export_service_.toMarkdown(database_.listArticles()));
  setStatus(ok ? QStringLiteral("Markdown 导出完成") : QStringLiteral("Markdown 导出失败"));
  return ok;
}

bool AppController::exportXml(const QString& path) {
  const bool ok = export_service_.writeTextFile(path, export_service_.toXml(database_.listArticles()));
  setStatus(ok ? QStringLiteral("XML 导出完成") : QStringLiteral("XML 导出失败"));
  return ok;
}

void AppController::saveSettings(const QString& apiKey, const QString& verifyCode, int intervalSeconds, int maxRuns, double qpsLimit) {
  config_.setApiKey(apiKey);
  config_.setVerifyCode(verifyCode);
  config_.setIntervalSeconds(intervalSeconds);
  config_.setMaxRuns(maxRuns);
  config_.setQpsLimit(qpsLimit);
  config_.save();
  setStatus(QStringLiteral("设置已保存 / Settings saved"));
}

int AppController::createCollectionTask(const QString& name, const QString& keyword, int intervalSeconds, int maxRuns) {
  CollectionTask task;
  task.name = name.trimmed().isEmpty() ? QStringLiteral("默认采集任务") : name.trimmed();
  task.keyword = keyword.trimmed().isEmpty() ? QStringLiteral("AI") : keyword.trimmed();
  task.endpointPath = QStringLiteral("/fbmain/monitor/v3/web_search");
  task.intervalSeconds = qMax(5, intervalSeconds);
  task.maxRuns = qMax(1, maxRuns);
  const int id = database_.saveTask(task);
  setStatus(id > 0 ? QStringLiteral("采集任务已保存") : QStringLiteral("采集任务保存失败"));
  emit dataChanged();
  return id;
}

int AppController::runMockCollection(const QString& keyword) {
  const QString task_keyword = keyword.trimmed().isEmpty() ? QStringLiteral("AI") : keyword.trimmed();
  int inserted = 0;
  for (const auto& article : client_.mockSearchArticles(task_keyword, 1)) {
    if (database_.upsertArticle(article)) ++inserted;
  }
  database_.recordCollectionRun(0, QStringLiteral("mock_success"), inserted, QStringLiteral("Mock fallback collection finished"));
  setStatus(QStringLiteral("采集完成：%1 条 / Collection finished: %1").arg(inserted));
  emit dataChanged();
  return inserted;
}

int AppController::runCollection(const QString& keyword) {
  const QString task_keyword = keyword.trimmed().isEmpty() ? QStringLiteral("AI") : keyword.trimmed();
  QString error;
  int inserted = 0;
  const int pages = qMax(1, config_.maxRuns());
  for (int page = 1; page <= pages; ++page) {
    const auto articles = client_.searchArticlesBlocking(QString(), config_.apiKey(), config_.verifyCode(), task_keyword, page, &error);
    for (const auto& article : articles) {
      if (database_.upsertArticle(article)) ++inserted;
    }
    const int wait_ms = config_.qpsLimit() > 0 ? static_cast<int>(1000.0 / config_.qpsLimit()) : 1000;
    if (page < pages) QThread::msleep(static_cast<unsigned long>(qBound(200, wait_ms, 5000)));
  }
  const QString status = client_.isConfigured(config_.apiKey()) ? QStringLiteral("success") : QStringLiteral("mock_fallback");
  database_.recordCollectionRun(0, status, inserted, error);
  setStatus(QStringLiteral("采集完成：%1 条 / Collection finished: %1").arg(inserted));
  emit dataChanged();
  return inserted;
}

int AppController::runEndpointCollection(const QString& endpointPath, const QString& keyword) {
  const QString path = endpointPath.trimmed().isEmpty() ? QStringLiteral("/fbmain/monitor/v3/web_search") : endpointPath.trimmed();
  const QString task_keyword = keyword.trimmed().isEmpty() ? QStringLiteral("AI") : keyword.trimmed();
  QString error;
  int inserted = 0;
  const auto articles = client_.callEndpointBlocking(QString(), path, config_.apiKey(), config_.verifyCode(), task_keyword, 1, &error);
  for (const auto& article : articles) {
    if (database_.upsertArticle(article)) ++inserted;
  }
  database_.recordCollectionRun(0, client_.isConfigured(config_.apiKey()) ? QStringLiteral("endpoint_success") : QStringLiteral("endpoint_mock_fallback"), inserted, path + QStringLiteral(" ") + error);
  setStatus(QStringLiteral("接口采集完成：%1 条").arg(inserted));
  emit dataChanged();
  return inserted;
}

QStringList AppController::apiEndpointRows(const QString& categoryKeyword) const {
  QStringList rows;
  const auto endpoints = api_catalog_.loadFromFile(QStringLiteral("/home/pi/dev/jizhilia-api-knowledge/api-index.json"));
  const auto filtered = api_catalog_.findByCategory(endpoints, categoryKeyword);
  for (const auto& e : filtered) {
    rows << QStringLiteral("%1｜%2｜%3").arg(e.category, e.title, e.path);
    if (rows.size() >= 80) break;
  }
  return rows;
}

QStringList AppController::pluginRows() const {
  return plugin_registry_.plugins();
}

QString AppController::pluginAnalysis() const {
  return plugin_registry_.analyze(database_.listArticles());
}

int AppController::runTaskById(int taskId) {
  for (const auto& task : database_.listTasks()) {
    if (task.id == taskId && task.enabled && task.currentRuns < task.maxRuns) {
      QString error;
      int inserted = 0;
      const auto articles = client_.searchArticlesBlocking(QString(), config_.apiKey(), config_.verifyCode(), task.keyword, task.currentRuns + 1, &error);
      for (const auto& article : articles) {
        if (database_.upsertArticle(article)) ++inserted;
      }
      database_.incrementTaskRun(taskId);
      database_.recordCollectionRun(taskId, client_.isConfigured(config_.apiKey()) ? QStringLiteral("success") : QStringLiteral("mock_fallback"), inserted, error);
      setStatus(QStringLiteral("任务 #%1 完成：%2 条").arg(taskId).arg(inserted));
      emit dataChanged();
      return inserted;
    }
  }
  setStatus(QStringLiteral("任务不可运行 / Task is not runnable"));
  return 0;
}

QStringList AppController::taskRows() const {
  QStringList rows;
  for (const auto& task : database_.listTasks()) {
    rows << QStringLiteral("#%1｜%2｜关键词 %3｜每 %4 秒｜%5 次")
      .arg(task.id).arg(task.name, task.keyword).arg(task.intervalSeconds).arg(task.maxRuns);
  }
  return rows;
}

QStringList AppController::runRows() const {
  return database_.runRows(80);
}

bool AppController::runFullSelfCheck(const QString& exportDir) {
  const QString dir = exportDir.trimmed().isEmpty() ? QDir::tempPath() : exportDir.trimmed();
  QDir().mkpath(dir);
  loadMockArticles();
  const int endpoint_inserted = runEndpointCollection(QStringLiteral("/fbmain/monitor/v3/web_search"), QStringLiteral("AI"));
  const bool md_ok = exportMarkdown(QDir(dir).filePath(QStringLiteral("media-hit-full-check.md")));
  const bool xml_ok = exportXml(QDir(dir).filePath(QStringLiteral("media-hit-full-check.xml")));
  const QString report_path = QDir(dir).filePath(QStringLiteral("media-hit-full-check-report.txt"));
  QFile report(report_path);
  const bool report_ok = report.open(QIODevice::WriteOnly | QIODevice::Text);
  if (report_ok) {
    report.write(generateReport().toUtf8());
    report.write("\n\n--- Plugin Analysis ---\n");
    report.write(pluginAnalysis().toUtf8());
    report.close();
  }
  const bool ok = endpoint_inserted > 0 && md_ok && xml_ok && report_ok && QFile::exists(report_path);
  setStatus(ok ? QStringLiteral("全流程自检完成") : QStringLiteral("全流程自检失败"));
  emit dataChanged();
  return ok;
}

void AppController::setStatus(const QString& status) {
  if (status_ == status) return;
  status_ = status;
  emit statusChanged();
}
