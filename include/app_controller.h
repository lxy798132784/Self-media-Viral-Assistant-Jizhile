#pragma once
#include <QObject>
#include <QStringList>
#include <QVector>
#include "config_manager.h"
#include "database_manager.h"
#include "export_service.h"
#include "content_data_client.h"
#include "api_catalog.h"
#include "plugin_interfaces.h"

/**
 * @brief QML 应用控制器 / QML application controller
 *
 * @details 将配置、数据库、导出和采集动作暴露给 QML 页面。
 *          Exposes configuration, database, export, and collection actions to QML pages.
 */
class AppController : public QObject {
  Q_OBJECT
  Q_PROPERTY(QString status READ status NOTIFY statusChanged)
  Q_PROPERTY(QString language READ language NOTIFY languageChanged)
  Q_PROPERTY(int articleCount READ articleCount NOTIFY dataChanged)
  Q_PROPERTY(int totalReads READ totalReads NOTIFY dataChanged)
  Q_PROPERTY(int totalLikes READ totalLikes NOTIFY dataChanged)
  // 爆文采集元数据：花费/余额/总数/总页/状态，供 UI 诚实展示真实或示例数据。
  // Hot-article metadata: cost/balance/total/pages/status for honest UI display.
  Q_PROPERTY(QString hotStatus READ hotStatus NOTIFY hotResultChanged)
  Q_PROPERTY(QString hotMessage READ hotMessage NOTIFY hotResultChanged)
  Q_PROPERTY(QString hotNote READ hotNote NOTIFY hotResultChanged)
  Q_PROPERTY(double hotCost READ hotCost NOTIFY hotResultChanged)
  Q_PROPERTY(double hotRemainMoney READ hotRemainMoney NOTIFY hotResultChanged)
  Q_PROPERTY(int hotTotal READ hotTotal NOTIFY hotResultChanged)
  Q_PROPERTY(int hotTotalPage READ hotTotalPage NOTIFY hotResultChanged)
  Q_PROPERTY(int hotResultCount READ hotResultCount NOTIFY hotResultChanged)
  Q_PROPERTY(bool hotIsReal READ hotIsReal NOTIFY hotResultChanged)
  Q_PROPERTY(bool hotIsSample READ hotIsSample NOTIFY hotResultChanged)
  Q_PROPERTY(bool hotIsError READ hotIsError NOTIFY hotResultChanged)
 public:
  explicit AppController(QObject* parent = nullptr);
  QString status() const;
  QString language() const;
  int articleCount() const;
  int totalReads() const;
  int totalLikes() const;
  // 爆文采集元数据 getter / Hot-article metadata getters
  QString hotStatus() const;
  QString hotMessage() const;
  QString hotNote() const;
  double hotCost() const;
  double hotRemainMoney() const;
  int hotTotal() const;
  int hotTotalPage() const;
  int hotResultCount() const;
  bool hotIsReal() const;
  bool hotIsSample() const;
  bool hotIsError() const;
  Q_INVOKABLE bool initialize();
  Q_INVOKABLE void setLanguage(const QString& language);
  Q_INVOKABLE QString trText(const QString& key) const;
  Q_INVOKABLE void loadMockArticles();
  Q_INVOKABLE QStringList articleRows(const QString& keyword = QString()) const;
  Q_INVOKABLE QString generateReport() const;
  Q_INVOKABLE QStringList recommendTopics() const;
  Q_INVOKABLE bool exportMarkdown(const QString& path);
  Q_INVOKABLE bool exportXml(const QString& path);
  Q_INVOKABLE void saveSettings(const QString& apiKey, const QString& verifyCode, int intervalSeconds, int maxRuns, double qpsLimit);
  Q_INVOKABLE int createCollectionTask(const QString& name, const QString& keyword, int intervalSeconds, int maxRuns);
  Q_INVOKABLE int runMockCollection(const QString& keyword);
  Q_INVOKABLE int runCollection(const QString& keyword);
  Q_INVOKABLE int runEndpointCollection(const QString& endpointPath, const QString& keyword);
  Q_INVOKABLE QStringList hotTypicalParameterRows() const;
  Q_INVOKABLE QString hotTypicalPayloadPreview(const QString& apiKey, const QString& keyword, const QString& pubType,
                                               const QString& category, int page, const QString& startTime,
                                               const QString& endTime) const;
  Q_INVOKABLE QStringList datePresetRows() const;
  Q_INVOKABLE QStringList dateRangeForPreset(const QString& preset) const;
  Q_INVOKABLE QStringList aiExtensionRows() const;
  Q_INVOKABLE QString aiExtensionPayloadPreview(const QString& title, const QString& summary) const;
  Q_INVOKABLE int runHotTypicalCollection(const QString& apiKey, const QString& keyword, const QString& pubType,
                                          const QString& category, int page, const QString& startTime,
                                          const QString& endTime);
  Q_INVOKABLE QStringList hotTypicalResultRows() const;
  Q_INVOKABLE bool exportHotTypicalResults(const QString& path, const QString& format);
  Q_INVOKABLE QStringList apiEndpointRows(const QString& categoryKeyword = QString()) const;
  Q_INVOKABLE QString endpointPathFromRow(const QString& endpointRow) const;
  Q_INVOKABLE int runEndpointRow(const QString& endpointRow, const QString& keyword);
  Q_INVOKABLE QStringList pluginRows() const;
  Q_INVOKABLE QString pluginDetail(const QString& pluginIdOrRow) const;
  Q_INVOKABLE QString pluginScanReport(const QString& pluginDir) const;
  Q_INVOKABLE QString pluginExportPreview(const QString& pluginIdOrRow) const;
  Q_INVOKABLE QString pluginAnalysis() const;
  Q_INVOKABLE int runTaskById(int taskId);
  Q_INVOKABLE int runTaskRow(const QString& taskRow);
  Q_INVOKABLE QString taskDetail(const QString& taskRow) const;
  Q_INVOKABLE QString articleDetail(const QString& articleRow) const;
  Q_INVOKABLE QString runDetail(const QString& runRow) const;
  Q_INVOKABLE QString hotTypicalSmokePreview(const QString& apiKey, const QString& keyword, const QString& pubType,
                                             const QString& category, int page, const QString& startTime,
                                             const QString& endTime) const;
  Q_INVOKABLE QString emotionRecentMonthCollectionPreview(int minRead, int maxRead, int targetCount) const;
  Q_INVOKABLE int runEmotionRecentMonthCollection(const QString& apiKey, int minRead, int maxRead, int targetCount);
  Q_INVOKABLE QString targetedHotTypicalCollectionPreview(const QString& keywords, const QString& pubType,
                                                          const QString& category, const QString& startTime,
                                                          const QString& endTime, int minRead, int maxRead,
                                                          int targetCount, int maxPagesPerKeyword,
                                                          int maxScanCandidates) const;
  Q_INVOKABLE int runTargetedHotTypicalCollection(const QString& apiKey, const QString& keywords,
                                                  const QString& pubType, const QString& category,
                                                  const QString& startTime, const QString& endTime,
                                                  int minRead, int maxRead, int targetCount,
                                                  int maxPagesPerKeyword, int maxScanCandidates);
  Q_INVOKABLE bool exportReport(const QString& path);
  Q_INVOKABLE QStringList taskRows() const;
  Q_INVOKABLE QStringList runRows() const;
  Q_INVOKABLE bool runFullSelfCheck(const QString& exportDir);
  Q_INVOKABLE void noteSelection(const QString& area, const QString& value);
  Q_INVOKABLE bool copyTextToClipboard(const QString& text);
 signals:
  void statusChanged();
  void languageChanged();
  void dataChanged();
  void hotResultChanged();
 private:
  void setStatus(const QString& status);
  QString language_ = "zh";
  QString status_ = "Ready";
  ConfigManager config_;
  DatabaseManager database_;
  ExportService export_service_;
  ContentDataClient client_;
  ApiCatalog api_catalog_;
  BuiltinPluginRegistry plugin_registry_;
  QVector<Article> hot_typical_results_;
  HotTypicalResponse hot_typical_response_;  ///< 最近一次爆文采集的完整响应信封 / last hot-article response envelope
};
