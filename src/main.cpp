#include <QGuiApplication>
#include <QFile>
#include <QDir>
#include <QImage>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickItem>
#include <QQuickItemGrabResult>
#include <QQuickRenderControl>
#include <QQuickStyle>
#include <QQuickView>
#include <QQuickWindow>
#include <QTimer>
#include "app_controller.h"

/**
 * @brief 应用入口 / Application entry point
 *
 * @details 初始化 Qt Quick、注册 AppController，并加载主 QML 页面。
 *          Initializes Qt Quick, registers AppController, and loads the main QML page.
 *
 * @param argc 命令行参数数量 / Command-line argument count
 * @param argv 命令行参数数组 / Command-line argument array
 * @return 进程退出码 / Process exit code
 *
 * @note `--self-test` 用于无界面运行基础初始化验证。
 *       `--self-test` runs a headless initialization check.
 * @example QT_QPA_PLATFORM=offscreen ./media-hit-assistant --self-test
 */
int main(int argc, char* argv[]) {
  QGuiApplication app(argc, argv);
  QQuickStyle::setStyle("Fusion");

  const QStringList args = app.arguments();
  if (args.contains("--self-test")) {
    AppController controller;
    if (!controller.initialize()) return 2;
    controller.loadMockArticles();
    const QString md = QDir::temp().filePath("media-hit-self-test.md");
    const QString xml = QDir::temp().filePath("media-hit-self-test.xml");
    if (!controller.exportMarkdown(md) || !controller.exportXml(xml)) return 3;
    if (!QFile::exists(md) || !QFile::exists(xml)) return 4;
    return controller.articleCount() > 0 ? 0 : 5;
  }

  AppController controller;
  controller.initialize();
  const bool qmlSmoke = args.contains("--qml-smoke");
  const bool screenshotMode = args.contains("--screenshot") || args.contains("--screenshot-page");
  if (screenshotMode || qmlSmoke) {
    controller.loadMockArticles();
    controller.runHotTypicalCollection(QString(), QStringLiteral("AI"), QStringLiteral("0"), QStringLiteral("0"), 1,
                                       QStringLiteral("2026-05-15"), QStringLiteral("2026-05-17"));
  }

  QQmlApplicationEngine engine;
  engine.rootContext()->setContextProperty("appController", &controller);
  const QUrl url(QStringLiteral("qrc:/qml/Main.qml"));
  QObject::connect(&engine, &QQmlApplicationEngine::objectCreated, &app,
                   [url](QObject* obj, const QUrl& objUrl) {
                     if (!obj && url == objUrl) QCoreApplication::exit(-1);
                   }, Qt::QueuedConnection);
  engine.load(url);

  if (screenshotMode) {
    const bool pageShot = args.contains("--screenshot-page");
    const int idx = pageShot ? args.indexOf("--screenshot-page") : args.indexOf("--screenshot");
    const int pageIndex = pageShot && idx + 1 < args.size() ? args.at(idx + 1).toInt() : -1;
    const QString output = pageShot
                               ? (idx + 2 < args.size() ? args.at(idx + 2) : QDir::temp().filePath("media-hit-assistant-page.png"))
                               : (idx + 1 < args.size() ? args.at(idx + 1) : QDir::temp().filePath("media-hit-assistant-screenshot.png"));
    QTimer::singleShot(1400, &app, [&app, &engine, output, pageIndex]() {
      QObject* rootObject = engine.rootObjects().isEmpty() ? nullptr : engine.rootObjects().first();
      if (rootObject && pageIndex >= 0) {
        rootObject->setProperty("currentPageIndex", pageIndex);
      }
      QTimer::singleShot(500, &app, [&app, &engine, output]() {
      QObject* rootObject = engine.rootObjects().isEmpty() ? nullptr : engine.rootObjects().first();
      auto* window = qobject_cast<QQuickWindow*>(rootObject);
      auto* item = qobject_cast<QQuickItem*>(rootObject);
      if (!window && item) {
        window = item->window();
      }
      if (!window) {
        QCoreApplication::exit(6);
        return;
      }
      QImage shot = window->grabWindow();
      if (shot.isNull() || !shot.save(output)) {
        QCoreApplication::exit(7);
        return;
      }
      QCoreApplication::exit(0);
      });
    });
  } else if (qmlSmoke) {
    QTimer::singleShot(1200, &app, [&app, &engine]() {
      if (engine.rootObjects().isEmpty()) {
        QCoreApplication::exit(8);
        return;
      }
      QCoreApplication::exit(0);
    });
  }

  return app.exec();
}
