import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

RowLayout {
    id: root
    spacing: Theme.spacingLG

    // ── Shuffle Button ──
    ControlButton {
        icon: "🔀"
        size: 16
        active: Playlist.shuffleEnabled
        onClicked: Playlist.toggleShuffle()
        tooltip: Playlist.shuffleEnabled ? "随机播放: 开" : "随机播放: 关"
    }

    // ── Previous ──
    ControlButton {
        icon: "⏮"
        size: 20
        onClicked: Playlist.previousTrack()
    }

    // ── Play / Pause (larger) ──
    Rectangle {
        id: playBtn
        width: 48; height: 48; radius: 24
        color: playBtnHover.hovered ? Theme.accentSecondary : Theme.accentPrimary

        Behavior on color { ColorAnimation { duration: Theme.animFast } }

        Text {
            anchors.centerIn: parent
            text: Audio.playbackState === 1 ? "⏸" : "▶"
            color: Theme.textOnAccent   // 红底白字
            font.pixelSize: 20
            anchors.horizontalCenterOffset: Audio.playbackState === 1 ? 0 : 2
        }

        MouseArea {
            id: playBtnHover
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: Audio.togglePlayPause()
        }
    }

    // ── Next ──
    ControlButton {
        icon: "⏭"
        size: 20
        onClicked: Playlist.nextTrack()
    }

    // ── Repeat Button ──
    ControlButton {
        icon: Playlist.repeatMode === 2 ? "🔂" : (Playlist.repeatMode === 1 ? "🔁" : "➡️")
        size: 16
        active: Playlist.repeatMode !== 0
        onClicked: Playlist.cycleRepeatMode()
        tooltip: {
            switch (Playlist.repeatMode) {
                case 0: return "顺序播放"
                case 1: return "列表循环"
                case 2: return "单曲循环"
            }
        }
    }
}

