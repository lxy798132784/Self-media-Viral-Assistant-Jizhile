#include "config_manager.h"
#include <QDir>
#include <QSettings>
#include <QStandardPaths>

ConfigManager::ConfigManager(QObject* parent) : QObject(parent) {
  export_directory_ = QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation);
}
QString ConfigManager::apiKey() const { return api_key_; }
QString ConfigManager::verifyCode() const { return verify_code_; }
int ConfigManager::intervalSeconds() const { return interval_seconds_; }
int ConfigManager::maxRuns() const { return max_runs_; }
double ConfigManager::qpsLimit() const { return qps_limit_; }
QString ConfigManager::exportDirectory() const { return export_directory_; }
void ConfigManager::setApiKey(const QString& value) { api_key_ = value.trimmed(); }
void ConfigManager::setVerifyCode(const QString& value) { verify_code_ = value.trimmed(); }
void ConfigManager::setIntervalSeconds(int value) { interval_seconds_ = qMax(5, value); }
void ConfigManager::setMaxRuns(int value) { max_runs_ = qMax(1, value); }
void ConfigManager::setQpsLimit(double value) { qps_limit_ = qBound(0.2, value, 2.0); }
void ConfigManager::setExportDirectory(const QString& value) { export_directory_ = value; }
bool ConfigManager::load() {
  QSettings s("Hermes", "MediaHitAssistant");
  api_key_ = s.value("apiKey", qEnvironmentVariable("JIZHILIA_API_KEY")).toString();
  verify_code_ = s.value("verifyCode", qEnvironmentVariable("JIZHILIA_VERIFY_CODE")).toString();
  interval_seconds_ = s.value("intervalSeconds", 300).toInt();
  max_runs_ = s.value("maxRuns", 10).toInt();
  qps_limit_ = s.value("qpsLimit", 1.5).toDouble();
  export_directory_ = s.value("exportDirectory", export_directory_).toString();
  return true;
}
bool ConfigManager::save() const {
  QSettings s("Hermes", "MediaHitAssistant");
  s.setValue("apiKey", api_key_);
  s.setValue("verifyCode", verify_code_);
  s.setValue("intervalSeconds", interval_seconds_);
  s.setValue("maxRuns", max_runs_);
  s.setValue("qpsLimit", qps_limit_);
  s.setValue("exportDirectory", export_directory_);
  return s.status() == QSettings::NoError;
}
