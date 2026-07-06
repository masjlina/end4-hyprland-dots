import QtQuick
import qs.services
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets
import Quickshell
import Quickshell.Io

QuickToggleModel {
    id: root
    name: Translation.tr("VPN")
    statusText: Translation.tr("Disconnected")
    tooltipText: Translation.tr("VPN (WireGuard) | Right-click to configure")

    toggled: false
    icon: "vpn_lock"
    available: false

    property string wireguardName: ""

    mainAction: () => {
        if (toggled) {
            disconnectProc.running = true
        } else {
            connectProc.running = true
        }
    }

    altAction: () => {
        Quickshell.execDetached(["kcmshell6", "kcm_networkmanagement"])
        GlobalStates.sidebarRightOpen = false
    }

    Connections {
        target: Network
        function onVpnConnectedChanged() {
            fetchActiveState.running = true
        }
    }

    Component.onCompleted: {
        fetchActiveState.running = true
    }

    Process {
        id: fetchActiveState
        running: false
        command: ["sh", "-c", "nmcli -t -f NAME,TYPE,ACTIVE connection show"]
        stdout: StdioCollector {
            id: collector
            onStreamFinished: {
                const lines = collector.text.trim().split("\n");
                let foundVpn = false;
                let activeVpn = "";
                let firstVpn = "";

                lines.forEach(line => {
                    const parts = line.split(":");
                    if (parts.length >= 3 && parts[1] === "wireguard") {
                        const name = parts[0];
                        const active = parts[2] === "yes";
                        if (!firstVpn) {
                            firstVpn = name;
                        }
                        if (active) {
                            foundVpn = true;
                            activeVpn = name;
                        }
                    }
                });

                root.available = firstVpn !== "";
                root.toggled = foundVpn;
                if (foundVpn) {
                    root.wireguardName = activeVpn;
                    root.statusText = activeVpn;
                } else {
                    root.wireguardName = firstVpn;
                    root.statusText = firstVpn ? Translation.tr("Disconnected") : Translation.tr("Not Configured");
                }
            }
        }
    }

    Process {
        id: connectProc
        running: false
        command: ["sh", "-c", `nmcli connection up "${root.wireguardName}"`]
        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0) {
                Quickshell.execDetached(["notify-send", 
                    Translation.tr("VPN Connection Failed"), 
                    Translation.tr(`Failed to connect to ${root.wireguardName}`),
                    "-a", "Shell"
                ])
            }
            fetchActiveState.running = true
        }
    }

    Process {
        id: disconnectProc
        running: false
        command: ["sh", "-c", `nmcli connection down "${root.wireguardName}"`]
        onExited: (exitCode, exitStatus) => {
            fetchActiveState.running = true
        }
    }
}
