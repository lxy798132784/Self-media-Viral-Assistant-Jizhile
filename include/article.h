#pragma once
#include <QString>

/**
 * @brief 文章数据结构 / Article data structure
 *
 * @details 表示从公众号 API 或本地数据库得到的一篇文章。
 *          Represents one article fetched from provider APIs or local SQLite.
 */
struct Article {
  QString title;
  QString author;
  QString accountName;
  QString url;
  QString publishTime;
  int readCount = 0;
  int likeCount = 0;
  int watchCount = 0;
  QString summary;
};
