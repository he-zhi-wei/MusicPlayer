#include "PlaylistManager.h"
#include <algorithm>
#include <QDebug>
#include <QSettings>
#include <QVariantMap>

PlaylistManager::PlaylistManager(QObject *parent)
    : QObject(parent)
    , m_rng(QRandomGenerator::securelySeeded())
{
    restoreFromDisk();   // 恢复上次的播放列表

    // 列表或当前曲目变化时写盘（QSettings 内部缓冲，开销很小）
    connect(this, &PlaylistManager::playlistChanged, this, [this] { saveToDisk(); });
    connect(this, &PlaylistManager::currentIndexChanged, this, [this] { saveToDisk(); });
}

// ── 持久化 ──

void PlaylistManager::saveToDisk() const
{
    QSettings settings;
    QVariantList list;
    list.reserve(m_playlist.size());
    for (const auto &t : m_playlist) {
        QVariantMap map;
        map["id"] = t.id;
        map["title"] = t.title;
        map["artist"] = t.artist;
        map["album"] = t.album;
        map["durationMs"] = t.durationMs;
        map["filePath"] = t.filePath;
        map["coverArtPath"] = t.coverArtPath;
        list.append(map);
    }
    settings.setValue("playlist/tracks", list);
    settings.setValue("playlist/currentIndex", m_currentIndex);
}

void PlaylistManager::restoreFromDisk()
{
    QSettings settings;
    const QVariantList list = settings.value("playlist/tracks").toList();

    for (const QVariant &v : list) {
        const QVariantMap map = v.toMap();
        MusicInfo track;
        track.id = map.value("id", -1).toInt();
        track.title = map.value("title").toString();
        track.artist = map.value("artist").toString();
        track.album = map.value("album").toString();
        track.durationMs = map.value("durationMs").toLongLong();
        track.filePath = map.value("filePath").toString();
        track.coverArtPath = map.value("coverArtPath").toString();
        if (!track.filePath.isEmpty())
            m_playlist.append(track);
    }

    reshuffleOrder();

    const int savedIndex = settings.value("playlist/currentIndex", -1).toInt();
    if (savedIndex >= 0 && savedIndex < m_playlist.size())
        m_currentIndex = savedIndex;
}

// ── Properties ──

QVariantList PlaylistManager::playlistVariant() const {
    QVariantList list;
    list.reserve(m_playlist.size());
    for (const auto &t : m_playlist)
        list.append(QVariant::fromValue(t));
    return list;
}

int  PlaylistManager::currentIndex() const    { return m_currentIndex; }
int  PlaylistManager::trackCount() const       { return m_playlist.size(); }
bool PlaylistManager::isShuffleEnabled() const { return m_shuffle; }
int  PlaylistManager::repeatMode() const       { return static_cast<int>(m_repeatMode); }

MusicInfo PlaylistManager::currentTrack() const {
    int idx = effectiveIndex();
    return (idx >= 0 && idx < m_playlist.size()) ? m_playlist[idx] : MusicInfo{};
}

MusicInfo PlaylistManager::trackAt(int index) const {
    if (index < 0 || index >= m_playlist.size()) return MusicInfo{};
    const int realIdx = m_shuffle ? m_shuffleOrder[index] : index;
    return m_playlist.value(realIdx);
}

// ── Playlist editing ──

void PlaylistManager::addTrack(const MusicInfo &track) {
    // 按 filePath 去重（MusicInfo::operator== 比较 filePath）
    if (m_playlist.contains(track)) return;
    m_playlist.append(track);
    reshuffleOrder();
    emit playlistChanged();
}

void PlaylistManager::addTracks(const QList<MusicInfo> &tracks) {
    // 过滤掉播放列表中已存在的曲目，避免重复扫描同一文件夹产生重复项
    QList<MusicInfo> unique;
    unique.reserve(tracks.size());
    for (const auto &t : tracks) {
        if (!m_playlist.contains(t))
            unique.append(t);
    }
    if (unique.isEmpty()) return;

    m_playlist.append(unique);
    reshuffleOrder();
    emit playlistChanged();
}

void PlaylistManager::removeTrack(int index) {
    if (index < 0 || index >= m_playlist.size()) return;
    int realIdx = m_shuffle ? m_shuffleOrder.value(index, index) : index;
    m_playlist.removeAt(realIdx);
    reshuffleOrder();
    if (m_currentIndex >= m_playlist.size())
        m_currentIndex = m_playlist.size() - 1;
    emit playlistChanged();
}

void PlaylistManager::clearPlaylist() {
    m_playlist.clear();
    m_shuffleOrder.clear();
    m_currentIndex = -1;
    emit playlistChanged();
}

// ── Playback control ──

void PlaylistManager::playTrackAt(int index) {
    if (index < 0 || index >= m_playlist.size()) return;
    m_currentIndex = index;
    emit currentIndexChanged();
    emit trackRequested(currentTrack());
}

void PlaylistManager::nextTrack() {
    if (m_playlist.isEmpty()) return;

    if (m_repeatMode == RepeatOne) {
        // Re-emit same track
        emit currentIndexChanged();
        emit trackRequested(currentTrack());
        return;
    }

    int next = m_currentIndex + 1;
    if (next >= m_playlist.size()) {
        if (m_repeatMode == RepeatAll)
            next = 0;
        else
            return; // stop at end
    }

    m_currentIndex = next;
    emit currentIndexChanged();
    emit trackRequested(currentTrack());
}

void PlaylistManager::previousTrack() {
    if (m_playlist.isEmpty()) return;

    int prev = m_currentIndex - 1;
    if (prev < 0) {
        if (m_repeatMode == RepeatAll)
            prev = m_playlist.size() - 1;
        else
            return;
    }

    m_currentIndex = prev;
    emit currentIndexChanged();
    emit trackRequested(currentTrack());
}

// ── Modes ──

void PlaylistManager::toggleShuffle() {
    m_shuffle = !m_shuffle;
    reshuffleOrder();
    emit shuffleModeChanged();
}

void PlaylistManager::cycleRepeatMode() {
    m_repeatMode = static_cast<RepeatMode>((static_cast<int>(m_repeatMode) + 1) % 3);
    emit repeatModeChanged();
}

void PlaylistManager::moveTrack(int from, int to) {
    if (from < 0 || from >= m_playlist.size() ||
        to < 0   || to >= m_playlist.size() ||
        from == to) return;
    m_playlist.move(from, to);
    reshuffleOrder();
    emit playlistChanged();
}

// ── Internal ──

void PlaylistManager::reshuffleOrder() {
    const int n = m_playlist.size();
    m_shuffleOrder.resize(n);
    for (int i = 0; i < n; ++i) m_shuffleOrder[i] = i;
    if (m_shuffle && n > 1) {
        std::shuffle(m_shuffleOrder.begin(), m_shuffleOrder.end(),
                     std::mt19937(m_rng.generate()));
    }
}

int PlaylistManager::effectiveIndex() const {
    if (m_currentIndex < 0 || m_currentIndex >= m_playlist.size()) return -1;
    return m_shuffle ? m_shuffleOrder.value(m_currentIndex, m_currentIndex) : m_currentIndex;
}
