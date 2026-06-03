#pragma once
#include <QObject>
#include <QSqlDatabase>
#include <QStringList>
#include <QVector>
#include "article.h"
#include "collection_task.h"

/**
 * @brief SQLite 数据库管理器 / SQLite database manager
 *
 * @details 初始化 schema、保存文章、查询文章列表和统计指标。
 *          Initializes schema, saves articles, queries article lists and metrics.
 */
class DatabaseManager : public QObject {
  Q_OBJECT
 public:
  explicit DatabaseManager(QObject* parent = nullptr);
  ~DatabaseManager() override;
  bool open(const QString& database_path);
  bool initialize();
  bool upsertArticle(const Article& article);
  QVector<Article> listArticles(const QString& keyword = QString()) const;
  QVector<Article> listArticlesSorted(const QString& keyword, const QString& sort_key, int limit = 100) const;
  int articleCount() const;
  int totalReads() const;
  int totalLikes() const;
  int saveTask(const CollectionTask& task);
  QVector<CollectionTask> listTasks() const;
  bool recordCollectionRun(int task_id, const QString& status, int inserted_count, const QString& message);
  int runCount(int task_id = -1) const;
  bool incrementTaskRun(int task_id);
  QStringList runRows(int limit = 50) const;
 private:
  QString connection_name_;
  QSqlDatabase db_;
};
