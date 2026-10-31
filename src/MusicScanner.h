#pragma once

#include <QObject>
#include <QStringList>
#include <QUrl>
#include <QStandardPaths>
#include <QDir>
#include <QFile>
#include <QMediaPlayer>
#include <QAudioOutput>
#include <QTimer>
#include <QImage>
#include "MusicInfo.h"

class MusicScanner : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool isScanning READ isScanning NOTIFY isScanningChanged)
    Q_PROPERTY(int fileCount READ fileCount NOTIFY fileCountChanged)

public:
    explicit MusicScanner(QObject *parent = nullptr);
    ~MusicScanner() override;

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

private slots:
    void probeNext();                                        // 读取下一首的元数据
    void onProbeStatusChanged(QMediaPlayer::MediaStatus status);
    void onProbeTimeout();

private:
    void ensureCoverCacheDir();
    void finishCurrentProbe();                               // 结束当前文件探测并前进
    void finishScan();                                       // 扫描结束，派发结果
    QString saveCoverArt(const QImage &image, const QString &sourcePath);

    static const QStringList s_audioExtensions;
    bool m_scanning = false;
    int  m_fileCount = 0;
    QString m_coverCacheDir;

    // 元数据探测：用一只隐藏的播放器顺序读取标签，避免阻塞 UI 线程
    QMediaPlayer *m_probe = nullptr;
    QAudioOutput *m_probeOutput = nullptr;
    QTimer       *m_probeTimeout = nullptr;
    QList<MusicInfo> m_pending;        // 待探测
    QList<MusicInfo> m_results;        // 探测完成的结果
    MusicInfo m_currentProbe;          // 正在探测的曲目
    bool m_probeAdvancing = false;     // 防止状态回调重入
    int  m_processed = 0;
    int  m_total = 0;
};
