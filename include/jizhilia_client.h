#pragma once
#include <QObject>
#include <QJsonObject>
#include <QNetworkAccessManager>
#include <QVector>
#include "article.h"

/**
 * @brief 极致了 API 客户端 / Jizhilia API client
 *
 * @details 构造请求体、统一校验配置，并为后续真实网络请求提供封装入口。
 *          Builds request payloads, validates settings, and provides an extension point for real network requests.
 */
class JizhiliaClient : public QObject {
  Q_OBJECT
 public:
  explicit JizhiliaClient(QObject* parent = nullptr);
  QJsonObject buildArticleSearchPayload(const QString& keyword, int page, const QString& api_key, const QString& verify_code) const;
  QJsonObject buildGenericPayload(const QString& keyword, int page, const QString& api_key, const QString& verify_code) const;
  QVector<Article> mockSearchArticles(const QString& keyword, int page) const;
  QVector<Article> mockEndpointArticles(const QString& endpoint_path, const QString& keyword, int page) const;
  QVector<Article> parseArticlesFromJson(const QByteArray& json, const QString& keyword) const;
  QVector<Article> searchArticlesBlocking(const QString& base_url, const QString& api_key, const QString& verify_code, const QString& keyword, int page, QString* error_message) const;
  QVector<Article> callEndpointBlocking(const QString& base_url, const QString& endpoint_path, const QString& api_key, const QString& verify_code, const QString& keyword, int page, QString* error_message) const;
  bool isRetryableStatus(int status_code) const;
  int retryDelayMs(int attempt) const;
  bool isConfigured(const QString& api_key) const;
 private:
  QByteArray postJsonBlocking(const QString& url, const QJsonObject& payload, QString* error_message) const;
};
