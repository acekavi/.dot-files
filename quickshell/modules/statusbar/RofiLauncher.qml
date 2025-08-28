import QtQuick 2.15
import Quickshell
import Quickshell.Io

Process {
    id: rofiLauncher
    command: ["rofi", "-show", "drun"]

    function launch() {
        start()
    }
}
