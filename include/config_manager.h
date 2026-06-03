#pragma once
#include <QObject>
#include <QString>

/**
 * @brief 应用配置管理器 / Application configuration manager
 *
 * @details 管理极致了 API Key、验证码、采集频率、次数和限速等设置。
 *          Manages Jizhilia API key, verify code, collection frequency, count, and rate limit settings.
 */
class ConfigManager : public QObject {
  Q_OBJECT
 public:
  explicit ConfigManager(QObject* parent = nullptr);
  QString apiKey() const;
  QString verifyCode() const;
  int intervalSeconds() const;
  int maxRuns() const;
  double qpsLimit() const;
  QString exportDirectory() const;
  void setApiKey(const QString& value);
  void setVerifyCode(const QString& value);
  void setIntervalSeconds(int value);
  void setMaxRuns(int value);
  void setQpsLimit(double value);
  void setExportDirectory(const QString& value);
  bool load();
  bool save() const;
 private:
  QString api_key_;
  QString verify_code_;
  int interval_seconds_ = 300;
  int max_runs_ = 10;
  double qps_limit_ = 1.5;
  QString export_directory_;
};
