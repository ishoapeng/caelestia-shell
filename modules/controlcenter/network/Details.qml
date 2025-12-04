pragma ComponentBehavior: Bound

import ".."
import qs.components
import qs.components.controls
import qs.components.containers
import qs.services
import qs.config
import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    required property Session session

    readonly property Network.AccessPoint network: session.network?.active
    property string connectionName: ""
    property string connectionUuid: ""
    property string password: ""
    property bool passwordVisible: false
    property bool loadingDetails: false

    Component.onCompleted: {
        if (network) {
            loadConnectionDetails();
        }
    }

    onNetworkChanged: {
        if (network) {
            connectionName = "";
            connectionUuid = "";
            password = "";
            loadConnectionDetails();
        }
    }

    function loadConnectionDetails(): void {
        if (!network) return;
        loadingDetails = true;
        getConnProc.running = true;
    }

    function loadPassword(): void {
        if (!connectionUuid) {
            password = "";
            return;
        }
        getPassProc.running = true;
    }

    Process {
        id: getConnProc

        command: ["nmcli", "-t", "-f", "NAME,UUID,DEVICE", "connection", "show", "--active"]
        environment: ({
            LANG: "C.UTF-8",
            LC_ALL: "C.UTF-8"
        })
        stdout: StdioCollector {
            onStreamFinished: {
                const output = text.trim();
                const lines = output.split("\n");
                
                for (const line of lines) {
                    const parts = line.split(":");
                    if (parts.length >= 3 && parts[2] === "wifi") {
                        root.connectionName = parts[0] || "";
                        root.connectionUuid = parts[1] || "";
                        root.loadPassword();
                        break;
                    }
                }
                root.loadingDetails = false;
            }
        }
    }

    Process {
        id: getPassProc

        command: ["nmcli", "-s", "connection", "show", root.connectionUuid]
        environment: ({
            LANG: "C.UTF-8",
            LC_ALL: "C.UTF-8"
        })
        stdout: StdioCollector {
            onStreamFinished: {
                const output = text;
                const match = output.match(/802-11-wireless-security\.psk[:\s]+(.+)/);
                if (match && match[1]) {
                    root.password = match[1].trim();
                } else {
                    root.password = "";
                }
            }
        }
    }

    StyledFlickable {
        anchors.fill: parent

        flickableDirection: Flickable.VerticalFlick
        contentHeight: layout.height

        ColumnLayout {
            id: layout

            anchors.left: parent.left
            anchors.right: parent.right
            spacing: Appearance.spacing.normal

            MaterialIcon {
                Layout.alignment: Qt.AlignHCenter
                text: Icons.getNetworkIcon(network?.strength ?? 0)
                font.pointSize: Appearance.font.size.extraLarge * 3
                font.bold: true
            }

            StyledText {
                Layout.alignment: Qt.AlignHCenter
                text: network?.ssid ?? qsTr("Unknown Network")
                font.pointSize: Appearance.font.size.large
                font.bold: true
            }

            StyledText {
                Layout.topMargin: Appearance.spacing.large
                text: qsTr("Connection Information")
                font.pointSize: Appearance.font.size.larger
                font.weight: 500
            }

            StyledText {
                text: qsTr("Network connection details")
                color: Colours.palette.m3outline
            }

            StyledRect {
                Layout.fillWidth: true
                implicitHeight: infoLayout.implicitHeight + Appearance.padding.large * 2

                radius: Appearance.rounding.normal
                color: Colours.tPalette.m3surfaceContainer

                ColumnLayout {
                    id: infoLayout

                    anchors.fill: parent
                    anchors.margins: Appearance.padding.large
                    spacing: Appearance.spacing.normal

                    InfoRow {
                        label: qsTr("SSID")
                        value: network?.ssid || qsTr("Unknown")
                    }

                    InfoRow {
                        label: qsTr("Signal Strength")
                        value: network ? `${network.strength}%` : qsTr("Unknown")
                    }

                    InfoRow {
                        label: qsTr("Frequency")
                        value: network?.frequency > 0 ? `${(network.frequency / 1000).toFixed(1)} GHz` : qsTr("Unknown")
                    }

                    InfoRow {
                        label: qsTr("Security")
                        value: network?.security || qsTr("None")
                    }

                    InfoRow {
                        label: qsTr("BSSID")
                        value: network?.bssid || qsTr("Unknown")
                    }

                    InfoRow {
                        label: qsTr("Connection Name")
                        value: root.connectionName || qsTr("Unknown")
                    }

                    InfoRow {
                        label: qsTr("Connection UUID")
                        value: root.connectionUuid || qsTr("Unknown")
                    }
                }
            }

            StyledText {
                Layout.topMargin: Appearance.spacing.large
                text: qsTr("Security")
                font.pointSize: Appearance.font.size.larger
                font.weight: 500
            }

            StyledText {
                text: qsTr("WiFi password and security settings")
                color: Colours.palette.m3outline
            }

            StyledRect {
                Layout.fillWidth: true
                implicitHeight: passwordContent.implicitHeight + Appearance.padding.large * 2

                radius: Appearance.rounding.normal
                color: Colours.tPalette.m3surfaceContainer

                ColumnLayout {
                    id: passwordContent

                    anchors.fill: parent
                    anchors.margins: Appearance.padding.large
                    spacing: Appearance.spacing.normal

                    RowLayout {
                        Layout.fillWidth: true

                        StyledText {
                            text: qsTr("Password")
                            color: Colours.palette.m3onSurface
                            font.pointSize: Appearance.font.size.normal
                            font.weight: 500
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        IconButton {
                            icon: root.passwordVisible ? "visibility_off" : "visibility"
                            onClicked: root.passwordVisible = !root.passwordVisible
                        }
                    }

                    StyledRect {
                        Layout.fillWidth: true
                        implicitHeight: passwordField.implicitHeight + Appearance.padding.normal * 2

                        radius: Appearance.rounding.small
                        color: Colours.tPalette.m3surfaceContainerHigh

                        StyledText {
                            id: passwordField

                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.margins: Appearance.padding.normal

                            text: {
                                if (root.loadingDetails)
                                    return qsTr("Loading...");
                                if (!root.password)
                                    return qsTr("No password stored");
                                return root.passwordVisible ? root.password : "•".repeat(root.password.length);
                            }
                            color: root.password ? Colours.palette.m3onSurface : Colours.palette.m3outline
                            font.pointSize: Appearance.font.size.normal
                            font.family: root.passwordVisible ? "" : "monospace"
                        }
                    }

                    StyledText {
                        visible: !root.password && !root.loadingDetails
                        text: qsTr("Password not available. It may be stored in a keyring or not saved.")
                        color: Colours.palette.m3outline
                        font.pointSize: Appearance.font.size.small
                        wrapMode: Text.WordWrap
                    }
                }
            }

            RowLayout {
                Layout.topMargin: Appearance.spacing.large
                Layout.alignment: Qt.AlignHCenter
                spacing: Appearance.spacing.normal

                IconTextButton {
                    icon: "link_off"
                    text: qsTr("Disconnect")
                    onClicked: {
                        if (network) {
                            Network.disconnectFromNetwork();
                            root.session.network.active = null;
                        }
                    }
                }
            }
        }
    }

    component InfoRow: RowLayout {
        required property string label
        required property string value

        Layout.fillWidth: true

        StyledText {
            text: root.label + ":"
            color: Colours.palette.m3outline
            font.pointSize: Appearance.font.size.normal
        }

        StyledText {
            Layout.fillWidth: true
            Layout.leftMargin: Appearance.spacing.normal
            text: root.value
            color: Colours.palette.m3onSurface
            font.pointSize: Appearance.font.size.normal
            elide: Text.ElideRight
        }
    }
}

