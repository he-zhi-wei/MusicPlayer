import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: fullPlayer
    color: "#e6f5f5f7"          // 浅色全屏播放页遮罩底
    opacity: 0

    property bool active: false

    function open() {
        active = true
        opacity = 1
    }

    function close() {
        active = false
        opacity = 0
    }

    Behavior on opacity {
        NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic }
    }

    // ── Background Tint ──
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(245/255, 245/255, 247/255, 0.98)   // 云白近不透明背景
    }

    // ── Close Button ──
    Rectangle {
        anchors { top: parent.top; right: parent.right; topMargin: Theme.spacingLG; rightMargin: Theme.spacingLG }
        width: 36; height: 36; radius: 18
        color: closeHover.hovered ? Theme.bgHover : "transparent"

        Text {
            anchors.centerIn: parent
            text: "✕"
            color: Theme.textSecondary
            font.pixelSize: Theme.fontSizeLG
        }

        MouseArea {
            id: closeHover
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: fullPlayer.close()
        }
    }

    // ── Layout ──
    Item {
        anchors.fill: parent
        anchors.margins: Theme.spacingXL

        RowLayout {
            anchors.centerIn: parent
            spacing: Theme.spacingXL * 2

            // ── Vinyl Animation ──
            Item {
                Layout.preferredWidth: Math.min(parent.width * 0.5, 420)
                Layout.preferredHeight: Layout.preferredWidth

                VinylAnimation {
                    discSize: Math.min(parent.width, parent.height)
                }
            }

            // ── Track Info ──
            ColumnLayout {
                Layout.preferredWidth: 300
                spacing: Theme.spacingSM

                Text {
                    Layout.fillWidth: true
                    text: Audio.currentTrack && Audio.currentTrack.title ? Audio.currentTrack.title : "未选择歌曲"
                    color: Theme.textPrimary
                    font.pixelSize: Theme.fontSizeXXL
                    font.bold: true
                    elide: Text.ElideRight
                    maximumLineCount: 2
                    wrapMode: Text.WordWrap
                }

                Text {
                    Layout.fillWidth: true
                    text: {
                        var t = Audio.currentTrack
                        if (!t) return ""
                        return (t.artist || "Unknown Artist") + " · " + (t.album || "Unknown Album")
                    }
                    color: Theme.textSecondary
                    font.pixelSize: Theme.fontSizeMD
                    elide: Text.ElideRight
                    maximumLineCount: 1
                }

                Item { Layout.preferredHeight: Theme.spacingMD }

                // Progress in full view
                ProgressSlider {
                    Layout.fillWidth: true
                }

                Item { Layout.preferredHeight: Theme.spacingMD }

                // Controls
                PlaybackControls {
                    Layout.alignment: Qt.AlignHCenter
                }
            }
        }
    }
}
