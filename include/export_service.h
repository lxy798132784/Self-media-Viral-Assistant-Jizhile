#pragma once
#include <QString>
#include <QVector>
#include "article.h"

/**
 * @brief 内容导出服务 / Content export service
 *
 * @details 将文章列表导出为 Markdown 或 XML。
 *          Exports article lists to Markdown or XML.
 */
class ExportService {
 public:
  QString toMarkdown(const QVector<Article>& articles) const;
  QString toXml(const QVector<Article>& articles) const;
  bool writeTextFile(const QString& path, const QString& content) const;
};
