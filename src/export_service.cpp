#include "export_service.h"
#include <QFile>
#include <QTextStream>

static QString XmlEscape(QString s) { return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;"); }
static QString N(double v) { return QString::number(v, 'f', (qAbs(v - qRound64(v)) < 0.0001) ? 0 : 1); }

QString ExportService::toMarkdown(const QVector<Article>& articles) const {
  QString out = "# 自媒体爆款文章导出\n\n";
  out += "| 标题 | 作者/账号 | 发布时间 | 爆值 | 阅读 | 点赞 | 平均阅读 | 粉丝 | 分类 | 类型 | 原创 | 位置 | 链接 |\n";
  out += "| --- | --- | --- | ---: | ---: | ---: | ---: | ---: | --- | --- | --- | ---: | --- |\n";
  for (const auto& a : articles) {
    out += QString("| %1 | %2 | %3 | %4 | %5 | %6 | %7 | %8 | %9 | %10 | %11 | %12 | %13 |\n")
      .arg(a.title, a.accountName.isEmpty() ? a.author : a.accountName, a.publishTime, N(a.hotScore))
      .arg(a.readCount).arg(a.likeCount).arg(a.avgReadCount).arg(a.fansCount)
      .arg(a.category, a.publishType, a.isOriginal).arg(a.position).arg(a.url);
  }
  out += "\n## 详情\n\n";
  for (const auto& a : articles) {
    out += QString("### %1\n\n- 作者：%2\n- 微信ID：%3\n- 封面：%4\n- 链接：%5\n\n%6\n\n")
      .arg(a.title, a.accountName.isEmpty() ? a.author : a.accountName, a.wxid, a.coverUrl, a.url, a.summary);
  }
  return out;
}

QString ExportService::toXml(const QVector<Article>& articles) const {
  QString out = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<articles>\n";
  for (const auto& a : articles) {
    out += QString("  <article><title>%1</title><account>%2</account><author>%3</author><url>%4</url><publishTime>%5</publishTime><hotScore>%6</hotScore><readCount>%7</readCount><likeCount>%8</likeCount><avgReadCount>%9</avgReadCount><fansCount>%10</fansCount><position>%11</position><wxid>%12</wxid><category>%13</category><isOriginal>%14</isOriginal><publishType>%15</publishType><coverUrl>%16</coverUrl><summary>%17</summary></article>\n")
      .arg(XmlEscape(a.title), XmlEscape(a.accountName), XmlEscape(a.author), XmlEscape(a.url), XmlEscape(a.publishTime), N(a.hotScore))
      .arg(a.readCount).arg(a.likeCount).arg(a.avgReadCount).arg(a.fansCount).arg(a.position)
      .arg(XmlEscape(a.wxid), XmlEscape(a.category), XmlEscape(a.isOriginal), XmlEscape(a.publishType), XmlEscape(a.coverUrl), XmlEscape(a.summary));
  }
  out += "</articles>\n";
  return out;
}

QString ExportService::toSpreadsheetXml(const QVector<Article>& articles) const {
  QString out = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
  out += "<?mso-application progid=\"Excel.Sheet\"?>\n";
  out += "<Workbook xmlns=\"urn:schemas-microsoft-com:office:spreadsheet\" xmlns:ss=\"urn:schemas-microsoft-com:office:spreadsheet\">\n<Worksheet ss:Name=\"HotArticles\"><Table>\n";
  const QStringList headers = {"标题", "作者", "账号", "发布时间", "爆值", "阅读", "点赞", "平均阅读", "粉丝", "分类", "类型", "原创", "位置", "微信ID", "封面", "链接"};
  out += "<Row>";
  for (const auto& h : headers) out += QString("<Cell><Data ss:Type=\"String\">%1</Data></Cell>").arg(XmlEscape(h));
  out += "</Row>\n";
  for (const auto& a : articles) {
    const QStringList cells = {a.title, a.author, a.accountName, a.publishTime, N(a.hotScore), QString::number(a.readCount), QString::number(a.likeCount), QString::number(a.avgReadCount), QString::number(a.fansCount), a.category, a.publishType, a.isOriginal, QString::number(a.position), a.wxid, a.coverUrl, a.url};
    out += "<Row>";
    for (const auto& c : cells) out += QString("<Cell><Data ss:Type=\"String\">%1</Data></Cell>").arg(XmlEscape(c));
    out += "</Row>\n";
  }
  out += "</Table></Worksheet></Workbook>\n";
  return out;
}

bool ExportService::writeTextFile(const QString& path, const QString& content) const { QFile f(path); if(!f.open(QIODevice::WriteOnly|QIODevice::Text)) return false; QTextStream s(&f); s << content; return true; }
