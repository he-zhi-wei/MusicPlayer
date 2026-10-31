#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QIcon>
#include <QQuickStyle>
#include "src/AudioPlayer.h"
#include "src/PlaylistManager.h"
#include "src/MusicScanner.h"
#include "src/MusicInfo.h"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    app.setApplicationName("MusicPlayer");
    app.setOrganizationName("p1");

    // 使用非原生样式，使 QML 中自定义的 Slider/控件样式生效
    QQuickStyle::setStyle("Basic");

    // Register value type for QML property/signal usage
    qRegisterMetaType<MusicInfo>("MusicInfo");
    qmlRegisterUncreatableType<MusicInfo>("p1", 1, 0, "musicInfo",
        "MusicInfo is a value type, not directly creatable from QML");

    QQmlApplicationEngine engine;

    // Create backend singletons
    auto *audioPlayer  = new AudioPlayer(&app);
    auto *playlistMgr  = new PlaylistManager(&app);
    auto *musicScanner = new MusicScanner(&app);

    // Wire: PlaylistManager → AudioPlayer
    QObject::connect(playlistMgr, &PlaylistManager::trackRequested,
                     audioPlayer, &AudioPlayer::loadTrack);

    // Wire: AudioPlayer track ended → next track
    QObject::connect(audioPlayer, &AudioPlayer::trackEnded,
                     playlistMgr, &PlaylistManager::nextTrack);

    // Wire: scanner found files → populate playlist
    QObject::connect(musicScanner, &MusicScanner::tracksFound,
                     playlistMgr, &PlaylistManager::addTracks);

    // Expose to QML
    engine.rootContext()->setContextProperty("Audio",   audioPlayer);
    engine.rootContext()->setContextProperty("Playlist", playlistMgr);
    engine.rootContext()->setContextProperty("Scanner",  musicScanner);

    engine.loadFromModule("p1", "Main");

    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
