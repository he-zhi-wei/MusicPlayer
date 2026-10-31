import QtQuick
import QtQuick.Controls
import p1

Item {
    id: root
    property bool spinning: Audio.playbackState === 1
    property real discSize: Math.min(width, height) * 0.85

    anchors.fill: parent

    // ── Vinyl Disc ──
    Item {
        id: discContainer
        anchors.centerIn: parent
        width: discSize; height: discSize

        RotationAnimation on rotation {
            from: 0; to: 360
            duration: 3000
            loops: Animation.Infinite
            running: root.spinning
            paused: !root.spinning
        }

        // Outer ring (grooves effect)
        Rectangle {
            anchors.centerIn: parent
            width: discSize; height: discSize
            radius: discSize / 2
            // 黑胶唱片本体保持深色（实体物件，不随浅色主题变化）
            color: "#1a1a1a"
            border.color: "#333333"
            border.width: 2

            // Grooves (concentric rings)
            Repeater {
                model: 6
                Rectangle {
                    anchors.centerIn: parent
                    width: discSize * (0.85 - index * 0.12)
                    height: discSize * (0.85 - index * 0.12)
                    radius: width / 2
                    color: "transparent"
                    border.color: Qt.rgba(1,1,1,0.04 + index * 0.01)
                    border.width: 0.5
                }
            }

            // Inner ring
            Rectangle {
                anchors.centerIn: parent
                width: discSize * 0.22; height: discSize * 0.22
                radius: width / 2
                color: Theme.accentPrimary   // 内圈标签用主题红
                border.color: "#333333"
                border.width: 1

                // Center hole
                Rectangle {
                    anchors.centerIn: parent
                    width: discSize * 0.06; height: discSize * 0.06
                    radius: width / 2
                    color: Theme.bgPrimary   // 中孔透出浅色背景
                }
            }
        }

        // ── Album Cover (center) ──
        Rectangle {
            anchors.centerIn: parent
            width: discSize * 0.55; height: discSize * 0.55
            radius: 4
            color: Theme.bgCard
            border.color: Theme.borderColor
            border.width: 0.5

            // Placeholder cover
            Text {
                anchors.centerIn: parent
                text: "♪"
                color: Theme.textMuted
                font.pixelSize: discSize * 0.2
            }

            // Title overlay at bottom of cover
            Rectangle {
                anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
                height: parent.height * 0.25
                color: "#cc1d1d1f"   // 深色压字条，保证白字可读

                Text {
                    anchors { centerIn: parent }
                    text: Audio.currentTrack && Audio.currentTrack.title ? Audio.currentTrack.title : ""
                    color: "white"
                    font.pixelSize: Math.max(10, discSize * 0.04)
                    font.bold: true
                    elide: Text.ElideRight
                    width: parent.width - 8
                }
            }
        }
    }
}
