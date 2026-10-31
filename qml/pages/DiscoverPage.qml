import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

Rectangle {
    id: page
    color: Theme.bgPrimary

    ColumnLayout {
        anchors.centerIn: parent
        spacing: Theme.spacingLG
        width: Math.min(parent.width * 0.6, 420)

        // Icon
        Text {
            Layout.alignment: Qt.AlignHCenter
            text: "🎵"
            font.pixelSize: 64
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: "欢迎使用 Music Player"
            color: Theme.textPrimary
            font.pixelSize: Theme.fontSizeXL
            font.bold: true
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: "一款简洁、好看的本地音乐播放器"
            color: Theme.textSecondary
            font.pixelSize: Theme.fontSizeMD
            horizontalAlignment: Text.AlignHCenter
        }

        Item { Layout.preferredHeight: 8 }

        // Scan Button
        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 240
            Layout.preferredHeight: 48
            radius: Theme.radiusLG
            color: scanBtnHover.hovered ? Theme.accentSecondary : Theme.accentPrimary

            Behavior on color { ColorAnimation { duration: Theme.animFast } }

            Text {
                anchors.centerIn: parent
                text: Scanner.isScanning ? "⏳ 正在扫描..." : "📂 选择音乐文件夹"
                color: Theme.textOnAccent   // 红底白字
                font.pixelSize: Theme.fontSizeMD
                font.bold: true
            }

            MouseArea {
                id: scanBtnHover
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: scanDialog.open()
            }
        }

        // Scan progress
        ColumnLayout {
            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: true
            visible: Scanner.isScanning
            spacing: Theme.spacingSM

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "正在扫描音频文件..."
                color: Theme.textSecondary
                font.pixelSize: Theme.fontSizeSM
            }
        }

        // Song count
        Text {
            Layout.alignment: Qt.AlignHCenter
            visible: !Scanner.isScanning && Playlist.trackCount > 0
            text: "已加载 " + Playlist.trackCount + " 首歌曲"
            color: Theme.textSecondary
            font.pixelSize: Theme.fontSizeMD
        }
    }

    // ── Folder dialog for quick scan ──
    FolderDialog {
        id: scanDialog
        title: "选择音乐文件夹"
        onAccepted: {
            console.log("[FolderDialog] accepted, folder =", selectedFolder)
            if (selectedFolder.toString().length > 0)
                Scanner.scanDirectory(selectedFolder)
        }
        onRejected: console.log("[FolderDialog] rejected/cancelled")
    }
}
