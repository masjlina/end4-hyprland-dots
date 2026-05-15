import qs.services
import qs.modules.common
import qs.modules.common.widgets
import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell

Item {
    id: root

    implicitHeight: contentColumn.implicitHeight
    implicitWidth: contentColumn.implicitWidth

    property int totalSeconds: 0
    property int initialSeconds: 0
    property bool running: false

    function toggle() {
        if (root.totalSeconds > 0) {
            root.running = !root.running;
        }
    }

    function reset() {
        root.running = false;
        root.totalSeconds = 0;
        root.initialSeconds = 0;
    }

    Timer {
        id: sleepTimer
        interval: 1000
        repeat: true
        running: root.running
        onTriggered: {
            if (root.totalSeconds > 0) {
                root.totalSeconds -= 1;
                if (root.totalSeconds <= 0) {
                    root.running = false;
                    Quickshell.execDetached(["systemctl", "poweroff"]);
                }
            }
        }
    }

    ColumnLayout {
        id: contentColumn
        anchors.fill: parent
        spacing: 16

        // The timer circle
        CircularProgress {
            Layout.alignment: Qt.AlignHCenter
            lineWidth: 8
            value: root.initialSeconds > 0 ? (root.totalSeconds / root.initialSeconds) : 0
            implicitSize: 200
            enableAnimation: true

            MouseArea {
                anchors.fill: parent
                onWheel: (wheel) => {
                    if (root.running) return;
                    let deltaSeconds = 60; // 1 minute
                    if (wheel.modifiers & Qt.ShiftModifier) {
                        deltaSeconds = 5 * 60; // 5 minutes with shift
                    }
                    if (wheel.angleDelta.y > 0) {
                        root.totalSeconds += deltaSeconds;
                    } else if (wheel.angleDelta.y < 0) {
                        root.totalSeconds = Math.max(0, root.totalSeconds - deltaSeconds);
                    }
                    root.initialSeconds = root.totalSeconds;
                }
            }

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 0

                StyledText {
                    Layout.alignment: Qt.AlignHCenter
                    text: {
                        let h = Math.floor(root.totalSeconds / 3600).toString().padStart(2, '0');
                        let m = Math.floor((root.totalSeconds % 3600) / 60).toString().padStart(2, '0');
                        let s = (root.totalSeconds % 60).toString().padStart(2, '0');
                        if (h === "00") return `${m}:${s}`;
                        return `${h}:${m}:${s}`;
                    }
                    font.pixelSize: 40
                    color: Appearance.m3colors.m3onSurface
                }
                StyledText {
                    Layout.alignment: Qt.AlignHCenter
                    text: Translation.tr("Sleep")
                    font.pixelSize: Appearance.font.pixelSize.normal
                    color: Appearance.colors.colSubtext
                }
            }
        }

        // Add time buttons
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 8
            visible: !root.running && root.totalSeconds === 0
            
            RippleButton {
                implicitHeight: 35
                implicitWidth: 50
                contentItem: StyledText {
                    anchors.centerIn: parent
                    text: "+5m"
                    color: Appearance.colors.colOnLayer2
                }
                colBackground: Appearance.colors.colLayer2
                colBackgroundHover: Appearance.colors.colLayer2Hover
                onClicked: { root.totalSeconds += 5 * 60; root.initialSeconds = root.totalSeconds; }
            }
            RippleButton {
                implicitHeight: 35
                implicitWidth: 60
                contentItem: StyledText {
                    anchors.centerIn: parent
                    text: "+15m"
                    color: Appearance.colors.colOnLayer2
                }
                colBackground: Appearance.colors.colLayer2
                colBackgroundHover: Appearance.colors.colLayer2Hover
                onClicked: { root.totalSeconds += 15 * 60; root.initialSeconds = root.totalSeconds; }
            }
            RippleButton {
                implicitHeight: 35
                implicitWidth: 50
                contentItem: StyledText {
                    anchors.centerIn: parent
                    text: "+1h"
                    color: Appearance.colors.colOnLayer2
                }
                colBackground: Appearance.colors.colLayer2
                colBackgroundHover: Appearance.colors.colLayer2Hover
                onClicked: { root.totalSeconds += 3600; root.initialSeconds = root.totalSeconds; }
            }
        }

        // The Start/Stop and Reset buttons
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 10
            visible: root.totalSeconds > 0 || root.running

            RippleButton {
                implicitHeight: 35
                implicitWidth: 90
                font.pixelSize: Appearance.font.pixelSize.larger
                onClicked: root.toggle()
                colBackground: root.running ? Appearance.colors.colSecondaryContainer : Appearance.colors.colPrimary
                colBackgroundHover: root.running ? Appearance.colors.colSecondaryContainerHover : Appearance.colors.colPrimaryHover

                contentItem: StyledText {
                    anchors.centerIn: parent
                    horizontalAlignment: Text.AlignHCenter
                    text: root.running ? Translation.tr("Pause") : Translation.tr("Start")
                    color: root.running ? Appearance.colors.colOnSecondaryContainer : Appearance.colors.colOnPrimary
                }
            }

            RippleButton {
                implicitHeight: 35
                implicitWidth: 90

                onClicked: root.reset()
                enabled: root.totalSeconds > 0 || root.running

                font.pixelSize: Appearance.font.pixelSize.larger
                colBackground: Appearance.colors.colErrorContainer
                colBackgroundHover: Appearance.colors.colErrorContainerHover
                colRipple: Appearance.colors.colErrorContainerActive

                contentItem: StyledText {
                    anchors.centerIn: parent
                    horizontalAlignment: Text.AlignHCenter
                    text: Translation.tr("Reset")
                    color: Appearance.colors.colOnErrorContainer
                }
            }
        }
    }
}
