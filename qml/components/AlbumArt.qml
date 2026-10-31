import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import p1

Rectangle {
    id: root
    property real size: 48
    property string coverPath: ""
    signal clicked()

    readonly property bool coverReady: coverPath !== "" && coverImage.status === Image.Ready

    width: size; height: size
    radius: size * 0.15
    color: Theme.bgCard         // 白色封面卡片底
    border.color: Theme.borderColor
    border.width: coverReady ? 0 : 0.5

    // 无封面时的占位音符
    Text {
        anchors.centerIn: parent
        visible: !root.coverReady
        text: "♪"
        color: Theme.textMuted
        font.pixelSize: size * 0.45
    }

    // 真实封面：用 MultiEffect 做圆角遮罩，避免方形图片盖住圆角
    Image {
        id: coverImage
        anchors.fill: parent
        source: root.coverPath
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        visible: false
        layer.enabled: root.coverReady
        layer.effect: MultiEffect {
            maskEnabled: true
            maskSource: maskShape
        }
    }

    Rectangle {
        id: maskShape
        anchors.fill: parent
        radius: root.radius
        color: "black"
        visible: false
        layer.enabled: true
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
