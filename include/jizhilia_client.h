#pragma once
#include <QObject>
#include <QJsonObject>
#include <QNetworkAccessManager>
#include <QStringList>
#include <QVector>
#include <optional>
#include "article.h"

/**
 * @brief 官网示例中的爆文类型 / Official hot-article type enum.
 * @details API values: 0 text-image, 5 video, 7 music, 8 image, 10 text, 11 repost.
 */
enum class PubType : int { TextImage = 0, Video = 5, Music = 7, Image = 8, Text = 10, Repost = 11 };

/**
 * @brief `/fbmain/monitor/v3/hot_typical_search` 请求模型 / Request model.
 * @details Mirrors the official Apifox sample fields while using Qt/C++20 types.
 */
struct HotTypicalRequest {
  QString category = QStringLiteral("0");
  QString end_time;
  QString key;
  std::optional<QString> keyword;
  QString page = QStringLiteral("1");
  PubType pub_type = PubType::TextImage;
  QString start_time;
};

/**
 * @brief 极致了 API 客户端 / Jizhilia API client
 *
 * @details 构造请求体、执行同步 HTTP POST、解析文章响应，并在未配置密钥时进入安全示例采集。
 *          Builds payloads, performs blocking HTTP POST calls, parses article responses, and falls back to safe sample collection when credentials are not configured.
 */
class JizhiliaClient : public QObject {
  Q_OBJECT
 public:
  explicit JizhiliaClient(QObject* parent = nullptr);

  /**
   * @brief 构造公众号文章搜索请求 / Build article-search payload
   * @details 将关键词、页码、API key 和 verify code 转成极致了文章搜索接口需要的 JSON 字段。
   *          Converts keyword, page, API key, and verify code into the JSON fields expected by the article-search endpoint.
   * @param keyword 搜索关键词 / Search keyword
   * @param page 页码 / Page number
   * @param api_key 极致了 API Key / Jizhilia API key
   * @param verify_code 验证码 / Verification code
   * @return 请求 JSON / Request JSON object
   */
  QJsonObject buildArticleSearchPayload(const QString& keyword, int page, const QString& api_key, const QString& verify_code) const;

  /**
   * @brief 构造通用接口请求 / Build generic endpoint payload
   * @details 兼容不同极致了 endpoint，保留常用分页与认证字段。
   *          Provides a common payload shape for multiple Jizhilia endpoints with pagination and authentication fields.
   * @param keyword 搜索关键词 / Search keyword
   * @param page 页码 / Page number
   * @param api_key 极致了 API Key / Jizhilia API key
   * @param verify_code 验证码 / Verification code
   * @return 请求 JSON / Request JSON object
   */
  QJsonObject buildGenericPayload(const QString& keyword, int page, const QString& api_key, const QString& verify_code) const;

  /**
   * @brief 构造公众号爆文接口请求 / Build official-account hot article payload
   * @details 对齐 Apifox 文档 `/fbmain/monitor/v3/hot_typical_search` 的 multipart/form-data 字段。
   *          Matches the multipart/form-data fields documented for `/fbmain/monitor/v3/hot_typical_search`.
   */
  QJsonObject buildHotTypicalSearchPayload(const QString& api_key, const QString& keyword, const QString& pub_type,
                                           const QString& category, int page, const QString& start_time,
                                           const QString& end_time) const;
  QJsonObject buildHotTypicalSearchPayload(const HotTypicalRequest& request) const;
  bool validateHotTypicalRequest(const HotTypicalRequest& request, QString* error_message) const;
  QString pubTypeToApiValue(PubType pub_type) const;
  std::optional<PubType> pubTypeFromApiValue(const QString& api_value) const;

  /**
   * @brief 返回公众号爆文接口参数名 / Return hot article API parameter names
   */
  QStringList hotTypicalParameterNames() const;

  /**
   * @brief 生成示例文章 / Generate sample articles
   * @details 在没有真实密钥或网络不可用时，生成可写入 SQLite 的样本数据，保证分析和导出闭环可验证。
   *          Generates SQLite-ready sample data when credentials or network are unavailable so analysis and export remain verifiable.
   * @param keyword 关键词 / Keyword
   * @param page 页码 / Page number
   * @return 文章列表 / Article list
   */
  QVector<Article> mockSearchArticles(const QString& keyword, int page) const;

  /**
   * @brief 生成指定 endpoint 的示例文章 / Generate endpoint-specific sample articles
   * @details 在样本摘要中记录 endpoint path，方便确认接口选择是否贯穿采集链路。
   *          Adds the endpoint path into sample summaries so endpoint selection can be verified through the collection pipeline.
   * @param endpoint_path 接口路径 / Endpoint path
   * @param keyword 关键词 / Keyword
   * @param page 页码 / Page number
   * @return 文章列表 / Article list
   */
  QVector<Article> mockEndpointArticles(const QString& endpoint_path, const QString& keyword, int page) const;

  /**
   * @brief 解析文章 JSON / Parse article JSON
   * @details 支持 data、list、records 等常见数组字段，并把阅读、点赞、在看等指标映射为 Article。
   *          Supports common array fields such as data, list, and records, then maps reads, likes, and watch metrics into Article objects.
   * @param json 原始 JSON 响应 / Raw JSON response
   * @param keyword 回退关键词 / Fallback keyword
   * @return 文章列表 / Article list
   */
  QVector<Article> parseArticlesFromJson(const QByteArray& json, const QString& keyword) const;

  /**
   * @brief 同步搜索文章 / Search articles synchronously
   * @details 配置有效时请求真实接口；未配置时返回示例数据并写入错误说明。
   *          Calls the real endpoint when configured; otherwise returns sample data and writes an explanatory message.
   * @param base_url API 根地址 / API base URL
   * @param api_key 极致了 API Key / Jizhilia API key
   * @param verify_code 验证码 / Verification code
   * @param keyword 关键词 / Keyword
   * @param page 页码 / Page number
   * @param error_message 错误说明输出 / Error message output
   * @return 文章列表 / Article list
   */
  QVector<Article> searchArticlesBlocking(const QString& base_url, const QString& api_key, const QString& verify_code, const QString& keyword, int page, QString* error_message) const;

  /**
   * @brief 同步调用任意 endpoint / Call any endpoint synchronously
   * @details 使用 endpoint path 组合 URL，统一请求、解析、错误处理和示例回退。
   *          Combines base URL and endpoint path, then applies shared request, parsing, error handling, and sample fallback logic.
   * @param base_url API 根地址 / API base URL
   * @param endpoint_path 接口路径 / Endpoint path
   * @param api_key 极致了 API Key / Jizhilia API key
   * @param verify_code 验证码 / Verification code
   * @param keyword 关键词 / Keyword
   * @param page 页码 / Page number
   * @param error_message 错误说明输出 / Error message output
   * @return 文章列表 / Article list
   */
  QVector<Article> callEndpointBlocking(const QString& base_url, const QString& endpoint_path, const QString& api_key, const QString& verify_code, const QString& keyword, int page, QString* error_message) const;

  /**
   * @brief 调用公众号爆文接口 / Call hot article endpoint
   * @details 使用 Apifox 文档中的全部参数构造请求；未配置 key 时进入本地示例回退。
   *          Uses every documented Apifox parameter; falls back to local samples when key is not configured.
   */
  QVector<Article> callHotTypicalSearchBlocking(const QString& base_url, const QString& api_key, const QString& keyword,
                                                const QString& pub_type, const QString& category, int page,
                                                const QString& start_time, const QString& end_time,
                                                QString* error_message) const;

  /**
   * @brief 判断 HTTP 状态是否可重试 / Check whether HTTP status is retryable
   * @details 主要覆盖 429 和 5xx，供 fallback 与错误处理策略使用。
   *          Covers 429 and 5xx statuses for retry and fallback decisions.
   * @param status_code HTTP 状态码 / HTTP status code
   * @return 是否可重试 / Whether retry is appropriate
   */
  bool isRetryableStatus(int status_code) const;
  int retryDelayMs(int attempt) const;
  QString classifyApiError(int status_code, const QString& error_text) const;
  QString hotTypicalSmokePlan(const QString& apiKey, const QString& keyword, const QString& pubType,
                              const QString& category, int page, const QString& start_time,
                              const QString& end_time) const;

  /**
   * @brief 判断是否配置 API Key / Check API key configuration
   * @details 空值或占位值视为未配置，系统会进入示例采集模式。
   *          Empty or placeholder values are treated as unconfigured, causing the app to use sample collection mode.
   * @param api_key 极致了 API Key / Jizhilia API key
   * @return 是否已配置 / Whether configured
   */
  bool isConfigured(const QString& api_key) const;
 private:
  /**
   * @brief 发送 JSON POST / Send JSON POST
   * @details 使用 Qt Network 同步等待响应，并返回原始响应体或错误说明。
   *          Uses Qt Network to wait synchronously for a response and returns raw response bytes or an error message.
   * @param url 请求 URL / Request URL
   * @param payload 请求 JSON / Request JSON
   * @param error_message 错误说明输出 / Error message output
   * @return 原始响应体 / Raw response body
   */
  QByteArray postJsonBlocking(const QString& url, const QJsonObject& payload, QString* error_message) const;
  QByteArray postMultipartBlocking(const QString& url, const QJsonObject& payload, QString* error_message) const;
};
