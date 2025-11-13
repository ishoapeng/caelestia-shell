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

    StyledText {
        text: qsTr("Output Devices")
        font.pointSize: Appearance.font.size.larger
        font.weight: 500
    }

    StyledText {
        text: qsTr("Audio output devices")
        color: Colours.palette.m3outline
    }

    StyledFlickable {
        Layout.fillWidth: true
        Layout.fillHeight: true

        flickableDirection: Flickable.VerticalFlick
        contentHeight: sinksLayout.implicitHeight

        ColumnLayout {
            id: sinksLayout

            anchors.left: parent.left
            anchors.right: parent.right
            spacing: Appearance.spacing.small

            Repeater {
                model: Audio.sinks

                DeviceItem {
                    required property PwNode modelData

                    device: modelData
                    isActive: Audio.sink?.id === modelData.id
                    isOutput: true

                    onClicked: {
                        Audio.setAudioSink(modelData);
                        root.session.audio.active = modelData;
                    }
                }
            }
        }
    }

    StyledText {
        Layout.topMargin: Appearance.spacing.normal
        text: qsTr("Input Devices")
        font.pointSize: Appearance.font.size.larger
        font.weight: 500
    }

    StyledText {
        text: qsTr("Audio input devices")
        color: Colours.palette.m3outline
    }

    StyledFlickable {
        Layout.fillWidth: true
        Layout.preferredHeight: 200

        flickableDirection: Flickable.VerticalFlick
        contentHeight: sourcesLayout.implicitHeight

        ColumnLayout {
            id: sourcesLayout

            anchors.left: parent.left
            anchors.right: parent.right
            spacing: Appearance.spacing.small

            Repeater {
                model: Audio.sources

                DeviceItem {
                    required property PwNode modelData

                    device: modelData
                    isActive: Audio.source?.id === modelData.id
                    isOutput: false

                    onClicked: {
                        Audio.setAudioSource(modelData);
                        root.session.audio.active = modelData;
                    }
                }
            }
        }
    }

    component DeviceItem: StyledRect {
        id: item

        required property PwNode device
        required property bool isActive
        required property bool isOutput

        function onClicked(): void {}

        Layout.fillWidth: true
        implicitHeight: content.implicitHeight + Appearance.padding.normal * 2

        radius: Appearance.rounding.normal
        color: item.isActive ? Colours.palette.m3secondaryContainer : Colours.tPalette.m3surfaceContainer

        StateLayer {
            radius: parent.radius
            function onClicked(): void {
                item.onClicked();
            }
        }

        RowLayout {
            id: content

            anchors.fill: parent
            anchors.margins: Appearance.padding.normal
            spacing: Appearance.spacing.normal

            MaterialIcon {
                text: item.isOutput ? "volume_up" : "mic"
                color: item.isActive ? Colours.palette.m3onSecondaryContainer : Colours.palette.m3onSurface
                font.pointSize: Appearance.font.size.large
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Appearance.spacing.smaller

                StyledText {
                    text: item.device.description || item.device.name || qsTr("Unknown Device")
                    color: item.isActive ? Colours.palette.m3onSecondaryContainer : Colours.palette.m3onSurface
                    font.pointSize: Appearance.font.size.normal
                    font.weight: item.isActive ? 500 : 400
                    elide: Text.ElideRight
                }

                StyledText {
                    visible: item.device.name && item.device.name !== item.device.description
                    text: item.device.name
                    color: item.isActive ? Colours.palette.m3onSecondaryContainer : Colours.palette.m3outline
                    font.pointSize: Appearance.font.size.small
                    elide: Text.ElideRight
                }
            }

            MaterialIcon {
                visible: item.isActive
                text: "check"
                color: Colours.palette.m3onSecondaryContainer
                font.pointSize: Appearance.font.size.large
            }
        }
    }
}

