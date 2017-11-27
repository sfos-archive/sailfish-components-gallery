import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Gallery 1.0
import Sailfish.Ambience 1.0

Item {
    id: overlay

    property QtObject player
    property bool active: true
    property bool viewerOnlyMode

    property alias additionalActions: additionalActionsLoader.sourceComponent
    property alias detailsButton: detailsButton
    property alias localFile: fileInfo.localFile
    property alias editingAllowed: editButton.visible
    property alias deletingAllowed: deleteButton.visible
    property alias sharingAllowed: shareButton.visible
    readonly property bool allowed: isImage || localFile
    readonly property bool playing: player && player.playing
    property alias topFade: topFade
    property real fadeOpacity: 0.6

    property url source
    property string itemId
    property bool isImage
    property bool error
    property int duration: 1
    readonly property int _duration: {
        if (player && player.loaded) {
            return player.duration / 1000
        } else {
            return duration
        }
    }

    signal createPlayer
    signal remove

    enabled: active && allowed && source != ""
    Behavior on opacity { FadeAnimator {}}
    opacity: enabled ? 1.0 : 0.0

    Rectangle {
        id: topFade

        width: parent.width
        height: detailsButton.height + 2 * detailsButton.y
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.rgba(0, 0, 0, fadeOpacity ) }
            GradientStop { position: 0.2; color: Qt.rgba(0, 0, 0, fadeOpacity ) }
            GradientStop { position: 1.0; color: "transparent" }
        }
    }

    Rectangle {
        id: bottomFade
        width: parent.width
        height: bottomButtonRow.height + 2* bottomButtonRow.anchors.bottomMargin
        anchors.bottom: parent.bottom
        gradient: Gradient {
            GradientStop { position: 0.0; color: "transparent" }
            GradientStop { position: 0.8; color: Qt.rgba(0, 0, 0, fadeOpacity) }
            GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, fadeOpacity) }
        }
    }

    IconButton {
        id: detailsButton
        x: Theme.horizontalPageMargin
        y: Theme.paddingLarge
        icon.source: "image://theme/icon-m-about"
        visible: localFile && !viewerOnlyMode && itemId.length > 0
        onClicked: if (itemId.length > 0) pageStack.push("DetailsPage.qml", { modelItem: overlay.itemId } )
    }

    Timer {
        interval: 4000
        running: overlay.active && playing
        onTriggered: {
            if (positionSlider.pressed) {
                restart()
            } else {
                overlay.active = false
            }
        }
    }

    Slider {
        id: positionSlider

        visible: !isImage
        opacity: overlay.error ? 0.0 : 1.0
        anchors { left: parent.left; right: bottomButtonRow.left; bottom: parent.bottom }
        rightMargin: Theme.paddingLarge

        height: Math.max(implicitHeight, bottomButtonRow.height + bottomButtonRow.anchors.bottomMargin * 2 + _valueLabel.height/2)
        handleVisible: false
        minimumValue: 0
        maximumValue: overlay._duration > 0 ? overlay._duration : 1

        valueText: Format.formatDuration(value, value >= 3600
                                         ? Format.DurationLong
                                         : Format.DurationShort)

        onReleased: {
            var position = value * 1000
            if (!player) createPlayer()
            if (!player.loaded) {
                player.pause() // force load
            }
            player.seek(position)
        }

        Connections {
            target: player
            onPositionChanged: {
                if (!positionSlider.pressed) {
                    positionSlider.value = player.position / 1000
                }
            }
        }
        Connections {
            target: player
            onSourceChanged: positionSlider.value = 0
        }
    }

    Row {
        id: bottomButtonRow

        x: isImage ? parent.width/2 - width/2 : parent.width - width - Theme.horizontalPageMargin
        anchors  {
            bottom: parent.bottom
            bottomMargin: Theme.paddingLarge
        }
        spacing: Theme.paddingLarge

        Loader {
            id: additionalActionsLoader
            anchors.verticalCenter: parent.verticalCenter
        }

        IconButton {
            id: deleteButton
            icon.source: "image://theme/icon-m-delete"
            visible: localFile
            anchors.verticalCenter: parent.verticalCenter
            onClicked: overlay.remove()
        }

        IconButton {
            id: editButton
            icon.source: "image://theme/icon-m-edit"
            visible: fileInfo.editableImage && isImage && !viewerOnlyMode
            anchors.verticalCenter: parent.verticalCenter

            onClicked: pageStack.push("Sailfish.Gallery.ImageEditPage", { source: overlay.source })
        }

        IconButton {
            id: shareButton
            icon.source: "image://theme/icon-m-share"
            anchors.verticalCenter: parent.verticalCenter
            onClicked: pageStack.push("GallerySharePage.qml", {
                                          "endDestination": root,
                                          "source": overlay.source,
                                          "mimeType": localFile ? fileInfo.mimeType : "text/x-url",
                                          "content":  localFile ? undefined : { "type": "text/x-url", "status": overlay.source }
                                      })
        }

        IconButton {
            icon.source: "image://theme/icon-m-ambience"
            anchors.verticalCenter: parent.verticalCenter
            visible: isImage
            onClicked: {
                var previousAmbienceUrl = Ambience.source
                Ambience.setAmbience(overlay.source, function(ambienceId) {
                    pageStack.push(ambienceSettingsPage, {
                                       'contentId': ambienceId,
                                       'previousAmbienceUrl': previousAmbienceUrl
                                   })
                })
            }
            Component { id: ambienceSettingsPage; AmbienceSettingsPage {}}
        }
    }

    FileInfo {
        id: fileInfo
        source: overlay.source
    }
}
