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

    anchors.fill: parent
    anchors.margins: Appearance.padding.large
    spacing: 0

    // Get all streams (applications)
    readonly property var outputStreams: Pipewire.nodes.values.filter(n => n.isStream && n.isSink)
    readonly property var inputStreams: Pipewire.nodes.values.filter(n => n.isStream && !n.isSink && n.audio)

    property int currentTab: 0

    // Track streams for real-time updates
    PwObjectTracker {
        objects: [...root.outputStreams, ...root.inputStreams]
    }

    // Tabs
    RowLayout {
        Layout.fillWidth: true
        Layout.bottomMargin: Appearance.spacing.normal
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
            text: qsTr("Output Devices")
            checked: root.currentTab === 2
            onClicked: root.currentTab = 2
        }

        TabButton {
            text: qsTr("Input Devices")
            checked: root.currentTab === 3
            onClicked: root.currentTab = 3
        }
    }

    // Content area
    StyledFlickable {
        Layout.fillWidth: true
        Layout.fillHeight: true

        flickableDirection: Flickable.VerticalFlick
        contentHeight: content.implicitHeight

        ColumnLayout {
            id: content

            anchors.left: parent.left
            anchors.right: parent.right
            spacing: Appearance.spacing.normal

            // Playback tab - Application streams
            Loader {
                Layout.fillWidth: true
                visible: root.currentTab === 0
                active: root.currentTab === 0

                sourceComponent: ColumnLayout {
                    id: playbackContent

                    property var session: root.session
                    property var outputStreams: root.outputStreams

                    spacing: Appearance.spacing.normal

                    StyledText {
                        text: qsTr("Playback")
                        font.pointSize: Appearance.font.size.larger
                        font.weight: 500
                    }

                    StyledText {
                        Layout.bottomMargin: Appearance.spacing.small
                        text: qsTr("Application audio streams")
                        color: Colours.palette.m3outline
                    }

                    Repeater {
                        model: playbackContent.outputStreams

                        StreamItem {
                            required property PwNode modelData

                            Layout.topMargin: index === 0 ? 0 : Appearance.spacing.small
                            stream: modelData
                            isOutput: true
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 100

                        MaterialIcon {
                            anchors.centerIn: parent
                            text: "add"
                            font.pointSize: Appearance.font.size.extraLarge * 2
                            color: Colours.palette.m3outline
                        }
                    }
                }
            }

            // Recording tab - Input streams
            Loader {
                Layout.fillWidth: true
                visible: root.currentTab === 1
                active: root.currentTab === 1

                sourceComponent: ColumnLayout {
                    id: recordingContent

                    property var inputStreams: root.inputStreams

                    spacing: Appearance.spacing.normal

                    StyledText {
                        text: qsTr("Recording")
                        font.pointSize: Appearance.font.size.larger
                        font.weight: 500
                    }

                    StyledText {
                        Layout.bottomMargin: Appearance.spacing.small
                        text: qsTr("Application input streams")
                        color: Colours.palette.m3outline
                    }

                    Repeater {
                        model: recordingContent.inputStreams

                        StreamItem {
                            required property PwNode modelData

                            Layout.topMargin: index === 0 ? 0 : Appearance.spacing.small
                            stream: modelData
                            isOutput: false
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 100

                        MaterialIcon {
                            anchors.centerIn: parent
                            text: "add"
                            font.pointSize: Appearance.font.size.extraLarge * 2
                            color: Colours.palette.m3outline
                        }
                    }
                }
            }

            // Output Devices tab
            Loader {
                Layout.fillWidth: true
                visible: root.currentTab === 2
                active: root.currentTab === 2

                sourceComponent: ColumnLayout {
                    id: outputDevicesContent

                    property var session: root.session

                    spacing: Appearance.spacing.normal

                    StyledText {
                        text: qsTr("Output Devices")
                        font.pointSize: Appearance.font.size.larger
                        font.weight: 500
                    }

                    StyledText {
                        Layout.bottomMargin: Appearance.spacing.small
                        text: qsTr("Audio output devices")
                        color: Colours.palette.m3outline
                    }

                    Repeater {
                        model: Audio.sinks

                        DeviceItem {
                            required property PwNode modelData

                            Layout.topMargin: index === 0 ? 0 : Appearance.spacing.small
                            device: modelData
                            isActive: Audio.sink?.id === modelData.id
                            isOutput: true
                            showControls: true

                            onClicked: {
                                Audio.setAudioSink(modelData);
                                if (outputDevicesContent.session?.audio) {
                                    outputDevicesContent.session.audio.active = modelData;
                                }
                            }
                        }
                    }
                }
            }

            // Input Devices tab
            Loader {
                Layout.fillWidth: true
                visible: root.currentTab === 3
                active: root.currentTab === 3

                sourceComponent: ColumnLayout {
                    id: inputDevicesContent

                    property var session: root.session

                    spacing: Appearance.spacing.normal

                    StyledText {
                        text: qsTr("Input Devices")
                        font.pointSize: Appearance.font.size.larger
                        font.weight: 500
                    }

                    StyledText {
                        Layout.bottomMargin: Appearance.spacing.small
                        text: qsTr("Audio input devices")
                        color: Colours.palette.m3outline
                    }

                    Repeater {
                        model: Audio.sources

                        DeviceItem {
                            required property PwNode modelData

                            Layout.topMargin: index === 0 ? 0 : Appearance.spacing.small
                            device: modelData
                            isActive: Audio.source?.id === modelData.id
                            isOutput: false
                            showControls: true

                            onClicked: {
                                Audio.setAudioSource(modelData);
                                if (inputDevicesContent.session?.audio) {
                                    inputDevicesContent.session.audio.active = modelData;
                                }
                            }
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
            font.pointSize: Appearance.font.size.normal
            font.weight: button.checked ? 500 : 400
        }
    }

    component StreamItem: StyledRect {
        id: item

        required property PwNode stream
        required property bool isOutput

        Layout.fillWidth: true
        implicitHeight: streamContent.implicitHeight + Appearance.padding.large * 2

        radius: Appearance.rounding.normal
        color: Colours.tPalette.m3surfaceContainer

        RowLayout {
            id: streamContent

            anchors.fill: parent
            anchors.margins: Appearance.padding.large
            spacing: Appearance.spacing.normal

            MaterialIcon {
                text: item.isOutput ? "volume_up" : "mic"
                color: Colours.palette.m3primary
                font.pointSize: Appearance.font.size.large
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Appearance.spacing.smaller

                StyledText {
                    text: item.stream.description || item.stream.name || qsTr("Unknown Stream")
                    color: Colours.palette.m3onSurface
                    font.pointSize: Appearance.font.size.normal
                    font.weight: 500
                    elide: Text.ElideRight
                }

                StyledText {
                    visible: item.stream.name && item.stream.name !== item.stream.description
                    text: item.stream.name
                    color: Colours.palette.m3outline
                    font.pointSize: Appearance.font.size.small
                    elide: Text.ElideRight
                }

                CustomMouseArea {
                    Layout.fillWidth: true
                    implicitHeight: Appearance.padding.normal * 3
                    acceptedButtons: Qt.NoButton

                    onWheel: event => {
                        if (!item.stream?.audio) return;
                        const currentVolume = item.stream.audio.volume;
                        const increment = Config.services.audioIncrement;
                        if (event.angleDelta.y > 0) {
                            item.stream.audio.volume = Math.min(Config.services.maxVolume, currentVolume + increment);
                        } else if (event.angleDelta.y < 0) {
                            item.stream.audio.volume = Math.max(0, currentVolume - increment);
                        }
                    }

                    StyledSlider {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        implicitHeight: parent.implicitHeight

                        value: item.stream?.audio?.volume ?? 0
                        to: Config.services.maxVolume
                        enabled: !!item.stream?.audio
                        onMoved: {
                            if (item.stream?.audio) {
                                item.stream.audio.muted = false;
                                item.stream.audio.volume = value;
                            }
                        }

                        Behavior on value {
                            Anim {}
                        }
                    }
                }

                RowLayout {
                    StyledText {
                        text: item.stream?.audio?.muted ? qsTr("Muted") : `${Math.round((item.stream?.audio?.volume ?? 0) * 100)}%`
                        color: item.stream?.audio?.muted ? Colours.palette.m3outline : Colours.palette.m3onSurfaceVariant
                        font.pointSize: Appearance.font.size.small
                    }

                    IconButton {
                        icon: item.stream?.audio?.muted ? (item.isOutput ? "volume_off" : "mic_off") : (item.isOutput ? "volume_up" : "mic")
                        onClicked: {
                            if (item.stream?.audio) {
                                item.stream.audio.muted = !item.stream.audio.muted;
                            }
                        }
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

        ColumnLayout {
            id: deviceContent

            anchors.fill: parent
            anchors.margins: Appearance.padding.large
            spacing: Appearance.spacing.normal

            RowLayout {
                Layout.fillWidth: true

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

            // Volume controls for devices
            Loader {
                Layout.fillWidth: true
                visible: item.showControls && item.device?.audio
                active: item.showControls && item.device?.audio

                sourceComponent: ColumnLayout {
                    spacing: Appearance.spacing.smaller

                    CustomMouseArea {
                        Layout.fillWidth: true
                        implicitHeight: Appearance.padding.normal * 3
                        acceptedButtons: Qt.NoButton

                        onWheel: event => {
                            if (!item.device?.audio) return;
                            const currentVolume = item.device.audio.volume;
                            const increment = Config.services.audioIncrement;
                            if (event.angleDelta.y > 0) {
                                item.device.audio.volume = Math.min(Config.services.maxVolume, currentVolume + increment);
                            } else if (event.angleDelta.y < 0) {
                                item.device.audio.volume = Math.max(0, currentVolume - increment);
                            }
                        }

                        StyledSlider {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            implicitHeight: parent.implicitHeight

                            value: item.device?.audio?.volume ?? 0
                            to: Config.services.maxVolume
                            enabled: !!item.device?.audio
                            onMoved: {
                                if (item.device?.audio) {
                                    item.device.audio.muted = false;
                                    item.device.audio.volume = value;
                                }
                            }

                            Behavior on value {
                                Anim {}
                            }
                        }
                    }

                    RowLayout {
                        StyledText {
                            text: item.device?.audio?.muted ? qsTr("Muted") : `${Math.round((item.device?.audio?.volume ?? 0) * 100)}%`
                            color: item.device?.audio?.muted ? Colours.palette.m3outline : Colours.palette.m3onSurfaceVariant
                            font.pointSize: Appearance.font.size.small
                        }

                        IconButton {
                            icon: item.device?.audio?.muted ? (item.isOutput ? "volume_off" : "mic_off") : (item.isOutput ? "volume_up" : "mic")
                            onClicked: {
                                if (item.device?.audio) {
                                    item.device.audio.muted = !item.device.audio.muted;
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
