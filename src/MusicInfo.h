#pragma once

#include <QString>
#include <QMetaType>

struct MusicInfo
{
    Q_GADGET
    Q_PROPERTY(int id MEMBER id)
    Q_PROPERTY(QString title MEMBER title)
    Q_PROPERTY(QString artist MEMBER artist)
    Q_PROPERTY(QString album MEMBER album)
    Q_PROPERTY(qint64 durationMs MEMBER durationMs)
    Q_PROPERTY(QString filePath MEMBER filePath)
    Q_PROPERTY(QString coverArtPath MEMBER coverArtPath)

public:
    int id = -1;
    QString title;
    QString artist;
    QString album;
    qint64 durationMs = 0;
    QString filePath;
    QString coverArtPath;

    Q_INVOKABLE QString durationString() const {
        const int totalSec = static_cast<int>(durationMs / 1000);
        const int min = totalSec / 60;
        const int sec = totalSec % 60;
        return QString("%1:%2")
            .arg(min)
            .arg(sec, 2, 10, QChar('0'));
    }

    Q_INVOKABLE QString durationShort() const {
        const int totalSec = static_cast<int>(durationMs / 1000);
        const int min = totalSec / 60;
        const int sec = totalSec % 60;
        return QString("%1:%2")
            .arg(min)
            .arg(sec, 2, 10, QChar('0'));
    }

    bool operator==(const MusicInfo &other) const {
        return filePath == other.filePath;
    }

    bool isValid() const {
        return !filePath.isEmpty();
    }
};

Q_DECLARE_METATYPE(MusicInfo)
