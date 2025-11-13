pragma ComponentBehavior: Bound

import ".."
import qs.components
import qs.components.controls
import qs.services
import qs.config
import qs.utils
import Quickshell.Services.Pipewire
import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root

    required property Session session

    spacing: Appearance.spacing.normal

    MaterialIcon {
        Layout.alignment: Qt.AlignHCenter
        text: "tune"
        font.pointSize: Appearance.font.size.extraLarge * 3
        font.bold: true
        color: Colours.palette.m3primary
    }

    StyledText {
        Layout.alignment: Qt.AlignHCenter
        text: qsTr("Audio Settings")
        font.pointSize: Appearance.font.size.large
        font.bold: true
    }

    StyledText {
        Layout.topMargin: Appearance.spacing.large
        text: qsTr("Output Volume")
        font.pointSize: Appearance.font.size.larger
        font.weight: 500
    }

    StyledText {
        text: qsTr("Adjust the default output device volume")
        color: Colours.palette.m3outline
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
                    text: Icons.getVolumeIcon(Audio.volume, Audio.muted)
                    color: Audio.muted ? Colours.palette.m3outline : Colours.palette.m3primary
                    font.pointSize: Appearance.font.size.large
                }

                StyledText {
                    Layout.fillWidth: true
                    text: Audio.muted ? qsTr("Muted") : `${Math.round(Audio.volume * 100)}%`
                    color: Audio.muted ? Colours.palette.m3outline : Colours.palette.m3onSurface
                    font.pointSize: Appearance.font.size.normal
                }

                IconButton {
                    icon: Audio.muted ? "volume_off" : "volume_up"
                    onClicked: {
                        if (Audio.sink?.audio) {
                            Audio.sink.audio.muted = !Audio.sink.audio.muted;
                        }
                    }
                }
            }

            CustomMouseArea {
                Layout.fillWidth: true
                implicitHeight: Appearance.padding.normal * 3

                onWheel: event => {
                    if (event.angleDelta.y > 0)
                        Audio.incrementVolume();
                    else if (event.angleDelta.y < 0)
                        Audio.decrementVolume();
                }

                StyledSlider {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    implicitHeight: parent.implicitHeight

                    value: Audio.volume
                    to: Config.services.maxVolume
                    onMoved: Audio.setVolume(value)

                    Behavior on value {
                        Anim {}
                    }
                }
            }
        }
    }

    StyledText {
        Layout.topMargin: Appearance.spacing.large
        text: qsTr("Input Volume")
        font.pointSize: Appearance.font.size.larger
        font.weight: 500
    }

    StyledText {
        text: qsTr("Adjust the default input device volume")
        color: Colours.palette.m3outline
    }

    StyledRect {
        Layout.fillWidth: true
        Layout.topMargin: Appearance.spacing.small
        implicitHeight: sourceVolumeControl.implicitHeight + Appearance.padding.large * 2

        radius: Appearance.rounding.normal
        color: Colours.tPalette.m3surfaceContainer

        ColumnLayout {
            id: sourceVolumeControl

            anchors.fill: parent
            anchors.margins: Appearance.padding.large
            spacing: Appearance.spacing.normal

            RowLayout {
                MaterialIcon {
                    text: Audio.sourceMuted ? "mic_off" : "mic"
                    color: Audio.sourceMuted ? Colours.palette.m3outline : Colours.palette.m3primary
                    font.pointSize: Appearance.font.size.large
                }

                StyledText {
                    Layout.fillWidth: true
                    text: Audio.sourceMuted ? qsTr("Muted") : `${Math.round(Audio.sourceVolume * 100)}%`
                    color: Audio.sourceMuted ? Colours.palette.m3outline : Colours.palette.m3onSurface
                    font.pointSize: Appearance.font.size.normal
                }

                IconButton {
                    icon: Audio.sourceMuted ? "mic_off" : "mic"
                    onClicked: {
                        if (Audio.source?.audio) {
                            Audio.source.audio.muted = !Audio.source.audio.muted;
                        }
                    }
                }
            }

            CustomMouseArea {
                Layout.fillWidth: true
                implicitHeight: Appearance.padding.normal * 3

                onWheel: event => {
                    if (event.angleDelta.y > 0)
                        Audio.incrementSourceVolume();
                    else if (event.angleDelta.y < 0)
                        Audio.decrementSourceVolume();
                }

                StyledSlider {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    implicitHeight: parent.implicitHeight

                    value: Audio.sourceVolume
                    to: Config.services.maxVolume
                    onMoved: Audio.setSourceVolume(value)

                    Behavior on value {
                        Anim {}
                    }
                }
            }
        }
    }
}

