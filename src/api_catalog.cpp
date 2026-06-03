#include "api_catalog.h"
#include <QFile>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QSet>

QVector<ApiEndpoint> ApiCatalog::loadFromFile(const QString& path) const {
  QFile file(path);
  QVector<ApiEndpoint> endpoints;
  if (!file.open(QIODevice::ReadOnly)) return endpoints;
  const auto doc = QJsonDocument::fromJson(file.readAll());
  if (!doc.isArray()) return endpoints;
  for (const auto& value : doc.array()) {
    const auto obj = value.toObject();
    ApiEndpoint e;
    e.category = obj.value("category").toString();
    e.title = obj.value("title").toString();
    e.method = obj.value("method").toString();
    e.path = obj.value("api_path").toString();
    e.url = obj.value("url").toString();
    endpoints.push_back(e);
  }
  return endpoints;
}
QStringList ApiCatalog::categories(const QVector<ApiEndpoint>& endpoints) const {
  QSet<QString> seen;
  QStringList out;
  for (const auto& e : endpoints) {
    if (!seen.contains(e.category)) { seen.insert(e.category); out << e.category; }
  }
  return out;
}
QVector<ApiEndpoint> ApiCatalog::findByCategory(const QVector<ApiEndpoint>& endpoints, const QString& keyword) const {
  QVector<ApiEndpoint> out;
  const QString needle = keyword.trimmed();
  for (const auto& e : endpoints) {
    if (needle.isEmpty() || e.category.contains(needle, Qt::CaseInsensitive) || e.title.contains(needle, Qt::CaseInsensitive)) out.push_back(e);
  }
  return out;
}
ApiEndpoint ApiCatalog::findByPath(const QVector<ApiEndpoint>& endpoints, const QString& path) const {
  for (const auto& e : endpoints) {
    if (e.path == path || e.url.endsWith(path)) return e;
  }
  return ApiEndpoint{};
}
