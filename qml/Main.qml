import QtQuick
import QtQuick.Controls
import QtQuick.Window

Window {
    id: root
    width: 1100
    height: 720
    visible: true
    title: "Music Player"
    color: Theme.bgPrimary   // 浅色窗口背景

    // Enforce minimum size
    minimumWidth: 800
    minimumHeight: 500

    // 窗口尺寸持久化：先恢复再开启写回，避免初始值覆盖已保存尺寸
    property bool geometryReady: false

    Component.onCompleted: {
        var w = Settings.value("window/width", 1100)
        var h = Settings.value("window/height", 720)
        if (w > 0 && h > 0) {
            width = Math.max(Number(w), minimumWidth)
            height = Math.max(Number(h), minimumHeight)
        }
        geometryReady = true
    }

    onWidthChanged: if (geometryReady) Settings.setValue("window/width", width)
    onHeightChanged: if (geometryReady) Settings.setValue("window/height", height)

    AppShell {
        anchors.fill: parent
    }
}
