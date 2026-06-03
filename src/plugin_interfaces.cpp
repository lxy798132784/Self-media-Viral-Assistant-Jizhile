#include "plugin_interfaces.h"

QStringList BuiltinPluginRegistry::plugins() const {
  return {
      QStringLiteral("provider:jizhilia"),
      QStringLiteral("exporter:markdown"),
      QStringLiteral("exporter:xml"),
      QStringLiteral("analyzer:hit-score"),
  };
}

QStringList BuiltinPluginRegistry::dynamicPluginHints(const QString& plugin_dir) const {
  return {
      QStringLiteral("CTK plugin directory: %1").arg(plugin_dir.isEmpty() ? QStringLiteral("plugins") : plugin_dir),
      QStringLiteral("provider plugins expose ProviderPluginInterface"),
      QStringLiteral("exporter plugins expose ExporterPluginInterface"),
      QStringLiteral("analyzer plugins expose AnalyzerPluginInterface"),
  };
}

QString BuiltinPluginRegistry::analyze(const QVector<Article>& articles) const {
  if (articles.isEmpty()) {
    return QStringLiteral("暂无内容可分析。");
  }
  QString report = QStringLiteral("# 爆款评分分析\n\n");
  for (const auto& a : articles) {
    const int score = a.readCount / 1000 + a.likeCount / 100 + a.watchCount / 100;
    report += QStringLiteral("## %1\n- 账号：%2\n- 爆款评分：%3\n- 建议：提炼标题承诺、读者痛点和可转发结论。\n\n")
                  .arg(a.title, a.accountName)
                  .arg(score);
  }
  return report;
}

QString BuiltinPluginRegistry::exportByPlugin(const QString& plugin_id, const QVector<Article>& articles) const {
  ExportService exporter;
  if (plugin_id == QStringLiteral("exporter:xml")) return exporter.toXml(articles);
  return exporter.toMarkdown(articles);
}
