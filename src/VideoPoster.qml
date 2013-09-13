import QtQuick 2.0
import Sailfish.Silica 1.0
import QtMultimedia 5.0
import org.nemomobile.thumbnailer 1.0

MouseArea {
    id: videoItem

    property MediaPlayer player
    property bool active
    property url source
    property string mimeType
    property int duration
    onDurationChanged: positionSlider.maximumValue = duration

    property bool playing: active && videoItem.player && videoItem.player.playbackState == MediaPlayer.PlayingState
    readonly property bool _loaded: active
                && videoItem.player
                && videoItem.player.status >= MediaPlayer.Loaded
                && videoItem.player.status < MediaPlayer.EndOfMedia

    Connections {
        target: videoItem._loaded ? videoItem.player : null

        onPositionChanged: positionSlider.value = videoItem.player.position / 1000
        onDurationChanged: positionSlider.maximumValue = videoItem.player.duration / 1000
    }

    onActiveChanged: {
        if (!active) {
            positionSlider.value = 0
        }
    }

    // Poster
    Thumbnail {
        id: poster

        anchors.centerIn: parent

        width: videoItem.width

        sourceSize.width: Screen.height
        sourceSize.height: Screen.height

        source: videoItem.source
        mimeType: videoItem.mimeType

        priority: Thumbnail.HighPriority
        fillMode: Thumbnail.PreserveAspectFit
        opacity: !videoItem._loaded ? 1.0 : 0.0
        Behavior on opacity { FadeAnimation { id: posterFade } }

        visible: !videoItem._loaded || posterFade.running
    }

    Item {
        width: videoItem.width
        height: videoItem.height

        opacity: videoItem.playing ? 0.0 : 1.0
        Behavior on opacity { FadeAnimation { id: controlFade } }

        visible: videoItem.player && (!videoItem.playing || controlFade.running)

        Image {
            anchors.centerIn: parent
            source: "image://theme/icon-cover-play"

            MouseArea {
                anchors.fill: parent
                enabled: !videoItem.playing
                onClicked: {
                    videoItem.player.source = videoItem.source
                    videoItem.player.play()
                }
            }
        }

        Slider {
            id: positionSlider

            anchors { left: parent.left; right: parent.right; bottom: parent.bottom }

            enabled: !videoItem.playing
            height: Theme.itemSizeSmall
            handleVisible: false
            minimumValue: 0
            valueText: Format.formatDuration(value, Formatter.DurationShort)

            onReleased: {
                if (videoItem.active) {
                    videoItem.player.source = videoItem.source
                    videoItem.player.seek(value * 1000)
                    videoItem.player.pause()
                }
            }
        }
    }
}
