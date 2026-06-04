cmake_minimum_required(VERSION 3.22)
project(MediaHitAssistant VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

find_package(Qt6 6.2 REQUIRED COMPONENTS Core Gui Qml Quick QuickControls2 Sql Network Test)

qt_add_executable(media-hit-assistant
    include/app_controller.h
    include/config_manager.h
    include/database_manager.h
    include/jizhilia_client.h
    src/main.cpp
    include/collection_task.h
    src/app_controller.cpp
    src/config_manager.cpp
    src/api_catalog.cpp
    src/database_manager.cpp
    src/export_service.cpp
    src/jizhilia_client.cpp
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
    include/jizhilia_client.h
    include/app_controller.h
    include/collection_task.h
    tests/test_core.cpp
    src/app_controller.cpp
    src/config_manager.cpp
    src/api_catalog.cpp
    src/database_manager.cpp
    src/export_service.cpp
    src/jizhilia_client.cpp
    src/plugin_interfaces.cpp
)
target_include_directories(unit_tests PRIVATE include)
target_compile_definitions(unit_tests PRIVATE MEDIA_HIT_SOURCE_DIR="${CMAKE_SOURCE_DIR}")
target_link_libraries(unit_tests PRIVATE Qt6::Core Qt6::Sql Qt6::Network Qt6::Test)
add_test(NAME unit_tests COMMAND unit_tests WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})

include(GNUInstallDirs)
install(TARGETS media-hit-assistant RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})
install(FILES packaging/com.mediahit.Assistant.desktop DESTINATION ${CMAKE_INSTALL_DATADIR}/applications)
install(FILES packaging/com.mediahit.Assistant.metainfo.xml DESTINATION ${CMAKE_INSTALL_DATADIR}/metainfo)
install(FILES packaging/com.mediahit.Assistant.svg DESTINATION ${CMAKE_INSTALL_DATADIR}/icons/hicolor/scalable/apps)
install(FILES README.md LICENSE CHANGELOG.md DESTINATION ${CMAKE_INSTALL_DOCDIR})
install(DIRECTORY docs/ DESTINATION ${CMAKE_INSTALL_DOCDIR}/docs)
install(DIRECTORY plugins/ DESTINATION ${CMAKE_INSTALL_DATADIR}/media-hit-assistant/plugins)
install(FILES vendor/jizhilia-api-knowledge/api-index.json DESTINATION ${CMAKE_INSTALL_DATADIR}/media-hit-assistant/vendor)
