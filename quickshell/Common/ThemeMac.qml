pragma Singleton
pragma ComponentBehavior: Bound

import QtCore
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower
import qs.Services
import "StockThemes.js" as StockThemes

Singleton {
    id: root

    // macOS-specific theme properties
    property bool isMacTheme: true
    property string currentTheme: "macOS"
    property bool isLightMode: false
    
    readonly property string dynamic: "dynamic"

    readonly property string homeDir: {
        const url = StandardPaths.writableLocation(StandardPaths.HomeLocation).toString()
        return url.startsWith("file://") ? url.substring(7) : url
    }
    readonly property string configDir: {
        const url = StandardPaths.writableLocation(StandardPaths.ConfigLocation).toString()
        return url.startsWith("file://") ? url.substring(7) : url
    }
    readonly property string shellDir: Qt.resolvedUrl(".").toString().replace("file://", "").replace("/Common/", "")
    readonly property string wallpaperPath: typeof SessionData !== "undefined" ? SessionData.wallpaperPath : ""
    
    property bool matugenAvailable: false
    property bool gtkThemingEnabled: typeof SettingsData !== "undefined" ? SettingsData.gtkAvailable : false
    property bool qtThemingEnabled: typeof SettingsData !== "undefined" ? (SettingsData.qt5ctAvailable || SettingsData.qt6ctAvailable) : false
    property var workerRunning: false
    property var matugenColors: ({})
    property bool extractionRequested: false
    property int colorUpdateTrigger: 0
    property var customThemeData: null
    
    readonly property string stateDir: {
        const cacheHome = StandardPaths.writableLocation(StandardPaths.CacheLocation).toString()
        const path = cacheHome.startsWith("file://") ? cacheHome.substring(7) : cacheHome
        return path + "/dankshell"
    }

    // macOS color palette
    readonly property var macOSColors: {
        if (isLightMode) {
            return {
                // Light mode colors based on macOS Sonoma
                primary: "#007AFF",              // Blue accent
                primaryText: "#FFFFFF",
                primaryContainer: "#0051D5",
                secondary: "#5AC8FA",            // Light blue
                surface: "#F5F5F7",              // Light gray
                surfaceText: "#000000",
                surfaceVariant: "#E5E5E7",       // Lighter gray
                surfaceVariantText: "#3C3C43",   // Secondary label
                surfaceTint: "#007AFF",
                background: "#FFFFFF",
                backgroundText: "#000000",
                outline: "#C6C6C8",              // Separator
                surfaceContainer: "#F2F2F7",     // Secondary background
                surfaceContainerHigh: "#E5E5EA", // Tertiary background
                error: "#FF3B30",                // Red
                warning: "#FF9500",              // Orange
                info: "#007AFF",                 // Blue
                success: "#34C759"               // Green
            }
        } else {
            return {
                // Dark mode colors based on macOS Sonoma
                primary: "#0A84FF",              // Blue accent
                primaryText: "#FFFFFF",
                primaryContainer: "#0051D5",
                secondary: "#64D2FF",            // Light blue
                surface: "#1C1C1E",              // Dark gray
                surfaceText: "#FFFFFF",
                surfaceVariant: "#2C2C2E",       // Medium gray
                surfaceVariantText: "#EBEBF5",   // Secondary label
                surfaceTint: "#0A84FF",
                background: "#000000",
                backgroundText: "#FFFFFF",
                outline: "#38383A",              // Separator
                surfaceContainer: "#1C1C1E",     // Secondary background
                surfaceContainerHigh: "#2C2C2E", // Tertiary background
                error: "#FF453A",                // Red
                warning: "#FF9F0A",              // Orange
                info: "#0A84FF",                 // Blue
                success: "#32D74B"               // Green
            }
        }
    }

    function getMatugenColor(path, fallback) {
        colorUpdateTrigger
        const colorMode = (typeof SessionData !== "undefined" && SessionData.isLightMode) ? "light" : "dark"
        let cur = matugenColors && matugenColors.colors && matugenColors.colors[colorMode]
        for (const part of path.split(".")) {
            if (!cur || typeof cur !== "object" || !(part in cur))
                return fallback
            cur = cur[part]
        }
        return cur || fallback
    }

    readonly property var currentThemeData: {
        if (currentTheme === dynamic && matugenColors && Object.keys(matugenColors).length > 0) {
            return {
                primary: getMatugenColor("primary", macOSColors.primary),
                primaryText: getMatugenColor("on_primary", macOSColors.primaryText),
                primaryContainer: getMatugenColor("primary_container", macOSColors.primaryContainer),
                secondary: getMatugenColor("secondary", macOSColors.secondary),
                surface: getMatugenColor("surface", macOSColors.surface),
                surfaceText: getMatugenColor("on_background", macOSColors.surfaceText),
                surfaceVariant: getMatugenColor("surface_variant", macOSColors.surfaceVariant),
                surfaceVariantText: getMatugenColor("on_surface_variant", macOSColors.surfaceVariantText),
                surfaceTint: getMatugenColor("surface_tint", macOSColors.surfaceTint),
                background: getMatugenColor("background", macOSColors.background),
                backgroundText: getMatugenColor("on_background", macOSColors.backgroundText),
                outline: getMatugenColor("outline", macOSColors.outline),
                surfaceContainer: getMatugenColor("surface_container", macOSColors.surfaceContainer),
                surfaceContainerHigh: getMatugenColor("surface_container_high", macOSColors.surfaceContainerHigh),
                error: macOSColors.error,
                warning: macOSColors.warning,
                info: macOSColors.info,
                success: macOSColors.success
            }
        } else {
            return macOSColors
        }
    }

    // Color properties matching Theme.qml interface
    property color primary: currentThemeData.primary
    property color primaryText: currentThemeData.primaryText
    property color primaryContainer: currentThemeData.primaryContainer
    property color secondary: currentThemeData.secondary
    property color surface: currentThemeData.surface
    property color surfaceText: currentThemeData.surfaceText
    property color surfaceVariant: currentThemeData.surfaceVariant
    property color surfaceVariantText: currentThemeData.surfaceVariantText
    property color surfaceTint: currentThemeData.surfaceTint
    property color background: currentThemeData.background
    property color backgroundText: currentThemeData.backgroundText
    property color outline: currentThemeData.outline
    property color surfaceContainer: currentThemeData.surfaceContainer
    property color surfaceContainerHigh: currentThemeData.surfaceContainerHigh

    property color error: currentThemeData.error || "#FF453A"
    property color warning: currentThemeData.warning || "#FF9F0A"
    property color info: currentThemeData.info || "#0A84FF"
    property color tempWarning: "#FF9F0A"
    property color tempDanger: "#FF453A"
    property color success: currentThemeData.success || "#32D74B"

    // macOS-specific alpha values for hover states
    property color primaryHover: Qt.rgba(primary.r, primary.g, primary.b, 0.15)
    property color primaryHoverLight: Qt.rgba(primary.r, primary.g, primary.b, 0.1)
    property color primaryPressed: Qt.rgba(primary.r, primary.g, primary.b, 0.2)
    property color primarySelected: Qt.rgba(primary.r, primary.g, primary.b, 0.3)
    property color primaryBackground: Qt.rgba(primary.r, primary.g, primary.b, 0.06)

    property color secondaryHover: Qt.rgba(secondary.r, secondary.g, secondary.b, 0.1)

    property color surfaceHover: Qt.rgba(surfaceVariant.r, surfaceVariant.g, surfaceVariant.b, 0.1)
    property color surfacePressed: Qt.rgba(surfaceVariant.r, surfaceVariant.g, surfaceVariant.b, 0.15)
    property color surfaceSelected: Qt.rgba(surfaceVariant.r, surfaceVariant.g, surfaceVariant.b, 0.2)
    property color surfaceLight: Qt.rgba(surfaceVariant.r, surfaceVariant.g, surfaceVariant.b, 0.12)
    property color surfaceVariantAlpha: Qt.rgba(surfaceVariant.r, surfaceVariant.g, surfaceVariant.b, 0.25)
    property color surfaceTextHover: Qt.rgba(surfaceText.r, surfaceText.g, surfaceText.b, 0.1)
    property color surfaceTextAlpha: Qt.rgba(surfaceText.r, surfaceText.g, surfaceText.b, 0.4)
    property color surfaceTextLight: Qt.rgba(surfaceText.r, surfaceText.g, surfaceText.b, 0.08)
    property color surfaceTextMedium: Qt.rgba(surfaceText.r, surfaceText.g, surfaceText.b, 0.7)

    property color outlineButton: Qt.rgba(outline.r, outline.g, outline.b, 0.6)
    property color outlineLight: Qt.rgba(outline.r, outline.g, outline.b, 0.06)
    property color outlineMedium: Qt.rgba(outline.r, outline.g, outline.b, 0.1)
    property color outlineStrong: Qt.rgba(outline.r, outline.g, outline.b, 0.15)

    property color errorHover: Qt.rgba(error.r, error.g, error.b, 0.15)

    property color shadowMedium: Qt.rgba(0, 0, 0, 0.1)
    property color shadowStrong: Qt.rgba(0, 0, 0, 0.35)

    // macOS animation timings
    property int shorterDuration: 120
    property int shortDuration: 200
    property int mediumDuration: 350
    property int longDuration: 550
    property int extraLongDuration: 1100
    property int standardEasing: Easing.OutCubic
    property int emphasizedEasing: Easing.OutQuart

    // macOS design specifications
    property real cornerRadius: 10  // macOS corner radius
    property real spacingXS: 4
    property real spacingS: 8
    property real spacingM: 12
    property real spacingL: 16
    property real spacingXL: 24
    property real fontSizeSmall: 11   // macOS small font
    property real fontSizeMedium: 13  // macOS default font
    property real fontSizeLarge: 15   // macOS large font
    property real fontSizeXLarge: 17  // macOS title font
    property real barHeight: 30       // macOS menu bar height
    property real iconSize: 20        // macOS icon size
    property real iconSizeSmall: 16
    property real iconSizeLarge: 28

    // macOS transparency values
    property real panelTransparency: 0.72    // macOS panel transparency
    property real widgetTransparency: 0.75   // macOS widget transparency
    property real popupTransparency: 0.88    // macOS popup transparency

    // Font family
    property string fontFamily: {
        // Try SF Pro first, fallback to system fonts
        const fonts = ["SF Pro Display", "SF Pro Text", ".AppleSystemUIFont", "Helvetica Neue", "Inter", "Cantarell"]
        return fonts.join(", ")
    }

    function switchTheme(themeName, savePrefs = true) {
        if (themeName === dynamic) {
            currentTheme = dynamic
            extractColors()
        } else {
            currentTheme = "macOS"
        }
        if (savePrefs && typeof SettingsData !== "undefined")
            SettingsData.setTheme(currentTheme)
        
        generateSystemThemesFromCurrentTheme()
    }

    function setLightMode(light, savePrefs = true) {
        isLightMode = light
        if (savePrefs && typeof SessionData !== "undefined")
            SessionData.setLightMode(isLightMode)
            PortalService.setLightMode(isLightMode)
        generateSystemThemesFromCurrentTheme()
    }

    function toggleLightMode(savePrefs = true) {
        setLightMode(!isLightMode, savePrefs)
    }
    
    function forceGenerateSystemThemes() {
        if (!matugenAvailable) {
            if (typeof ToastService !== "undefined") {
                ToastService.showWarning("matugen not available - cannot generate system themes")
            }
            return
        }
        generateSystemThemesFromCurrentTheme()
    }

    function getAvailableThemes() {
        return ["macOS", dynamic]
    }

    function getThemeDisplayName(themeName) {
        if (themeName === "macOS") return "macOS"
        if (themeName === dynamic) return "Dynamic"
        return themeName
    }

    function getThemeColors(themeName) {
        return macOSColors
    }

    function loadCustomTheme(themeData) {
        // Not supported in macOS theme
    }

    function loadCustomThemeFromFile(filePath) {
        // Not supported in macOS theme
    }

    property alias availableThemeNames: root._availableThemeNames
    readonly property var _availableThemeNames: ["macOS", dynamic]
    property string currentThemeName: currentTheme


    function popupBackground() {
        return Qt.rgba(surfaceContainer.r, surfaceContainer.g, surfaceContainer.b, popupTransparency)
    }

    function contentBackground() {
        return Qt.rgba(surfaceContainer.r, surfaceContainer.g, surfaceContainer.b, popupTransparency)
    }

    function panelBackground() {
        return Qt.rgba(surfaceContainer.r, surfaceContainer.g, surfaceContainer.b, panelTransparency)
    }

    function widgetBackground() {
        return Qt.rgba(surfaceContainer.r, surfaceContainer.g, surfaceContainer.b, widgetTransparency)
    }

    function getPopupBackgroundAlpha() {
        return popupTransparency
    }

    function getContentBackgroundAlpha() {
        return popupTransparency
    }

    function isColorDark(c) {
        return (0.299 * c.r + 0.587 * c.g + 0.114 * c.b) < 0.5
    }

    // macOS-style battery icons
    function getBatteryIcon(level, isCharging, batteryAvailable) {
        if (!batteryAvailable)
            return _getBatteryPowerProfileIcon()

        if (isCharging) {
            if (level >= 90) return "battery_charging_full"
            if (level >= 80) return "battery_charging_90"
            if (level >= 60) return "battery_charging_80"
            if (level >= 50) return "battery_charging_60"
            if (level >= 30) return "battery_charging_50"
            if (level >= 20) return "battery_charging_30"
            return "battery_charging_20"
        } else {
            if (level >= 95) return "battery_full"
            if (level >= 85) return "battery_6_bar"
            if (level >= 70) return "battery_5_bar"
            if (level >= 55) return "battery_4_bar"
            if (level >= 40) return "battery_3_bar"
            if (level >= 25) return "battery_2_bar"
            if (level >= 10) return "battery_1_bar"
            return "battery_alert"
        }
    }

    function _getBatteryPowerProfileIcon() {
        if (typeof PowerProfiles === "undefined")
            return "balance"

        switch (PowerProfiles.profile) {
        case PowerProfile.PowerSaver:
            return "energy_savings_leaf"
        case PowerProfile.Performance:
            return "rocket_launch"
        default:
            return "balance"
        }
    }

    function getPowerProfileIcon(profile) {
        switch (profile) {
        case PowerProfile.PowerSaver:
            return "battery_saver"
        case PowerProfile.Balanced:
            return "battery_std"
        case PowerProfile.Performance:
            return "flash_on"
        default:
            return "settings"
        }
    }

    function getPowerProfileLabel(profile) {
        switch (profile) {
        case PowerProfile.PowerSaver:
            return "Low Power Mode"
        case PowerProfile.Balanced:
            return "Automatic"
        case PowerProfile.Performance:
            return "High Power Mode"
        default:
            return profile.charAt(0).toUpperCase() + profile.slice(1)
        }
    }

    function getPowerProfileDescription(profile) {
        switch (profile) {
        case PowerProfile.PowerSaver:
            return "Reduce energy usage to extend battery life"
        case PowerProfile.Balanced:
            return "Balance performance and energy usage"
        case PowerProfile.Performance:
            return "Increase performance and energy usage"
        default:
            return "Custom power profile"
        }
    }

    function extractColors() {
        extractionRequested = true
        if (matugenAvailable)
            fileChecker.running = true
        else
            matugenCheck.running = true
    }

    function onLightModeChanged() {
        if (matugenColors && Object.keys(matugenColors).length > 0) {
            colorUpdateTrigger++
        }
        
        generateSystemThemesFromCurrentTheme()
    }

    function setDesiredTheme(kind, value, isLight, iconTheme) {
        if (!matugenAvailable) {
            console.warn("matugen not available - cannot set system theme")
            return
        }
        
        const desired = {
            "kind": kind,
            "value": value,
            "mode": isLight ? "light" : "dark",
            "iconTheme": iconTheme || "System Default"
        }
        
        const json = JSON.stringify(desired)
        const desiredPath = stateDir + "/matugen.desired.json"
        
        Quickshell.execDetached([
            "sh", "-c", 
            `mkdir -p '${stateDir}' && cat > '${desiredPath}' << 'EOF'\n${json}\nEOF`
        ])
        workerRunning = true
        systemThemeGenerator.command = [shellDir + "/scripts/matugen-worker.sh", stateDir, shellDir, "--run"]
        systemThemeGenerator.running = true
    }
    
    function generateSystemThemesFromCurrentTheme() {
        if (!matugenAvailable)
            return

        const isLight = (typeof SessionData !== "undefined" && SessionData.isLightMode)
        const iconTheme = (typeof SettingsData !== "undefined" && SettingsData.iconTheme) ? SettingsData.iconTheme : "System Default"
        
        if (currentTheme === dynamic) {
            if (!wallpaperPath) {
                return
            }
            setDesiredTheme("image", wallpaperPath, isLight, iconTheme)
        } else {
            // Use macOS primary color
            setDesiredTheme("hex", macOSColors.primary, isLight, iconTheme)
        }
    }

    function applyGtkColors() {
        if (!matugenAvailable) {
            if (typeof ToastService !== "undefined") {
                ToastService.showError("matugen not available - cannot apply GTK colors")
            }
            return
        }

        const isLight = (typeof SessionData !== "undefined" && SessionData.isLightMode) ? "true" : "false"
        gtkApplier.command = [shellDir + "/scripts/gtk.sh", configDir, isLight, shellDir]
        gtkApplier.running = true
    }

    function applyQtColors() {
        if (!matugenAvailable) {
            if (typeof ToastService !== "undefined") {
                ToastService.showError("matugen not available - cannot apply Qt colors")
            }
            return
        }

        qtApplier.command = [shellDir + "/scripts/qt.sh", configDir]
        qtApplier.running = true
    }


    function extractJsonFromText(text) {
        if (!text) return null

        const start = text.search(/[{\[]/)
        if (start === -1) return null

        const open = text[start]
        const pairs = { "{": '}', "[": ']' }
        const close = pairs[open]
        if (!close) return null

        let inString = false
        let escape = false
        const stack = [open]

        for (var i = start + 1; i < text.length; i++) {
            const ch = text[i]

            if (inString) {
                if (escape) {
                    escape = false
                } else if (ch === '\\') {
                    escape = true
                } else if (ch === '"') {
                    inString = false
                }
                continue
            }

            if (ch === '"') {
                inString = true
                continue
            }
            if (ch === '{' || ch === '[') {
                stack.push(ch)
                continue
            }
            if (ch === '}' || ch === ']') {
                const last = stack.pop()
                if (!last || pairs[last] !== ch) {
                    return null
                }
                if (stack.length === 0) {
                    return text.slice(start, i + 1)
                }
            }
        }
        return null
    }

    Process {
        id: matugenCheck
        command: ["which", "matugen"]
        onExited: code => {
            matugenAvailable = (code === 0)
            if (!matugenAvailable) {
                if (typeof ToastService !== "undefined") {
                    ToastService.wallpaperErrorStatus = "matugen_missing"
                    ToastService.showWarning("matugen not found - dynamic theming disabled")
                }
                return
            }
            if (extractionRequested) {
                fileChecker.running = true
            }
            
            const isLight = (typeof SessionData !== "undefined" && SessionData.isLightMode)
            const iconTheme = (typeof SettingsData !== "undefined" && SettingsData.iconTheme) ? SettingsData.iconTheme : "System Default"
            
            if (currentTheme === dynamic) {
                if (wallpaperPath) {
                    // Clear cache on startup to force regeneration
                    Quickshell.execDetached(["rm", "-f", stateDir + "/matugen.key"])
                    setDesiredTheme("image", wallpaperPath, isLight, iconTheme)
                }
            } else {
                // Use macOS primary color for system theming
                Quickshell.execDetached(["rm", "-f", stateDir + "/matugen.key"])
                setDesiredTheme("hex", macOSColors.primary, isLight, iconTheme)
            }
        }
    }

    Process {
        id: fileChecker
        command: ["test", "-r", wallpaperPath]
        onExited: code => {
            if (code === 0) {
                matugenProcess.running = true
            }
        }
    }

    Process {
        id: matugenProcess
        command: ["matugen", "image", wallpaperPath, "--json", "hex"]

        stdout: StdioCollector {
            id: matugenCollector
            onStreamFinished: {
                if (!matugenCollector.text) {
                    if (typeof ToastService !== "undefined") {
                        ToastService.wallpaperErrorStatus = "error"
                        ToastService.showError("Wallpaper Processing Failed: Empty JSON extracted from matugen output.")
                    }
                    return
                }
                const extractedJson = extractJsonFromText(matugenCollector.text)
                if (!extractedJson) {
                    if (typeof ToastService !== "undefined") {
                        ToastService.wallpaperErrorStatus = "error"
                        ToastService.showError("Wallpaper Processing Failed: Invalid JSON extracted from matugen output.")
                    }
                    console.log("Raw matugen output:", matugenCollector.text)
                    return
                }
                try {
                    root.matugenColors = JSON.parse(extractedJson)
                    root.colorUpdateTrigger++
                    if (typeof ToastService !== "undefined") {
                        ToastService.clearWallpaperError()
                    }
                } catch (e) {
                    if (typeof ToastService !== "undefined") {
                        ToastService.wallpaperErrorStatus = "error"
                        ToastService.showError("Wallpaper processing failed (JSON parse error after extraction)")
                    }
                }
            }
        }

        onExited: code => {
            if (code !== 0) {
                if (typeof ToastService !== "undefined") {
                    ToastService.wallpaperErrorStatus = "error"
                    ToastService.showError("Matugen command failed with exit code " + code)
                }
            }
        }
    }

    Process {
        id: ensureStateDir
    }
    
    Process {
        id: systemThemeGenerator
        running: false

        onExited: exitCode => {
            workerRunning = false
            
            if (exitCode === 2) {
                // Exit code 2 means wallpaper/color not found - this is expected on first run
                console.log("Theme worker: wallpaper/color not found, skipping theme generation")
            } else if (exitCode !== 0) {
                if (typeof ToastService !== "undefined") {
                    ToastService.showError("Theme worker failed (" + exitCode + ")")
                }
                console.warn("Theme worker failed with exit code:", exitCode)
            }
        }
    }

    Process {
        id: gtkApplier
        running: false

        stdout: StdioCollector {
            id: gtkStdout
        }

        stderr: StdioCollector {
            id: gtkStderr
        }

        onExited: exitCode => {
            if (exitCode === 0) {
                if (typeof ToastService !== "undefined") {
                    ToastService.showInfo("GTK colors applied successfully")
                }
            } else {
                if (typeof ToastService !== "undefined") {
                    ToastService.showError("Failed to apply GTK colors: " + gtkStderr.text)
                }
            }
        }
    }

    Process {
        id: qtApplier
        running: false

        stdout: StdioCollector {
            id: qtStdout
        }

        stderr: StdioCollector {
            id: qtStderr
        }

        onExited: exitCode => {
            if (exitCode === 0) {
                if (typeof ToastService !== "undefined") {
                    ToastService.showInfo("Qt colors applied successfully")
                }
            } else {
                if (typeof ToastService !== "undefined") {
                    ToastService.showError("Failed to apply Qt colors: " + qtStderr.text)
                }
            }
        }
    }

    Component.onCompleted: {
        matugenCheck.running = true
        if (typeof SessionData !== "undefined")
            SessionData.isLightModeChanged.connect(root.onLightModeChanged)
    }

    FileView {
        id: customThemeFileView
        watchChanges: false
        // Not used in macOS theme
    }

    IpcHandler {
        target: "theme"

        function toggle(): string {
            root.toggleLightMode()
            return root.isLightMode ? "light" : "dark"
        }

        function light(): string {
            root.setLightMode(true)
            return "light"
        }

        function dark(): string {
            root.setLightMode(false)
            return "dark"
        }

        function getMode(): string {
            return root.isLightMode ? "light" : "dark"
        }
    }
}
