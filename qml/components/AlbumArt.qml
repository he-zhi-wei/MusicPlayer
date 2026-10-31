import QtQuick
import QtQuick.Controls

Rectangle {
    id: root
    property real size: 48
    property string coverPath: ""
    property bool isPlaying: Audio.playbackState === 1
    signal clicked()

    width: size; height: size
    radius: size * 0.15
    color: Theme.bgCard   // 白色封面卡片底
    border.color: Theme.borderColor
    border.width: 0.5

    // Default music note when no cover
    Text {
        anchors.centerIn: parent
        text: "♪"
        color: Theme.textMuted
        font.pixelSize: size * 0.45
    }

    // Subtle shadow via border effect
    layer.enabled: true
    layer.effect: null  // basic rendering

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
