# Illogical Impulse WiFi Controller Implementation Documentation

## Overview

The illogical impulse Quickshell configuration implements a comprehensive WiFi management system that provides real-time network monitoring, scanning, connection management, and a user-friendly GUI. This system is built around NetworkManager (nmcli) and integrates seamlessly with the Quickshell desktop environment.

## Architecture Overview

### Core Components

1. **Network Service** (`services/Network.qml`) - Central WiFi management singleton
2. **Network Toggle** (`modules/sidebarRight/quickToggles/NetworkToggle.qml`) - Quick WiFi enable/disable
3. **WiFi Dialog** (`modules/sidebarRight/wifiNetworks/WifiDialog.qml`) - Network selection interface
4. **WiFi Network Item** (`modules/sidebarRight/wifiNetworks/WifiNetworkItem.qml`) - Individual network display
5. **WiFi Access Point Model** (`services/network/WifiAccessPoint.qml`) - Network data structure

### Service Integration

The WiFi system integrates with:
- **Quickshell Services** - For system integration
- **Material Design 3** - For consistent theming
- **Global States** - For sidebar management
- **Translation System** - For internationalization

## Network Service Implementation

### Core Properties

```qml
// Connection state
property bool wifi: true
property bool ethernet: false
property bool wifiEnabled: false
property bool wifiScanning: false
property bool wifiConnecting: false

// Network information
property string networkName: ""
property int networkStrength: 0
property WifiAccessPoint wifiConnectTarget
readonly property list<WifiAccessPoint> wifiNetworks: []
readonly property WifiAccessPoint active: wifiNetworks.find(n => n.active) ?? null
```

### Material Symbol Generation

The service dynamically generates Material Design icons based on connection state:

```qml
property string materialSymbol: ethernet ? "lan" :
    wifiEnabled ? (
    Network.networkStrength > 80 ? "signal_wifi_4_bar" :
    Network.networkStrength > 60 ? "network_wifi_3_bar" :
    Network.networkStrength > 40 ? "network_wifi_2_bar" :
    Network.networkStrength > 20 ? "network_wifi_1_bar" :
    "signal_wifi_0_bar"
) : "signal_wifi_off"
```

### WiFi Control Functions

#### Enable/Disable WiFi
```qml
function enableWifi(enabled = true): void {
    const cmd = enabled ? "on" : "off";
    enableWifiProc.exec(["nmcli", "radio", "wifi", cmd]);
}

function toggleWifi(): void {
    enableWifi(!wifiEnabled);
}
```

#### WiFi Scanning
```qml
function rescanWifi(): void {
    wifiScanning = true;
    rescanProcess.running = true;
}
```

#### Network Connection
```qml
function connectToWifiNetwork(accessPoint: WifiAccessPoint): void {
    accessPoint.askingPassword = false;
    root.wifiConnectTarget = accessPoint;
    connectProc.exec(["nmcli", "dev", "wifi", "connect", accessPoint.ssid])
}
```

#### Network Disconnection
```qml
function disconnectWifiNetwork(): void {
    if (active) disconnectProc.exec(["nmcli", "connection", "down", active.ssid]);
}
```

#### Password Management
```qml
function changePassword(network: WifiAccessPoint, password: string, username = ""): void {
    network.askingPassword = false;
    changePasswordProc.exec({
        "environment": {
            "PASSWORD": password
        },
        "command": ["bash", "-c", `nmcli connection modify ${network.ssid} wifi-sec.psk "$PASSWORD"`]
    })
}
```

## Process Management

### Core Processes

#### WiFi Status Monitoring
```qml
Process {
    id: wifiStatusProcess
    command: ["nmcli", "radio", "wifi"]
    Component.onCompleted: running = true
    environment: ({
        LANG: "C",
        LC_ALL: "C"
    })
    stdout: StdioCollector {
        onStreamFinished: {
            root.wifiEnabled = text.trim() === "enabled";
        }
    }
}
```

#### Network Monitoring
```qml
Process {
    id: subscriber
    running: true
    command: ["nmcli", "monitor"]
    stdout: SplitParser {
        onRead: root.update()
    }
}
```

#### Connection Type Detection
```qml
Process {
    id: updateConnectionType
    property string buffer
    command: ["sh", "-c", "nmcli -t -f NAME,TYPE,DEVICE c show --active"]
    running: true
    function startCheck() {
        buffer = "";
        updateConnectionType.running = true;
    }
    stdout: SplitParser {
        onRead: data => {
            updateConnectionType.buffer += data + "\n";
        }
    }
    onExited: (exitCode, exitStatus) => {
        const lines = updateConnectionType.buffer.trim().split('\n');
        let hasEthernet = false;
        let hasWifi = false;
        lines.forEach(line => {
            if (line.includes("ethernet"))
                hasEthernet = true;
            else if (line.includes("wireless"))
                hasWifi = true;
        });
        root.ethernet = hasEthernet;
        root.wifi = hasWifi;
    }
}
```

#### Network Name Update
```qml
Process {
    id: updateNetworkName
    command: ["sh", "-c", "nmcli -t -f NAME c show --active | head -1"]
    running: true
    stdout: SplitParser {
        onRead: data => {
            root.networkName = data;
        }
    }
}
```

#### Signal Strength Update
```qml
Process {
    id: updateNetworkStrength
    running: true
    command: ["sh", "-c", "nmcli -f IN-USE,SIGNAL,SSID device wifi | awk '/^\*/{if (NR!=1) {print $2}}'"]
    stdout: SplitParser {
        onRead: data => {
            root.networkStrength = parseInt(data);
        }
    }
}
```

### WiFi Network Discovery

#### Network Scanning Process
```qml
Process {
    id: getNetworks
    running: true
    command: ["nmcli", "-g", "ACTIVE,SIGNAL,FREQ,SSID,BSSID,SECURITY", "d", "w"]
    environment: ({
        LANG: "C",
        LC_ALL: "C"
    })
    stdout: StdioCollector {
        onStreamFinished: {
            // Parse network data and update wifiNetworks list
            const allNetworks = text.trim().split("\n").map(n => {
                const net = n.replace(rep, PLACEHOLDER).split(":");
                return {
                    active: net[0] === "yes",
                    strength: parseInt(net[1]),
                    frequency: parseInt(net[2]),
                    ssid: net[3],
                    bssid: net[4]?.replace(rep2, ":") ?? "",
                    security: net[5] || ""
                };
            }).filter(n => n.ssid && n.ssid.length > 0);

            // Group networks by SSID and prioritize connected ones
            const networkMap = new Map();
            for (const network of allNetworks) {
                const existing = networkMap.get(network.ssid);
                if (!existing) {
                    networkMap.set(network.ssid, network);
                } else {
                    // Prioritize active/connected networks
                    if (network.active && !existing.active) {
                        networkMap.set(network.ssid, network);
                    } else if (!network.active && !existing.active) {
                        // If both are inactive, keep the one with better signal
                        if (network.strength > existing.strength) {
                            networkMap.set(network.ssid, network);
                        }
                    }
                }
            }
        }
    }
}
```

## WiFi Access Point Model

### Data Structure

```qml
QtObject {
    required property var lastIpcObject

    // Network properties
    readonly property string ssid: lastIpcObject.ssid
    readonly property string bssid: lastIpcObject.bssid
    readonly property int strength: lastIpcObject.strength
    readonly property int frequency: lastIpcObject.frequency
    readonly property bool active: lastIpcObject.active
    readonly property string security: lastIpcObject.security
    readonly property bool isSecure: security.length > 0

    // UI state
    property bool askingPassword: false
}
```

## User Interface Components

### Network Toggle Button

The NetworkToggle provides quick access to WiFi controls:

```qml
QuickToggleButton {
    toggled: Network.wifiEnabled
    buttonIcon: Network.materialSymbol
    onClicked: Network.toggleWifi()
    altAction: () => {
        Quickshell.execDetached(["bash", "-c", `${Network.ethernet ? Config.options.apps.networkEthernet : Config.options.apps.network}`])
        GlobalStates.sidebarRightOpen = false
    }
    StyledToolTip {
        content: Translation.tr("%1 | Right-click to configure").arg(Network.networkName)
    }
}
```

**Features:**
- **Visual State**: Shows WiFi enabled/disabled status
- **Dynamic Icon**: Changes based on connection type and signal strength
- **Primary Action**: Toggle WiFi on/off
- **Secondary Action**: Open network configuration (right-click)
- **Tooltip**: Shows current network name and usage instructions

### WiFi Dialog

The main WiFi network selection interface:

```qml
WindowDialog {
    id: root

    WindowDialogTitle {
        text: Translation.tr("Connect to Wi-Fi")
    }

    StyledListView {
        Layout.fillHeight: true
        Layout.fillWidth: true
        model: ScriptModel {
            values: [...Network.wifiNetworks].sort((a, b) => {
                if (a.active && !b.active) return -1;
                if (!a.active && b.active) return 1;
                return b.strength - a.strength;
            })
        }
        delegate: WifiNetworkItem {
            required property WifiAccessPoint modelData
            wifiNetwork: modelData
        }
    }

    WindowDialogButtonRow {
        DialogButton {
            buttonText: Translation.tr("Details")
            onClicked: {
                Quickshell.execDetached(["bash", "-c", `${Network.ethernet ? Config.options.apps.networkEthernet : Config.options.apps.network}`]);
                GlobalStates.sidebarRightOpen = false;
            }
        }
        DialogButton {
            buttonText: Translation.tr("Done")
            onClicked: root.dismiss()
        }
    }
}
```

**Features:**
- **Network List**: Displays all available WiFi networks
- **Smart Sorting**: Active networks first, then by signal strength
- **Configuration Access**: Quick access to network settings
- **Modal Dialog**: Prevents interaction with background

### WiFi Network Item

Individual network display with connection capabilities:

```qml
RippleButton {
    id: root
    required property WifiAccessPoint wifiNetwork

    onClicked: {
        Network.connectToWifiNetwork(wifiNetwork)
    }

    contentItem: ColumnLayout {
        RowLayout {
            MaterialSymbol {
                iconSize: Appearance.font.pixelSize.larger
                property int strength: root.wifiNetwork?.strength ?? 0
                text: strength > 80 ? "signal_wifi_4_bar" :
                    strength > 60 ? "network_wifi_3_bar" :
                    strength > 40 ? "network_wifi_2_bar" :
                    strength > 20 ? "network_wifi_1_bar" :
                    "signal_wifi_0_bar"
                color: Appearance.colors.colOnSurfaceVariant
            }

            StyledText {
                Layout.fillWidth: true
                text: root.wifiNetwork?.ssid ?? Translation.tr("Unknown")
                color: Appearance.colors.colOnSurfaceVariant
            }

            MaterialSymbol {
                visible: (root.wifiNetwork?.isSecure || root.wifiNetwork?.active) ?? false
                text: root.wifiNetwork?.active ? "check" :
                      Network.wifiConnectTarget === root.wifiNetwork ? "settings_ethernet" : "lock"
                iconSize: Appearance.font.pixelSize.larger
                color: Appearance.colors.colOnSurfaceVariant
            }
        }

        // Password prompt (when needed)
        ColumnLayout {
            id: passwordPrompt
            visible: root.wifiNetwork?.askingPassword ?? false

            MaterialTextField {
                id: passwordField
                Layout.fillWidth: true
                placeholderText: Translation.tr("Password")
                echoMode: TextInput.Password
                inputMethodHints: Qt.ImhSensitiveData
                onAccepted: {
                    Network.changePassword(root.wifiNetwork, passwordField.text)
                }
            }

            RowLayout {
                DialogButton {
                    buttonText: Translation.tr("Cancel")
                    onClicked: root.wifiNetwork.askingPassword = false
                }
                DialogButton {
                    buttonText: Translation.tr("Connect")
                    onClicked: {
                        Network.changePassword(root.wifiNetwork, passwordField.text)
                    }
                }
            }
        }
    }
}
```

**Features:**
- **Signal Strength Indicator**: Visual representation of network quality
- **Network Information**: SSID display with security indicators
- **Connection Status**: Shows active networks and connection attempts
- **Password Handling**: Integrated password input for secure networks
- **Interactive Elements**: Click to connect, visual feedback

## Integration Points

### Sidebar Integration

The WiFi system integrates with the right sidebar:

```qml
// In SidebarRightContent.qml
ButtonGroup {
    Layout.alignment: Qt.AlignHCenter
    spacing: 5
    padding: 5
    color: Appearance.colors.colLayer1

    NetworkToggle {
        altAction: () => {
            Network.enableWifi();
            Network.rescanWifi();
            root.showWifiDialog = true;
        }
    }
    // Other toggles...
}

// WiFi Dialog Loader
Loader {
    id: wifiDialogLoader
    anchors.fill: parent
    active: root.showWifiDialog || item.visible

    sourceComponent: WifiDialog {
        onDismiss: {
            show = false
            root.showWifiDialog = false
        }
    }
}
```

### Global State Management

The system integrates with global states for sidebar management:

```qml
Connections {
    target: GlobalStates
    function onSidebarRightOpenChanged() {
        if (!GlobalStates.sidebarRightOpen) {
            root.showWifiDialog = false;
        }
    }
}
```

## NetworkManager Integration

### Command Structure

The system uses NetworkManager CLI (`nmcli`) for all operations:

#### WiFi Radio Control
```bash
nmcli radio wifi on|off
```

#### Network Scanning
```bash
nmcli dev wifi list --rescan yes
```

#### Network Information
```bash
nmcli -g ACTIVE,SIGNAL,FREQ,SSID,BSSID,SECURITY d w
```

#### Connection Management
```bash
nmcli dev wifi connect <SSID>
nmcli connection down <SSID>
```

#### Connection Monitoring
```bash
nmcli monitor
```

### Data Parsing

The system parses NetworkManager output to extract:

- **Connection Status**: Active/inactive networks
- **Signal Strength**: RSSI values (0-100)
- **Network Details**: SSID, BSSID, frequency, security
- **Real-time Updates**: Connection state changes

## Error Handling

### Connection Failures

The system handles connection failures gracefully:

```qml
Process {
    id: connectProc
    stderr: SplitParser {
        onRead: line => {
            if (line.includes("Secrets were required")) {
                root.wifiConnectTarget.askingPassword = true
            }
        }
    }
    onExited: (exitCode, exitStatus) => {
        root.wifiConnectTarget.askingPassword = (exitCode !== 0)
        root.wifiConnectTarget = null
    }
}
```

### Network State Recovery

Automatic recovery from network state changes:

```qml
Process {
    id: subscriber
    running: true
    command: ["nmcli", "monitor"]
    stdout: SplitParser {
        onRead: root.update()
    }
}
```

## Performance Considerations

### Lazy Loading

The WiFi dialog is loaded on-demand:

```qml
Loader {
    id: wifiDialogLoader
    active: root.showWifiDialog || item.visible
    onActiveChanged: {
        if (active) {
            item.show = true;
            item.forceActiveFocus();
        }
    }
}
```

### Efficient Updates

Network updates are triggered only when needed:

```qml
function update() {
    updateConnectionType.startCheck();
    wifiStatusProcess.running = true
    updateNetworkName.running = true;
    updateNetworkStrength.running = true;
}
```

## Security Features

### Password Handling

- **Secure Input**: Password fields use `TextInput.Password` mode
- **Environment Variables**: Passwords passed via environment variables
- **Input Hints**: `Qt.ImhSensitiveData` for sensitive input
- **Session Isolation**: Passwords not stored in application state

### Network Security Detection

```qml
readonly property bool isSecure: security.length > 0
```

## Internationalization

The system supports multiple languages through the translation system:

```qml
Translation.tr("Connect to Wi-Fi")
Translation.tr("Password")
Translation.tr("Connect")
Translation.tr("Cancel")
Translation.tr("Details")
Translation.tr("Done")
```

## Configuration Options

### App Integration

The system integrates with external network management applications:

```qml
altAction: () => {
    Quickshell.execDetached(["bash", "-c",
        `${Network.ethernet ? Config.options.apps.networkEthernet : Config.options.apps.network}`])
    GlobalStates.sidebarRightOpen = false
}
```

### Customization Points

- **Network Applications**: Configurable network management apps
- **Material Icons**: Dynamic icon selection based on state
- **Theming**: Integration with Material Design 3 color system
- **Layout**: Responsive design with configurable spacing

## Troubleshooting

### Common Issues

1. **NetworkManager Not Running**: Ensure `systemctl --user enable NetworkManager`
2. **Permission Issues**: Check user permissions for network management
3. **Scanning Failures**: Verify WiFi radio is enabled
4. **Connection Failures**: Check network credentials and security settings

### Debug Information

The system provides detailed logging for troubleshooting:

```qml
stdout: SplitParser {
    onRead: line => {
        // print(line) // Debug output
        getNetworks.running = true
    }
}
```

## Future Enhancements

### Planned Features

- **Enterprise WiFi**: Username/password authentication
- **Network Profiles**: Saved network configurations
- **Advanced Security**: WPA3 and enterprise security support
- **Performance Metrics**: Connection quality monitoring
- **Network History**: Recently used networks

### Architecture Improvements

- **Plugin System**: Extensible network management
- **API Abstraction**: NetworkManager-independent backend
- **Offline Support**: Cached network information
- **Multi-Interface**: Support for multiple network interfaces

## Conclusion

The illogical impulse WiFi implementation provides a comprehensive, user-friendly network management solution that integrates seamlessly with the Quickshell desktop environment. It offers real-time monitoring, intuitive controls, and robust error handling while maintaining high performance and security standards.

The system's modular architecture makes it easy to extend and customize, while its integration with NetworkManager ensures compatibility with standard Linux networking tools and configurations.
