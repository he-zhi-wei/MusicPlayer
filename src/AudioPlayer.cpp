#include "AudioPlayer.h"
#include <QUrl>
#include <QDebug>

AudioPlayer::AudioPlayer(QObject *parent)
    : QObject(parent)
    , m_player(new QMediaPlayer(this))
    , m_audioOutput(new QAudioOutput(this))
{
    m_player->setAudioOutput(m_audioOutput);
    m_audioOutput->setVolume(0.7);

    connect(m_player, &QMediaPlayer::playbackStateChanged,
            this, &AudioPlayer::onPlaybackStateChanged);
    connect(m_player, &QMediaPlayer::positionChanged,
            this, &AudioPlayer::onPositionChanged);
    connect(m_player, &QMediaPlayer::durationChanged,
            this, &AudioPlayer::onDurationChanged);
    connect(m_player, &QMediaPlayer::mediaStatusChanged,
            this, &AudioPlayer::onMediaStatusChanged);
    connect(m_player, &QMediaPlayer::errorOccurred,
            this, &AudioPlayer::onErrorOccurred);
}

// ---- property getters ----

int AudioPlayer::playbackState() const
{
    return static_cast<int>(m_player->playbackState());
}

qint64 AudioPlayer::position() const { return m_player->position(); }

qint64 AudioPlayer::duration() const { return m_player->duration(); }

qreal AudioPlayer::volume() const { return m_audioOutput->volume(); }

bool AudioPlayer::isMuted() const { return m_audioOutput->isMuted(); }

MusicInfo AudioPlayer::currentTrack() const { return m_currentTrack; }

bool AudioPlayer::hasNext() const { return true; }   // managed by PlaylistManager

bool AudioPlayer::hasPrevious() const { return true; }

QString AudioPlayer::positionString() const { return formatMs(m_player->position()); }

QString AudioPlayer::durationString() const { return formatMs(m_player->duration()); }

void AudioPlayer::setVolume(qreal v) {
    v = qBound(0.0, v, 1.0);
    if (!qFuzzyCompare(static_cast<double>(m_audioOutput->volume()), static_cast<double>(v))) {
        m_audioOutput->setVolume(v);
        emit volumeChanged();
    }
}

void AudioPlayer::setMuted(bool m) {
    if (m_audioOutput->isMuted() != m) {
        m_audioOutput->setMuted(m);
        emit mutedChanged();
    }
}

// ---- playback control ----

void AudioPlayer::play() { m_player->play(); }

void AudioPlayer::pause() { m_player->pause(); }

void AudioPlayer::togglePlayPause() {
    if (m_player->playbackState() == QMediaPlayer::PlayingState)
        m_player->pause();
    else
        m_player->play();
}

void AudioPlayer::stop() { m_player->stop(); }

void AudioPlayer::seek(qint64 positionMs) {
    m_player->setPosition(positionMs);
}

void AudioPlayer::next() { emit trackEnded(); }

void AudioPlayer::previous() { /* handled by PlaylistManager */ }

void AudioPlayer::toggleMute() {
    setMuted(!m_audioOutput->isMuted());
}

void AudioPlayer::loadTrack(const MusicInfo &track) {
    m_currentTrack = track;
    m_player->setSource(QUrl::fromLocalFile(track.filePath));
    m_player->play();
    emit currentTrackChanged();
}

// ---- internal slots ----

void AudioPlayer::onMediaStatusChanged(QMediaPlayer::MediaStatus status) {
    if (status == QMediaPlayer::EndOfMedia) {
        emit trackEnded();
    }
}

void AudioPlayer::onPlaybackStateChanged(QMediaPlayer::PlaybackState state) {
    Q_UNUSED(state)
    emit playbackStateChanged();
}

void AudioPlayer::onPositionChanged(qint64 pos) {
    Q_UNUSED(pos)
    emit positionChanged();
}

void AudioPlayer::onDurationChanged(qint64 dur) {
    Q_UNUSED(dur)
    emit durationChanged();
}

void AudioPlayer::onErrorOccurred(QMediaPlayer::Error error, const QString &errorString) {
    qWarning() << "AudioPlayer error:" << error << errorString;
    emit errorOccurred(errorString);
}

QString AudioPlayer::formatMs(qint64 ms) {
    if (ms <= 0) return "0:00";
    const int totalSec = static_cast<int>(ms / 1000);
    const int min = totalSec / 60;
    const int sec = totalSec % 60;
    return QString("%1:%2").arg(min).arg(sec, 2, 10, QChar('0'));
}
