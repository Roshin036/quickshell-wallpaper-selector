
import QtQuick
//import QtQuick.Controls
import Qt.labs.folderlistmodel
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

import Qt5Compat.GraphicalEffects

PanelWindow {
    id: popupWindow
    visible: true
    color: "transparent"

    // Enable keyboard focus for this overlay window on Wayland
    focusable: true
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    Component.onCompleted: pathView.forceActiveFocus()

    // Click outside to close
    /*
    MouseArea {
        anchors.fill: parent
        onClicked: quitProc.running = true
    }
    */

    Item {
        width: 700
        height: 400
        anchors.centerIn: parent

        MouseArea {
            anchors.fill: parent
            onClicked: (mouse) => mouse.accepted = true
            onDoubleClicked: (mouse) => mouse.accepted = true
        }

        Column {
            anchors.fill: parent
            spacing: 20

            PathView {
                id: pathView
                width: parent.width
                height: 300
                model: wallpaperModel
                pathItemCount: 3
                preferredHighlightBegin: 0.5
                preferredHighlightEnd: 0.5
                focus: true

                // Native arrow keys & Enter key handling
                Keys.onLeftPressed: decrementCurrentIndex()
                Keys.onRightPressed: incrementCurrentIndex()

                Keys.onReturnPressed: {
                    var cleanPath = wallpaperModel.get(
                        pathView.currentIndex,
                        "fileUrl"
                    ).toString().replace("file://", "");

                    wallpaperProc.command = [
                        "plasma-apply-wallpaperimage",
                        cleanPath
                    ];
                    wallpaperProc.running = true;
                    quitProc.running = true;
                }

                // Touchpad scroll with dampening
                /*
                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.NoButton
                    property real scrollAccumulator: 0

                    onWheel: (wheel) => {
                        scrollAccumulator += wheel.angleDelta.y !== 0
                            ? wheel.angleDelta.y
                            : wheel.angleDelta.x;

                        if (scrollAccumulator > 80) {
                            pathView.decrementCurrentIndex();
                            scrollAccumulator = 0;
                        } else if (scrollAccumulator < -80) {
                            pathView.incrementCurrentIndex();
                            scrollAccumulator = 0;
                        }
                    }
                }
                */

                path: Path {
                    startX: 50
                    startY: 150

                    PathLine {
                        x: 350
                        y: 150
                    }

                    PathLine {
                        x: 650
                        y: 150
                    }
                }

                delegate: Item {
                    width: 280
                    height: 180

                    scale: PathView.isCurrentItem ? 1.15 : 0.85
                    opacity: PathView.isCurrentItem ? 1.0 : 0.9
                    z: PathView.isCurrentItem ? 3 : 1

                    Behavior on scale {
                        NumberAnimation {
                            duration: 200
                        }
                    }

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 200
                        }
                    }

                    Rectangle {
                        id: imageClip
                        anchors.fill: parent
                        anchors.margins: 3
                        radius: 12
                        color: "#ffffff"
                        border.color: pathView.currentIndex === index ? "#cda7f4" : "transparent"
                        border.width: 3
                        

                        Image {
                            id: wallpaperImage
                            anchors.fill: parent
                            anchors.margins: 3
                            source: fileUrl
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            visible: false
                        }

                        Rectangle {
                            id: roundedMask
                            anchors.fill: wallpaperImage
                            radius: 9
                            visible: false
                            layer.enabled: true
                        }

                        OpacityMask {
                            anchors.fill: wallpaperImage
                            source: wallpaperImage
                            maskSource: roundedMask
                        }

                        MouseArea {
                            anchors.fill: parent

                            onClicked: {
                                pathView.currentIndex = index;
                            }

                            onDoubleClicked: {
                                var cleanPath = wallpaperModel.get(
                                    index,
                                    "fileUrl"
                                ).toString().replace("file://", "");

                                wallpaperProc.command = [
                                    "plasma-apply-wallpaperimage",
                                    cleanPath
                                ];
                                wallpaperProc.running = true;
                                quitProc.running = true;
                            }
                        }
                    }
                }
            }
        }
    }

    FolderListModel {
        id: wallpaperModel
        folder: "file://" + Quickshell.env("HOME") + "/Pictures/Wallpapers"
        nameFilters: ["*.png", "*.jpg", "*.jpeg", "*.webp"]
        showDirs: false
    }

    Process {
        id: wallpaperProc
    }

    Process {
        id: quitProc
        command: ["pkill", "-x", "quickshell"]
    }
}
