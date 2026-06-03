#include "export_service.h"
#include <QFile>
#include <QTextStream>

static QString XmlEscape(QString s) { return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;"); }
QString ExportService::toMarkdown(const QVector<Article>& articles) const {
  QString out = "# 自媒体爆款文章导出\n\n";
  for (const auto& a : articles) {
    out += QString("## %1\n\n- 公众号：%2\n- 作者：%3\n- 阅读：%4\n- 点赞：%5\n- 链接：%6\n\n%7\n\n")
      .arg(a.title, a.accountName, a.author).arg(a.readCount).arg(a.likeCount).arg(a.url, a.summary);
  }
  return out;
}
QString ExportService::toXml(const QVector<Article>& articles) const {
  QString out = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<articles>\n";
  for (const auto& a : articles) {
    out += QString("  <article><title>%1</title><account>%2</account><author>%3</author><url>%4</url><readCount>%5</readCount><likeCount>%6</likeCount><summary>%7</summary></article>\n")
      .arg(XmlEscape(a.title), XmlEscape(a.accountName), XmlEscape(a.author), XmlEscape(a.url)).arg(a.readCount).arg(a.likeCount).arg(XmlEscape(a.summary));
  }
  out += "</articles>\n";
  return out;
}
bool ExportService::writeTextFile(const QString& path, const QString& content) const { QFile f(path); if(!f.open(QIODevice::WriteOnly|QIODevice::Text)) return false; QTextStream s(&f); s << content; return true; }
