import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.thumbnailer 1.0

MouseArea {
    id: root

    signal load

    property QtObject player
    property bool active
    property url source
    property string mimeType

    property real contentWidth: width
    property real contentHeight: height

    property bool overlayMode
    property bool transpose
    property bool down: pressed && containsMouse
    property alias showBusyIndicator: busyIndicator.running

    readonly property bool playing: active && player && player.playing
    readonly property bool loaded: active && player && player.loaded

    implicitWidth: poster.implicitWidth
    implicitHeight: poster.implicitHeight

    // Poster
    Thumbnail {
        id: poster

        anchors.centerIn: parent

        width: !transpose ? root.contentWidth : root.contentHeight
        height: !transpose ? root.contentHeight : root.contentWidth

        sourceSize.width: Screen.height
        sourceSize.height: Screen.height

        source: root.source
        mimeType: root.mimeType

        priority: Thumbnail.HighPriority
        fillMode: Thumbnail.PreserveAspectFit
        opacity: !loaded ? 1.0 : 0.0
        Behavior on opacity { FadeAnimator {} }

        visible: !loaded
        rotation: transpose ? (implicitHeight > implicitWidth ? 270 : 90)  : 0
    }

    BusyIndicator {
        id: busyIndicator
        anchors.centerIn: parent
        size: BusyIndicatorSize.Large
    }

    Image {
        id: icon
        anchors.centerIn: parent
        opacity: !busyIndicator.running && (overlayMode || !playing) ? 1.0 : 0.0
        Behavior on opacity { FadeAnimator {} }

        Binding	{
            target: icon
            when: overlayMode // avoid flicker to pause icon when pressing play
            property: "source"
            value: "image://theme/icon-"
                   + (playing ?  "l-pause" : "video-overlay-play")
                   + "?" + (mouseArea.down ? Theme.highlightColor : Theme.primaryColor)
        }
        MouseArea {
            id: mouseArea

            property bool down: pressed && containsMouse
            anchors.fill: parent
            onClicked: {
                root.load()
                if (player.playing) {
                    player.pause()
                } else if (player.ready) {
                    player.play()
                }
            }
        }
    }
}
