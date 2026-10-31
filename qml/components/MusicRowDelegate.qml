import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import p1

Rectangle {
    id: row
    property var track: modelData
    property bool isCurrent: false
    property int rowIndex: index

    width: ListView.view ? ListView.view.width : 300
    height: 52
    // 浅色列表行：当前播放淡红底，悬停浅灰底
    color: isCurrent ? Theme.accentTint
           : (mouseArea.containsMouse ? Theme.bgHover : "transparent")

    Behavior on color { ColorAnimation { duration: Theme.animFast } }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Theme.spacingMD
        anchors.rightMargin: Theme.spacingMD
        spacing: Theme.spacingMD

        // Index / playing icon
        Item {
            Layout.preferredWidth: 30
            Layout.fillHeight: true

            Text {
                anchors.centerIn: parent
                text: isCurrent ? "▶" : String(index + 1)
                color: isCurrent ? Theme.accentPrimary : Theme.textMuted
                font.pixelSize: Theme.fontSizeSM
                font.bold: isCurrent
            }
        }

        // 封面缩略图（有内嵌封面时显示真实图片）
        AlbumArt {
            Layout.preferredWidth: 36
            Layout.preferredHeight: 36
            size: 36
            coverPath: track.coverArtPath || ""
        }

        // Title + Artist
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            Text {
                Layout.fillWidth: true
                text: track.title || "Unknown"
                color: isCurrent ? Theme.accentPrimary : Theme.textPrimary   // 当前播放标题用主题红
                font.pixelSize: Theme.fontSizeMD
                font.bold: isCurrent
                elide: Text.ElideRight
                maximumLineCount: 1
            }

            Text {
                Layout.fillWidth: true
                text: (track.artist || "Unknown") + " · " + (track.album || "Unknown")
                color: Theme.textSecondary
                font.pixelSize: Theme.fontSizeSM
                elide: Text.ElideRight
                maximumLineCount: 1
            }
        }

        // Duration
        Text {
            Layout.preferredWidth: 44
            horizontalAlignment: Text.AlignRight
            text: track.durationString ? track.durationString() : "--:--"
            color: Theme.textMuted
            font.pixelSize: Theme.fontSizeSM
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            Playlist.playTrackAt(index)
        }
    }

    // Thin bottom separator
    Rectangle {
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
        height: 0.5
        color: Theme.borderColor
    }
}
