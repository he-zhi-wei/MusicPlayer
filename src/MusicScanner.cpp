#include "MusicScanner.h"
#include <QDirIterator>
#include <QMediaMetaData>
#include <QFileInfo>
#include <QDir>
#include <QDebug>
#include <QCryptographicHash>

const QStringList MusicScanner::s_audioExtensions = {
    "*.mp3", "*.flac", "*.wav", "*.ogg", "*.m4a",
    "*.aac", "*.wma", "*.ape", "*.opus", "*.wv"
};

MusicScanner::MusicScanner(QObject *parent)
    : QObject(parent)
{
    ensureCoverCacheDir();

    // 静音的隐藏播放器，仅用于读取音频标签与时长
    m_probe = new QMediaPlayer(this);
    m_probeOutput = new QAudioOutput(this);
    m_probeOutput->setVolume(0.0);
    m_probeOutput->setMuted(true);
    m_probe->setAudioOutput(m_probeOutput);

    m_probeTimeout = new QTimer(this);
    m_probeTimeout->setSingleShot(true);
    m_probeTimeout->setInterval(3000);   // 单个文件最多等待 3 秒

    connect(m_probe, &QMediaPlayer::mediaStatusChanged,
            this, &MusicScanner::onProbeStatusChanged);
    connect(m_probeTimeout, &QTimer::timeout,
            this, &MusicScanner::onProbeTimeout);
    connect(m_probe, &QMediaPlayer::errorOccurred, this,
            [this](QMediaPlayer::Error, const QString &msg) {
                if (!m_scanning) return;
                if (!msg.isEmpty()) qWarning() << "Metadata probe failed:" << msg;
                finishCurrentProbe();
            });
}

MusicScanner::~MusicScanner() = default;

bool MusicScanner::isScanning() const { return m_scanning; }
int  MusicScanner::fileCount() const { return m_fileCount; }

void MusicScanner::scanDirectory(const QUrl &dirUrl)
{
    if (m_scanning) return;

    const QString dirPath = dirUrl.toLocalFile();
    QDir dir(dirPath);
    if (!dir.exists()) {
        qWarning() << "Directory does not exist:" << dirPath;
        return;
    }

    m_scanning = true;
    m_pending.clear();
    m_results.clear();
    m_processed = 0;
    m_total = 0;

    emit isScanningChanged();
    emit scanningStarted();

    // 第一步：快速收集文件（不做 IO 密集的标签解析）
    int idCounter = 0;
    QDirIterator it(dirPath, s_audioExtensions, QDir::Files, QDirIterator::Subdirectories);
    while (it.hasNext()) {
        it.next();
        const QFileInfo fi = it.fileInfo();

        MusicInfo info;
        info.id = idCounter++;
        info.filePath = fi.absoluteFilePath();
        info.title = fi.completeBaseName();      // 兜底：文件名去扩展名
        info.artist = "Unknown Artist";
        info.album = "Unknown Album";
        info.durationMs = 0;
        info.coverArtPath = "";

        m_pending.append(info);
    }

    m_total = m_pending.size();

    if (m_total == 0) {
        finishScan();
        return;
    }

    emit scanProgress(0, m_total);
    probeNext();
}

// ── 元数据探测队列 ──

void MusicScanner::probeNext()
{
    m_probeAdvancing = false;

    if (m_pending.isEmpty()) {
        finishScan();
        return;
    }

    m_currentProbe = m_pending.takeFirst();
    m_probeTimeout->start();
    m_probe->setSource(QUrl::fromLocalFile(m_currentProbe.filePath));
}

void MusicScanner::onProbeStatusChanged(QMediaPlayer::MediaStatus status)
{
    if (!m_scanning || m_probeAdvancing) return;

    switch (status) {
    case QMediaPlayer::LoadedMedia:
    case QMediaPlayer::BufferedMedia:
    case QMediaPlayer::InvalidMedia:
    case QMediaPlayer::NoMedia:
        finishCurrentProbe();
        break;
    default:
        break;
    }
}

void MusicScanner::onProbeTimeout()
{
    if (!m_scanning || m_probeAdvancing) return;
    qWarning() << "Metadata probe timeout:" << m_currentProbe.filePath;
    finishCurrentProbe();
}

void MusicScanner::finishCurrentProbe()
{
    if (m_probeAdvancing) return;
    m_probeAdvancing = true;
    m_probeTimeout->stop();

    MusicInfo info = m_currentProbe;

    if (m_probe->mediaStatus() != QMediaPlayer::InvalidMedia) {
        const QMediaMetaData md = m_probe->metaData();

        const QString title = md.value(QMediaMetaData::Title).toString().trimmed();
        if (!title.isEmpty()) info.title = title;

        QString artist = md.value(QMediaMetaData::ContributingArtist).toString().trimmed();
        if (artist.isEmpty())
            artist = md.value(QMediaMetaData::Author).toString().trimmed();
        if (!artist.isEmpty()) info.artist = artist;

        const QString album = md.value(QMediaMetaData::AlbumTitle).toString().trimmed();
        if (!album.isEmpty()) info.album = album;

        if (m_probe->duration() > 0)
            info.durationMs = m_probe->duration();

        const QImage cover =
            md.value(QMediaMetaData::CoverArtImage).value<QImage>();
        if (!cover.isNull()) {
            const QString coverPath = saveCoverArt(cover, info.filePath);
            if (!coverPath.isEmpty()) info.coverArtPath = coverPath;
        }
    }

    m_results.append(info);
    ++m_processed;
    emit scanProgress(m_processed, m_total);

    m_probe->setSource(QUrl());   // 释放当前文件句柄
    probeNext();
}

void MusicScanner::finishScan()
{
    m_scanning = false;
    m_fileCount += m_results.size();

    if (!m_results.isEmpty())
        emit tracksFound(m_results);

    emit fileCountChanged();
    emit isScanningChanged();
    emit scanningFinished();

    qDebug() << "Scanned" << m_results.size() << "tracks with metadata";

    m_results.clear();
    m_pending.clear();
    m_processed = 0;
    m_total = 0;
}

// ── 封面缓存 ──

QString MusicScanner::saveCoverArt(const QImage &image, const QString &sourcePath)
{
    if (m_coverCacheDir.isEmpty() || image.isNull()) return QString();

    // 以文件路径的 SHA1 作为缓存文件名，同一首歌只写一次
    const QString hash = QCryptographicHash::hash(
        sourcePath.toUtf8(), QCryptographicHash::Sha1).toHex().left(20);
    const QString filePath = m_coverCacheDir + "/" + hash + ".jpg";

    if (!QFile::exists(filePath)) {
        if (!image.save(filePath, "JPG", 90))
            return QString();
    }
    return QUrl::fromLocalFile(filePath).toString();
}

void MusicScanner::ensureCoverCacheDir()
{
    m_coverCacheDir = QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation)
                      + "/covers";
    QDir().mkpath(m_coverCacheDir);
}
