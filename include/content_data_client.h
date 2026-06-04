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
 * @brief 采集结果状态 / Collection result status
 * @details 用于区分真实数据、真实空结果、接口错误、网络错误和示例兜底，
 *          避免把示例数据或错误当成真实采集结果展示给用户。
 *          Distinguishes real data, real empty results, API errors, network
 *          errors, and sample fallback so the UI never shows fabricated or
 *          error states as if they were genuine collected results.
 */
enum class HotTypicalStatus {
  RealData,       ///< code:0 且有数据 / code:0 with data
  RealEmpty,      ///< code:0 但无数据（真实空结果）/ code:0 but empty
  ApiError,       ///< code!=0（key 失效/余额不足/参数错）/ code!=0
  NetworkError,   ///< 网络超时/连接失败 / timeout or connection failure
  ValidationError,///< 本地参数校验失败 / local validation failed
  SampleFallback  ///< 未配置 key，使用本地示例 / no key, local sample
};

/**
 * @brief `/fbmain/monitor/v3/hot_typical_search` 完整响应信封 / Full response envelope
 * @details 保留官方返回的全部元数据（花费、余额、总数、总页、计费说明、状态码），
 *          供 UI 真实展示，绝不丢弃。Keeps every official metadata field for
 *          honest visualization; nothing is discarded.
 */
struct HotTypicalResponse {
  HotTypicalStatus status = HotTypicalStatus::NetworkError;
  int code = -1;                ///< 状态码，0 为成功 / status code, 0 = success
  QString msg;                  ///< 提示信息 / message
  QString note;                 ///< 计费说明 / fee note
  double cost = 0.0;            ///< 本次花费 / cost of this call
  double remain_money = 0.0;    ///< 账户余额 / remaining balance
  int total = 0;                ///< 结果总量 / total results
  int total_page = 0;           ///< 结果总页数 / total pages
  QVector<Article> articles;    ///< 解析出的文章 / parsed articles
  QString error_text;           ///< 错误详情（网络/校验）/ error detail
  bool isReal() const { return status == HotTypicalStatus::RealData || status == HotTypicalStatus::RealEmpty; }
  bool isSample() const { return status == HotTypicalStatus::SampleFallback; }
};

/**
 * @brief 内容数据服务 客户端 / Content Data Service client
 *
 * @details 构造请求体、执行同步 HTTP POST、解析文章响应，并在未配置密钥时进入安全示例采集。
 *          Builds payloads, performs blocking HTTP POST calls, parses article responses, and falls back to safe sample collection when credentials are not configured.
 */
class ContentDataClient : public QObject {
  Q_OBJECT
 public:
  explicit ContentDataClient(QObject* parent = nullptr);

  /**
   * @brief 构造公众号文章搜索请求 / Build article-search payload
   * @details 将关键词、页码、API key 和 verify code 转成内容数据文章搜索接口需要的 JSON 字段。
   *          Converts keyword, page, API key, and verify code into the JSON fields expected by the article-search endpoint.
   * @param keyword 搜索关键词 / Search keyword
   * @param page 页码 / Page number
   * @param api_key 内容数据服务 Key / Content Data Service key
   * @param verify_code 验证码 / Verification code
   * @return 请求 JSON / Request JSON object
   */
  QJsonObject buildArticleSearchPayload(const QString& keyword, int page, const QString& api_key, const QString& verify_code) const;

  /**
   * @brief 构造通用接口请求 / Build generic endpoint payload
   * @details 兼容不同内容数据 endpoint，保留常用分页与认证字段。
   *          Provides a common payload shape for multiple ContentData endpoints with pagination and authentication fields.
   * @param keyword 搜索关键词 / Search keyword
   * @param page 页码 / Page number
   * @param api_key 内容数据服务 Key / Content Data Service key
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
   * @param api_key 内容数据服务 Key / Content Data Service key
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
   * @param api_key 内容数据服务 Key / Content Data Service key
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
   * @brief 获取爆文搜索完整响应信封 / Fetch full hot-article response envelope
   * @details 区分真实数据、真实空结果、接口错误、网络错误、参数错误和示例兜底，
   *          保留 code/msg/note/cost/remain_money/total/total_page 等全部元数据。
   *          关键：配置真实 key 时，空结果或接口错误绝不用示例数据冒充，也不盲目重试烧钱；
   *          仅网络错误才重试。Never fabricates sample data for a configured key, and only
   *          retries on network errors so empty results and API errors do not burn balance.
   */
  HotTypicalResponse fetchHotTypical(const QString& base_url, const QString& api_key, const QString& keyword,
                                     const QString& pub_type, const QString& category, int page,
                                     const QString& start_time, const QString& end_time) const;

  /**
   * @brief 解析爆文搜索响应信封 / Parse hot-article response envelope
   * @details 提取官方返回的全部元数据并按 code 判定状态，code!=0 视为接口错误。
   *          Extracts every official metadata field and treats code!=0 as an API error.
   */
  HotTypicalResponse parseHotTypicalResponse(const QByteArray& json, const QString& keyword) const;

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
   * @param api_key 内容数据服务 Key / Content Data Service key
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
