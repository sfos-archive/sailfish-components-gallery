/****************************************************************************************
** Copyright (c) 2017 - 2023 Jolla Ltd.
**
** All rights reserved.
**
** This file is part of Sailfish Gallery components package.
**
** You may use this file under the terms of BSD license as follows:
**
** Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions are met:
**
** 1. Redistributions of source code must retain the above copyright notice, this
**    list of conditions and the following disclaimer.
**
** 2. Redistributions in binary form must reproduce the above copyright notice,
**    this list of conditions and the following disclaimer in the documentation
**    and/or other materials provided with the distribution.
**
** 3. Neither the name of the copyright holder nor the names of its
**    contributors may be used to endorse or promote products derived from
**    this software without specific prior written permission.
**
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
** AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
** IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
** DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
** FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
** DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
** SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
** CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
** OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
** OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**
****************************************************************************************/

import QtQuick 2.0
import QtMultimedia 5.0
import Sailfish.Media 1.0
import Nemo.Policy 1.0
import Nemo.KeepAlive 1.2
import Nemo.Notifications 1.0

/*!
  \inqmlmodule Sailfish.Gallery
*/
MediaPlayer {
    id: root

    property bool busy

    onLoadedChanged: if (loaded) playerLoader.anchors.centerIn = currentItem
    /*!
      \internal
    */
    property bool _minimizedPlaying
    property alias active: permissions.enabled
    readonly property bool playing: playbackState == MediaPlayer.PlayingState
    readonly property bool loaded: status >= MediaPlayer.Loaded && status <= MediaPlayer.EndOfMedia
    readonly property bool hasError: error !== MediaPlayer.NoError
    /*!
      \internal
    */
    property bool _reseting

    signal displayError

    onPositionChanged: {
        // JB#50154: Work-around, force load frame preview when seeking the end
        if (status === MediaPlayer.EndOfMedia) {
            asyncPause.restart()
        }
        busy = false
    }

    property var asyncPause: Timer {
        interval: 16
        onTriggered: pause()
    }

    onHasErrorChanged: {
        if (error === MediaPlayer.FormatError) {
            //: %1 is replaced with specific codec
            //% "Unsupported codec: %1"
            _errorNotification.body = qsTrId("components_gallery-la-unsupported-codec").arg(errorString)
            _errorNotification.publish()
        }
    }
    onStatusChanged: {
        busy = false
        if (status === MediaPlayer.InvalidMedia) {
            displayError()
        }
    }

    autoLoad: false

    function togglePlay() {
        if (playing) {
            pause()
        } else {
            play()
        }
    }

    function reset() {
        stop()
        _reseting = true
        _reseting = false
    }

    /*!
      \internal
    */
    property QtObject _errorNotification: Notification {
        isTransient: true
        urgency: Notification.Critical
        icon: "icon-system-warning"
    }

    /*!
      \internal
    */
    property Item _content: Item {
        Binding {
            target: root
            when: _reseting
            property: "source"
            value: ""
        }
        Connections {
            target: Qt.application
            onActiveChanged: {
                if (!Qt.application.active) {
                    // if we were playing a video when we minimized, store that information.
                    _minimizedPlaying = playing
                    if (_minimizedPlaying) {
                        pause() // and automatically pause the video
                    }
                } else if (_minimizedPlaying) {
                    play()
                }
            }
        }

        DisplayBlanking {
            preventBlanking: playing
        }
        MediaKey { enabled: keysResource.acquired; key: Qt.Key_MediaTogglePlayPause; onPressed: togglePlay() }
        MediaKey { enabled: keysResource.acquired; key: Qt.Key_MediaPlay; onPressed: play() }
        MediaKey { enabled: keysResource.acquired; key: Qt.Key_MediaPause; onPressed: pause() }
        MediaKey { enabled: keysResource.acquired; key: Qt.Key_MediaStop; onPressed: stop() }
        MediaKey { enabled: keysResource.acquired; key: Qt.Key_ToggleCallHangup; onPressed: togglePlay() }

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
