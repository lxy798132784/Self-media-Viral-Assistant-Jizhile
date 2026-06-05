#include "database_manager.h"
#include <QSqlError>
#include <QSqlQuery>
#include <QStringList>
#include <QUuid>
#include <QVariant>

DatabaseManager::DatabaseManager(QObject* parent) : QObject(parent), connection_name_(QUuid::createUuid().toString()) {}
DatabaseManager::~DatabaseManager() {
  const QString name = connection_name_;
  if (db_.isOpen()) db_.close();
  db_ = QSqlDatabase();
  QSqlDatabase::removeDatabase(name);
}
bool DatabaseManager::open(const QString& database_path) {
  if (db_.isOpen()) return true;
  db_ = QSqlDatabase::addDatabase("QSQLITE", connection_name_);
  db_.setDatabaseName(database_path);
  return db_.open();
}
bool DatabaseManager::initialize() {
  QSqlQuery q(db_);
  const bool articles_ok = q.exec("CREATE TABLE IF NOT EXISTS articles (url TEXT PRIMARY KEY, title TEXT NOT NULL, author TEXT, account_name TEXT, publish_time TEXT, read_count INTEGER DEFAULT 0, like_count INTEGER DEFAULT 0, watch_count INTEGER DEFAULT 0, summary TEXT)");
  // 旧版本只保存标题/账号/阅读等基础字段；热门内容接口文档实际还返回 hot/avg/fans/position/
  // wxid/category/is_original/publish_type/cover。这里做幂等迁移，保证已安装用户不丢字段。
  const QStringList article_migrations = {
      QStringLiteral("ALTER TABLE articles ADD COLUMN hot_score REAL DEFAULT 0"),
      QStringLiteral("ALTER TABLE articles ADD COLUMN avg_read_count INTEGER DEFAULT 0"),
      QStringLiteral("ALTER TABLE articles ADD COLUMN fans_count INTEGER DEFAULT 0"),
      QStringLiteral("ALTER TABLE articles ADD COLUMN position INTEGER DEFAULT 0"),
      QStringLiteral("ALTER TABLE articles ADD COLUMN wxid TEXT"),
      QStringLiteral("ALTER TABLE articles ADD COLUMN category TEXT"),
      QStringLiteral("ALTER TABLE articles ADD COLUMN is_original TEXT"),
      QStringLiteral("ALTER TABLE articles ADD COLUMN publish_type TEXT"),
      QStringLiteral("ALTER TABLE articles ADD COLUMN cover_url TEXT")};
  for (const auto& sql : article_migrations) {
    QSqlQuery migration(db_);
    migration.exec(sql);  // duplicate-column errors are expected after first run; table existence is verified by articles_ok.
  }
  const bool tasks_ok = q.exec("CREATE TABLE IF NOT EXISTS collection_tasks (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, keyword TEXT NOT NULL, endpoint_path TEXT NOT NULL, interval_seconds INTEGER, max_runs INTEGER, current_runs INTEGER DEFAULT 0, page_size INTEGER, enabled INTEGER DEFAULT 1)");
  const bool runs_ok = q.exec("CREATE TABLE IF NOT EXISTS collection_runs (id INTEGER PRIMARY KEY AUTOINCREMENT, task_id INTEGER, run_time TEXT DEFAULT CURRENT_TIMESTAMP, status TEXT, inserted_count INTEGER, message TEXT)");
  return articles_ok && tasks_ok && runs_ok;
}
bool DatabaseManager::upsertArticle(const Article& a) {
  QSqlQuery q(db_);
  q.prepare("INSERT INTO articles(url,title,author,account_name,publish_time,read_count,like_count,watch_count,summary,hot_score,avg_read_count,fans_count,position,wxid,category,is_original,publish_type,cover_url) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?) ON CONFLICT(url) DO UPDATE SET title=excluded.title,author=excluded.author,account_name=excluded.account_name,publish_time=excluded.publish_time,read_count=excluded.read_count,like_count=excluded.like_count,watch_count=excluded.watch_count,summary=excluded.summary,hot_score=excluded.hot_score,avg_read_count=excluded.avg_read_count,fans_count=excluded.fans_count,position=excluded.position,wxid=excluded.wxid,category=excluded.category,is_original=excluded.is_original,publish_type=excluded.publish_type,cover_url=excluded.cover_url");
  q.addBindValue(a.url); q.addBindValue(a.title); q.addBindValue(a.author); q.addBindValue(a.accountName); q.addBindValue(a.publishTime); q.addBindValue(a.readCount); q.addBindValue(a.likeCount); q.addBindValue(a.watchCount); q.addBindValue(a.summary);
  q.addBindValue(a.hotScore); q.addBindValue(a.avgReadCount); q.addBindValue(a.fansCount); q.addBindValue(a.position); q.addBindValue(a.wxid); q.addBindValue(a.category); q.addBindValue(a.isOriginal); q.addBindValue(a.publishType); q.addBindValue(a.coverUrl);
  return q.exec();
}
QVector<Article> DatabaseManager::listArticles(const QString& keyword) const {
  return listArticlesSorted(keyword, QStringLiteral("reads"), 1000);
}
QVector<Article> DatabaseManager::listArticlesSorted(const QString& keyword, const QString& sort_key, int limit) const {
  QVector<Article> rows;
  QSqlQuery q(db_);
  QString order = QStringLiteral("read_count DESC");
  if (sort_key == QStringLiteral("likes")) order = QStringLiteral("like_count DESC");
  if (sort_key == QStringLiteral("watch")) order = QStringLiteral("watch_count DESC");
  if (sort_key == QStringLiteral("hot")) order = QStringLiteral("hot_score DESC");
  if (sort_key == QStringLiteral("fans")) order = QStringLiteral("fans_count DESC");
  if (sort_key == QStringLiteral("recent")) order = QStringLiteral("publish_time DESC");
  const QString base = QStringLiteral("SELECT title,author,account_name,url,publish_time,read_count,like_count,watch_count,summary,hot_score,avg_read_count,fans_count,position,wxid,category,is_original,publish_type,cover_url FROM articles");
  if (keyword.trimmed().isEmpty()) {
    q.prepare(base + QStringLiteral(" ORDER BY ") + order + QStringLiteral(" LIMIT ?"));
    q.addBindValue(qMax(1, limit));
  } else {
    q.prepare(base + QStringLiteral(" WHERE title LIKE ? OR account_name LIKE ? OR summary LIKE ? ORDER BY ") + order + QStringLiteral(" LIMIT ?"));
    const QString like = "%" + keyword + "%"; q.addBindValue(like); q.addBindValue(like); q.addBindValue(like); q.addBindValue(qMax(1, limit));
  }
  if (!q.exec()) return rows;
  while (q.next()) {
    Article a; a.title=q.value(0).toString(); a.author=q.value(1).toString(); a.accountName=q.value(2).toString(); a.url=q.value(3).toString(); a.publishTime=q.value(4).toString(); a.readCount=q.value(5).toInt(); a.likeCount=q.value(6).toInt(); a.watchCount=q.value(7).toInt(); a.summary=q.value(8).toString();
    a.hotScore=q.value(9).toDouble(); a.avgReadCount=q.value(10).toInt(); a.fansCount=q.value(11).toInt(); a.position=q.value(12).toInt(); a.wxid=q.value(13).toString(); a.category=q.value(14).toString(); a.isOriginal=q.value(15).toString(); a.publishType=q.value(16).toString(); a.coverUrl=q.value(17).toString(); rows.push_back(a);
  }
  return rows;
}
int DatabaseManager::articleCount() const { QSqlQuery q(db_); if(q.exec("SELECT COUNT(*) FROM articles") && q.next()) return q.value(0).toInt(); return 0; }
int DatabaseManager::totalReads() const { QSqlQuery q(db_); if(q.exec("SELECT COALESCE(SUM(read_count),0) FROM articles") && q.next()) return q.value(0).toInt(); return 0; }
int DatabaseManager::totalLikes() const { QSqlQuery q(db_); if(q.exec("SELECT COALESCE(SUM(like_count),0) FROM articles") && q.next()) return q.value(0).toInt(); return 0; }
int DatabaseManager::saveTask(const CollectionTask& task) {
  QSqlQuery q(db_);
  if (task.id > 0) {
    q.prepare("UPDATE collection_tasks SET name=?, keyword=?, endpoint_path=?, interval_seconds=?, max_runs=?, current_runs=?, page_size=?, enabled=? WHERE id=?");
    q.addBindValue(task.name); q.addBindValue(task.keyword); q.addBindValue(task.endpointPath); q.addBindValue(task.intervalSeconds); q.addBindValue(task.maxRuns); q.addBindValue(task.currentRuns); q.addBindValue(task.pageSize); q.addBindValue(task.enabled ? 1 : 0); q.addBindValue(task.id);
    return q.exec() ? task.id : 0;
  }
  q.prepare("INSERT INTO collection_tasks(name,keyword,endpoint_path,interval_seconds,max_runs,current_runs,page_size,enabled) VALUES(?,?,?,?,?,?,?,?)");
  q.addBindValue(task.name); q.addBindValue(task.keyword); q.addBindValue(task.endpointPath); q.addBindValue(task.intervalSeconds); q.addBindValue(task.maxRuns); q.addBindValue(task.currentRuns); q.addBindValue(task.pageSize); q.addBindValue(task.enabled ? 1 : 0);
  if (!q.exec()) return 0;
  return q.lastInsertId().toInt();
}
QVector<CollectionTask> DatabaseManager::listTasks() const {
  QVector<CollectionTask> tasks;
  QSqlQuery q(db_);
  if (!q.exec("SELECT id,name,keyword,endpoint_path,interval_seconds,max_runs,current_runs,page_size,enabled FROM collection_tasks ORDER BY id DESC")) return tasks;
  while (q.next()) {
    CollectionTask t; t.id=q.value(0).toInt(); t.name=q.value(1).toString(); t.keyword=q.value(2).toString(); t.endpointPath=q.value(3).toString(); t.intervalSeconds=q.value(4).toInt(); t.maxRuns=q.value(5).toInt(); t.currentRuns=q.value(6).toInt(); t.pageSize=q.value(7).toInt(); t.enabled=q.value(8).toInt()!=0; tasks.push_back(t);
  }
  return tasks;
}
bool DatabaseManager::recordCollectionRun(int task_id, const QString& status, int inserted_count, const QString& message) {
  QSqlQuery q(db_);
  q.prepare("INSERT INTO collection_runs(task_id,status,inserted_count,message) VALUES(?,?,?,?)");
  q.addBindValue(task_id); q.addBindValue(status); q.addBindValue(inserted_count); q.addBindValue(message);
  return q.exec();
}
int DatabaseManager::runCount(int task_id) const {
  QSqlQuery q(db_);
  if (task_id >= 0) {
    q.prepare("SELECT COUNT(*) FROM collection_runs WHERE task_id=?");
    q.addBindValue(task_id);
  } else {
    q.prepare("SELECT COUNT(*) FROM collection_runs");
  }
  if (q.exec() && q.next()) return q.value(0).toInt();
  return 0;
}
bool DatabaseManager::incrementTaskRun(int task_id) {
  if (task_id <= 0) return false;
  QSqlQuery q(db_);
  q.prepare("UPDATE collection_tasks SET current_runs=current_runs+1 WHERE id=?");
  q.addBindValue(task_id);
  return q.exec() && q.numRowsAffected() > 0;
}

QStringList DatabaseManager::runRows(int limit) const {
  QStringList rows;
  QSqlQuery q(db_);
  q.prepare("SELECT id, task_id, run_time, status, inserted_count, message FROM collection_runs ORDER BY id DESC LIMIT ?");
  q.addBindValue(qMax(1, limit));
  if (!q.exec()) return rows;
  while (q.next()) {
    rows << QStringLiteral("#%1｜任务 %2｜%3｜%4｜新增 %5｜%6")
      .arg(q.value(0).toInt())
      .arg(q.value(1).toInt())
      .arg(q.value(2).toString(), q.value(3).toString())
      .arg(q.value(4).toInt())
      .arg(q.value(5).toString().left(80));
  }
  return rows;
}
