pragma ComponentBehavior: Bound

import ".."
import qs.components
import qs.components.controls
import qs.components.containers
import qs.services
import qs.config
import qs.utils
import Quickshell
import Quickshell.Services.Pipewire
import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root

    required property Session session
    required property var outputStreams
    required property var inputStreams

    spacing: Appearance.spacing.normal

    property int currentTab: 0

    StyledText {
        text: currentTab === 0 ? qsTr("Playback") : currentTab === 1 ? qsTr("Recording") : currentTab === 2 ? qsTr("Output Devices") : qsTr("Input Devices")
        font.pointSize: Appearance.font.size.larger
        font.weight: 500
    }

    StyledText {
        text: currentTab === 0 ? qsTr("Application audio streams") : currentTab === 1 ? qsTr("Application input streams") : currentTab === 2 ? qsTr("Audio output devices") : qsTr("Audio input devices")
        color: Colours.palette.m3outline
    }

    // Tabs
    RowLayout {
        Layout.fillWidth: true
        Layout.bottomMargin: Appearance.spacing.small
        spacing: Appearance.spacing.small

        TabButton {
            text: qsTr("Playback")
            checked: root.currentTab === 0
            onClicked: root.currentTab = 0
        }

        TabButton {
            text: qsTr("Recording")
            checked: root.currentTab === 1
            onClicked: root.currentTab = 1
        }

        TabButton {
            text: qsTr("Output")
            checked: root.currentTab === 2
            onClicked: root.currentTab = 2
        }

        TabButton {
            text: qsTr("Input")
            checked: root.currentTab === 3
            onClicked: root.currentTab = 3
        }
    }

    StyledFlickable {
        Layout.fillWidth: true
        Layout.fillHeight: true

        flickableDirection: Flickable.VerticalFlick
        contentHeight: contentLayout.implicitHeight

        ColumnLayout {
            id: contentLayout

            anchors.left: parent.left
            anchors.right: parent.right
            spacing: Appearance.spacing.small

            // Playback tab - Application streams
            Repeater {
                visible: root.currentTab === 0
                model: root.currentTab === 0 ? root.outputStreams : []

                StreamItem {
                    required property PwNode modelData

                    Layout.topMargin: index === 0 ? 0 : Appearance.spacing.small
                    stream: modelData
                    isOutput: true
                    isActive: root.session.audio?.active?.id === modelData.id

                    onClicked: {
                        root.session.audio.active = modelData;
                    }
                }
            }

            // Recording tab - Input streams
            Repeater {
                visible: root.currentTab === 1
                model: root.currentTab === 1 ? root.inputStreams : []

                StreamItem {
                    required property PwNode modelData

                    Layout.topMargin: index === 0 ? 0 : Appearance.spacing.small
                    stream: modelData
                    isOutput: false
                    isActive: root.session.audio?.active?.id === modelData.id

                    onClicked: {
                        root.session.audio.active = modelData;
                    }
                }
            }

            // Output Devices tab
            Repeater {
                visible: root.currentTab === 2
                model: root.currentTab === 2 ? Audio.sinks : []

                DeviceItem {
                    required property PwNode modelData

                    Layout.topMargin: index === 0 ? 0 : Appearance.spacing.small
                    device: modelData
                    isActive: Audio.sink?.id === modelData.id
                    isOutput: true
                    showControls: false

                    onClicked: {
                        Audio.setAudioSink(modelData);
                        if (root.session?.audio) {
                            root.session.audio.active = modelData;
                        }
                    }
                }
            }

            // Input Devices tab
            Repeater {
                visible: root.currentTab === 3
                model: root.currentTab === 3 ? Audio.sources : []

                DeviceItem {
                    required property PwNode modelData

                    Layout.topMargin: index === 0 ? 0 : Appearance.spacing.small
                    device: modelData
                    isActive: Audio.source?.id === modelData.id
                    isOutput: false
                    showControls: false

                    onClicked: {
                        Audio.setAudioSource(modelData);
                        if (root.session?.audio) {
                            root.session.audio.active = modelData;
                        }
                    }
                }
            }
        }
    }

    component TabButton: StyledRect {
        id: button

        property string text
        property bool checked

        signal clicked

        implicitHeight: label.implicitHeight + Appearance.padding.normal * 2
        implicitWidth: label.implicitWidth + Appearance.padding.normal * 2

        radius: Appearance.rounding.small
        color: button.checked ? Colours.palette.m3primaryContainer : Colours.tPalette.m3surfaceContainer

        StateLayer {
            radius: parent.radius
            function onClicked(): void {
                button.clicked();
            }
        }

        StyledText {
            id: label

            anchors.centerIn: parent
            text: button.text
            color: button.checked ? Colours.palette.m3onPrimaryContainer : Colours.palette.m3onSurface
            font.pointSize: Appearance.font.size.small
            font.weight: button.checked ? 500 : 400
        }
    }

    component StreamItem: StyledRect {
        id: item

        required property PwNode stream
        required property bool isOutput
        required property bool isActive

        signal clicked

        Layout.fillWidth: true
        implicitHeight: streamContent.implicitHeight + Appearance.padding.large * 2

        radius: Appearance.rounding.normal
        color: item.isActive ? Colours.palette.m3secondaryContainer : Colours.tPalette.m3surfaceContainer

        StateLayer {
            radius: parent.radius
            function onClicked(): void {
                item.clicked();
            }
        }

        RowLayout {
            id: streamContent

            anchors.fill: parent
            anchors.margins: Appearance.padding.large
            spacing: Appearance.spacing.normal

            MaterialIcon {
                text: item.isOutput ? "volume_up" : "mic"
                color: item.isActive ? Colours.palette.m3onSecondaryContainer : Colours.palette.m3primary
                font.pointSize: Appearance.font.size.large
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Appearance.spacing.smaller

                StyledText {
                    Layout.fillWidth: true
                    text: item.stream.description || item.stream.name || qsTr("Unknown Stream")
                    color: item.isActive ? Colours.palette.m3onSecondaryContainer : Colours.palette.m3onSurface
                    font.pointSize: Appearance.font.size.normal
                    font.weight: item.isActive ? 500 : 400
                    elide: Text.ElideRight
                }

                StyledText {
                    Layout.fillWidth: true
                    visible: item.stream.name && item.stream.name !== item.stream.description
                    text: item.stream.name
                    color: item.isActive ? Colours.palette.m3onSecondaryContainer : Colours.palette.m3outline
                    font.pointSize: Appearance.font.size.small
                    elide: Text.ElideRight
                }

                StyledText {
                    Layout.fillWidth: true
                    text: item.stream?.audio?.muted ? qsTr("Muted") : `${Math.round((item.stream?.audio?.volume ?? 0) * 100)}%`
                    color: item.isActive ? Colours.palette.m3onSecondaryContainer : Colours.palette.m3outline
                    font.pointSize: Appearance.font.size.small
                    elide: Text.ElideRight
                }
            }

            MaterialIcon {
                Layout.preferredWidth: visible ? implicitWidth : 0
                visible: item.isActive
                text: "check"
                color: Colours.palette.m3onSecondaryContainer
                font.pointSize: Appearance.font.size.large
            }
        }
    }

    component DeviceItem: StyledRect {
        id: item

        required property PwNode device
        required property bool isActive
        required property bool isOutput
        property bool showControls: false

        signal clicked

        Layout.fillWidth: true
        implicitHeight: deviceContent.implicitHeight + Appearance.padding.large * 2

        radius: Appearance.rounding.normal
        color: item.isActive ? Colours.palette.m3secondaryContainer : Colours.tPalette.m3surfaceContainer

        StateLayer {
            radius: parent.radius
            function onClicked(): void {
                item.clicked();
            }
        }

        RowLayout {
            id: deviceContent

            anchors.fill: parent
            anchors.margins: Appearance.padding.large
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
                    Layout.fillWidth: true
                    text: item.device.description || item.device.name || qsTr("Unknown Device")
                    color: item.isActive ? Colours.palette.m3onSecondaryContainer : Colours.palette.m3onSurface
                    font.pointSize: Appearance.font.size.normal
                    font.weight: item.isActive ? 500 : 400
                    elide: Text.ElideRight
                }

                StyledText {
                    Layout.fillWidth: true
                    visible: item.device.name && item.device.name !== item.device.description
                    text: item.device.name
                    color: item.isActive ? Colours.palette.m3onSecondaryContainer : Colours.palette.m3outline
                    font.pointSize: Appearance.font.size.small
                    wrapMode: Text.Wrap
                    maximumLineCount: 2
                    elide: Text.ElideRight
                }
            }

            MaterialIcon {
                Layout.preferredWidth: visible ? implicitWidth : 0
                visible: item.isActive
                text: "check"
                color: Colours.palette.m3onSecondaryContainer
                font.pointSize: Appearance.font.size.large
            }
        }
    }
}

