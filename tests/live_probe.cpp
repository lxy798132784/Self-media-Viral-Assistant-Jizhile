// 一次性真实 API 探针：用真实 key 调一次 fetchHotTypical，验证诚实信封全链路。
// One-shot live probe: single real call to validate the honest envelope end-to-end.
#include <QCoreApplication>
#include <QTextStream>
#include "content_data_client.h"

int main(int argc, char** argv) {
  QCoreApplication app(argc, argv);
  QTextStream out(stdout);
  if (argc < 2) { out << "usage: live_probe <key>\n"; return 2; }
  const QString key = QString::fromUtf8(argv[1]);

  ContentDataClient client;
  // 用官方文档同款日期窗口，关键词 AI，图文类型，分类7，第1页。
  const auto resp = client.fetchHotTypical(QString(), key, QStringLiteral("AI"), QStringLiteral("0"),
                                           QStringLiteral("7"), 1,
                                           QStringLiteral("2025-08-01"), QStringLiteral("2025-08-03"));
  auto statusName = [](HotTypicalStatus s) -> QString {
    switch (s) {
      case HotTypicalStatus::RealData: return "RealData";
      case HotTypicalStatus::RealEmpty: return "RealEmpty";
      case HotTypicalStatus::ApiError: return "ApiError";
      case HotTypicalStatus::NetworkError: return "NetworkError";
      case HotTypicalStatus::ValidationError: return "ValidationError";
      case HotTypicalStatus::SampleFallback: return "SampleFallback";
    }
    return "?";
  };
  out << "=== LIVE PROBE RESULT ===\n";
  out << "status       : " << statusName(resp.status) << "\n";
  out << "code         : " << resp.code << "\n";
  out << "msg          : " << resp.msg << "\n";
  out << "note         : " << resp.note << "\n";
  out << "cost         : " << QString::number(resp.cost, 'f', 4) << "\n";
  out << "remain_money : " << QString::number(resp.remain_money, 'f', 2) << "\n";
  out << "total        : " << resp.total << "\n";
  out << "total_page   : " << resp.total_page << "\n";
  out << "articles     : " << resp.articles.size() << "\n";
  out << "isReal       : " << (resp.isReal() ? "true" : "false") << "\n";
  out << "isSample     : " << (resp.isSample() ? "true" : "false") << "\n";
  if (!resp.articles.isEmpty()) {
    const auto& a = resp.articles.first();
    out << "--- first article ---\n";
    out << "title  : " << a.title << "\n";
    out << "account: " << a.accountName << "\n";
    out << "reads  : " << a.readCount << "  likes: " << a.likeCount << "  hot: " << QString::number(a.hotScore, 'f', 2) << "\n";
    out << "url    : " << a.url << "\n";
  }
  out << "=== END ===\n";
  out.flush();
  return 0;
}
