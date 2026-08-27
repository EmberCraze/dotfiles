import QtQuick
import Quickshell.Io
import qs.Common
import qs.Widgets
import qs.Modules.Plugins

PluginComponent {
    id: root

    // stopped | idle | recording | transcribing (from `voxtype status`)
    property string currentState: "stopped"

    readonly property string stateIcon: {
        switch (currentState) {
        case "recording": return "mic"
        case "transcribing": return "graphic_eq"
        case "idle": return "mic_none"
        default: return "mic_off"
        }
    }

    readonly property color stateColor: {
        switch (currentState) {
        case "recording": return Theme.error
        case "transcribing": return Theme.primary
        case "idle": return Theme.surfaceVariantText
        default: return Qt.rgba(Theme.surfaceVariantText.r, Theme.surfaceVariantText.g, Theme.surfaceVariantText.b, 0.4)
        }
    }

    Process {
        id: statusProc
        command: ["voxtype", "status"]
        stdout: StdioCollector {
            onStreamFinished: {
                const s = text.trim()
                if (s.length > 0)
                    root.currentState = s
            }
        }
    }

    Process {
        id: toggleProc
        command: ["voxtype", "record", "toggle"]
    }

    Timer {
        interval: 500
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: statusProc.running = true
    }

    horizontalBarPill: Component {
        Item {
            width: pillIcon.width
            height: pillIcon.height

            DankIcon {
                id: pillIcon
                name: root.stateIcon
                size: Theme.iconSize - 6
                color: root.stateColor
                anchors.centerIn: parent

                SequentialAnimation on opacity {
                    running: root.currentState === "recording"
                    loops: Animation.Infinite
                    NumberAnimation { to: 0.4; duration: 500; easing.type: Easing.InOutQuad }
                    NumberAnimation { to: 1.0; duration: 500; easing.type: Easing.InOutQuad }
                }
                // Reset opacity when the pulse stops
                Connections {
                    target: root
                    function onCurrentStateChanged() {
                        if (root.currentState !== "recording")
                            pillIcon.opacity = 1.0
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: toggleProc.running = true
            }
        }
    }

    verticalBarPill: horizontalBarPill
}
