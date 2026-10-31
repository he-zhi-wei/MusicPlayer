import QtQuick
import QtQuick.Controls
import p1

Rectangle {
    property string icon: ""
    property real size: 18
    property bool active: false
    property string tooltip: ""
    signal clicked()

    width: 36; height: 36; radius: 18
    // 浅色主题：激活淡红底，悬停浅灰底
    color: active ? Theme.accentTint
           : (btnHover.hovered ? Theme.bgHover : "transparent")

    Behavior on color { ColorAnimation { duration: 150 } }

    Text {
        anchors.centerIn: parent
        text: parent.icon
        color: parent.active ? Theme.accentPrimary : Theme.textPrimary   // 浅底深字，激活用主题红
        font.pixelSize: parent.size
        opacity: parent.active ? 1.0 : 0.7
    }

    MouseArea {
        id: btnHover
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: parent.clicked()
    }
}
