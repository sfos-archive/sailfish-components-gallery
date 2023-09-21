/****************************************************************************************
** Copyright (c) 2018 - 2023 Jolla Ltd.
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

Rectangle {
    z: 10
    width: parent.width
    height: column.height + column.y + Theme.paddingMedium
    color: Theme.rgba(Theme.highlightBackgroundColor, Theme.highlightBackgroundOpacity)

    property Flickable flickable
    Component.onCompleted: {
        if (!flickable) {
            var parentItem = parent
            while (parentItem) {
                if (parentItem.maximumFlickVelocity) {
                    flickable = parentItem
                    parent = flickable
                    break
                }
                parentItem = parentItem.parent
            }
        }
    }

    Column {
        id: column
        y: Theme.paddingMedium
        x: Theme.paddingLarge
        width: parent.width - 2 * x

        DebugLabel {
            text: "Margins t " +  flickable.topMargin + " b " + flickable.bottomMargin + " l " + flickable.leftMargin + " r " + flickable.rightMargin
        }
        DebugLabel {
            text: "Content w " +  flickable.contentWidth + " h " + flickable.contentHeight + " x " + flickable.contentX + " y " + flickable.contentY
        }
        DebugLabel {
            text: "Item iw " + flickable.implicitContentWidth + " ih " + flickable.implicitContentWidth + " interactive " + flickable.interactive
        }
        DebugLabel {
            text: "Drag	detector horizontal " + flickable._dragDetector.horizontalDragUnused + " vertical " + flickable._dragDetector.verticalDragUnused
        }
        DebugLabel {
            text: flickable.zoom !== undefined ? "Zoom " + flickable.zoom.toFixed(1) + " minimum " + flickable.minimumZoom.toFixed(1) + " fitted " + flickable.fittedZoom : ""
        }
        DebugLabel {
            text: editor ? "Crop w " + editor.width + " h " + editor.height + " x " + editor.x + " y " + editor.y : ""
        }
        DebugLabel {
            text: flickable.baseRotation !== undefined ? "Rotation base " + flickable.baseRotation + " image " + flickable.imageRotation : ""
        }
        DebugLabel {
            text: flickable.orientation !== undefined ? "Orientation " + flickable.orientation + " transpose " + flickable.transpose : ""
        }
        DebugLabel {
            text: metadata ? "Orientation meta " + metadata.orientation + " orientation " + flickable.orientation : ""
        }
    }
}
