pragma ComponentBehavior: Bound

import ".."
import qs.components
import qs.components.controls
import qs.components.containers
import qs.components.effects
import qs.services
import qs.config
import qs.utils
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts

RowLayout {
    id: root

    required property Session session

    anchors.fill: parent
    spacing: 0

    // Get all streams (applications)
    readonly property var outputStreams: Pipewire.nodes.values.filter(n => n.isStream && n.isSink)
    readonly property var inputStreams: Pipewire.nodes.values.filter(n => n.isStream && !n.isSink && n.audio)

    // Track streams for real-time updates
    PwObjectTracker {
        objects: [...root.outputStreams, ...root.inputStreams]
    }

    // Left side - Audio list
    Item {
        Layout.preferredWidth: Math.floor(parent.width * 0.4)
        Layout.minimumWidth: 420
        Layout.fillHeight: true

        AudioList {
            anchors.fill: parent
            anchors.margins: Appearance.padding.large + Appearance.padding.normal
            anchors.leftMargin: Appearance.padding.large
            anchors.rightMargin: Appearance.padding.large + Appearance.padding.normal / 2

            session: root.session
            outputStreams: root.outputStreams
            inputStreams: root.inputStreams
        }

        InnerBorder {
            leftThickness: 0
            rightThickness: Appearance.padding.normal / 2
        }
    }

    // Right side - Details or Settings
    Item {
        Layout.fillWidth: true
        Layout.fillHeight: true

        ClippingRectangle {
            anchors.fill: parent
            anchors.margins: Appearance.padding.normal
            anchors.leftMargin: 0
            anchors.rightMargin: Appearance.padding.normal / 2

            radius: rightBorder.innerRadius
            color: "transparent"

            Loader {
                id: loader

                property PwNode pane: root.session.audio?.active

                anchors.fill: parent
                anchors.margins: Appearance.padding.large * 2

                asynchronous: true
                sourceComponent: pane ? details : settings

                Behavior on pane {
                    SequentialAnimation {
                        ParallelAnimation {
                            Anim {
                                property: "opacity"
                                to: 0
                                easing.bezierCurve: Appearance.anim.curves.standardAccel
                            }
                            Anim {
                                property: "scale"
                                to: 0.8
                                easing.bezierCurve: Appearance.anim.curves.standardAccel
                            }
                        }
                        PropertyAction {}
                        ParallelAnimation {
                            Anim {
                                property: "opacity"
                                to: 1
                                easing.bezierCurve: Appearance.anim.curves.standardDecel
                            }
                            Anim {
                                property: "scale"
                                to: 1
                                easing.bezierCurve: Appearance.anim.curves.standardDecel
                            }
                        }
                    }
                }
            }
        }

        InnerBorder {
            id: rightBorder

            leftThickness: Appearance.padding.normal / 2
        }

        Component {
            id: settings

            StyledFlickable {
                flickableDirection: Flickable.VerticalFlick
                contentHeight: settingsInner.height

                Settings {
                    id: settingsInner

                    anchors.left: parent.left
                    anchors.right: parent.right
                    session: root.session
                }
            }
        }

        Component {
            id: details

            StyledFlickable {
                flickableDirection: Flickable.VerticalFlick
                contentHeight: detailsInner.height

                Details {
                    id: detailsInner

                    anchors.left: parent.left
                    anchors.right: parent.right
                    session: root.session
                }
            }
        }
    }

    component Anim: NumberAnimation {
        target: loader
        duration: Appearance.anim.durations.normal / 2
        easing.type: Easing.BezierSpline
    }
}
