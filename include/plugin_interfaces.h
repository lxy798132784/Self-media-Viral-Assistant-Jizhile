#pragma once
#include <QString>
#include <QStringList>
#include <QVector>
#include "article.h"
#include "export_service.h"

/**
 * @brief 插件能力接口集合 / Plugin capability interfaces.
 *
 * @details 当前版本提供内置插件注册表和 fail-closed 动态插件元数据扫描；后续可接入 CTK 动态库实例化。
 *          The current release provides built-ins plus fail-closed dynamic plugin metadata scanning; CTK runtime instantiation can be attached later.
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
  QStringList plugins(const QString& plugin_dir) const;
  QStringList pluginDescriptors(const QString& plugin_dir) const;
  QString pluginDescriptor(const QString& plugin_id, const QString& plugin_dir = QString()) const;
  QStringList dynamicPluginHints(const QString& plugin_dir) const;
  QStringList dynamicPluginScanReport(const QString& plugin_dir) const;
  QString analyze(const QVector<Article>& articles) const;
  QString exportByPlugin(const QString& plugin_id, const QVector<Article>& articles) const;
 private:
  QStringList scanDynamicPluginIds(const QString& plugin_dir, QStringList* report) const;
};
