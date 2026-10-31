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

    AppShell {
        anchors.fill: parent
    }
}
