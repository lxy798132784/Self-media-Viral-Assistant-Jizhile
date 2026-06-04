#include "plugin_interfaces.h"
#include <QDir>
#include <QFile>
#include <QJsonDocument>
#include <QJsonObject>
#include <QSet>

QStringList BuiltinPluginRegistry::plugins() const {
  return {
      QStringLiteral("provider:jizhilia"),
      QStringLiteral("exporter:markdown"),
      QStringLiteral("exporter:xml"),
      QStringLiteral("analyzer:hit-score"),
  };
}

QStringList BuiltinPluginRegistry::plugins(const QString& plugin_dir) const {
  QSet<QString> merged;
  QStringList rows = plugins();
  for (const auto& row : rows) merged.insert(row);
  QStringList report;
  for (const auto& id : scanDynamicPluginIds(plugin_dir, &report)) {
    if (!merged.contains(id)) {
      rows << id;
      merged.insert(id);
    }
  }
  return rows;
}

QStringList BuiltinPluginRegistry::pluginDescriptors(const QString& plugin_dir) const {
  QStringList rows;
  for (const auto& id : plugins(plugin_dir)) rows << pluginDescriptor(id, plugin_dir);
  return rows;
}

QString BuiltinPluginRegistry::pluginDescriptor(const QString& plugin_id, const QString& plugin_dir) const {
  const QString id = plugin_id.trimmed();
  if (id == QStringLiteral("provider:jizhilia")) return QStringLiteral("provider:jizhilia｜极致了内容采集｜支持真实 API 与本地示例回退");
  if (id == QStringLiteral("exporter:markdown")) return QStringLiteral("exporter:markdown｜Markdown 导出｜生成可编辑内容归档");
  if (id == QStringLiteral("exporter:xml")) return QStringLiteral("exporter:xml｜XML 导出｜生成结构化机器可读归档");
  if (id == QStringLiteral("analyzer:hit-score")) return QStringLiteral("analyzer:hit-score｜爆款评分分析｜阅读/点赞/在看综合打分");
  for (const auto& line : dynamicPluginScanReport(plugin_dir)) {
    if (line.contains(id)) return QStringLiteral("%1｜动态插件元数据｜%2").arg(id, line);
  }
  return QStringLiteral("%1｜未知插件｜已按 fail-closed 策略仅展示不执行").arg(id.isEmpty() ? QStringLiteral("[empty]") : id);
}

QStringList BuiltinPluginRegistry::dynamicPluginHints(const QString& plugin_dir) const {
  return {
      QStringLiteral("CTK plugin directory: %1").arg(plugin_dir.isEmpty() ? QStringLiteral("plugins") : plugin_dir),
      QStringLiteral("provider plugins expose ProviderPluginInterface"),
      QStringLiteral("exporter plugins expose ExporterPluginInterface"),
      QStringLiteral("analyzer plugins expose AnalyzerPluginInterface"),
      QStringLiteral("metadata files: providers/*.json, exporters/*.json, analyzers/*.json"),
      QStringLiteral("fail closed: invalid metadata is blocked and built-ins remain active"),
  };
}

QStringList BuiltinPluginRegistry::dynamicPluginScanReport(const QString& plugin_dir) const {
  QStringList report;
  scanDynamicPluginIds(plugin_dir, &report);
  if (report.isEmpty()) report << QStringLiteral("no dynamic plugin metadata found");
  return report;
}

QStringList BuiltinPluginRegistry::scanDynamicPluginIds(const QString& plugin_dir, QStringList* report) const {
  QStringList ids;
  const QString root_path = plugin_dir.trimmed().isEmpty() ? QStringLiteral("plugins") : plugin_dir.trimmed();
  const QDir root(root_path);
  const QStringList subdirs{QStringLiteral("providers"), QStringLiteral("exporters"), QStringLiteral("analyzers")};
  const QSet<QString> allowed_kinds{QStringLiteral("provider"), QStringLiteral("exporter"), QStringLiteral("analyzer")};
  for (const auto& subdir : subdirs) {
    const QDir dir(root.filePath(subdir));
    if (!dir.exists()) continue;
    for (const auto& file_name : dir.entryList(QStringList{QStringLiteral("*.json")}, QDir::Files | QDir::Readable)) {
      const QString path = dir.filePath(file_name);
      QFile file(path);
      if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        if (report) *report << QStringLiteral("blocked unreadable metadata: %1").arg(path);
        continue;
      }
      const auto doc = QJsonDocument::fromJson(file.readAll());
      if (!doc.isObject()) {
        if (report) *report << QStringLiteral("blocked invalid metadata: %1").arg(path);
        continue;
      }
      const auto obj = doc.object();
      const QString id = obj.value(QStringLiteral("id")).toString().trimmed();
      const QString kind = obj.value(QStringLiteral("kind")).toString().trimmed();
      if (id.isEmpty() || !allowed_kinds.contains(kind) || !id.startsWith(kind + QStringLiteral(":"))) {
        if (report) *report << QStringLiteral("blocked unsafe metadata: %1").arg(path);
        continue;
      }
      ids << id;
      if (report) *report << QStringLiteral("loaded metadata plugin: %1 from %2").arg(id, path);
    }
  }
  return ids;
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
