#include "MusicScanner.h"
#include <QFileInfo>
#include <QDir>
#include <QDebug>

const QStringList MusicScanner::s_audioExtensions = {
    "*.mp3", "*.flac", "*.wav", "*.ogg", "*.m4a",
    "*.aac", "*.wma", "*.ape", "*.opus", "*.wv"
};

MusicScanner::MusicScanner(QObject *parent)
    : QObject(parent)
{
    ensureCoverCacheDir();
}

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
    emit isScanningChanged();
    emit scanningStarted();

    // Collect all audio files
    QList<MusicInfo> foundTracks;
    int idCounter = 0;

    QDirIterator it(dirPath, s_audioExtensions, QDir::Files, QDirIterator::Subdirectories);
    int total = 0;
    // First pass: count files
    {
        QDirIterator countIt(dirPath, s_audioExtensions, QDir::Files, QDirIterator::Subdirectories);
        while (countIt.hasNext()) { countIt.next(); ++total; }
    }

    int processed = 0;
    while (it.hasNext()) {
        it.next();
        QFileInfo fi = it.fileInfo();

        MusicInfo info;
        info.id = idCounter++;
        info.filePath = fi.absoluteFilePath();
        info.title = fi.completeBaseName();      // fallback: filename without extension
        info.artist = "Unknown Artist";
        info.album = "Unknown Album";
        info.durationMs = 0;
        info.coverArtPath = "";

        foundTracks.append(info);

        ++processed;
        if (processed % 50 == 0 || processed == total) {
            emit scanProgress(processed, total);
        }
    }

    m_fileCount += foundTracks.size();
    m_scanning = false;

    if (!foundTracks.isEmpty()) {
        emit tracksFound(foundTracks);
    }

    emit fileCountChanged();
    emit isScanningChanged();
    emit scanningFinished();

    qDebug() << "Scanned" << foundTracks.size() << "tracks from" << dirPath;
}

void MusicScanner::ensureCoverCacheDir()
{
    m_coverCacheDir = QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation)
                      + "/covers";
    QDir().mkpath(m_coverCacheDir);
}
