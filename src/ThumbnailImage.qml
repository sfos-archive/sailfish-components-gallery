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
ThumbnailBase {
    id: thumbnailBase

    readonly property alias status: thumbnail.status
    /*!
      \internal
    */
    property alias _thumbnail: thumbnail

    Image {
        anchors.fill: parent
        source: thumbnail.status === Thumbnail.Ready ? ""
                                                     : "image://theme/graphic-grid-item-background"
    }

    Thumbnail {
        id: thumbnail
        property bool gridMoving: thumbnailBase.grid ? thumbnailBase.grid.moving : false

        source: thumbnailBase.source
        mimeType: thumbnailBase.mimeType
        width: thumbnailBase.width
        height: thumbnailBase.contentHeight
        sourceSize.width: width
        sourceSize.height: height
        priority: Thumbnail.NormalPriority

        onGridMovingChanged: {
            if (!gridMoving) {
                var visibleIndex = Math.floor(thumbnailBase.grid.contentY / thumbnailBase.contentHeight) * thumbnailBase.grid.columnCount

                if (visibleIndex <= index && index <= visibleIndex + 18) {
                    priority = Thumbnail.HighPriority
                } else {
                    priority = Thumbnail.LowPriority
                }
            }
        }

        onStatusChanged: {
            if (status == Thumbnail.Error) {
                errorLabelComponent.createObject(thumbnail)
            }
        }
    }

    Component {
        id: errorLabelComponent
        Label {
            //: Thumbnail Image loading failed
            //% "Oops, can't display the thumbnail!"
            text: qsTrId("components_gallery-la-image-thumbnail-loading-failed")
            anchors.centerIn: parent
            width: parent.width - 2 * Theme.paddingMedium
            height: parent.height - 2 * Theme.paddingSmall
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: Theme.fontSizeSmall
            fontSizeMode: Text.Fit
            opacity: thumbnail.status == Thumbnail.Error ? 1.0 : 0.0
            Behavior on opacity { FadeAnimator {}}
        }
    }
}
