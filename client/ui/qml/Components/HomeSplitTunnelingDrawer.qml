import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import PageEnum 1.0

import "../Controls2"
import "../Controls2/TextTypes"
import "../Config"

DrawerType2 {
    id: root

    property bool isAppSplitTinnelingEnabled: Qt.platform.os === "windows" || Qt.platform.os === "android"

    anchors.fill: parent
    expandedHeight: parent.height * 0.9

    expandedStateContent: ColumnLayout {
        id: content

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 0

        Header2Type {
            Layout.fillWidth: true
            Layout.topMargin: 24
            Layout.rightMargin: 16
            Layout.leftMargin: 16
            Layout.bottomMargin: 16

            headerText: qsTr("Split tunneling")
            descriptionText:  qsTr("Allows you to connect to some sites or applications through a VPN connection and bypass others")
        }

        LabelWithButtonType {
            id: splitTunnelingSwitch
            Layout.fillWidth: true
            Layout.topMargin: 16

            visible: ServersModel.isDefaultServerDefaultContainerHasSplitTunneling

            text: qsTr("Split tunneling on the server")
            descriptionText: qsTr("Enabled \nCan't be disabled for current server")
            rightImageSource: "qrc:/images/controls/chevron-right.svg"

            clickedFunction: function() {
                PageController.goToPage(PageEnum.PageSettingsSplitTunneling)
                root.closeTriggered()
            }
        }

        DividerType {
            visible: ServersModel.isDefaultServerDefaultContainerHasSplitTunneling
        }

        // --- sites: own switch + own direction ---

        SwitcherType {
            Layout.fillWidth: true
            Layout.leftMargin: 16
            Layout.rightMargin: 16

            text: qsTr("Site-based split tunneling")
            checked: SitesModel.isTunnelingEnabled

            onToggled: function() {
                SitesModel.toggleSplitTunneling(checked)
            }
        }

        FilterDropDown {
            Layout.fillWidth: true
            Layout.topMargin: 4
            Layout.leftMargin: 16
            Layout.rightMargin: 16

            visible: SitesModel.isTunnelingEnabled

            filterModel: sitesRouteModeModel
            currentValue: SitesModel.routeMode === 2 ? "bypass" : "via"

            onSelected: function(value) {
                SitesModel.routeMode = value === "bypass" ? 2 : 1
            }
        }

        LabelWithButtonType {
            Layout.fillWidth: true

            text: qsTr("Manage the site list")
            descriptionText: SitesModel.isTunnelingEnabled ? qsTr("Enabled") : qsTr("Disabled")
            rightImageSource: "qrc:/images/controls/chevron-right.svg"

            clickedFunction: function() {
                PageController.goToPage(PageEnum.PageSettingsSplitTunneling)
                root.closeTriggered()
            }
        }

        DividerType {
        }

        // --- service presets (direction is defined by the sites mode) ---

        LabelWithButtonType {
            id: serviceBasedSplitTunnelingSwitch
            Layout.fillWidth: true

            text: qsTr("Service-based split tunneling")
            descriptionText: SplitPresetsModel.enabledCount > 0 ? qsTr("Enabled") : qsTr("Disabled")
            rightImageSource: "qrc:/images/controls/chevron-right.svg"

            clickedFunction: function() {
                PageController.goToPage(PageEnum.PageSettingsSplitPresets)
                root.closeTriggered()
            }
        }

        DividerType {
        }

        // --- apps: own switch + own direction ---

        SwitcherType {
            Layout.fillWidth: true
            Layout.leftMargin: 16
            Layout.rightMargin: 16

            visible: isAppSplitTinnelingEnabled

            text: qsTr("App-based split tunneling")
            checked: AppSplitTunnelingModel.isTunnelingEnabled

            onToggled: function() {
                AppSplitTunnelingModel.toggleSplitTunneling(checked)
            }
        }

        FilterDropDown {
            Layout.fillWidth: true
            Layout.topMargin: 4
            Layout.leftMargin: 16
            Layout.rightMargin: 16

            // Windows supports app exclusions only (WFP driver); both
            // directions work on Android
            visible: isAppSplitTinnelingEnabled && AppSplitTunnelingModel.isTunnelingEnabled
                     && Qt.platform.os === "android"

            filterModel: appsRouteModeModel
            currentValue: AppSplitTunnelingModel.routeMode === 2 ? "bypass" : "via"

            onSelected: function(value) {
                AppSplitTunnelingModel.routeMode = value === "bypass" ? 2 : 1
            }
        }

        LabelWithButtonType {
            id: appSplitTunnelingSwitch
            visible: isAppSplitTinnelingEnabled

            Layout.fillWidth: true

            text: qsTr("Manage the app list")
            descriptionText: AppSplitTunnelingModel.isTunnelingEnabled ? qsTr("Enabled") : qsTr("Disabled")
            rightImageSource: "qrc:/images/controls/chevron-right.svg"

            clickedFunction: function() {
                PageController.goToPage(PageEnum.PageSettingsAppSplitTunneling)
                root.closeTriggered()
            }
        }

        DividerType {
            visible: isAppSplitTinnelingEnabled
        }
    }

    ListModel {
        id: sitesRouteModeModel
    }

    ListModel {
        id: appsRouteModeModel
    }

    Component.onCompleted: {
        sitesRouteModeModel.append({ "name": qsTr("via VPN"), "value": "via" })
        sitesRouteModeModel.append({ "name": qsTr("bypass VPN"), "value": "bypass" })
        appsRouteModeModel.append({ "name": qsTr("via VPN"), "value": "via" })
        appsRouteModeModel.append({ "name": qsTr("bypass VPN"), "value": "bypass" })
    }
}
