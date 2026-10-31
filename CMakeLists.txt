cmake_minimum_required(VERSION 3.16)

project(p1 VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS
    Quick
    QuickControls2
    QuickLayouts
    QuickDialogs2
    Multimedia
    Sql
    Widgets
)

qt_standard_project_setup(REQUIRES 6.5)

# 为 QML 子目录（qml/components、qml/pages）自动生成 qmldir，消除 QTP0004 警告
qt_policy(SET QTP0004 NEW)

qt_add_executable(appp1
    main.cpp
    src/AudioPlayer.cpp
    src/PlaylistManager.cpp
    src/MusicScanner.cpp
)

# Must be set BEFORE qt_add_qml_module for singleton registration to work
set_source_files_properties(
    qml/Theme.qml PROPERTIES
    QT_QML_SINGLETON_TYPE TRUE
)

qt_add_qml_module(appp1
    URI p1
    VERSION 1.0
    QML_FILES
        qml/Main.qml
        qml/AppShell.qml
        qml/Sidebar.qml
        qml/PlaylistView.qml
        qml/NowPlayingBar.qml
        qml/FullPlayerPage.qml
        qml/Theme.qml
        qml/pages/DiscoverPage.qml
        qml/components/GlassPanel.qml
        qml/components/AlbumArt.qml
        qml/components/VinylAnimation.qml
        qml/components/ProgressSlider.qml
        qml/components/PlaybackControls.qml
        qml/components/MusicRowDelegate.qml
        qml/components/NavButton.qml
        qml/components/ControlButton.qml
    SOURCES
        src/MusicInfo.h
        src/AudioPlayer.h
        src/PlaylistManager.h
        src/MusicScanner.h
)

target_link_libraries(appp1 PRIVATE
    Qt6::Quick
    Qt6::QuickControls2
    Qt6::QuickLayouts
    Qt6::QuickDialogs2
    Qt6::Multimedia
    Qt6::Sql
    Qt6::Widgets
)

set_target_properties(appp1 PROPERTIES
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE FALSE
)

install(TARGETS appp1
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
