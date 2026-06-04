#include "api_catalog.h"
#include <QCoreApplication>
#include <QDir>
#include <QFile>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QSet>

QString ApiCatalog::defaultIndexPath() const {
  const QString rel = QStringLiteral("vendor/content-data/api-index.json");
  const QStringList candidates = {
      QDir::current().filePath(rel),
#ifdef MEDIA_HIT_SOURCE_DIR
      QDir(QStringLiteral(MEDIA_HIT_SOURCE_DIR)).filePath(rel),
#endif
      QDir(QCoreApplication::applicationDirPath()).filePath(QStringLiteral("../share/media-hit-assistant/vendor/api-index.json")),
      QDir(QCoreApplication::applicationDirPath()).filePath(QStringLiteral("../share/doc/MediaHitAssistant/vendor/content-data/api-index.json")),
  };
  for (const auto& candidate : candidates) {
    if (QFile::exists(candidate)) return QDir::cleanPath(candidate);
  }
  return QDir::cleanPath(QDir::current().filePath(rel));
}

QVector<ApiEndpoint> ApiCatalog::loadDefault() const {
  return loadFromFile(defaultIndexPath());
}

QVector<ApiEndpoint> ApiCatalog::loadFromFile(const QString& path) const {
  const QString requested = path.trimmed().isEmpty() ? defaultIndexPath() : path;
  QFile file(requested);
  QVector<ApiEndpoint> endpoints;
  if (!file.open(QIODevice::ReadOnly)) {
    file.setFileName(defaultIndexPath());
    if (!file.open(QIODevice::ReadOnly)) return endpoints;
  }
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
