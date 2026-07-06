import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions
import qs.modules.ii.sidebarRight.quickToggles
import qs.modules.common.models.quickToggles
import qs
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

QuickToggleButton {
    id: root
    
    VpnToggle {
        id: model
    }

    visible: model.available
    toggled: model.toggled
    buttonIcon: model.icon
    
    onClicked: model.mainAction()
    altAction: model.altAction
    
    StyledToolTip {
        text: Translation.tr("VPN: %1 | Right-click to configure").arg(model.statusText)
    }
}
