pragma ComponentBehavior: Bound

import ".." as II
import "../modules/common" as Common
import "../modules/common/functions" as Functions
import "../modules/common/widgets" as Widgets
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland

Scope {
    id: root

    readonly property string monitorConfigPath: "~/.config/hypr/custom/monitors.lua"
    readonly property string helperScriptPath: Functions.FileUtils.trimFileProtocol(Qt.resolvedUrl("scripts/apply_monitor_mode.py"))
    readonly property string stateFilePath: Functions.FileUtils.trimFileProtocol(Qt.resolvedUrl("monitor_mode_state.json"))
    property string selectedMode: ""
    property string currentMode: ""
    property string statusText: ""
    property string errorText: ""
    property var activeOutputs: []

    function modeLabel(mode) {
        if (mode === "laptop") return "Laptop only";
        if (mode === "external") return "External only";
        if (mode === "both") return "Both displays";
        return "Unknown";
    }

    function refreshStatus() {
        root.errorText = "";
        root.statusText = "Reading current configuration...";
        statusProc.running = false;
        statusProc.running = true;
    }

    function applyMode(mode) {
        if (!mode || applyProc.running) return;
        root.errorText = "";
        root.statusText = "Applying configuration...";
        applyProc.targetMode = mode;
        applyProc.running = false;
        applyProc.running = true;
    }

    function toggle() {
        II.GlobalStates.monitorModeWidgetOpen = !II.GlobalStates.monitorModeWidgetOpen;
    }

    function close() {
        II.GlobalStates.monitorModeWidgetOpen = false;
    }

    function applyResult(text, fallbackError) {
        try {
            const data = JSON.parse(text);
            root.currentMode = data.current_mode || "";
            root.selectedMode = data.current_mode || root.selectedMode;
            root.activeOutputs = data.active_outputs || [];
            root.statusText = data.message || ("Текущий режим: " + root.modeLabel(root.currentMode));
            root.errorText = "";
        } catch (error) {
            root.errorText = fallbackError;
        }
    }

    Loader {
        id: dialogLoader
        active: II.GlobalStates.monitorModeWidgetOpen

        sourceComponent: PanelWindow {
            id: panelWindow
            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.namespace: "quickshell:monitorModeWidget"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
            color: "transparent"

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            mask: Region {
                item: overlayRoot
            }

            Component.onCompleted: {
                root.refreshStatus();
            }

            Rectangle {
                id: overlayRoot
                anchors.fill: parent
                color: Qt.rgba(0, 0, 0, 0.42)

                MouseArea {
                    anchors.fill: parent
                    onClicked: root.close()
                }

            ColumnLayout {
                id: contentColumn
                anchors.centerIn: parent
                spacing: 15

                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Escape) {
                        root.close();
                        event.accepted = true;
                    }
                }

                ColumnLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 0

                    Widgets.StyledText {
                        Layout.alignment: Qt.AlignHCenter
                        horizontalAlignment: Text.AlignHCenter
                        font {
                            family: Common.Appearance.font.family.title
                            pixelSize: Common.Appearance.font.pixelSize.title
                            variableAxes: Common.Appearance.font.variableAxes.title
                        }
                        text: "Display Mode"
                    }

                    Widgets.StyledText {
                        Layout.alignment: Qt.AlignHCenter
                        horizontalAlignment: Text.AlignHCenter
                        font.pixelSize: Common.Appearance.font.pixelSize.normal
                        text: "Arrow keys to navigate, Enter to select\nEsc or click anywhere to cancel"
                    }
                }

                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 15

                    ModeCardButton {
                        id: laptopButton
                        focus: panelWindow.visible
                        modeId: "laptop"
                        buttonIcon: "laptop"
                        buttonText: "Laptop only"
                        isCurrentMode: root.currentMode === "laptop"
                        onClicked: {
                            root.selectedMode = "laptop";
                            root.applyMode("laptop");
                        }
                        onFocusChanged: {
                            if (focus)
                                subtitleLabel.text = "Keep only the internal display active";
                        }
                        KeyNavigation.right: externalButton
                    }

                    ModeCardButton {
                        id: externalButton
                        modeId: "external"
                        buttonIcon: "desktop_windows"
                        buttonText: "External only"
                        isCurrentMode: root.currentMode === "external"
                        onClicked: {
                            root.selectedMode = "external";
                            root.applyMode("external");
                        }
                        onFocusChanged: {
                            if (focus)
                                subtitleLabel.text = "Keep only external monitors active";
                        }
                        KeyNavigation.left: laptopButton
                        KeyNavigation.right: bothButton
                    }

                    ModeCardButton {
                        id: bothButton
                        modeId: "both"
                        buttonIcon: "connected_tv"
                        buttonText: "Both displays"
                        isCurrentMode: root.currentMode === "both"
                        onClicked: {
                            root.selectedMode = "both";
                            root.applyMode("both");
                        }
                        onFocusChanged: {
                            if (focus)
                                subtitleLabel.text = "Enable the laptop and selected external monitors";
                        }
                        KeyNavigation.left: externalButton
                    }
                }

                Rectangle {
                    id: subtitleRect
                    Layout.alignment: Qt.AlignHCenter
                    color: Common.Appearance.m3colors.m3inverseSurface
                    clip: true
                    radius: Common.Appearance.rounding.normal
                    implicitHeight: subtitleLabel.implicitHeight + 10 * 2
                    implicitWidth: subtitleLabel.implicitWidth + 15 * 2

                    Behavior on implicitWidth {
                        NumberAnimation {
                            duration: Common.Appearance.animation.elementMove.duration
                            easing.type: Common.Appearance.animation.elementMove.type
                            easing.bezierCurve: Common.Appearance.animation.elementMove.bezierCurve
                        }
                    }

                    Widgets.StyledText {
                        id: subtitleLabel
                        anchors.centerIn: parent
                        color: Common.Appearance.m3colors.m3inverseOnSurface
                        text: ""
                    }
                }

                Widgets.StyledText {
                    Layout.alignment: Qt.AlignHCenter
                    visible: root.statusText.length > 0
                    text: root.statusText
                    color: Common.Appearance.m3colors.m3onSurface
                    font.pixelSize: Common.Appearance.font.pixelSize.smallie
                }

                Widgets.StyledText {
                    Layout.alignment: Qt.AlignHCenter
                    visible: root.errorText.length > 0
                    text: root.errorText
                    color: Common.Appearance.m3colors.m3error
                    font.pixelSize: Common.Appearance.font.pixelSize.smallie
                }
                } // end ColumnLayout
            } // end overlayRoot Rectangle
        } // end PanelWindow
    } // end Loader

    // Inline component for the mode card buttons
    component ModeCardButton: Widgets.RippleButton {
        id: button

        required property string modeId
        property string buttonIcon
        property string buttonText
        property bool isCurrentMode: false
        property bool keyboardDown: false
        property real size: 120

        buttonRadius: (button.focus || button.down) ? size / 2 : Common.Appearance.rounding.verylarge
        colBackground: button.keyboardDown ? Common.Appearance.m3colors.m3secondaryContainer :
            button.focus ? Common.Appearance.m3colors.m3primary :
            isCurrentMode ? Common.Appearance.m3colors.m3primaryContainer :
            Common.Appearance.m3colors.m3secondaryContainer
        colBackgroundHover: Common.Appearance.m3colors.m3primary
        colRipple: Common.Appearance.m3colors.m3primaryContainer
        property color colText: (button.down || button.keyboardDown || button.focus || button.hovered) ?
            Common.Appearance.m3colors.m3onPrimary : Common.Appearance.m3colors.m3onSurface

        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        background.implicitHeight: size
        background.implicitWidth: size

        Behavior on buttonRadius {
            NumberAnimation {
                duration: Common.Appearance.animation.elementMoveFast.duration
                easing.type: Common.Appearance.animation.elementMoveFast.type
                easing.bezierCurve: Common.Appearance.animation.elementMoveFast.bezierCurve
            }
        }

        Keys.onPressed: (event) => {
            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                keyboardDown = true
                button.clicked()
                event.accepted = true;
            }
        }
        Keys.onReleased: (event) => {
            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                keyboardDown = false
                event.accepted = true;
            }
        }

        contentItem: ColumnLayout {
            spacing: 8

            Widgets.MaterialSymbol {
                Layout.alignment: Qt.AlignHCenter
                color: button.colText
                horizontalAlignment: Text.AlignHCenter
                iconSize: 40
                text: button.buttonIcon
            }

            Widgets.StyledText {
                Layout.alignment: Qt.AlignHCenter
                horizontalAlignment: Text.AlignHCenter
                color: button.colText
                font.pixelSize: Common.Appearance.font.pixelSize.smaller
                text: button.buttonText
            }
        }

        Widgets.StyledToolTip {
            text: button.buttonText
        }
    }

    Process {
        id: statusProc
        command: ["python3", root.helperScriptPath, "status", root.monitorConfigPath, root.stateFilePath]

        stdout: StdioCollector {
            onStreamFinished: {
                root.applyResult(text, "Не удалось прочитать текущее состояние monitors.lua");
            }
        }

        stderr: StdioCollector {
            onStreamFinished: {
                if (text.trim().length > 0) root.errorText = text.trim();
            }
        }

        onExited: function(exitCode) {
            if (exitCode !== 0 && !root.errorText.length) {
                root.errorText = "Status command failed.";
            }
        }
    }

    Process {
        id: applyProc
        property string targetMode: ""
        command: ["python3", root.helperScriptPath, "apply", targetMode, root.monitorConfigPath, root.stateFilePath]

        stdout: StdioCollector {
            onStreamFinished: {
                root.applyResult(text, "Не удалось применить режим мониторов");
            }
        }

        stderr: StdioCollector {
            onStreamFinished: {
                if (text.trim().length > 0) root.errorText = text.trim();
            }
        }

        onExited: function(exitCode) {
            if (exitCode !== 0) {
                if (!root.errorText.length) root.errorText = "Failed to update monitors.lua";
                return;
            }
            root.refreshStatus();
            // Close the widget after successful apply
            root.close();
        }
    }

    IpcHandler {
        target: "monitorModeWidget"

        function toggle(): void {
            root.toggle();
        }

        function open(): void {
            II.GlobalStates.monitorModeWidgetOpen = true;
        }

        function close(): void {
            root.close();
        }
    }

    GlobalShortcut {
        name: "monitorModeWidgetToggle"
        description: "Toggle monitor mode widget"

        onPressed: root.toggle()
    }
}
