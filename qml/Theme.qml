pragma Singleton
import QtQuick

QtObject {
    // ── 浅色配色（Apple Music 风 / 云白简约）──
    readonly property color bgPrimary:       "#f5f5f7"   // 窗口/内容背景
    readonly property color bgSecondary:     "#e9e9ee"   // 侧边栏
    readonly property color bgTertiary:      "#eeeef2"   // 三级浅灰底
    readonly property color bgCard:          "#ffffff"   // 卡片/表面
    readonly property color bgHover:         "#dedee4"   // 浅色悬停底

    readonly property color accentPrimary:   "#fa2d48"   // 主强调红（播放键/主按钮/进度条）
    readonly property color accentSecondary: "#ff5c74"   // 悬停红

    // 浅色主题辅助 token（新增，不影响旧属性名）
    readonly property color textOnAccent:    "#ffffff"   // 红底上的文字/图标
    readonly property color accentTint:      "#1afa2d48" // 导航/行激活淡红底（约 10% 红）
    readonly property color progressTrack:   "#e5e5ea"   // 进度条/音量轨道

    readonly property color textPrimary:     "#1d1d1f"
    readonly property color textSecondary:   "#6e6e73"
    readonly property color textMuted:       "#aeaeb2"

    readonly property color borderColor:     "#e3e3e8"
    readonly property color borderLight:     "#ededf1"
    readonly property color borderDark:      "#d8d8de"

    readonly property color success:         "#34c759"
    readonly property color warning:         "#ff9f0a"

    // ── 磨砂玻璃（浅色）──
    readonly property color glassBg:         "#b3ffffff"
    readonly property color glassBorder:     "#4de3e3e8"
    readonly property real  glassBlur:       20.0

    // ── Layout ──
    readonly property real sidebarWidth:     220
    readonly property real nowPlayingHeight: 76
    readonly property real titleBarHeight:   0

    readonly property real spacingXS:        4
    readonly property real spacingSM:        8
    readonly property real spacingMD:        16
    readonly property real spacingLG:        24
    readonly property real spacingXL:        36

    // ── 圆角整体加大一档 ──
    readonly property real radiusSM:         6
    readonly property real radiusMD:         12
    readonly property real radiusLG:         16
    readonly property real radiusXL:         24

    // ── Typography ──
    readonly property string fontFamily:     "Segoe UI"
    readonly property int    fontSizeXS:     10
    readonly property int    fontSizeSM:     12
    readonly property int    fontSizeMD:     14
    readonly property int    fontSizeLG:     18
    readonly property int    fontSizeXL:     24
    readonly property int    fontSizeXXL:    32

    // ── Animations ──
    readonly property int    animFast:       150
    readonly property int    animNormal:     300
    readonly property int    animSlow:       500

    // ── Helpers ──
    function formatDuration(ms) {
        if (!ms || ms <= 0) return "0:00"
        const sec = Math.floor(ms / 1000)
        const min = Math.floor(sec / 60)
        const s = sec % 60
        return min + ":" + (s < 10 ? "0" : "") + s
    }

    function formatTime(seconds) {
        const min = Math.floor(seconds / 60)
        const sec = Math.floor(seconds % 60)
        return min + ":" + (sec < 10 ? "0" : "") + sec
    }
}
