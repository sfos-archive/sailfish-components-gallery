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
import Sailfish.Silica.private 1.0
import Sailfish.Gallery 1.0
import Sailfish.Gallery.private 1.0

/*!
  \inqmlmodule Sailfish.Gallery
*/
ZoomableFlickable {
    id: flickable

    property alias source: photo.source

    property bool active: true
    /*!
      \internal
    */
    readonly property bool _active: active || viewMoving
    readonly property bool error: photo.status == Image.Error
    readonly property alias imageMetaData: metadata

    property alias photo: photo
    property alias largePhoto: largePhoto

    signal clicked

    onAboutToZoom: {
        if (largePhoto.source != photo.source) {
            largePhoto.source = photo.source
        }
    }

    contentRotation: -metadata.orientation
    scrollDecoratorColor: Theme.lightPrimaryColor

    zoomEnabled: photo.status == Image.Ready
    maximumZoom: Math.max(Screen.width, Screen.height) / 200
                 * Math.max(1.0, photo.implicitWidth > 0 ? largePhoto.implicitHeight / photo.implicitHeight
                                                         : 1.0)

    on_ActiveChanged: {
        if (!_active) {
            resetZoom()
            largePhoto.source = ""
        }
    }

    implicitContentWidth: photo.implicitWidth
    implicitContentHeight: photo.implicitHeight

    Image {
        id: photo
        property var errorLabel
        objectName: "zoomableImage"

        anchors.fill: parent
        smooth: !(movingVertically || movingHorizontally)
        sourceSize.width: Screen.height
        fillMode: Image.PreserveAspectFit
        visible: largePhoto.status !== Image.Ready
        asynchronous: true
        cache: false

        onStatusChanged: {
            if (status == Image.Error) {
                errorLabel = errorLabelComponent.createObject(flickable)
            }
        }

        onSourceChanged: {
            if (errorLabel) {
                errorLabel.destroy()
                errorLabel = null
            }

            resetZoom()
        }

        opacity: status == Image.Ready ? 1 : 0
        Behavior on opacity { FadeAnimation{} }
    }

    Image {
        id: largePhoto
        sourceSize {
            width: 3264
            height: 3264
        }
        cache: false
        asynchronous: true
        anchors.fill: parent
    }

    Item {
        width: flickable.transpose ? parent.height : parent.width
        height: flickable.transpose ? parent.width : parent.height

        anchors.centerIn: parent
        rotation: -flickable.contentRotation

        MouseArea {
            x: width > parent.width
                    ? (parent.width - width) / 2
                    : flickable.contentX + Theme.paddingLarge
            y: height > parent.height
                    ? (parent.height - height) / 2
                    : flickable.contentY + Theme.paddingLarge

            width: flickable.width - (2 * Theme.paddingLarge)
            height: flickable.height - (2 * Theme.paddingLarge)

            onClicked: flickable.clicked()
        }
    }

    ImageMetadata {
        id: metadata

        source: photo.source
        autoUpdate: false
    }

    BusyIndicator {
        running: photo.status === Image.Loading && !delayBusyIndicator.running
        size: BusyIndicatorSize.Large
        anchors.centerIn: parent
        parent: flickable
        Timer {
            id: delayBusyIndicator
            running: photo.status === Image.Loading
            interval: 1000
        }
    }

    Component {
        id: errorLabelComponent
        InfoLabel {
            //: Image loading failed
            //% "Couldn't load the image. It could have been deleted or become inaccessible."
            text: qsTrId("components_gallery-la-image-loading-failed-inaccessible")
            anchors.verticalCenter: parent.verticalCenter
            opacity: photo.status == Image.Error ? 1.0 : 0.0
            Behavior on opacity { FadeAnimator {}}
        }
    }
}
