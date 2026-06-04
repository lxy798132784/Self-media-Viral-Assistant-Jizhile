cmake_minimum_required(VERSION 3.22)
project(MediaHitAssistant VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

find_package(Qt6 6.2 REQUIRED COMPONENTS Core Gui Qml Quick QuickControls2 Sql Network Test)

if(WIN32)
    set(CMAKE_WIN32_EXECUTABLE ON)
endif()

qt_add_executable(media-hit-assistant
    include/app_controller.h
    include/config_manager.h
    include/database_manager.h
    include/content_data_client.h
    src/main.cpp
    include/collection_task.h
    src/app_controller.cpp
    src/config_manager.cpp
    src/api_catalog.cpp
    src/database_manager.cpp
    src/export_service.cpp
    src/content_data_client.cpp
    src/plugin_interfaces.cpp
    resources/qml.qrc
)

target_include_directories(media-hit-assistant PRIVATE include)
target_compile_definitions(media-hit-assistant PRIVATE MEDIA_HIT_SOURCE_DIR="${CMAKE_SOURCE_DIR}")
target_link_libraries(media-hit-assistant PRIVATE Qt6::Core Qt6::Gui Qt6::Qml Qt6::Quick Qt6::QuickControls2 Qt6::Sql Qt6::Network)

include(CTest)
enable_testing()

add_executable(unit_tests
    include/config_manager.h
    include/database_manager.h
    include/content_data_client.h
    include/app_controller.h
    include/collection_task.h
    tests/test_core.cpp
    src/app_controller.cpp
    src/config_manager.cpp
    src/api_catalog.cpp
    src/database_manager.cpp
    src/export_service.cpp
    src/content_data_client.cpp
    src/plugin_interfaces.cpp
)
target_include_directories(unit_tests PRIVATE include)
target_compile_definitions(unit_tests PRIVATE MEDIA_HIT_SOURCE_DIR="${CMAKE_SOURCE_DIR}")
target_link_libraries(unit_tests PRIVATE Qt6::Core Qt6::Gui Qt6::Sql Qt6::Network Qt6::Test)
add_test(NAME unit_tests COMMAND unit_tests WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
set_tests_properties(unit_tests PROPERTIES ENVIRONMENT "QT_QPA_PLATFORM=offscreen;QT_QUICK_BACKEND=software")

# 一次性真实 API 探针（仅手动运行，不参与 CTest），验证诚实信封端到端。
# One-shot live API probe (manual only, excluded from CTest) for honest envelope verification.
add_executable(live_probe
    include/content_data_client.h
    include/article.h
    tests/live_probe.cpp
    src/content_data_client.cpp
)
target_include_directories(live_probe PRIVATE include)
target_link_libraries(live_probe PRIVATE Qt6::Core Qt6::Network)

include(GNUInstallDirs)
install(TARGETS media-hit-assistant RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})
install(FILES packaging/com.mediahit.Assistant.desktop DESTINATION ${CMAKE_INSTALL_DATADIR}/applications)
install(FILES packaging/com.mediahit.Assistant.metainfo.xml DESTINATION ${CMAKE_INSTALL_DATADIR}/metainfo)
install(FILES packaging/com.mediahit.Assistant.svg DESTINATION ${CMAKE_INSTALL_DATADIR}/icons/hicolor/scalable/apps)
install(FILES README.md LICENSE CHANGELOG.md DESTINATION ${CMAKE_INSTALL_DOCDIR})
install(DIRECTORY docs/ DESTINATION ${CMAKE_INSTALL_DOCDIR}/docs)
install(DIRECTORY plugins/ DESTINATION ${CMAKE_INSTALL_DATADIR}/media-hit-assistant/plugins)
install(FILES vendor/content-data/api-index.json DESTINATION ${CMAKE_INSTALL_DATADIR}/media-hit-assistant/vendor/content-data)
