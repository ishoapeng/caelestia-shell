pragma ComponentBehavior: Bound

import ".."
import qs.components
import qs.components.controls
import qs.services
import qs.config
import qs.utils
import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root

    required property Session session

    anchors.fill: parent
    anchors.margins: Appearance.padding.large
    spacing: Appearance.spacing.large

    Component.onCompleted: {
        console.log("[AudioPane] Component loaded");
        console.log("[AudioPane] Audio service available:", !!Audio);
        console.log("[AudioPane] Audio.volume:", Audio?.volume ?? "undefined");
        console.log("[AudioPane] Audio.muted:", Audio?.muted ?? "undefined");
        console.log("[AudioPane] Audio.sink:", Audio?.sink ?? "undefined");
    }

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
        text: qsTr("Volume")
        font.pointSize: Appearance.font.size.larger
        font.weight: 500
    }

    StyledText {
        id: volumeLabel

        Layout.bottomMargin: -Appearance.spacing.small / 2
        text: {
            const vol = Audio?.volume ?? 0;
            const muted = Audio?.muted ?? false;
            const text = qsTr("Volume (%1)").arg(muted ? qsTr("Muted") : `${Math.round(vol * 100)}%`);
            console.log("[AudioPane] Volume label updated - volume:", vol, "muted:", muted);
            return text;
        }
        color: Colours.palette.m3outline
        font.pointSize: Appearance.font.size.normal

        Connections {
            target: Audio
            function onVolumeChanged() {
                console.log("[AudioPane] Audio.volume changed to:", Audio.volume);
            }
            function onMutedChanged() {
                console.log("[AudioPane] Audio.muted changed to:", Audio.muted);
            }
        }
    }

    CustomMouseArea {
        Layout.fillWidth: true
        implicitHeight: Appearance.padding.normal * 3
        acceptedButtons: Qt.NoButton

        Component.onCompleted: {
            console.log("[AudioPane] CustomMouseArea loaded");
        }

        onWheel: event => {
            console.log("[AudioPane] Wheel event, delta:", event.angleDelta.y);
            try {
                if (event.angleDelta.y > 0) {
                    console.log("[AudioPane] Incrementing volume");
                    Audio.incrementVolume();
                } else if (event.angleDelta.y < 0) {
                    console.log("[AudioPane] Decrementing volume");
                    Audio.decrementVolume();
                }
            } catch (e) {
                console.error("[AudioPane] Error in wheel handler:", e);
            }
        }

        StyledSlider {
            id: volumeSlider

            anchors.left: parent.left
            anchors.right: parent.right
            implicitHeight: parent.implicitHeight

            Component.onCompleted: {
                console.log("[AudioPane] StyledSlider loaded");
                console.log("[AudioPane] Initial slider value:", Audio?.volume ?? "undefined");
            }

            value: {
                const vol = Audio?.volume ?? 0;
                console.log("[AudioPane] Slider value binding - volume:", vol);
                return vol;
            }

            onMoved: {
                console.log("[AudioPane] Slider moved to:", value);
                try {
                    Audio.setVolume(value);
                    console.log("[AudioPane] Volume set successfully");
                } catch (e) {
                    console.error("[AudioPane] Error setting volume:", e);
                }
            }

            Behavior on value {
                Anim {}
            }
        }
    }

    RowLayout {
        Layout.alignment: Qt.AlignHCenter
        Layout.topMargin: Appearance.spacing.normal
        spacing: Appearance.spacing.normal

        IconTextButton {
            id: muteButton

            Component.onCompleted: {
                console.log("[AudioPane] Mute button loaded");
                console.log("[AudioPane] Audio.sink:", Audio?.sink ?? "undefined");
                console.log("[AudioPane] Audio.sink?.audio:", Audio?.sink?.audio ?? "undefined");
            }

            icon: {
                const muted = Audio?.muted ?? false;
                const vol = Audio?.volume ?? 0;
                const icon = muted ? "volume_off" : Icons.getVolumeIcon(vol, muted);
                console.log("[AudioPane] Mute button icon updated - muted:", muted, "icon:", icon);
                return icon;
            }

            text: {
                const muted = Audio?.muted ?? false;
                return muted ? qsTr("Unmute") : qsTr("Mute");
            }

            onClicked: {
                console.log("[AudioPane] Mute button clicked");
                try {
                    console.log("[AudioPane] Current mute state:", Audio?.muted ?? "undefined");
                    console.log("[AudioPane] Audio.sink exists:", !!Audio?.sink);
                    console.log("[AudioPane] Audio.sink.audio exists:", !!Audio?.sink?.audio);
                    
                    if (Audio?.sink?.audio) {
                        const newMuted = !Audio.sink.audio.muted;
                        console.log("[AudioPane] Setting muted to:", newMuted);
                        Audio.sink.audio.muted = newMuted;
                        console.log("[AudioPane] Muted state updated successfully");
                    } else {
                        console.warn("[AudioPane] Cannot toggle mute - Audio.sink.audio is null");
                    }
                } catch (e) {
                    console.error("[AudioPane] Error in mute button click:", e);
                }
            }
        }
    }
}
