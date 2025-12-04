pragma ComponentBehavior: Bound

import ".."
import qs.components
import qs.components.controls
import qs.services
import qs.config
import Quickshell.Services.Pipewire
import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root

    required property Session session

    spacing: Appearance.spacing.normal

    readonly property PwNode device: session.audio.active

    MaterialIcon {
        Layout.alignment: Qt.AlignHCenter
        text: device?.isSink ? "volume_up" : "mic"
        font.pointSize: Appearance.font.size.extraLarge * 3
        font.bold: true
        color: Colours.palette.m3primary
    }

    StyledText {
        Layout.alignment: Qt.AlignHCenter
        text: device?.description || device?.name || qsTr("Unknown Device")
        font.pointSize: Appearance.font.size.large
        font.bold: true
    }

    StyledText {
        Layout.alignment: Qt.AlignHCenter
        Layout.topMargin: Appearance.spacing.small
        visible: device?.name && device?.name !== device?.description
        text: device?.name || ""
        color: Colours.palette.m3outline
        font.pointSize: Appearance.font.size.normal
    }

    StyledText {
        Layout.topMargin: Appearance.spacing.large
        text: qsTr("Volume")
        font.pointSize: Appearance.font.size.larger
        font.weight: 500
    }

    StyledRect {
        Layout.fillWidth: true
        Layout.topMargin: Appearance.spacing.small
        implicitHeight: volumeControl.implicitHeight + Appearance.padding.large * 2

        radius: Appearance.rounding.normal
        color: Colours.tPalette.m3surfaceContainer

        ColumnLayout {
            id: volumeControl

            anchors.fill: parent
            anchors.margins: Appearance.padding.large
            spacing: Appearance.spacing.normal

            RowLayout {
                MaterialIcon {
                    text: device?.audio?.muted ? (device?.isSink ? "volume_off" : "mic_off") : (device?.isSink ? "volume_up" : "mic")
                    color: device?.audio?.muted ? Colours.palette.m3outline : Colours.palette.m3primary
                    font.pointSize: Appearance.font.size.large
                }

                StyledText {
                    Layout.fillWidth: true
                    text: device?.audio?.muted ? qsTr("Muted") : `${Math.round((device?.audio?.volume ?? 0) * 100)}%`
                    color: device?.audio?.muted ? Colours.palette.m3outline : Colours.palette.m3onSurface
                    font.pointSize: Appearance.font.size.normal
                }

                IconButton {
                    icon: device?.audio?.muted ? (device?.isSink ? "volume_off" : "mic_off") : (device?.isSink ? "volume_up" : "mic")
                    onClicked: {
                        if (device?.audio) {
                            device.audio.muted = !device.audio.muted;
                        }
                    }
                }
            }

            CustomMouseArea {
                Layout.fillWidth: true
                implicitHeight: Appearance.padding.normal * 3

                onWheel: event => {
                    if (!device?.audio) return;
                    const currentVolume = device.audio.volume;
                    const increment = Config.services.audioIncrement;
                    if (event.angleDelta.y > 0) {
                        device.audio.volume = Math.min(Config.services.maxVolume, currentVolume + increment);
                    } else if (event.angleDelta.y < 0) {
                        device.audio.volume = Math.max(0, currentVolume - increment);
                    }
                }

                StyledSlider {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    implicitHeight: parent.implicitHeight

                    value: device?.audio?.volume ?? 0
                    to: Config.services.maxVolume
                    enabled: !!device?.audio
                    onMoved: {
                        if (device?.audio) {
                            device.audio.muted = false;
                            device.audio.volume = value;
                        }
                    }

                    Behavior on value {
                        Anim {}
                    }
                }
            }
        }
    }

    StyledText {
        Layout.topMargin: Appearance.spacing.large
        text: qsTr("Device Information")
        font.pointSize: Appearance.font.size.larger
        font.weight: 500
    }

    StyledRect {
        Layout.fillWidth: true
        Layout.topMargin: Appearance.spacing.small
        implicitHeight: infoLayout.implicitHeight + Appearance.padding.large * 2

        radius: Appearance.rounding.normal
        color: Colours.tPalette.m3surfaceContainer

        ColumnLayout {
            id: infoLayout

            anchors.fill: parent
            anchors.margins: Appearance.padding.large
            spacing: Appearance.spacing.normal

            InfoRow {
                label: qsTr("Name")
                value: device?.name || qsTr("Unknown")
            }

            InfoRow {
                label: qsTr("Description")
                value: device?.description || qsTr("Unknown")
            }

            InfoRow {
                label: qsTr("Type")
                value: device?.isSink ? qsTr("Output") : qsTr("Input")
            }

            InfoRow {
                label: qsTr("ID")
                value: device?.id?.toString() || qsTr("Unknown")
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

