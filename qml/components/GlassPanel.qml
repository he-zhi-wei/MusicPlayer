import QtQuick
import QtQuick.Controls
import p1

Rectangle {
    id: root
    property real blurRadius: Theme.glassBlur
    property color tintColor: Theme.glassBg
    property alias contentItem: contentContainer.data

    color: "transparent"
    radius: Theme.radiusLG
    clip: true

    // Semi-transparent glass fill
    Rectangle {
        anchors.fill: parent
        color: root.tintColor
        radius: root.radius
        border.color: Theme.glassBorder
        border.width: 1
    }

    // 背景模糊的近似：浅色半透明白色覆盖层
    // (Qt5/6 MultiEffect approach requires ShaderEffectSource from the background)
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(1, 1, 1, 0.5)
        radius: root.radius
    }

    // Content container
    Item {
        id: contentContainer
        anchors.fill: parent
        anchors.margins: 2
    }
}
