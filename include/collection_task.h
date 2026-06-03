#pragma once
#include <QString>

/**
 * @brief 采集任务配置 / Collection task configuration
 *
 * @details 描述一次公众号爆款采集任务的关键词、接口模式、频率、次数和分页参数。
 *          Describes one WeChat hit-article collection task, including keyword, API mode, frequency, run count, and pagination.
 *
 * @note 该结构可直接保存到 SQLite，也可由 QML 表单创建。
 *       This structure can be persisted to SQLite or created from a QML form.
 */
struct CollectionTask {
  int id = 0;
  QString name;
  QString keyword;
  QString endpointPath;
  int intervalSeconds = 300;
  int maxRuns = 10;
  int currentRuns = 0;
  int pageSize = 20;
  bool enabled = true;
};
