#include "jizhilia_client.h"
#include <QDate>
#include <QEventLoop>
#include <QJsonArray>
#include <QJsonDocument>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QTimer>

JizhiliaClient::JizhiliaClient(QObject* parent) : QObject(parent) {}
QJsonObject JizhiliaClient::buildArticleSearchPayload(const QString& keyword, int page, const QString& api_key, const QString& verify_code) const {
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
QJsonObject JizhiliaClient::buildGenericPayload(const QString& keyword, int page, const QString& api_key, const QString& verify_code) const {
  QJsonObject payload = buildArticleSearchPayload(keyword, page, api_key, verify_code);
  payload["page"] = qMax(1, page);
  payload["query"] = keyword;
  payload["pageSize"] = 20;
  return payload;
}
QVector<Article> JizhiliaClient::mockSearchArticles(const QString& keyword, int page) const {
  QVector<Article> rows;
  const QString clean = keyword.trimmed().isEmpty() ? QStringLiteral("公众号") : keyword.trimmed();
  for (int i = 0; i < 5; ++i) {
    Article a;
    a.title = QStringLiteral("%1 爆款样本 %2：高点击标题与强转发结构").arg(clean).arg((page - 1) * 5 + i + 1);
    a.author = QStringLiteral("Mock Analyst");
    a.accountName = QStringLiteral("%1观察").arg(clean);
    a.url = QStringLiteral("mock://jizhilia/%1/%2").arg(clean).arg((page - 1) * 5 + i + 1);
    a.publishTime = QDate::currentDate().toString(Qt::ISODate);
    a.readCount = 50000 + page * 3000 + i * 12000;
    a.likeCount = 800 + i * 260;
    a.watchCount = 300 + i * 120;
    a.summary = QStringLiteral("Mock fallback：用于无 API Key 或开发环境，验证采集、入库、拆解、导出闭环。");
    rows.push_back(a);
  }
  return rows;
}
QVector<Article> JizhiliaClient::mockEndpointArticles(const QString& endpoint_path, const QString& keyword, int page) const {
  auto rows = mockSearchArticles(keyword, page);
  for (auto& row : rows) {
    row.summary = QStringLiteral("接口 %1 的本地样本：%2").arg(endpoint_path, row.summary);
    row.url = QStringLiteral("mock://jizhilia%1/%2/%3").arg(endpoint_path, keyword).arg(page);
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
static void CollectObjects(const QJsonValue& value, QVector<QJsonObject>* out) {
  if (value.isObject()) {
    const auto obj = value.toObject();
    if (obj.contains("title") || obj.contains("url") || obj.contains("read_num") || obj.contains("readCount")) out->push_back(obj);
    for (const auto& child : obj) CollectObjects(child, out);
  } else if (value.isArray()) {
    for (const auto& child : value.toArray()) CollectObjects(child, out);
  }
}
QVector<Article> JizhiliaClient::parseArticlesFromJson(const QByteArray& json, const QString& keyword) const {
  QVector<Article> rows;
  const auto doc = QJsonDocument::fromJson(json);
  if (doc.isNull()) return rows;
  QVector<QJsonObject> objects;
  CollectObjects(doc.isArray() ? QJsonValue(doc.array()) : QJsonValue(doc.object()), &objects);
  int fallback_index = 0;
  for (const auto& obj : objects) {
    Article a;
    a.title = FirstString(obj, {"title", "Title", "article_title", "nickname"});
    a.author = FirstString(obj, {"author", "Author", "author_name"});
    a.accountName = FirstString(obj, {"wx_name", "account_name", "nickname", "source"});
    a.url = FirstString(obj, {"url", "link", "article_url", "content_url"});
    a.publishTime = FirstString(obj, {"publish_time", "pub_time", "datetime", "date"});
    a.readCount = FirstInt(obj, {"read_num", "readCount", "read_count", "read"});
    a.likeCount = FirstInt(obj, {"like_num", "likeCount", "like_count", "like"});
    a.watchCount = FirstInt(obj, {"watch_num", "old_like_num", "comment_count"});
    a.summary = FirstString(obj, {"digest", "summary", "desc", "description"});
    if (a.title.isEmpty()) a.title = QStringLiteral("%1 采集文章 %2").arg(keyword).arg(++fallback_index);
    if (a.url.isEmpty()) a.url = QStringLiteral("jizhilia://parsed/%1/%2").arg(keyword).arg(rows.size() + 1);
    rows.push_back(a);
  }
  return rows;
}
QVector<Article> JizhiliaClient::searchArticlesBlocking(const QString& base_url, const QString& api_key, const QString& verify_code, const QString& keyword, int page, QString* error_message) const {
  return callEndpointBlocking(base_url, QStringLiteral("/fbmain/monitor/v3/web_search"), api_key, verify_code, keyword, page, error_message);
}
QVector<Article> JizhiliaClient::callEndpointBlocking(const QString& base_url, const QString& endpoint_path, const QString& api_key, const QString& verify_code, const QString& keyword, int page, QString* error_message) const {
  if (!isConfigured(api_key)) {
    if (error_message) *error_message = QStringLiteral("API Key empty, using mock fallback");
    return mockEndpointArticles(endpoint_path, keyword, page);
  }
  const QString root = base_url.trimmed().isEmpty() ? QStringLiteral("https://api.jizhilia.com") : base_url.trimmed();
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
bool JizhiliaClient::isRetryableStatus(int status_code) const { return status_code == -1 || status_code == 500 || status_code == 103 || status_code == 104 || status_code == 50000; }
int JizhiliaClient::retryDelayMs(int attempt) const { const int safe_attempt = qBound(1, attempt, 5); return 1000 * (1 << (safe_attempt - 1)); }
bool JizhiliaClient::isConfigured(const QString& api_key) const { return !api_key.trimmed().isEmpty(); }
QByteArray JizhiliaClient::postJsonBlocking(const QString& url, const QJsonObject& payload, QString* error_message) const {
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
