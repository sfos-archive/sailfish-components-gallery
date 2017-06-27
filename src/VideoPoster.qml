import QtQuick 2.0
import Sailfish.Silica 1.0
import QtMultimedia 5.0
import org.nemomobile.thumbnailer 1.0

MouseArea {
    id: videoItem

    property QtObject player
    property bool active
    property url source
    property string mimeType
    property int duration

    property real contentWidth: width
    property real contentHeight: height

    property bool overlayMode
    property bool transpose
    property bool down: pressed && containsMouse

    property bool playing: active && player && player.playbackState == MediaPlayer.PlayingState
    readonly property bool loaded: active && player && player.status >= MediaPlayer.Loaded
                                   && player.status < MediaPlayer.EndOfMedia

    implicitWidth: poster.implicitWidth
    implicitHeight: poster.implicitHeight

    // Poster
    Thumbnail {
        id: poster

        anchors.centerIn: parent

        width: !transpose ? videoItem.contentWidth : videoItem.contentHeight
        height: !transpose ? videoItem.contentHeight : videoItem.contentWidth

        sourceSize.width: Screen.height
        sourceSize.height: Screen.height

        source: videoItem.source
        mimeType: videoItem.mimeType

        priority: Thumbnail.HighPriority
        fillMode: Thumbnail.PreserveAspectFit
        opacity: !loaded ? 1.0 : 0.0
        Behavior on opacity { FadeAnimator {} }

        visible: !loaded || posterFade.running
        rotation: transpose ? (implicitHeight > implicitWidth ? 270 : 90)  : 0
    }

    Image {
        id: icon
        anchors.centerIn: parent
        opacity: overlayMode || !playing ? 1.0 : 0.0
        Behavior on opacity { FadeAnimator {} }

        Binding	{
            target:	icon
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
                if (player.playbackState == MediaPlayer.PlayingState) {
                    // pause and go splitscreen
                    view._pause()
                } else if ((player.playbackState == MediaPlayer.StoppedState
                            || player.playbackState == MediaPlayer.PausedState)) {
                    // start playback and go fullscreen
                    view._play()
                }
            }
        }
    }
}
