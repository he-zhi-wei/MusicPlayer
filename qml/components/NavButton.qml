import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import p1

Rectangle {
    property string text: ""
    property bool active: false
    signal clicked()

    width: parent ? parent.width - 32 : 188
    height: 40
    Layout.alignment: Qt.AlignHCenter
    radius: Theme.radiusMD
    // 浅色侧边栏：激活态淡红底 + 主题红文字，悬停浅灰底
    color: active ? Theme.accentTint : (navHover.hovered ? Theme.bgHover : "transparent")

    Behavior on color { ColorAnimation { duration: 150 } }

    Text {
        anchors {
            left: parent.left
            leftMargin: 16
            verticalCenter: parent.verticalCenter
        }
        text: parent.text
        color: active ? Theme.accentPrimary : Theme.textSecondary   // 浅底深字，激活用主题红
        font.pixelSize: 14
    }

    MouseArea {
        id: navHover
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: parent.clicked()
    }
}
