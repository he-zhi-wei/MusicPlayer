import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

Rectangle {
    id: sidebar
    color: Theme.bgSecondary

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // ── Logo ──
        Item {
            Layout.preferredHeight: 80
            Layout.fillWidth: true

            RowLayout {
                anchors.centerIn: parent
                spacing: 10

                Rectangle {
                    width: 36; height: 36; radius: 18
                    color: Theme.accentPrimary
                    Text {
                        anchors.centerIn: parent
                        text: "♪"
                        color: Theme.textOnAccent   // 红底白字
                        font.pixelSize: 20
                    }
                }

                Text {
                    text: "Music Player"
                    color: Theme.textPrimary
                    font.pixelSize: Theme.fontSizeLG
                    font.bold: true
                }
            }
        }

        Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.borderColor }

        // ── Navigation ──
        ColumnLayout {
            Layout.topMargin: Theme.spacingMD
            Layout.fillWidth: true
            spacing: 4

            NavButton {
                text: "🎵  发现音乐"
                onClicked: panel.goToPage("discover")
                active: true
            }
            NavButton {
                text: "📋  播放列表"
                onClicked: panel.goToPage("playlist")
            }
        }

        Item { Layout.fillHeight: true }

        // ── Scan Folder Button ──
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 60

            Rectangle {
                anchors.centerIn: parent
                width: parent.width - Theme.spacingLG * 2
                height: 40
                radius: Theme.radiusMD
                color: scanBtnHover.hovered ? Theme.accentSecondary : Theme.accentPrimary

                Behavior on color { ColorAnimation { duration: Theme.animFast } }

                Text {
                    anchors.centerIn: parent
                    text: Scanner.isScanning ? "扫描中..." : "+ 添加本地音乐"
                    color: Theme.textOnAccent   // 红底白字
                    font.pixelSize: Theme.fontSizeMD
                    font.bold: true
                }

                MouseArea {
                    id: scanBtnHover
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: folderDialog.open()
                }
            }
        }

        Item { Layout.preferredHeight: Theme.spacingMD; Layout.fillWidth: true }
    }

    // ── Folder Dialog ──
    FolderDialog {
        id: folderDialog
        title: "选择音乐文件夹"
        onAccepted: {
            console.log("[FolderDialog] accepted, folder =", selectedFolder)
            if (selectedFolder.toString().length > 0)
                Scanner.scanDirectory(selectedFolder)
        }
        onRejected: console.log("[FolderDialog] rejected/cancelled")
    }

    // Access to parent shell (AppShell)
    property QtObject panel: {
        var p = parent
        while (p && !p.goToPage) p = p.parent
        return p
    }
}

