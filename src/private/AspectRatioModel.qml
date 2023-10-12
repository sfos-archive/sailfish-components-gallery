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

ListModel {
    ListElement {
        //% "No cropping"
        text: qsTrId("components_gallery-li-no_cropping")
        ratio: -1.0
        type: "none"
    }
    ListElement {
        //: Original aspect ratio
        //% "Original"
        text: qsTrId("components_gallery-li-aspect_ratio_original")
        ratio: 0.0
        type: "original"
    }
    ListElement {
        //: Square aspect ratio
        //% "Square"
        text: qsTrId("components_gallery-li-aspect_ratio_square")
        ratio: 1.0
        type: "square"
    }
    ListElement {
        //: Avatar aspect ratio
        //% "Avatar"
        text: qsTrId("components_gallery-li-aspect_ratio_avatar")
        ratio: 1.0 // separate this from square so that we can open people picker for avatars
        type: "avatar"
    }
    ListElement {
        //: ambience aspect ratio
        //% "Ambience"
        text: qsTrId("components_gallery-li-aspect_ratio_ambience")
        ratio: 1.0
        type: "Ambience"
    }
    ListElement {
        //: 3:4 aspect ratio
        //% "3:4"
        text: qsTrId("components_gallery-li-aspect_ratio_3_4")
        ratio: 0.75
        type: "3:4"
    }
    ListElement {
        //: 4:3 aspect ratio
        //% "4:3"
        text: qsTrId("components_gallery-li-aspect_ratio_4_3")
        ratio: 1.333
        type: "4:3"
    }
}
