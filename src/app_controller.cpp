#include "app_controller.h"
#include <QCoreApplication>
#include <QDate>
#include <QDir>
#include <QFile>
#include <QJsonDocument>
#include <QJsonObject>
#include <QGuiApplication>
#include <QClipboard>
#include <QStandardPaths>
#include <QSet>
#include <QThread>

AppController::AppController(QObject* parent) : QObject(parent) {}

QString AppController::status() const { return status_; }
QString AppController::language() const { return language_; }
int AppController::articleCount() const { return database_.articleCount(); }
int AppController::totalReads() const { return database_.totalReads(); }
int AppController::totalLikes() const { return database_.totalLikes(); }

// 爆文采集元数据 getter：把最近一次响应信封暴露给 QML，供 UI 诚实展示。
// Hot-article metadata getters: expose the last response envelope to QML for honest display.
QString AppController::hotStatus() const {
  switch (hot_typical_response_.status) {
    case HotTypicalStatus::RealData: return language_ == QStringLiteral("en") ? QStringLiteral("Real data") : QStringLiteral("真实数据");
    case HotTypicalStatus::RealEmpty: return language_ == QStringLiteral("en") ? QStringLiteral("Empty result") : QStringLiteral("空结果");
    case HotTypicalStatus::ApiError: return language_ == QStringLiteral("en") ? QStringLiteral("API error") : QStringLiteral("接口错误");
    case HotTypicalStatus::NetworkError: return language_ == QStringLiteral("en") ? QStringLiteral("Network error") : QStringLiteral("网络错误");
    case HotTypicalStatus::ValidationError: return language_ == QStringLiteral("en") ? QStringLiteral("Invalid params") : QStringLiteral("参数错误");
    case HotTypicalStatus::SampleFallback: return language_ == QStringLiteral("en") ? QStringLiteral("Sample data") : QStringLiteral("示例数据");
  }
  return QStringLiteral("-");
}
QString AppController::hotMessage() const { return hot_typical_response_.msg; }
QString AppController::hotNote() const { return hot_typical_response_.note; }
double AppController::hotCost() const { return hot_typical_response_.cost; }
double AppController::hotRemainMoney() const { return hot_typical_response_.remain_money; }
int AppController::hotTotal() const { return hot_typical_response_.total; }
int AppController::hotTotalPage() const { return hot_typical_response_.total_page; }
int AppController::hotResultCount() const { return hot_typical_results_.size(); }
bool AppController::hotIsReal() const { return hot_typical_response_.isReal(); }
bool AppController::hotIsSample() const { return hot_typical_response_.isSample(); }
bool AppController::hotIsError() const {
  return hot_typical_response_.status == HotTypicalStatus::ApiError ||
         hot_typical_response_.status == HotTypicalStatus::NetworkError ||
         hot_typical_response_.status == HotTypicalStatus::ValidationError;
}

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

void AppController::setLanguage(const QString& language) {
  const QString normalized = language.toLower().startsWith(QStringLiteral("en")) ? QStringLiteral("en") : QStringLiteral("zh");
  if (language_ == normalized) return;
  language_ = normalized;
  emit languageChanged();
}

QString AppController::trText(const QString& key) const {
  const bool en = language_ == QStringLiteral("en");
  if (key == QStringLiteral("app_title")) return en ? QStringLiteral("Media Hit Assistant") : QStringLiteral("自媒体爆款助手");
  if (key == QStringLiteral("subtitle")) return en ? QStringLiteral("Official account content intelligence workspace") : QStringLiteral("公众号内容情报工作台");
  if (key == QStringLiteral("dashboard_title")) return en ? QStringLiteral("Dashboard") : QStringLiteral("仪表盘");
  if (key == QStringLiteral("library_title")) return en ? QStringLiteral("Content Library") : QStringLiteral("内容库");
  if (key == QStringLiteral("hot_api_title")) return en ? QStringLiteral("Hot Collection") : QStringLiteral("爆文采集");
  if (key == QStringLiteral("hot_results_title")) return en ? QStringLiteral("Parsed Results") : QStringLiteral("解析结果表");
  if (key == QStringLiteral("report_title")) return en ? QStringLiteral("Analysis Report") : QStringLiteral("拆解报告");
  if (key == QStringLiteral("topics_title")) return en ? QStringLiteral("Topic Recommendations") : QStringLiteral("选题推荐");
  if (key == QStringLiteral("plugins_title")) return en ? QStringLiteral("Plugins") : QStringLiteral("插件");
  if (key == QStringLiteral("api_browser_title")) return en ? QStringLiteral("API Endpoints") : QStringLiteral("接口浏览器");
  if (key == QStringLiteral("runs_title")) return en ? QStringLiteral("Run History") : QStringLiteral("运行历史");
  if (key == QStringLiteral("settings_title")) return en ? QStringLiteral("Settings") : QStringLiteral("设置");
  if (key == QStringLiteral("run_endpoint")) return en ? QStringLiteral("Run selected endpoint") : QStringLiteral("运行选中接口");
  if (key == QStringLiteral("run_task")) return en ? QStringLiteral("Run selected task") : QStringLiteral("运行选中任务");
  if (key == QStringLiteral("refresh_runs")) return en ? QStringLiteral("Refresh history") : QStringLiteral("刷新历史");
  if (key == QStringLiteral("load_samples")) return en ? QStringLiteral("Load sample data") : QStringLiteral("加载示例数据");
  if (key == QStringLiteral("self_check")) return en ? QStringLiteral("Status") : QStringLiteral("状态");
  if (key == QStringLiteral("collect_now")) return en ? QStringLiteral("Collect now") : QStringLiteral("立即采集");
  if (key == QStringLiteral("preview_payload")) return en ? QStringLiteral("Generate request preview") : QStringLiteral("生成请求预览");
  if (key == QStringLiteral("collect_hot")) return en ? QStringLiteral("Collect hot articles") : QStringLiteral("采集公众号爆文");
  return key;
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
  a.hotScore = 96.8;
  a.avgReadCount = 64000;
  a.fansCount = 380000;
  a.position = 1;
  a.wxid = QStringLiteral("gh_mock_growth_001");
  a.category = QStringLiteral("科技");
  a.isOriginal = QStringLiteral("原创");
  a.publishType = QStringLiteral("图文");
  a.coverUrl = QStringLiteral("mock://cover/hit-article-1");
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
  b.hotScore = 82.4;
  b.avgReadCount = 38000;
  b.fansCount = 160000;
  b.position = 2;
  b.wxid = QStringLiteral("gh_mock_method_002");
  b.category = QStringLiteral("职场");
  b.isOriginal = QStringLiteral("非原创");
  b.publishType = QStringLiteral("转载");
  b.coverUrl = QStringLiteral("mock://cover/hit-article-2");
  b.summary = QStringLiteral("用历史爆文、实时搜一搜和评论高频词组合选题。");
  database_.upsertArticle(b);
  setStatus(QStringLiteral("已加载示例数据 / Mock articles loaded"));
  emit dataChanged();
}

QStringList AppController::articleRows(const QString& keyword) const {
  QStringList rows;
  for (const auto& a : database_.listArticles(keyword)) {
    rows << QStringLiteral("%1｜%2｜阅读 %3｜点赞 %4｜爆值 %5｜%6｜%7｜位置 %8")
                .arg(a.title, a.accountName).arg(a.readCount).arg(a.likeCount)
                .arg(a.hotScore, 0, 'f', 1)
                .arg(a.category.isEmpty() ? QStringLiteral("未分类") : a.category,
                     a.publishType.isEmpty() ? QStringLiteral("未知类型") : a.publishType)
                .arg(a.position);
  }
  return rows;
}

QString AppController::generateReport() const {
  const auto rows = database_.listArticles();
  if (rows.isEmpty()) return QStringLiteral("暂无内容。请先加载示例数据或配置 API 后采集。\nNo content yet. Load mock data or configure API collection first.");
  QString report = QStringLiteral("# 拆解报告 / Analysis Report\n\n");
  for (const auto& a : rows) {
    const int score = a.readCount / 1000 + a.likeCount / 100;
    report += QStringLiteral("## %1\n- 账号：%2\n- 爆款评分：%3\n- API 字段：爆值 %4；分类 %5；类型 %6；原创 %7；发文位置 %8；均读 %9；粉丝 %10\n- 观察：%11\n\n")
                  .arg(a.title, a.accountName).arg(score).arg(a.hotScore, 0, 'f', 1)
                  .arg(a.category, a.publishType, a.isOriginal).arg(a.position).arg(a.avgReadCount).arg(a.fansCount).arg(a.summary);
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

QStringList AppController::hotTypicalParameterRows() const {
  if (language_ == QStringLiteral("en")) {
    return {
          QStringLiteral("API key | required | string"),
          QStringLiteral("Keyword | optional | string"),
          QStringLiteral("Content type | required | 0/5/7/8/10/11"),
          QStringLiteral("Category | required | 0..30"),
          QStringLiteral("Page | required | string, >= 1"),
          QStringLiteral("Start date | required | YYYY-MM-DD"),
          QStringLiteral("End date | required | YYYY-MM-DD")};
  }
  return {
      QStringLiteral("key｜必填｜字符串｜内容数据 key"),
      QStringLiteral("keyword｜可选｜字符串｜关键词，为空搜索全部"),
      QStringLiteral("pub_type｜必填｜枚举｜0 图文，5 纯视频，7 纯音乐，8 纯图片，10 纯文字，11 转载文章"),
      QStringLiteral("category｜必填｜枚举｜0 全部，1 国际，2 体育，3 娱乐，4 社会，5 财经，6 时事，7 科技，8 情感，9 汽车，10 教育，11 时尚，12 游戏，13 军事，14 旅游，15 美食，16 文化，17 健康，18 搞笑，19 家居，20 动漫，21 宠物，22 母婴，23 星座，24 历史，25 音乐，26 未分类，27 综合，28 职场，29 三农，30 养老"),
      QStringLiteral("page｜必填｜字符串｜翻页参数，第一页为 1"),
      QStringLiteral("start_time｜必填｜日期｜开始日期 YYYY-MM-DD"),
      QStringLiteral("end_time｜必填｜日期｜截止日期 YYYY-MM-DD")};
}

QString AppController::hotTypicalPayloadPreview(const QString& apiKey, const QString& keyword, const QString& pubType,
                                                const QString& category, int page, const QString& startTime,
                                                const QString& endTime) const {
  QJsonObject root;
  root["method"] = QStringLiteral("POST");
  root["path"] = QStringLiteral("/fbmain/monitor/v3/hot_typical_search");
  root["content_type"] = QStringLiteral("multipart/form-data");
  root["payload"] = client_.buildHotTypicalSearchPayload(apiKey, keyword, pubType, category, page, startTime, endTime);
  return QString::fromUtf8(QJsonDocument(root).toJson(QJsonDocument::Indented));
}

QStringList AppController::datePresetRows() const {
  if (language_ == QStringLiteral("en")) {
    return {QStringLiteral("Last 7 days"), QStringLiteral("Last 30 days"), QStringLiteral("This month"), QStringLiteral("Custom range")};
  }
  return {QStringLiteral("最近7天"), QStringLiteral("最近30天"), QStringLiteral("本月"), QStringLiteral("自定义范围")};
}

QStringList AppController::dateRangeForPreset(const QString& preset) const {
  const QString p = preset.trimmed().toLower();
  const QDate today = QDate::currentDate();
  QDate start = today.addDays(-6);
  QDate end = today;
  if (p == QStringLiteral("last_30_days")) {
    start = today.addDays(-29);
  } else if (p == QStringLiteral("this_month")) {
    start = QDate(today.year(), today.month(), 1);
  }
  return {start.toString(Qt::ISODate), end.toString(Qt::ISODate)};
}

QStringList AppController::aiExtensionRows() const {
  if (language_ == QStringLiteral("en")) {
    return {QStringLiteral("AI extension slot: disabled for now"), QStringLiteral("Reserved inputs: title, summary, tags, angle"),
            QStringLiteral("Future outputs: topic scoring, rewrite, headline variants")};
  }
  return {QStringLiteral("AI 扩展位：当前未启用"), QStringLiteral("预留输入：标题、摘要、标签、角度"),
          QStringLiteral("未来输出：选题评分、改写、标题变体")};
}

QString AppController::aiExtensionPayloadPreview(const QString& title, const QString& summary) const {
  QJsonObject root;
  root["status"] = QStringLiteral("disabled");
  root["future_ai_extension"] = QStringLiteral("reserved");
  root["title"] = title;
  root["summary"] = summary;
  return QString::fromUtf8(QJsonDocument(root).toJson(QJsonDocument::Indented));
}

int AppController::runHotTypicalCollection(const QString& apiKey, const QString& keyword, const QString& pubType,
                                           const QString& category, int page, const QString& startTime,
                                           const QString& endTime) {

  const QString task_keyword = keyword.trimmed().isEmpty() ? QStringLiteral("公众号") : keyword.trimmed();
  const QString key = apiKey.trimmed().isEmpty() ? config_.apiKey() : apiKey.trimmed();
  // 走诚实信封路径：真实 key 的空结果/错误绝不伪造数据，仅未配置 key 才用示例。
  // Honest envelope path: a configured key never fabricates data; samples only when key is absent.
  const HotTypicalResponse response =
      client_.fetchHotTypical(QString(), key, task_keyword, pubType, category, qMax(1, page), startTime, endTime);
  hot_typical_response_ = response;
  hot_typical_results_ = response.articles;

  int inserted = 0;
  // 仅当数据真实或为示例时入库；接口错误/网络错误/参数错误不污染数据库。
  // Persist only real or sample data; errors must not pollute the database.
  if (response.status == HotTypicalStatus::RealData ||
      response.status == HotTypicalStatus::RealEmpty ||
      response.status == HotTypicalStatus::SampleFallback) {
    for (const auto& article : response.articles) {
      if (database_.upsertArticle(article)) ++inserted;
    }
  }

  // 记录运行状态：状态码 + 花费 + 余额 + 总数，便于审计与成本追踪。
  // Record run status with code/cost/balance/total for audit and cost tracking.
  const QString params = hotTypicalPayloadPreview(key.isEmpty() ? QStringLiteral("[empty]") : QStringLiteral("[configured]"),
                                                  task_keyword, pubType, category, qMax(1, page), startTime, endTime);
  QString run_status;
  switch (response.status) {
    case HotTypicalStatus::RealData: run_status = QStringLiteral("hot_typical_real_data"); break;
    case HotTypicalStatus::RealEmpty: run_status = QStringLiteral("hot_typical_real_empty"); break;
    case HotTypicalStatus::ApiError: run_status = QStringLiteral("hot_typical_api_error"); break;
    case HotTypicalStatus::NetworkError: run_status = QStringLiteral("hot_typical_network_error"); break;
    case HotTypicalStatus::ValidationError: run_status = QStringLiteral("hot_typical_validation_error"); break;
    case HotTypicalStatus::SampleFallback: run_status = QStringLiteral("hot_typical_sample_fallback"); break;
  }
  const QString run_note = QStringLiteral("status=%1 code=%2 cost=%3 remain=%4 total=%5 msg=%6")
                               .arg(run_status).arg(response.code)
                               .arg(response.cost, 0, 'f', 2).arg(response.remain_money, 0, 'f', 2)
                               .arg(response.total).arg(response.msg);
  database_.recordCollectionRun(0, run_status, inserted, params.left(400) + QStringLiteral(" ") + run_note);

  // UI 状态行：诚实呈现是真实数据、空结果、示例还是错误。
  // UI status line: honestly state real / empty / sample / error.
  QString ui_status;
  switch (response.status) {
    case HotTypicalStatus::RealData:
      ui_status = QStringLiteral("爆文采集完成：%1 条真实数据（花费 ¥%2，余额 ¥%3，共 %4 条 / %5 页）")
                      .arg(inserted).arg(response.cost, 0, 'f', 2).arg(response.remain_money, 0, 'f', 2)
                      .arg(response.total).arg(response.total_page);
      break;
    case HotTypicalStatus::RealEmpty:
      ui_status = QStringLiteral("查询成功但无结果（花费 ¥%1，余额 ¥%2）。这是真实空结果，未补任何示例数据。")
                      .arg(response.cost, 0, 'f', 2).arg(response.remain_money, 0, 'f', 2);
      break;
    case HotTypicalStatus::ApiError:
      ui_status = QStringLiteral("接口错误（code=%1）：%2").arg(response.code).arg(response.msg);
      break;
    case HotTypicalStatus::NetworkError:
      ui_status = QStringLiteral("网络错误：%1").arg(response.error_text);
      break;
    case HotTypicalStatus::ValidationError:
      ui_status = QStringLiteral("参数校验失败：%1").arg(response.error_text);
      break;
    case HotTypicalStatus::SampleFallback:
      ui_status = QStringLiteral("未配置 API Key，展示 %1 条本地示例数据（非真实采集）。").arg(inserted);
      break;
  }
  setStatus(ui_status);
  emit hotResultChanged();
  emit dataChanged();
  return inserted;
}

QStringList AppController::hotTypicalResultRows() const {
  QStringList rows;
  for (const auto& a : hot_typical_results_) {
    // 顺序对齐官方文档返回字段：title/mp_nickname/pub_time/hot/read_num/zan_num/avg/fans/category/
    // position/is_original/publish_type/wxid/cover/url。QML 通过同一顺序渲染完整解析结果表。
    rows << QStringLiteral("%1｜%2｜%3｜%4｜%5｜%6｜%7｜%8｜%9｜%10｜%11｜%12｜%13｜%14｜%15")
              .arg(a.title, a.accountName.isEmpty() ? a.author : a.accountName, a.publishTime)
              .arg(a.hotScore, 0, 'f', 1).arg(a.readCount).arg(a.likeCount).arg(a.avgReadCount).arg(a.fansCount)
              .arg(a.category, QString::number(a.position), a.isOriginal, a.publishType, a.wxid, a.coverUrl, a.url);
  }
  return rows;
}

bool AppController::exportHotTypicalResults(const QString& path, const QString& format) {
  QVector<Article> rows = hot_typical_results_.isEmpty() ? database_.listArticles() : hot_typical_results_;
  const QString f = format.trimmed().toLower();
  QString content;
  if (f == QStringLiteral("xml")) content = export_service_.toXml(rows);
  else if (f == QStringLiteral("xls") || f == QStringLiteral("xlsx") || f == QStringLiteral("excel")) content = export_service_.toSpreadsheetXml(rows);
  else content = export_service_.toMarkdown(rows);
  const bool ok = export_service_.writeTextFile(path, content);
  setStatus(ok ? QStringLiteral("爆文结果导出完成") : QStringLiteral("爆文结果导出失败"));
  return ok;
}

QStringList AppController::apiEndpointRows(const QString& categoryKeyword) const {
  QStringList rows;
  const auto endpoints = api_catalog_.loadDefault();
  const auto filtered = api_catalog_.findByCategory(endpoints, categoryKeyword);
  for (const auto& e : filtered) {
    rows << QStringLiteral("%1｜%2｜%3").arg(e.category, e.title, e.path);
    if (rows.size() >= 80) break;
  }
  return rows;
}

QStringList AppController::pluginRows() const {
  return plugin_registry_.pluginDescriptors(QStringLiteral("plugins"));
}


QString AppController::endpointPathFromRow(const QString& endpointRow) const {
  const QStringList parts = endpointRow.split(QStringLiteral("｜"));
  return parts.isEmpty() ? QString() : parts.last().trimmed();
}

int AppController::runEndpointRow(const QString& endpointRow, const QString& keyword) {
  const QString path = endpointPathFromRow(endpointRow);
  return runEndpointCollection(path, keyword);
}

QString AppController::articleDetail(const QString& articleRow) const {
  const QString title = articleRow.split(QStringLiteral("｜")).value(0).trimmed();
  for (const auto& a : database_.listArticles()) {
    if (a.title == title || articleRow.contains(a.title)) {
      QJsonObject root;
      root["title"] = a.title;
      root["account"] = a.accountName;
      root["author"] = a.author;
      root["url"] = a.url;
      root["publish_time"] = a.publishTime;
      root["hot_score"] = a.hotScore;
      root["reads"] = a.readCount;
      root["likes"] = a.likeCount;
      root["watches"] = a.watchCount;
      root["avg_read_count"] = a.avgReadCount;
      root["fans_count"] = a.fansCount;
      root["position"] = a.position;
      root["wxid"] = a.wxid;
      root["category"] = a.category;
      root["is_original"] = a.isOriginal;
      root["publish_type"] = a.publishType;
      root["cover_url"] = a.coverUrl;
      root["summary"] = a.summary;
      return QString::fromUtf8(QJsonDocument(root).toJson(QJsonDocument::Indented));
    }
  }
  return QStringLiteral("未找到内容详情 / Article detail not found: %1").arg(articleRow);
}

QString AppController::pluginDetail(const QString& pluginIdOrRow) const {
  const QString id = pluginIdOrRow.split(QStringLiteral("｜")).value(0).trimmed();
  return plugin_registry_.pluginDescriptor(id.isEmpty() ? pluginIdOrRow : id, QStringLiteral("plugins"));
}

QString AppController::pluginScanReport(const QString& pluginDir) const {
  const QString dir = pluginDir.trimmed().isEmpty() ? QStringLiteral("plugins") : pluginDir.trimmed();
  QStringList rows = plugin_registry_.dynamicPluginHints(dir);
  rows << plugin_registry_.dynamicPluginScanReport(dir);
  return rows.join(QStringLiteral("\n"));
}

QString AppController::pluginExportPreview(const QString& pluginIdOrRow) const {
  const QString id = pluginIdOrRow.split(QStringLiteral("｜")).value(0).trimmed();
  return plugin_registry_.exportByPlugin(id, database_.listArticles()).left(2000);
}

QString AppController::taskDetail(const QString& taskRow) const {
  const int id = taskRow.section(QStringLiteral("｜"), 0, 0).remove(QStringLiteral("#")).toInt();
  for (const auto& task : database_.listTasks()) {
    if (task.id == id) {
      QJsonObject root;
      root["id"] = task.id;
      root["name"] = task.name;
      root["keyword"] = task.keyword;
      root["endpoint"] = task.endpointPath;
      root["interval_seconds"] = task.intervalSeconds;
      root["max_runs"] = task.maxRuns;
      root["current_runs"] = task.currentRuns;
      root["enabled"] = task.enabled;
      return QString::fromUtf8(QJsonDocument(root).toJson(QJsonDocument::Indented));
    }
  }
  return QStringLiteral("未找到任务详情 / Task detail not found: %1").arg(taskRow);
}

int AppController::runTaskRow(const QString& taskRow) {
  const int id = taskRow.section(QStringLiteral("｜"), 0, 0).remove(QStringLiteral("#")).toInt();
  return runTaskById(id);
}

QString AppController::runDetail(const QString& runRow) const {
  return QStringLiteral("运行记录 / Run receipt\n%1").arg(runRow.trimmed().isEmpty() ? QStringLiteral("[empty]") : runRow.trimmed());
}

QString AppController::hotTypicalSmokePreview(const QString& apiKey, const QString& keyword, const QString& pubType,
                                              const QString& category, int page, const QString& startTime,
                                              const QString& endTime) const {
  return client_.hotTypicalSmokePlan(apiKey, keyword, pubType, category, page, startTime, endTime);
}

QString AppController::emotionRecentMonthCollectionPreview(int minRead, int maxRead, int targetCount) const {
  const auto plan = client_.buildEmotionRecentMonthCollectionPlan(QDate::currentDate(), minRead, maxRead, targetCount);
  return client_.hotTypicalCollectionPlanSummary(plan);
}

int AppController::runEmotionRecentMonthCollection(const QString& apiKey, int minRead, int maxRead, int targetCount) {
  const auto plan = client_.buildEmotionRecentMonthCollectionPlan(QDate::currentDate(), minRead, maxRead, targetCount);
  return runTargetedHotTypicalCollection(apiKey, plan.keywords.join(QStringLiteral(",")), plan.pubType, plan.category,
                                         plan.startTime, plan.endTime, plan.minRead, plan.maxRead, plan.targetCount,
                                         plan.maxPagesPerKeyword, plan.maxScanCandidates);
}

QString AppController::targetedHotTypicalCollectionPreview(const QString& keywords, const QString& pubType,
                                                           const QString& category, const QString& startTime,
                                                           const QString& endTime, int minRead, int maxRead,
                                                           int targetCount, int maxPagesPerKeyword,
                                                           int maxScanCandidates) const {
  const auto plan = client_.buildHotTypicalCollectionPlan(keywords, pubType, category, startTime, endTime, minRead,
                                                          maxRead, targetCount, maxPagesPerKeyword, maxScanCandidates);
  return client_.hotTypicalCollectionPlanSummary(plan);
}

int AppController::runTargetedHotTypicalCollection(const QString& apiKey, const QString& keywords,
                                                   const QString& pubType, const QString& category,
                                                   const QString& startTime, const QString& endTime,
                                                   int minRead, int maxRead, int targetCount,
                                                   int maxPagesPerKeyword, int maxScanCandidates) {
  const auto plan = client_.buildHotTypicalCollectionPlan(keywords, pubType, category, startTime, endTime, minRead,
                                                          maxRead, targetCount, maxPagesPerKeyword, maxScanCandidates);
  const QString key = apiKey.trimmed().isEmpty() ? config_.apiKey() : apiKey.trimmed();
  QVector<Article> accepted;
  QSet<QString> seen;
  int scanned = 0;
  double total_cost = 0.0;
  double remain_money = 0.0;
  QStringList notes;
  HotTypicalStatus final_status = HotTypicalStatus::RealEmpty;

  for (const QString& keyword : plan.keywords) {
    if (accepted.size() >= plan.targetCount || scanned >= plan.maxScanCandidates) break;
    for (int page = 1; page <= plan.maxPagesPerKeyword; ++page) {
      if (accepted.size() >= plan.targetCount || scanned >= plan.maxScanCandidates) break;
      const HotTypicalResponse response = client_.fetchHotTypical(QString(), key, keyword, plan.pubType, plan.category,
                                                                  page, plan.startTime, plan.endTime);
      final_status = response.status;
      total_cost += response.cost;
      remain_money = response.remain_money;
      notes << QStringLiteral("keyword=%1 page=%2 status=%3 rows=%4 cost=%5 msg=%6")
                   .arg(keyword).arg(page).arg(static_cast<int>(response.status)).arg(response.articles.size())
                   .arg(response.cost, 0, 'f', 2).arg(response.msg);

      if (response.status == HotTypicalStatus::ApiError || response.status == HotTypicalStatus::NetworkError ||
          response.status == HotTypicalStatus::ValidationError) {
        hot_typical_response_ = response;
        hot_typical_results_ = accepted;
        database_.recordCollectionRun(0, QStringLiteral("emotion_collection_error"), accepted.size(),
                                      client_.hotTypicalCollectionPlanSummary(plan).left(300) + QStringLiteral(" ") + notes.join(QStringLiteral(" | ")).left(900));
        setStatus(QStringLiteral("情感定向采集停止：接口/网络/参数错误，已保留 %1 条合格结果；%2")
                      .arg(accepted.size()).arg(response.msg.isEmpty() ? response.error_text : response.msg));
        emit hotResultChanged();
        emit dataChanged();
        return accepted.size();
      }

      ++scanned;
      const auto filtered = client_.filterHotTypicalArticles(response.articles, plan.minRead, plan.maxRead,
                                                            plan.targetCount - accepted.size());
      for (const auto& article : filtered) {
        const QString id = article.url.trimmed().isEmpty() ? article.title.trimmed() : article.url.trimmed();
        if (!id.isEmpty() && seen.contains(id)) continue;
        if (!id.isEmpty()) seen.insert(id);
        accepted.push_back(article);
        if (accepted.size() >= plan.targetCount) break;
      }
    }
  }

  hot_typical_results_ = accepted;
  hot_typical_response_ = HotTypicalResponse{};
  hot_typical_response_.status = accepted.isEmpty() ? final_status : (key.trimmed().isEmpty() ? HotTypicalStatus::SampleFallback : HotTypicalStatus::RealData);
  hot_typical_response_.code = 0;
  hot_typical_response_.msg = QStringLiteral("情感定向采集完成：目标%1，合格%2，扫描请求%3").arg(plan.targetCount).arg(accepted.size()).arg(scanned);
  hot_typical_response_.note = QStringLiteral("接口筛选 category=8/pub_type=0/time/keyword，本地过滤 read_num=%1..%2；%3")
                                   .arg(plan.minRead).arg(plan.maxRead).arg(notes.join(QStringLiteral(" | ")).left(1200));
  hot_typical_response_.cost = total_cost;
  hot_typical_response_.remain_money = remain_money;
  hot_typical_response_.total = accepted.size();
  hot_typical_response_.total_page = scanned;

  int inserted = 0;
  for (const auto& article : accepted) {
    if (database_.upsertArticle(article)) ++inserted;
  }
  const QString run_status = accepted.size() >= plan.targetCount ? QStringLiteral("emotion_collection_target_met")
                                                                 : QStringLiteral("emotion_collection_partial");
  database_.recordCollectionRun(0, run_status, inserted,
                                client_.hotTypicalCollectionPlanSummary(plan).left(300) + QStringLiteral(" ") + hot_typical_response_.note.left(900));
  setStatus(QStringLiteral("情感定向采集完成：入库 %1 条，合格 %2/%3，扫描请求 %4，花费 ¥%5")
                .arg(inserted).arg(accepted.size()).arg(plan.targetCount).arg(scanned).arg(total_cost, 0, 'f', 2));
  emit hotResultChanged();
  emit dataChanged();
  return inserted;
}

bool AppController::exportReport(const QString& path) {
  const QString target = path.trimmed().isEmpty() ? QDir(QDir::tempPath()).filePath(QStringLiteral("media-hit-report.md")) : path.trimmed();
  const QString content = generateReport() + QStringLiteral("\n\n---\n") + pluginAnalysis();
  const bool ok = export_service_.writeTextFile(target, content);
  setStatus(ok ? QStringLiteral("报告导出完成：%1").arg(target) : QStringLiteral("报告导出失败：%1").arg(target));
  return ok;
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
  const bool report_export_ok = exportReport(QDir(dir).filePath(QStringLiteral("media-hit-full-check-combined-report.md")));
  const QString report_path = QDir(dir).filePath(QStringLiteral("media-hit-full-check-report.txt"));
  QFile report(report_path);
  const bool report_ok = report.open(QIODevice::WriteOnly | QIODevice::Text);
  if (report_ok) {
    report.write(generateReport().toUtf8());
    report.write("\n\n--- Plugin Analysis ---\n");
    report.write(pluginAnalysis().toUtf8());
    report.close();
  }
  const bool ok = endpoint_inserted > 0 && md_ok && xml_ok && report_export_ok && report_ok && QFile::exists(report_path);
  setStatus(ok ? QStringLiteral("检查完成") : QStringLiteral("检查失败"));
  emit dataChanged();
  return ok;
}

void AppController::noteSelection(const QString& area, const QString& value) {
  const QString clean_area = area.trimmed().isEmpty() ? QStringLiteral("unknown") : area.trimmed();
  const QString clean_value = value.trimmed().isEmpty() ? QStringLiteral("[empty]") : value.trimmed();
  setStatus(QStringLiteral("%1 已选中：%2 / Selected: %2").arg(clean_area, clean_value));
}

bool AppController::copyTextToClipboard(const QString& text) {
  auto* clipboard = QGuiApplication::clipboard();
  if (!clipboard) {
    setStatus(language_ == QStringLiteral("en") ? QStringLiteral("Clipboard unavailable") : QStringLiteral("剪贴板不可用"));
    return false;
  }
  clipboard->setText(text);
  setStatus(language_ == QStringLiteral("en") ? QStringLiteral("Copied") : QStringLiteral("已复制"));
  return true;
}

void AppController::setStatus(const QString& status) {
  if (status_ == status) return;
  status_ = status;
  emit statusChanged();
}
