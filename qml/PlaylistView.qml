import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: page
    color: Theme.bgPrimary

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // ── Header ──
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 72

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: Theme.spacingLG
                anchors.rightMargin: Theme.spacingLG
                spacing: Theme.spacingMD

                Text {
                    text: "全部歌曲"
                    color: Theme.textPrimary
                    font.pixelSize: Theme.fontSizeXL
                    font.bold: true
                }

                Text {
                    text: "(" + Playlist.trackCount + ")"
                    color: Theme.textSecondary
                    font.pixelSize: Theme.fontSizeLG
                }

                Item { Layout.fillWidth: true }

                // Play All button
                Rectangle {
                    Layout.preferredWidth: 110
                    Layout.preferredHeight: 36
                    radius: Theme.radiusMD
                    color: playAllHover.hovered ? Theme.accentSecondary : Theme.accentPrimary

                    Behavior on color { ColorAnimation { duration: Theme.animFast } }

                    Text {
                        anchors.centerIn: parent
                        text: "▶  播放全部"
                        color: Theme.textOnAccent   // 红底白字
                        font.pixelSize: Theme.fontSizeSM
                        font.bold: true
                    }

                    MouseArea {
                        id: playAllHover
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (Playlist.trackCount > 0)
                                Playlist.playTrackAt(0)
                        }
                    }
                }
            }
        }

        // ── Divider ──
        Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.borderColor }

        // ── Column Headers ──
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 36

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: Theme.spacingMD + 30 // offset for index column
                anchors.rightMargin: Theme.spacingMD
                spacing: Theme.spacingMD

                // Cover placeholder
                Item { Layout.preferredWidth: 36 }

                Text {
                    Layout.fillWidth: true
                    text: "歌曲标题"
                    color: Theme.textMuted
                    font.pixelSize: Theme.fontSizeXS
                }

                Text {
                    Layout.preferredWidth: 44
                    text: "时长"
                    color: Theme.textMuted
                    font.pixelSize: Theme.fontSizeXS
                    horizontalAlignment: Text.AlignRight
                }
            }

            Rectangle {
                anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
                height: 0.5
                color: Theme.borderColor
            }
        }

        // ── Empty state ──
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: Playlist.trackCount === 0
            color: "transparent"

            ColumnLayout {
                anchors.centerIn: parent
                spacing: Theme.spacingMD

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "📂"
                    font.pixelSize: 48
                }
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "还没有歌曲"
                    color: Theme.textSecondary
                    font.pixelSize: Theme.fontSizeLG
                }
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "点击左侧「+ 添加本地音乐」开始"
                    color: Theme.textMuted
                    font.pixelSize: Theme.fontSizeSM
                }
            }
        }

        // ── Song List ──
        ListView {
            id: listView
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            model: Playlist.playlist
            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
                contentItem: Rectangle {
                    implicitWidth: 6
                    radius: 3
                    color: Theme.textMuted
                    opacity: 0.4
                }
            }

            delegate: MusicRowDelegate {
                width: listView.width
                isCurrent: index === Playlist.currentIndex
            }
        }
    }
}
