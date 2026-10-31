#pragma once

#include <QObject>
#include <QSettings>
#include <QVariant>

// 应用设置封装：QML 通过 Settings.value / Settings.setValue 读写窗口尺寸等
class AppSettings : public QObject
{
    Q_OBJECT

public:
    explicit AppSettings(QObject *parent = nullptr);
    ~AppSettings() override;

    Q_INVOKABLE QVariant value(const QString &key, const QVariant &defaultValue = QVariant()) const;
    Q_INVOKABLE void setValue(const QString &key, const QVariant &value);
    Q_INVOKABLE void sync();

private:
    QSettings m_settings;
};
