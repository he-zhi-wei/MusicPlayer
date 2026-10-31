import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: bar
    color: Theme.bgSecondary
    border.color: Theme.borderColor
    border.width: 1

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Theme.spacingLG
        anchors.rightMargin: Theme.spacingLG
        spacing: Theme.spacingMD

        // ── Album Art ──
        AlbumArt {
            size: 48
            onClicked: {
                // Notify parent to show full player
                var p = bar.parent
                while (p && !p.showFullPlayer) p = p.parent
                if (p && p.showFullPlayer) p.showFullPlayer()
            }
        }

        // ── Track Info ──
        ColumnLayout {
            Layout.preferredWidth: 180
            spacing: 2

            Text {
                Layout.fillWidth: true
                text: Audio.currentTrack && Audio.currentTrack.title ? Audio.currentTrack.title : "未在播放"
                color: Theme.textPrimary
                font.pixelSize: Theme.fontSizeMD
                font.bold: true
                elide: Text.ElideRight
                maximumLineCount: 1
            }

            Text {
                Layout.fillWidth: true
                text: Audio.currentTrack && Audio.currentTrack.artist
                      ? Audio.currentTrack.artist : "—"
                color: Theme.textSecondary
                font.pixelSize: Theme.fontSizeSM
                elide: Text.ElideRight
                maximumLineCount: 1
            }
        }

        Item { Layout.fillWidth: true }

        // ── Playback Controls ──
        PlaybackControls {
            Layout.alignment: Qt.AlignHCenter
        }

        Item { Layout.fillWidth: true }

        // ── Progress ──
        ProgressSlider {
            Layout.preferredWidth: 260
            Layout.alignment: Qt.AlignVCenter
        }

        Item { Layout.preferredWidth: Theme.spacingSM }

        // ── Volume ──
        RowLayout {
            spacing: 4

            // Mute button
            Text {
                text: Audio.muted ? "🔇" : (Audio.volume < 0.1 ? "🔈" : (Audio.volume < 0.5 ? "🔉" : "🔊"))
                font.pixelSize: Theme.fontSizeMD
                opacity: volMouse.containsMouse ? 1.0 : 0.7

                MouseArea {
                    id: volMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Audio.toggleMute()
                }
            }

            Slider {
                id: volSlider
                Layout.preferredWidth: 80
                from: 0; to: 1
                value: Audio.muted ? 0 : Audio.volume
                stepSize: 0.01

                background: Rectangle {
                    x: volSlider.leftPadding
                    y: volSlider.topPadding + volSlider.availableHeight / 2 - height / 2
                    implicitWidth: 80; implicitHeight: 3
                    width: volSlider.availableWidth; height: implicitHeight
                    radius: 1.5
                    color: Theme.progressTrack   // 浅色音量轨道

                    Rectangle {
                        width: volSlider.visualPosition * parent.width
                        height: parent.height
                        color: Theme.accentPrimary   // 已播放部分用主题红
                        radius: 1.5
                    }
                }

                handle: Rectangle {
                    x: volSlider.leftPadding + volSlider.visualPosition * (volSlider.availableWidth - width)
                    y: volSlider.topPadding + volSlider.availableHeight / 2 - height / 2
                    implicitWidth: 10; implicitHeight: 10
                    radius: 5
                    color: volSlider.pressed ? Theme.textPrimary : Theme.textSecondary
                    visible: volSlider.hovered || volSlider.pressed
                }

                onMoved: {
                    Audio.setVolume(value)
                }
            }
        }
    }
}
