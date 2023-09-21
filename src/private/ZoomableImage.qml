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
import QtGraphicalEffects 1.0
import Sailfish.Silica 1.0
import ".."

ImageViewer {
    id: root

    property int baseRotation
    property int imageRotation
    property alias brightness: adjustLevels.brightness
    property alias contrast: adjustLevels.contrast
    readonly property bool longPressed: pressed && !delayPressTimer.running
    property bool animatingBrightnessContrast

    contentRotation: baseRotation + imageRotation

    onAnimatingBrightnessContrastChanged: adjustLevels.visible = true

    function rotate(angle) {
        resetZoom()
        // Don't wait for the rotation animation to complete to new image dimensions
        transposeBinding.value = (baseRotation + rotationAnimation.to + angle) % 180
        rotationAnimation.to = rotationAnimation.to + angle
        rotationAnimation.restart()
    }

    Binding {
        id: transposeBinding
        target: root
        when: rotationAnimation.running
        property: "transpose"
    }

    NumberAnimation {
        id: rotationAnimation
        target: root
        property: "imageRotation"
        easing.type: Easing.InOutQuad
        duration: 200
    }

    Behavior on zoom {
        enabled: rotationAnimation.running
        SmoothedAnimation { duration: 200 }
    }

    // On the Jolla 1, we're experiencing a crash inside the OpenGL
    // driver blob which starts when an FBO is somewhere around 2500+
    // pixels in size. Max texture size and Max renderbuffer size are
    // both 4096, well within, so the actual cause is unknown.
    property bool isJolla1: Screen.width == 540 && Screen.height == 960
    largePhoto.sourceSize {
        width: isJolla1 ? 2048 : 3264
        height: isJolla1 ? 2048 : 3264
    }

    BrightnessContrast {
        id: adjustLevels

        source: root
        visible: false
        cached: !animatingBrightnessContrast
        parent: root.parent
        width: source.width
        height: source.height
    }

    Timer {
        id: delayPressTimer
        running: pressed
        interval: 300
    }

    states: State {
        when: longPressed
        PropertyChanges {
            target: root
            brightness: 0.0
            contrast: 0.0
        }
    }
}
