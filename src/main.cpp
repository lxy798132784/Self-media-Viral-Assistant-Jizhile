#include <QGuiApplication>
#include <QFile>
#include <QDir>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>
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

  QQmlApplicationEngine engine;
  engine.rootContext()->setContextProperty("appController", &controller);
  const QUrl url(QStringLiteral("qrc:/qml/Main.qml"));
  QObject::connect(&engine, &QQmlApplicationEngine::objectCreated, &app,
                   [url](QObject* obj, const QUrl& objUrl) {
                     if (!obj && url == objUrl) QCoreApplication::exit(-1);
                   }, Qt::QueuedConnection);
  engine.load(url);
  return app.exec();
}
