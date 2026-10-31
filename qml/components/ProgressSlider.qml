import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import p1

RowLayout {
    id: root
    spacing: Theme.spacingSM

    property real progress: Audio.duration > 0 ? Audio.position / Audio.duration : 0
    property string currentTime: Audio.positionString || "0:00"
    property string totalTime: Audio.durationString || "0:00"

    Layout.fillWidth: true

    // Current time
    Text {
        Layout.preferredWidth: 40
        text: root.currentTime
        color: Theme.textSecondary
        font.pixelSize: Theme.fontSizeXS
        horizontalAlignment: Text.AlignRight
    }

    // Slider
    Slider {
        id: slider
        Layout.fillWidth: true
        from: 0
        to: Math.max(Audio.duration, 1)
        value: Audio.position
        enabled: Audio.duration > 0

        background: Rectangle {
            x: slider.leftPadding
            y: slider.topPadding + slider.availableHeight / 2 - height / 2
            implicitWidth: 200
            implicitHeight: 4
            width: slider.availableWidth
            height: implicitHeight
            radius: 2
            color: Theme.progressTrack   // 浅色进度轨道

            Rectangle {
                width: slider.visualPosition * parent.width
                height: parent.height
                color: Theme.accentPrimary
                radius: 2
            }
        }

        handle: Rectangle {
            x: slider.leftPadding + slider.visualPosition * (slider.availableWidth - width)
            y: slider.topPadding + slider.availableHeight / 2 - height / 2
            implicitWidth: 12
            implicitHeight: 12
            radius: 6
            color: slider.pressed ? Theme.accentSecondary : Theme.accentPrimary
            visible: slider.hovered || slider.pressed

            Behavior on implicitWidth { NumberAnimation { duration: Theme.animFast } }
            Behavior on implicitHeight { NumberAnimation { duration: Theme.animFast } }
        }

        onMoved: {
            Audio.seek(value)
        }
    }

    // Total time
    Text {
        Layout.preferredWidth: 40
        text: root.totalTime
        color: Theme.textSecondary
        font.pixelSize: Theme.fontSizeXS
        horizontalAlignment: Text.AlignLeft
    }
}
