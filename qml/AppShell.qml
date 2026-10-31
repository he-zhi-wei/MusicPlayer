import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: shell
    color: Theme.bgPrimary   // 浅色内容背景

    Component.onCompleted: {
        // If no scanned folder yet, go to DiscoverPage
        contentStack.push(discoverPage)
    }

    // 扫描完成后自动切换到播放列表页，让用户立刻看到结果
    Connections {
        target: Scanner
        function onScanningFinished() {
            if (Playlist.trackCount > 0)
                shell.goToPage("playlist")
        }
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        // ── Sidebar ──
        Sidebar {
            Layout.preferredWidth: Theme.sidebarWidth
            Layout.fillHeight: true
        }

        // Vertical divider
        Rectangle {
            Layout.preferredWidth: 1
            Layout.fillHeight: true
            color: Theme.borderDark
        }

        // ── Content Area ──
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            StackView {
                id: contentStack
                anchors.fill: parent
            }

            // ── Now Playing Bar (overlaid at bottom) ──
            NowPlayingBar {
                anchors {
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                }
                height: Theme.nowPlayingHeight
            }
        }
    }

    // ── Full Player Overlay ──
    FullPlayerPage {
        id: fullPlayer
        anchors.fill: parent
        z: 100
        visible: false
    }

    // ── Page References ──
    Component { id: discoverPage; DiscoverPage {} }
    Component { id: playlistPage; PlaylistView {} }

    // ── API for Sidebar ──
    function goToPage(name) {
        if (name === "discover") {
            contentStack.replace(discoverPage)
        } else if (name === "playlist") {
            contentStack.replace(playlistPage)
        }
    }

    function showFullPlayer() {
        fullPlayer.visible = true
        fullPlayer.open()
    }

    function hideFullPlayer() {
        fullPlayer.close()
    }
}
