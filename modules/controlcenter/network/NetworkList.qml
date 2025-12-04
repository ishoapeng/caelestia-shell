pragma ComponentBehavior: Bound

import ".."
import qs.components
import qs.components.controls
import qs.components.containers
import qs.services
import qs.config
import qs.utils
import Quickshell
import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root

    required property Session session

    spacing: Appearance.spacing.normal

    StyledText {
        text: qsTr("Networks")
        font.pointSize: Appearance.font.size.larger
        font.weight: 500
    }

    StyledText {
        text: qsTr("Available WiFi networks")
        color: Colours.palette.m3outline
    }

    StyledFlickable {
        Layout.fillWidth: true
        Layout.fillHeight: true

        flickableDirection: Flickable.VerticalFlick
        contentHeight: networksLayout.implicitHeight

        ColumnLayout {
            id: networksLayout

            anchors.left: parent.left
            anchors.right: parent.right
            spacing: Appearance.spacing.small

            Repeater {
                model: ScriptModel {
                    values: [...Network.networks].sort((a, b) => {
                        if (a.active !== b.active)
                            return b.active - a.active;
                        return b.strength - a.strength;
                    })
                }

                NetworkItem {
                    required property Network.AccessPoint modelData

                    Layout.topMargin: index === 0 ? 0 : Appearance.spacing.small
                    network: modelData
                    isActive: Network.active?.ssid === modelData.ssid

                    onClicked: {
                        if (modelData.active) {
                            root.session.network.active = modelData;
                        } else {
                            connectingToSsid = modelData.ssid;
                            Network.connectToNetwork(modelData.ssid, "");
                        }
                    }
                }
            }
        }
    }

    component NetworkItem: StyledRect {
        id: item

        required property Network.AccessPoint network
        required property bool isActive

        property string connectingToSsid: ""
        signal clicked

        Layout.fillWidth: true
        implicitHeight: networkContent.implicitHeight + Appearance.padding.large * 2

        radius: Appearance.rounding.normal
        color: item.isActive ? Colours.palette.m3secondaryContainer : Colours.tPalette.m3surfaceContainer

        StateLayer {
            radius: parent.radius
            function onClicked(): void {
                item.clicked();
            }
        }

        RowLayout {
            id: networkContent

            anchors.fill: parent
            anchors.margins: Appearance.padding.large
            spacing: Appearance.spacing.normal

            MaterialIcon {
                text: Icons.getNetworkIcon(item.network.strength)
                color: item.isActive ? Colours.palette.m3onSecondaryContainer : Colours.palette.m3onSurface
                font.pointSize: Appearance.font.size.large
            }

            MaterialIcon {
                visible: item.network.isSecure
                text: "lock"
                color: item.isActive ? Colours.palette.m3onSecondaryContainer : Colours.palette.m3outline
                font.pointSize: Appearance.font.size.small
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Appearance.spacing.smaller

                StyledText {
                    text: item.network.ssid
                    color: item.isActive ? Colours.palette.m3onSecondaryContainer : Colours.palette.m3onSurface
                    font.pointSize: Appearance.font.size.normal
                    font.weight: item.isActive ? 500 : 400
                    elide: Text.ElideRight
                }

                RowLayout {
                    spacing: Appearance.spacing.smaller

                    StyledText {
                        text: `${item.network.strength}%`
                        color: item.isActive ? Colours.palette.m3onSecondaryContainer : Colours.palette.m3outline
                        font.pointSize: Appearance.font.size.small
                    }

                    StyledText {
                        visible: item.network.frequency > 0
                        text: `${(item.network.frequency / 1000).toFixed(1)} GHz`
                        color: item.isActive ? Colours.palette.m3onSecondaryContainer : Colours.palette.m3outline
                        font.pointSize: Appearance.font.size.small
                    }
                }
            }

            MaterialIcon {
                visible: item.isActive
                text: "check"
                color: Colours.palette.m3onSecondaryContainer
                font.pointSize: Appearance.font.size.large
            }
        }

        Connections {
            target: Network

            function onActiveChanged(): void {
                if (Network.active && item.connectingToSsid === Network.active.ssid) {
                    item.connectingToSsid = "";
                }
            }
        }
    }
}

