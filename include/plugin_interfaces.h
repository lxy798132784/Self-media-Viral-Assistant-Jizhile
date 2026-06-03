#pragma once
#include <QString>
#include <QStringList>
#include <QVector>
#include "article.h"
#include "export_service.h"

/**
 * @brief 插件能力接口集合 / Plugin capability interfaces.
 *
 * @details 当前版本提供轻量内置插件注册表；后续可替换为 CTK 动态插件加载。
 *          This lightweight registry mirrors CTK-style extension points and can be
 *          replaced by dynamic CTK plugin loading later.
 */
class ProviderPluginInterface {
 public:
  virtual ~ProviderPluginInterface() = default;
  virtual QString pluginId() const = 0;
  virtual QString displayName() const = 0;
};

class ExporterPluginInterface {
 public:
  virtual ~ExporterPluginInterface() = default;
  virtual QString pluginId() const = 0;
  virtual QString exportText(const QVector<Article>& articles) const = 0;
};

class AnalyzerPluginInterface {
 public:
  virtual ~AnalyzerPluginInterface() = default;
  virtual QString pluginId() const = 0;
  virtual QString analyze(const QVector<Article>& articles) const = 0;
};

class BuiltinPluginRegistry {
 public:
  QStringList plugins() const;
  QStringList dynamicPluginHints(const QString& plugin_dir) const;
  QString analyze(const QVector<Article>& articles) const;
  QString exportByPlugin(const QString& plugin_id, const QVector<Article>& articles) const;
};
