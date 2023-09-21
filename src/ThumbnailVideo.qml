/****************************************************************************************
** Copyright (c) 2013 - 2023 Jolla Ltd.
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
import Sailfish.Silica 1.0

/*!
  \inqmlmodule Sailfish.Gallery
*/
ThumbnailImage {
    property alias duration: durationLabel.text
    property alias title: titleLabel.text

    Rectangle {
        anchors.bottom: parent.bottom
        width: parent.width
        height: parent.height / 2
        opacity: Theme.opacityOverlay
        gradient: Gradient {
            GradientStop { position: 0.0; color: "transparent" }
            GradientStop { position: 1.0; color: Theme.highlightDimmerColor }
        }
    }

    Label {
        id: durationLabel

        font {
            pixelSize: Theme.fontSizeSmall
        }
        anchors {
            bottom: titleLabel.top; left: parent.left; leftMargin: Theme.paddingMedium
        }
    }

    Label {
        id: titleLabel

        font {
            pixelSize: Theme.fontSizeExtraSmall
        }
        color: Theme.highlightColor
        truncationMode: TruncationMode.Elide
        anchors {
            bottom: parent.bottom; bottomMargin: Theme.paddingMedium
            left: parent.left; leftMargin: Theme.paddingMedium
            right: parent.right
        }
    }
}
