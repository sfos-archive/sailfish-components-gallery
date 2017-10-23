import QtQuick 2.0
import QtMultimedia 5.0
import Sailfish.Media 1.0
import org.nemomobile.policy 1.0

MediaPlayer {
    property bool _minimizedPlaying
    property alias active: permissions.enabled
    property bool playing: playbackState == MediaPlayer.PlayingState
    property bool loaded: status >= MediaPlayer.Loaded && status < MediaPlayer.EndOfMedia
    property bool ready: playbackState == MediaPlayer.StoppedState || playbackState == MediaPlayer.PausedState
    property bool hasError: error == MediaPlayer.NoError
    readonly property bool _applicationActive: Qt.application.active

    signal load

    on_ApplicationActiveChanged: {
        if (!_applicationActive) {
            // if we were playing a video when we minimized, store that information.
            _minimizedPlaying = playing
            if (_minimizedPlaying) {
                pause() // and automatically pause the video
            }
        } else if (_minimizedPlaying && active) {
            play()
        }
    }

    function _play() {
        load()
        play()
    }

    function _togglePlay() {
        if (playing) {
            pause()
        } else {
            load()
            play()
        }
    }

    function _pause() {
        load()
        pause()
    }

    function _stop() {
        stop()
    }

    function reset() {
        stop()
        source = ""
    }

    property Item _content: Item {
        ScreenBlank {
            suspend: playing
        }
        MediaKey { enabled: keysResource.acquired; key: Qt.Key_MediaTogglePlayPause; onPressed: _togglePlay() }
        MediaKey { enabled: keysResource.acquired; key: Qt.Key_MediaPlay; onPressed: _play() }
        MediaKey { enabled: keysResource.acquired; key: Qt.Key_MediaPause; onPressed: _pause() }
        MediaKey { enabled: keysResource.acquired; key: Qt.Key_MediaStop; onPressed: _stop() }
        MediaKey { enabled: keysResource.acquired; key: Qt.Key_ToggleCallHangup; onPressed: _togglePlay() }

        Permissions {
            id: permissions
            applicationClass: "player"
            Resource {
                id: keysResource
                type: Resource.HeadsetButtons
                optional: true
            }
        }
    }
}
