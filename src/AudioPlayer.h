#pragma once

#include <QObject>
#include <QMediaPlayer>
#include <QAudioOutput>
#include "MusicInfo.h"

class AudioPlayer : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int playbackState READ playbackState NOTIFY playbackStateChanged)
    Q_PROPERTY(qint64 position READ position NOTIFY positionChanged)
    Q_PROPERTY(qint64 duration READ duration NOTIFY durationChanged)
    Q_PROPERTY(qreal volume READ volume WRITE setVolume NOTIFY volumeChanged)
    Q_PROPERTY(bool muted READ isMuted WRITE setMuted NOTIFY mutedChanged)
    Q_PROPERTY(MusicInfo currentTrack READ currentTrack NOTIFY currentTrackChanged)
    Q_PROPERTY(bool hasNext READ hasNext NOTIFY hasNextChanged)
    Q_PROPERTY(bool hasPrevious READ hasPrevious NOTIFY hasPreviousChanged)
    Q_PROPERTY(QString positionString READ positionString NOTIFY positionChanged)
    Q_PROPERTY(QString durationString READ durationString NOTIFY durationChanged)

public:
    explicit AudioPlayer(QObject *parent = nullptr);

    enum PlaybackState {
        Stopped = 0,
        Playing = 1,
        Paused  = 2
    };
    Q_ENUM(PlaybackState)

    int playbackState() const;
    qint64 position() const;
    qint64 duration() const;
    qreal volume() const;
    bool isMuted() const;
    MusicInfo currentTrack() const;
    bool hasNext() const;
    bool hasPrevious() const;
    QString positionString() const;
    QString durationString() const;

public slots:
    // 属性 setter 同时声明为槽，QML 才能用 Audio.setVolume(x) 这种形式调用
    void setVolume(qreal v);
    void setMuted(bool m);
    void play();
    void pause();
    void togglePlayPause();
    void stop();
    void seek(qint64 positionMs);
    void next();
    void previous();
    void toggleMute();
    void loadTrack(const MusicInfo &track);
    // 恢复到上次的曲目与进度，但不自动播放
    void restoreTrack(const MusicInfo &track, qint64 positionMs);

signals:
    void playbackStateChanged();
    void positionChanged();
    void durationChanged();
    void volumeChanged();
    void mutedChanged();
    void currentTrackChanged();
    void hasNextChanged();
    void hasPreviousChanged();
    void trackEnded();
    void errorOccurred(const QString &message);

private slots:
    void onMediaStatusChanged(QMediaPlayer::MediaStatus status);
    void onPlaybackStateChanged(QMediaPlayer::PlaybackState state);
    void onPositionChanged(qint64 pos);
    void onDurationChanged(qint64 dur);
    void onErrorOccurred(QMediaPlayer::Error error, const QString &errorString);

private:
    QMediaPlayer *m_player;
    QAudioOutput *m_audioOutput;
    MusicInfo m_currentTrack;
    qint64 m_pendingSeek = -1;   // 等待媒体加载完成后跳转的位置（毫秒）

    static QString formatMs(qint64 ms);
};
