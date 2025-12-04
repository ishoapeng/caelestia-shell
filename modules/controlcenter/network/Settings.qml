pragma ComponentBehavior: Bound

import ".."
import qs.components
import qs.components.controls
import qs.services
import qs.config
import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root

    required property Session session

    spacing: Appearance.spacing.normal

    MaterialIcon {
        Layout.alignment: Qt.AlignHCenter
        text: "network_manage"
        font.pointSize: Appearance.font.size.extraLarge * 3
        font.bold: true
    }

    StyledText {
        Layout.alignment: Qt.AlignHCenter
        text: qsTr("Network Settings")
        font.pointSize: Appearance.font.size.large
        font.bold: true
    }

    StyledText {
        Layout.topMargin: Appearance.spacing.large
        text: qsTr("WiFi Status")
        font.pointSize: Appearance.font.size.larger
        font.weight: 500
    }

    StyledText {
        text: qsTr("Enable or disable WiFi")
        color: Colours.palette.m3outline
    }

    StyledRect {
        Layout.fillWidth: true
        implicitHeight: wifiToggleContent.implicitHeight + Appearance.padding.large * 2

        radius: Appearance.rounding.normal
        color: Colours.tPalette.m3surfaceContainer

        RowLayout {
            id: wifiToggleContent

            anchors.fill: parent
            anchors.margins: Appearance.padding.large
            spacing: Appearance.spacing.normal

            MaterialIcon {
                text: Network.wifiEnabled ? "wifi" : "wifi_off"
                color: Network.wifiEnabled ? Colours.palette.m3primary : Colours.palette.m3outline
                font.pointSize: Appearance.font.size.large
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Appearance.spacing.smaller

                StyledText {
                    text: qsTr("WiFi")
                    color: Colours.palette.m3onSurface
                    font.pointSize: Appearance.font.size.normal
                    font.weight: 500
                }

                StyledText {
                    text: Network.wifiEnabled ? qsTr("Enabled") : qsTr("Disabled")
                    color: Colours.palette.m3outline
                    font.pointSize: Appearance.font.size.small
                }
            }

            StyledSwitch {
                checked: Network.wifiEnabled
                onToggled: Network.enableWifi(checked)
            }
        }
    }

    StyledRect {
        Layout.fillWidth: true
        Layout.topMargin: Appearance.spacing.normal
        implicitHeight: rescanContent.implicitHeight + Appearance.padding.large * 2

        radius: Appearance.rounding.normal
        color: Colours.palette.m3primaryContainer

        StateLayer {
            radius: parent.radius
            disabled: Network.scanning || !Network.wifiEnabled
            color: Colours.palette.m3onPrimaryContainer

            function onClicked(): void {
                Network.rescanWifi();
            }
        }

        RowLayout {
            id: rescanContent

            anchors.centerIn: parent
            spacing: Appearance.spacing.normal
            opacity: Network.scanning ? 0 : 1

            MaterialIcon {
                animate: true
                text: "wifi_find"
                color: Colours.palette.m3onPrimaryContainer
                font.pointSize: Appearance.font.size.large
            }

            StyledText {
                text: qsTr("Rescan networks")
                color: Colours.palette.m3onPrimaryContainer
                font.pointSize: Appearance.font.size.normal
            }

            Behavior on opacity {
                Anim {}
            }
        }

        CircularIndicator {
            anchors.centerIn: parent
            strokeWidth: Appearance.padding.small / 2
            bgColour: "transparent"
            implicitHeight: parent.implicitHeight - Appearance.padding.smaller * 2
            running: Network.scanning
        }
    }
}

