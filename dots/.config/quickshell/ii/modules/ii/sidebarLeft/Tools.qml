import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Item {
    id: root
    property real padding: 15

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: root.padding
        spacing: 15

        StyledText {
            Layout.fillWidth: true
            text: Translation.tr("Quick Scripts")
            font.pixelSize: Appearance.font.pixelSize.large
            font.bold: true
            color: Appearance.colors.colOnLayer1
        }

        StyledFlickable {
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentHeight: contentColumn.implicitHeight
            clip: true

            ColumnLayout {
                id: contentColumn
                width: parent.width
                spacing: 12

                RippleButtonWithIcon {
                    Layout.fillWidth: true
                    implicitHeight: 50
                    materialIcon: "system_update_alt"
                    mainContentComponent: Component {
                        ColumnLayout {
                            spacing: 2
                            StyledText {
                                text: Translation.tr("Update all packages")
                                font.pixelSize: Appearance.font.pixelSize.small
                                font.bold: true
                                color: Appearance.colors.colOnSecondaryContainer
                            }
                            StyledText {
                                text: Translation.tr("Update system packages (pacman) & AUR (yay)")
                                font.pixelSize: Appearance.font.pixelSize.smaller
                                color: Appearance.colors.colSubtext
                            }
                        }
                    }
                    onClicked: {
                        Quickshell.execDetached(["bash", "-c", "kitty -1 --hold=yes bash -c 'sudo pacman -Syu && yay -Syu'"]);
                    }
                }
            }
        }
    }
}
