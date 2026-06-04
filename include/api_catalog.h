#pragma once
#include <QString>
#include <QStringList>
#include <QVector>

struct ApiEndpoint {
  QString category;
  QString title;
  QString method;
  QString path;
  QString url;
};

/**
 * @brief 内容数据索引 / Content data index
 *
 * @details 读取本地 api-index.json，为新项目提供接口清单。
 *          Loads local api-index.json and exposes endpoint metadata for the app.
 */
class ApiCatalog {
 public:
  QString defaultIndexPath() const;
  QVector<ApiEndpoint> loadDefault() const;
  QVector<ApiEndpoint> loadFromFile(const QString& path) const;
  QStringList categories(const QVector<ApiEndpoint>& endpoints) const;
  QVector<ApiEndpoint> findByCategory(const QVector<ApiEndpoint>& endpoints, const QString& keyword) const;
  ApiEndpoint findByPath(const QVector<ApiEndpoint>& endpoints, const QString& path) const;
};
