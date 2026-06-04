#include "content_data_client.h"
#include <QDate>
#include <QEventLoop>
#include <QJsonArray>
#include <QJsonDocument>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QHttpMultiPart>
#include <QHttpPart>
#include <QUrlQuery>
#include <QRegularExpression>
#include <QTimer>

ContentDataClient::ContentDataClient(QObject* parent) : QObject(parent) {}
QJsonObject ContentDataClient::buildArticleSearchPayload(const QString& keyword, int page, const QString& api_key, const QString& verify_code) const {
  QJsonObject payload;
  payload["keyword"] = keyword;
  payload["currentPage"] = qMax(1, page);
  payload["key"] = api_key;
  payload["verifycode"] = verify_code;
  payload["mode"] = 1;
  payload["offset"] = (qMax(1, page) - 1) * 20;
  payload["BusinessType"] = 2;
  return payload;
}
QJsonObject ContentDataClient::buildGenericPayload(const QString& keyword, int page, const QString& api_key, const QString& verify_code) const {
  QJsonObject payload = buildArticleSearchPayload(keyword, page, api_key, verify_code);
  payload["page"] = qMax(1, page);
  payload["query"] = keyword;
  payload["pageSize"] = 20;
  return payload;
}
QJsonObject ContentDataClient::buildHotTypicalSearchPayload(const QString& api_key, const QString& keyword, const QString& pub_type,
                                                         const QString& category, int page, const QString& start_time,
                                                         const QString& end_time) const {
  HotTypicalRequest request;
  request.key = api_key;
  const QString clean_keyword = keyword.trimmed();
  if (!clean_keyword.isEmpty()) request.keyword = clean_keyword;
  request.pub_type = pubTypeFromApiValue(pub_type).value_or(PubType::TextImage);
  request.category = category.trimmed().isEmpty() ? QStringLiteral("0") : category.trimmed();
  request.page = QString::number(qMax(1, page));
  request.start_time = start_time.trimmed();
  request.end_time = end_time.trimmed();
  return buildHotTypicalSearchPayload(request);
}
QJsonObject ContentDataClient::buildHotTypicalSearchPayload(const HotTypicalRequest& request) const {
  QJsonObject payload;
  payload["key"] = request.key.trimmed();
  payload["pub_type"] = pubTypeToApiValue(request.pub_type);
  payload["category"] = request.category.trimmed().isEmpty() ? QStringLiteral("0") : request.category.trimmed();
  bool ok = false;
  const int page_number = request.page.trimmed().toInt(&ok);
  payload["page"] = QString::number(ok ? qMax(1, page_number) : 1);
  payload["start_time"] = request.start_time.trimmed();
  payload["end_time"] = request.end_time.trimmed();
  if (request.keyword.has_value()) {
    const QString clean_keyword = request.keyword.value().trimmed();
    if (!clean_keyword.isEmpty()) payload["keyword"] = clean_keyword;
  }
  return payload;
}
QString ContentDataClient::pubTypeToApiValue(PubType pub_type) const {
  return QString::number(static_cast<int>(pub_type));
}
std::optional<PubType> ContentDataClient::pubTypeFromApiValue(const QString& api_value) const {
  bool ok = false;
  const int value = api_value.trimmed().toInt(&ok);
  if (!ok) return std::nullopt;
  switch (value) {
    case 0: return PubType::TextImage;
    case 5: return PubType::Video;
    case 7: return PubType::Music;
    case 8: return PubType::Image;
    case 10: return PubType::Text;
    case 11: return PubType::Repost;
    default: return std::nullopt;
  }
}
bool ContentDataClient::validateHotTypicalRequest(const HotTypicalRequest& request, QString* error_message) const {
  if (request.key.trimmed().isEmpty()) {
    if (error_message) *error_message = QStringLiteral("key is required");
    return false;
  }
  if (request.category.trimmed().isEmpty()) {
    if (error_message) *error_message = QStringLiteral("category is required");
    return false;
  }
  bool category_ok = false;
  const int category_value = request.category.trimmed().toInt(&category_ok);
  if (!category_ok || category_value < 0 || category_value > 30) {
    if (error_message) *error_message = QStringLiteral("category must be 0..30");
    return false;
  }
  bool page_ok = false;
  const int page_value = request.page.trimmed().toInt(&page_ok);
  if (!page_ok || page_value < 1) {
    if (error_message) *error_message = QStringLiteral("page must be >= 1");
    return false;
  }
  const QRegularExpression date_pattern(QStringLiteral("^\\d{4}-\\d{2}-\\d{2}$"));
  const auto start_match = date_pattern.match(request.start_time.trimmed());
  const auto end_match = date_pattern.match(request.end_time.trimmed());
  if (!start_match.hasMatch() || !QDate::fromString(request.start_time.trimmed(), Qt::ISODate).isValid()) {
    if (error_message) *error_message = QStringLiteral("start_time must use YYYY-MM-DD");
    return false;
  }
  if (!end_match.hasMatch() || !QDate::fromString(request.end_time.trimmed(), Qt::ISODate).isValid()) {
    if (error_message) *error_message = QStringLiteral("end_time must use YYYY-MM-DD");
    return false;
  }
  return true;
}
QStringList ContentDataClient::hotTypicalParameterNames() const {
  return {QStringLiteral("key"), QStringLiteral("keyword"), QStringLiteral("pub_type"), QStringLiteral("category"),
          QStringLiteral("page"), QStringLiteral("start_time"), QStringLiteral("end_time")};
}
QVector<Article> ContentDataClient::mockSearchArticles(const QString& keyword, int page) const {
  QVector<Article> rows;
  const QString clean = keyword.trimmed().isEmpty() ? QStringLiteral("公众号") : keyword.trimmed();
  for (int i = 0; i < 5; ++i) {
    Article a;
    a.title = QStringLiteral("%1 爆款样本 %2：高点击标题与强转发结构").arg(clean).arg((page - 1) * 5 + i + 1);
    a.author = QStringLiteral("Mock Analyst");
    a.accountName = QStringLiteral("%1观察").arg(clean);
    a.url = QStringLiteral("mock://content-data/%1/%2").arg(clean).arg((page - 1) * 5 + i + 1);
    a.publishTime = QDate::currentDate().toString(Qt::ISODate);
    a.readCount = 50000 + page * 3000 + i * 12000;
    a.likeCount = 800 + i * 260;
    a.watchCount = 300 + i * 120;
    a.hotScore = 80.0 + i * 3.5;
    a.avgReadCount = 28000 + i * 2000;
    a.fansCount = 100000 + i * 30000;
    a.position = i == 0 ? 1 : 2;
    a.category = QStringLiteral("科技");
    a.isOriginal = QStringLiteral("是");
    a.publishType = QStringLiteral("图文");
    a.coverUrl = QStringLiteral("mock://cover/%1").arg(i + 1);
    a.wxid = QStringLiteral("mock_wx_%1").arg(i + 1);
    a.summary = QStringLiteral("Mock fallback：用于无 Key 或开发环境，验证采集、入库、拆解、导出闭环。");
    rows.push_back(a);
  }
  return rows;
}
QVector<Article> ContentDataClient::mockEndpointArticles(const QString& endpoint_path, const QString& keyword, int page) const {
  auto rows = mockSearchArticles(keyword, page);
  for (auto& row : rows) {
    row.summary = QStringLiteral("接口 %1 的本地样本：%2").arg(endpoint_path, row.summary);
    row.url = QStringLiteral("mock://content-data%1/%2/%3").arg(endpoint_path, keyword).arg(page);
  }
  return rows;
}

static QString FirstString(const QJsonObject& obj, std::initializer_list<const char*> keys) {
  for (const char* key : keys) {
    const auto value = obj.value(QString::fromUtf8(key));
    if (value.isString() && !value.toString().isEmpty()) return value.toString();
    if (value.isDouble()) return QString::number(value.toDouble(), 'f', 0);
  }
  return QString();
}
static int FirstInt(const QJsonObject& obj, std::initializer_list<const char*> keys) {
  for (const char* key : keys) {
    const auto value = obj.value(QString::fromUtf8(key));
    if (value.isDouble()) return value.toInt();
    if (value.isString()) {
      bool ok = false; const int n = value.toString().remove(',').toInt(&ok); if (ok) return n;
    }
  }
  return 0;
}
static double FirstDouble(const QJsonObject& obj, std::initializer_list<const char*> keys) {
  for (const char* key : keys) {
    const auto value = obj.value(QString::fromUtf8(key));
    if (value.isDouble()) return value.toDouble();
    if (value.isString()) {
      bool ok = false; const double n = value.toString().remove(',').toDouble(&ok); if (ok) return n;
    }
  }
  return 0.0;
}
static void CollectObjects(const QJsonValue& value, QVector<QJsonObject>* out) {
  if (value.isObject()) {
    const auto obj = value.toObject();
    if (obj.contains("title") || obj.contains("url") || obj.contains("read_num") || obj.contains("readCount")) out->push_back(obj);
    for (const auto& child : obj) CollectObjects(child, out);
  } else if (value.isArray()) {
    for (const auto& child : value.toArray()) CollectObjects(child, out);
  }
}
QVector<Article> ContentDataClient::parseArticlesFromJson(const QByteArray& json, const QString& keyword) const {
  QVector<Article> rows;
  const auto doc = QJsonDocument::fromJson(json);
  if (doc.isNull()) return rows;
  QVector<QJsonObject> objects;
  CollectObjects(doc.isArray() ? QJsonValue(doc.array()) : QJsonValue(doc.object()), &objects);
  int fallback_index = 0;
  for (const auto& obj : objects) {
    Article a;
    a.title = FirstString(obj, {"title", "Title", "article_title", "nickname"});
    a.author = FirstString(obj, {"author", "Author", "author_name", "mp_nickname"});
    a.accountName = FirstString(obj, {"mp_nickname", "wx_name", "account_name", "nickname", "source"});
    a.url = FirstString(obj, {"url", "link", "article_url", "content_url"});
    a.publishTime = FirstString(obj, {"pub_time", "publish_time", "datetime", "date"});
    a.readCount = FirstInt(obj, {"read_num", "readCount", "read_count", "read"});
    a.likeCount = FirstInt(obj, {"zan_num", "like_num", "likeCount", "like_count", "like"});
    a.watchCount = FirstInt(obj, {"watch_num", "old_like_num", "comment_count"});
    a.hotScore = FirstDouble(obj, {"hot", "hotScore", "score"});
    a.avgReadCount = FirstInt(obj, {"avg", "avg_read", "avgReadCount"});
    a.fansCount = FirstInt(obj, {"fans", "fans_count", "fansCount"});
    a.position = FirstInt(obj, {"position"});
    a.wxid = FirstString(obj, {"wxid", "biz", "wechat_id"});
    a.category = FirstString(obj, {"category", "category_name"});
    a.isOriginal = FirstString(obj, {"is_original", "original"});
    a.publishType = FirstString(obj, {"publish_type", "pub_type_name"});
    a.coverUrl = FirstString(obj, {"cover", "cover_url", "thumb_url"});
    a.summary = FirstString(obj, {"digest", "summary", "desc", "description"});
    if (a.summary.isEmpty() && (a.hotScore > 0 || a.avgReadCount > 0 || a.fansCount > 0)) {
      a.summary = QStringLiteral("爆值 %1；平均阅读 %2；粉丝 %3；分类 %4；类型 %5")
                    .arg(a.hotScore).arg(a.avgReadCount).arg(a.fansCount).arg(a.category, a.publishType);
    }
    if (a.title.isEmpty()) a.title = QStringLiteral("%1 采集文章 %2").arg(keyword).arg(++fallback_index);
    if (a.url.isEmpty()) a.url = QStringLiteral("content-data://parsed/%1/%2").arg(keyword).arg(rows.size() + 1);
    rows.push_back(a);
  }
  return rows;
}
QVector<Article> ContentDataClient::searchArticlesBlocking(const QString& base_url, const QString& api_key, const QString& verify_code, const QString& keyword, int page, QString* error_message) const {
  return callEndpointBlocking(base_url, QStringLiteral("/fbmain/monitor/v3/web_search"), api_key, verify_code, keyword, page, error_message);
}
QVector<Article> ContentDataClient::callEndpointBlocking(const QString& base_url, const QString& endpoint_path, const QString& api_key, const QString& verify_code, const QString& keyword, int page, QString* error_message) const {
  if (!isConfigured(api_key)) {
    if (error_message) *error_message = QStringLiteral("API Key empty, using mock fallback");
    return mockEndpointArticles(endpoint_path, keyword, page);
  }
  const QString root = base_url.trimmed().isEmpty() ? QStringLiteral("https://www.dajiala.com") : base_url.trimmed();
  const QString path = endpoint_path.startsWith('/') ? endpoint_path : QStringLiteral("/") + endpoint_path;
  const QString url = root + path;
  for (int attempt = 1; attempt <= 3; ++attempt) {
    const QByteArray body = postJsonBlocking(url, buildGenericPayload(keyword, page, api_key, verify_code), error_message);
    const auto rows = parseArticlesFromJson(body, keyword);
    if (!rows.isEmpty()) return rows;
    QEventLoop loop; QTimer::singleShot(retryDelayMs(attempt), &loop, &QEventLoop::quit); loop.exec();
  }
  return mockEndpointArticles(endpoint_path, keyword, page);
}
QVector<Article> ContentDataClient::callHotTypicalSearchBlocking(const QString& base_url, const QString& api_key, const QString& keyword,
                                                              const QString& pub_type, const QString& category, int page,
                                                              const QString& start_time, const QString& end_time,
                                                              QString* error_message) const {
  const QString endpoint = QStringLiteral("/fbmain/monitor/v3/hot_typical_search");
  HotTypicalRequest request;
  request.key = api_key;
  const QString clean_keyword = keyword.trimmed();
  if (!clean_keyword.isEmpty()) request.keyword = clean_keyword;
  request.pub_type = pubTypeFromApiValue(pub_type).value_or(PubType::TextImage);
  request.category = category.trimmed().isEmpty() ? QStringLiteral("0") : category.trimmed();
  request.page = QString::number(qMax(1, page));
  request.start_time = start_time.trimmed();
  request.end_time = end_time.trimmed();
  QString validation_error;
  if (isConfigured(api_key) && !validateHotTypicalRequest(request, &validation_error)) {
    if (error_message) *error_message = validation_error;
    return mockEndpointArticles(endpoint, keyword, page);
  }
  if (!isConfigured(api_key)) {
    if (error_message) *error_message = QStringLiteral("API Key empty, using hot typical mock fallback");
    return mockEndpointArticles(endpoint, keyword, page);
  }
  const QString root = base_url.trimmed().isEmpty() ? QStringLiteral("https://www.dajiala.com") : base_url.trimmed();
  const QString url = root + endpoint;
  const auto payload = buildHotTypicalSearchPayload(request);
  for (int attempt = 1; attempt <= 3; ++attempt) {
    const QByteArray body = postMultipartBlocking(url, payload, error_message);
    const auto rows = parseArticlesFromJson(body, keyword);
    if (!rows.isEmpty()) return rows;
    QEventLoop loop; QTimer::singleShot(retryDelayMs(attempt), &loop, &QEventLoop::quit); loop.exec();
  }
  return mockEndpointArticles(endpoint, keyword, page);
}
bool ContentDataClient::isRetryableStatus(int status_code) const { return status_code == -1 || status_code == 500 || status_code == 103 || status_code == 104 || status_code == 50000; }
int ContentDataClient::retryDelayMs(int attempt) const { const int safe_attempt = qBound(1, attempt, 5); return 1000 * (1 << (safe_attempt - 1)); }
QString ContentDataClient::classifyApiError(int status_code, const QString& error_text) const {
  const QString text = error_text.toLower();
  if (status_code == -1 || text.contains(QStringLiteral("timeout")) || text.contains(QStringLiteral("timed out"))) return QStringLiteral("network_timeout");
  if (status_code == 401 || text.contains(QStringLiteral("unauthorized")) || text.contains(QStringLiteral("invalid token"))) return QStringLiteral("authentication_error");
  if (status_code == 429 || text.contains(QStringLiteral("rate limit"))) return QStringLiteral("rate_limited");
  if (status_code == 402 || text.contains(QStringLiteral("余额")) || text.contains(QStringLiteral("quota"))) return QStringLiteral("quota_or_balance_error");
  if (status_code == 400 || text.contains(QStringLiteral("parameter")) || text.contains(QStringLiteral("category")) || text.contains(QStringLiteral("page"))) return QStringLiteral("parameter_error");
  if (status_code >= 500) return QStringLiteral("server_error");
  return QStringLiteral("unknown_error");
}
QString ContentDataClient::hotTypicalSmokePlan(const QString& apiKey, const QString& keyword, const QString& pubType,
                                            const QString& category, int page, const QString& start_time,
                                            const QString& end_time) const {
  QJsonObject root;
  root["endpoint"] = QStringLiteral("/fbmain/monitor/v3/hot_typical_search");
  root["content_type"] = QStringLiteral("multipart/form-data");
  root["configured"] = isConfigured(apiKey);
  root["classification_hint"] = QStringLiteral("preview_only");
  root["payload"] = buildHotTypicalSearchPayload(apiKey, keyword, pubType, category, page, start_time, end_time);
  return QString::fromUtf8(QJsonDocument(root).toJson(QJsonDocument::Indented));
}
bool ContentDataClient::isConfigured(const QString& api_key) const { return !api_key.trimmed().isEmpty(); }
QByteArray ContentDataClient::postJsonBlocking(const QString& url, const QJsonObject& payload, QString* error_message) const {
  QNetworkAccessManager manager;
  QNetworkRequest request{QUrl(url)};
  request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
  QNetworkReply* reply = manager.post(request, QJsonDocument(payload).toJson(QJsonDocument::Compact));
  QEventLoop loop;
  QTimer timer; timer.setSingleShot(true);
  QObject::connect(reply, &QNetworkReply::finished, &loop, &QEventLoop::quit);
  QObject::connect(&timer, &QTimer::timeout, &loop, &QEventLoop::quit);
  timer.start(15000);
  loop.exec();
  if (timer.isActive()) timer.stop(); else { reply->abort(); if (error_message) *error_message = QStringLiteral("request timeout"); reply->deleteLater(); return {}; }
  const QByteArray data = reply->readAll();
  if (reply->error() != QNetworkReply::NoError && error_message) *error_message = reply->errorString();
  reply->deleteLater();
  return data;
}

QByteArray ContentDataClient::postMultipartBlocking(const QString& url, const QJsonObject& payload, QString* error_message) const {
  QNetworkAccessManager manager;
  QNetworkRequest request{QUrl(url)};
  auto* multi_part = new QHttpMultiPart(QHttpMultiPart::FormDataType);
  for (auto it = payload.begin(); it != payload.end(); ++it) {
    QHttpPart part;
    part.setHeader(QNetworkRequest::ContentDispositionHeader,
                   QVariant(QStringLiteral("form-data; name=\"%1\"").arg(it.key())));
    part.setBody(it.value().toVariant().toString().toUtf8());
    multi_part->append(part);
  }
  QNetworkReply* reply = manager.post(request, multi_part);
  multi_part->setParent(reply);
  QEventLoop loop;
  QTimer timer; timer.setSingleShot(true);
  QObject::connect(reply, &QNetworkReply::finished, &loop, &QEventLoop::quit);
  QObject::connect(&timer, &QTimer::timeout, &loop, &QEventLoop::quit);
  timer.start(15000);
  loop.exec();
  if (timer.isActive()) timer.stop(); else { reply->abort(); if (error_message) *error_message = QStringLiteral("request timeout"); reply->deleteLater(); return {}; }
  const QByteArray data = reply->readAll();
  if (reply->error() != QNetworkReply::NoError && error_message) *error_message = reply->errorString();
  reply->deleteLater();
  return data;
}
