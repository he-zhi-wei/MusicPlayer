#include "AppSettings.h"

AppSettings::AppSettings(QObject *parent)
    : QObject(parent)
    , m_settings()   // 使用与应用一致的默认 QSettings 位置
{
}

AppSettings::~AppSettings()
{
    m_settings.sync();
}

QVariant AppSettings::value(const QString &key, const QVariant &defaultValue) const
{
    return m_settings.value(key, defaultValue);
}

void AppSettings::setValue(const QString &key, const QVariant &value)
{
    // 缓存在内存中，退出时统一落盘，避免拖动窗口时频繁写磁盘
    m_settings.setValue(key, value);
}

void AppSettings::sync()
{
    m_settings.sync();
}
