pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property bool tlpAvailable: false
    property bool tlpEnabled: false
    property string powerProfile: "Unknown"
    property string powerSource: "Unknown"
    property string tlpVersion: "Unknown"
    property bool isOnAC: false
    property bool isOnBattery: false

    readonly property bool isActive: tlpAvailable && tlpEnabled

    Process {
        id: checkTlpProcess
        running: true
        command: ["which", "tlp"]

        onExited: (exitCode) => {
            root.tlpAvailable = (exitCode === 0)
            if (root.tlpAvailable) {
                refreshTimer.start()
                statusProcess.running = true
            }
        }
    }

    Process {
        id: statusProcess
        command: ["tlp-stat", "-s"]
        running: false

        stdout: SplitParser {
            onRead: (data) => {
                const lines = data.split('\n')
                for (const line of lines) {
                    if (line.includes('TLP ') && line.includes('---')) {
                        const versionMatch = line.match(/TLP\s+([\d.]+)/)
                        if (versionMatch) {
                            root.tlpVersion = versionMatch[1]
                        }
                    } else if (line.startsWith('tlp ')) {
                        const parts = line.split('=')
                        if (parts.length >= 2) {
                            const status = parts[1].trim()
                            root.tlpEnabled = status.startsWith('enabled')
                        }
                    } else if (line.startsWith('Power profile ')) {
                        const parts = line.split('=')
                        if (parts.length >= 2) {
                            root.powerProfile = parts[1].trim()
                        }
                    } else if (line.startsWith('Power source ')) {
                        const parts = line.split('=')
                        if (parts.length >= 2) {
                            const source = parts[1].trim()
                            root.powerSource = source
                            root.isOnAC = source.toLowerCase().includes('ac')
                            root.isOnBattery = source.toLowerCase().includes('battery')
                        }
                    }
                }
            }
        }

        onExited: (exitCode) => {
            if (exitCode !== 0) {
                console.warn("TLP status check failed with exit code:", exitCode)
            }
        }
    }

    Timer {
        id: refreshTimer
        interval: 5000
        repeat: true
        running: false

        onTriggered: {
            if (root.tlpAvailable && !statusProcess.running) {
                statusProcess.running = true
            }
        }
    }

    function refresh() {
        if (root.tlpAvailable && !statusProcess.running) {
            statusProcess.running = true
        }
    }

    function getModeDescription() {
        if (!isActive) {
            return "TLP not available"
        }

        if (powerProfile.includes('performance') || powerProfile.includes('AC')) {
            return "Performance Mode (AC)"
        } else if (powerProfile.includes('battery')) {
            return "Battery Saving Mode"
        }

        return powerProfile
    }

    function getModeIcon() {
        if (!isActive) {
            return "power_settings_new"
        }

        if (powerProfile.includes('performance') || powerProfile.includes('AC')) {
            return "bolt"
        } else if (powerProfile.includes('battery')) {
            return "battery_saver"
        }

        return "settings"
    }
}
