/****************************************************************************************
** Copyright (c) 2013 - 2023 Jolla Ltd.
**
** All rights reserved.
**
** This file is part of Sailfish Transfer Engine component package.
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
import Sailfish.Silica 1.0
import Nemo.Thumbnailer 1.0

/*!
  \inqmlmodule Sailfish.Gallery
*/
Item {
    id: root

    signal togglePlay

    property url source
    property string mimeType

    property bool playing
    property bool loaded
    property alias busy: busyIndicator.running
    property alias status: poster.status

    property real contentWidth: width
    property real contentHeight: height

    property bool overlayMode
    property bool transpose
    readonly property bool error: !!poster.errorLabel
    readonly property bool down: videoMouse.pressed && videoMouse.containsMouse

    signal clicked
    signal doubleClicked

    function displayError() {
        poster.errorLabel = errorLabelComponent.createObject(poster)
    }

    implicitWidth: poster.implicitWidth
    implicitHeight: poster.implicitHeight

    onSourceChanged: {
        if (poster.errorLabel) {
            poster.errorLabel.destroy()
            poster.errorLabel = null
        }
    }

    MouseArea {
        id: videoMouse
        anchors {
            fill: parent
            margins: Theme.paddingLarge // don't react near display edges
        }
        onClicked: clickDelay.restart()
        onDoubleClicked: {
            clickDelay.stop()
            root.doubleClicked()
        }
        Timer {
            id: clickDelay
            interval: 200
            onTriggered: root.clicked()
        }
    }

    // Poster
    Thumbnail {
        id: poster

        property var errorLabel

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
        enabled: !busy && (overlayMode || !playing) && !root.error
        opacity: enabled ? 1.0 : 0.0
        Behavior on opacity { FadeAnimator {} }

        Binding	{
            target: icon
            when: overlayMode || !playing // avoid flicker to pause icon when pressing play
            property: "source"
            value: "image://theme/icon-video-overlay-" + (playing ?  "pause" : "play")
                   + "?" + (iconMouse.down ? Theme.highlightColor : Theme.lightPrimaryColor)
        }
        MouseArea {
            id: iconMouse

            property bool down: pressed && containsMouse
            anchors.fill: parent
            onClicked: togglePlay()
        }
    }
    Component {
        id: errorLabelComponent
        Rectangle {
            anchors.fill: parent
            color: Theme.rgba(Theme.overlayBackgroundColor, Theme.highlightBackgroundOpacity)

            opacity: 0
            FadeAnimator on opacity { from: 0; to: 1 }
            InfoLabel {
                //% "Oops, can't load the video"
                text: qsTrId("components_gallery-la-video-loading-failed")
                anchors.verticalCenter: parent.verticalCenter

            }
        }
    }

}
