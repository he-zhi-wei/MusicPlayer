#pragma once

#include <QObject>
#include <QStringList>
#include <QDirIterator>
#include <QUrl>
#include <QStandardPaths>
#include <QDir>
#include <QFile>
#include "MusicInfo.h"

class MusicScanner : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool isScanning READ isScanning NOTIFY isScanningChanged)
    Q_PROPERTY(int fileCount READ fileCount NOTIFY fileCountChanged)

public:
    explicit MusicScanner(QObject *parent = nullptr);

    bool isScanning() const;
    int  fileCount() const;

public slots:
    void scanDirectory(const QUrl &dirUrl);

signals:
    void isScanningChanged();
    void fileCountChanged();
    void scanningStarted();
    void scanningFinished();
    void tracksFound(const QList<MusicInfo> &tracks);
    void scanProgress(int current, int total);

private:
    void ensureCoverCacheDir();

    static const QStringList s_audioExtensions;
    bool m_scanning = false;
    int  m_fileCount = 0;
    QString m_coverCacheDir;
};
