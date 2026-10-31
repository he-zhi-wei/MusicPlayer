#pragma once

#include <QObject>
#include <QList>
#include <QVariantList>
#include <QRandomGenerator>
#include "MusicInfo.h"

class PlaylistManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVariantList playlist READ playlistVariant NOTIFY playlistChanged)
    Q_PROPERTY(int currentIndex READ currentIndex NOTIFY currentIndexChanged)
    Q_PROPERTY(int trackCount READ trackCount NOTIFY playlistChanged)
    Q_PROPERTY(bool shuffleEnabled READ isShuffleEnabled NOTIFY shuffleModeChanged)
    Q_PROPERTY(int repeatMode READ repeatMode NOTIFY repeatModeChanged)
    Q_PROPERTY(MusicInfo currentTrack READ currentTrack NOTIFY currentIndexChanged)

public:
    explicit PlaylistManager(QObject *parent = nullptr);

    enum RepeatMode {
        RepeatOff  = 0,
        RepeatAll  = 1,
        RepeatOne  = 2
    };
    Q_ENUM(RepeatMode)

    QVariantList playlistVariant() const;
    int currentIndex() const;
    int trackCount() const;
    bool isShuffleEnabled() const;
    int repeatMode() const;
    MusicInfo currentTrack() const;

    // Useful computed property for QML
    Q_INVOKABLE MusicInfo trackAt(int index) const;

public slots:
    void addTrack(const MusicInfo &track);
    void addTracks(const QList<MusicInfo> &tracks);
    void removeTrack(int index);
    void clearPlaylist();

    void playTrackAt(int index);
    void nextTrack();
    void previousTrack();

    void toggleShuffle();
    void cycleRepeatMode();

    void moveTrack(int from, int to);

signals:
    void playlistChanged();
    void currentIndexChanged();
    void shuffleModeChanged();
    void repeatModeChanged();
    void trackRequested(const MusicInfo &track);

private:
    void reshuffleOrder();
    int  effectiveIndex() const;

    QList<MusicInfo> m_playlist;
    QList<int>       m_shuffleOrder;
    int              m_currentIndex = -1;
    bool             m_shuffle = false;
    RepeatMode       m_repeatMode = RepeatAll;

    QRandomGenerator m_rng;
};
