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

    readonly property string generalLuaPath: "~/.config/hypr/custom/general.lua"
    readonly property string scriptPath: Functions.FileUtils.trimFileProtocol(Qt.resolvedUrl("scripts/toggle_layout.py"))
    property bool ruEnabled: false
    property bool uaEnabled: false

    function refreshStatus() {
        statusProc.running = false;
        statusProc.running = true;
    }

    function toggleLang(lang) {
        if (toggleProc.running) return;
        toggleProc.targetLang = lang;
        toggleProc.running = false;
        toggleProc.running = true;
    }

    function parseResult(text) {
        try {
            const lines = text.trim().split("\n");
            const lastLine = lines[lines.length - 1];
            if (lastLine) {
                const data = JSON.parse(lastLine);
                root.ruEnabled = data.ru || false;
                root.uaEnabled = data.ua || false;
            }
        } catch (e) {
            console.error("KeyboardLayoutWidget: parse error:", e, text);
        }
    }

    function toggle() {
        II.GlobalStates.keyboardLayoutWidgetOpen = !II.GlobalStates.keyboardLayoutWidgetOpen;
    }

    function close() {
        II.GlobalStates.keyboardLayoutWidgetOpen = false;
    }

    Loader {
        id: dialogLoader
        active: II.GlobalStates.keyboardLayoutWidgetOpen

        sourceComponent: PanelWindow {
            id: panelWindow
            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.namespace: "quickshell:keyboardLayoutWidget"
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
                    anchors.centerIn: parent
                    spacing: 15

                    Keys.onPressed: event => {
                        if (event.key === Qt.Key_Escape) {
                            root.close();
                            event.accepted = true;
                        }
                    }

                    Widgets.StyledText {
                        Layout.alignment: Qt.AlignHCenter
                        horizontalAlignment: Text.AlignHCenter
                        font {
                            family: Common.Appearance.font.family.title
                            pixelSize: Common.Appearance.font.pixelSize.title
                            variableAxes: Common.Appearance.font.variableAxes.title
                        }
                        text: "Keyboard Layout"
                    }

                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 15

                        // EN is always on — just a visual indicator
                        ToggleCard {
                            buttonIcon: "language"
                            buttonText: "EN"
                            isActive: true
                            enabled: false
                            opacity: 0.7
                            KeyNavigation.right: ruCard
                        }

                        ToggleCard {
                            id: ruCard
                            focus: panelWindow.visible
                            buttonIcon: "translate"
                            buttonText: "RU"
                            isActive: root.ruEnabled
                            onClicked: root.toggleLang("ru")
                            KeyNavigation.left: ruCard
                            KeyNavigation.right: uaCard
                        }

                        ToggleCard {
                            id: uaCard
                            buttonIcon: "translate"
                            buttonText: "UA"
                            isActive: root.uaEnabled
                            onClicked: root.toggleLang("ua")
                            KeyNavigation.left: ruCard
                        }
                    }
                } // end ColumnLayout
            } // end overlayRoot
        } // end PanelWindow
    } // end Loader

    component ToggleCard: Widgets.RippleButton {
        id: card

        property string buttonIcon
        property string buttonText
        property bool isActive: false
        property bool keyboardDown: false
        property real size: 120

        buttonRadius: (card.focus || card.down) ? size / 2 : Common.Appearance.rounding.verylarge
        colBackground: card.keyboardDown ? Common.Appearance.m3colors.m3secondaryContainer :
            isActive ? Common.Appearance.m3colors.m3primary :
            card.focus ? Common.Appearance.m3colors.m3secondaryContainer :
            Common.Appearance.m3colors.m3surfaceVariant
        colBackgroundHover: isActive ? Common.Appearance.m3colors.m3primary : Common.Appearance.m3colors.m3secondaryContainer
        colRipple: Common.Appearance.m3colors.m3primaryContainer
        property color colText: (card.down || card.keyboardDown || card.focus || card.hovered) ?
            (isActive ? Common.Appearance.m3colors.m3onPrimary : Common.Appearance.m3colors.m3onSecondaryContainer) : 
            (isActive ? Common.Appearance.m3colors.m3onPrimary : Common.Appearance.m3colors.m3onSurfaceVariant)

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
                card.clicked()
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
                color: card.colText
                horizontalAlignment: Text.AlignHCenter
                iconSize: 40
                fill: card.isActive ? 1 : 0
                text: card.buttonIcon
            }

            Widgets.StyledText {
                Layout.alignment: Qt.AlignHCenter
                horizontalAlignment: Text.AlignHCenter
                color: card.colText
                font {
                    pixelSize: Common.Appearance.font.pixelSize.large
                    weight: Font.Bold
                }
                text: card.buttonText
            }
        }
    }

    Process {
        id: statusProc
        command: ["python3", root.scriptPath, "status", root.generalLuaPath]

        stdout: StdioCollector {
            onStreamFinished: root.parseResult(text)
        }
    }

    Process {
        id: toggleProc
        property string targetLang: ""
        command: ["python3", root.scriptPath, "toggle", targetLang, root.generalLuaPath]

        stdout: StdioCollector {
            onStreamFinished: root.parseResult(text)
        }
    }

    IpcHandler {
        target: "keyboardLayoutWidget"

        function toggle(): void {
            root.toggle();
        }

        function open(): void {
            II.GlobalStates.keyboardLayoutWidgetOpen = true;
        }

        function close(): void {
            root.close();
        }
    }

    GlobalShortcut {
        name: "keyboardLayoutWidgetToggle"
        description: "Toggle keyboard layout widget"

        onPressed: root.toggle()
    }
}
