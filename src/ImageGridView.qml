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
import Sailfish.Silica.private 1.0 as Private

/*!
  \inqmlmodule Sailfish.Gallery
*/
SilicaGridView {
    id: grid

    property real cellSize: Math.floor(width / columnCount)
    property int columnCount: Math.floor(width / Theme.itemSizeHuge)
    property int maxContentY: Math.max(0, contentHeight - height) + originY
    property string dateProperty: "dateTaken"

    // QTBUG-95676: StopAtBounds does not work with StrictlyEnforceRange,
    // work-around by implementing StopAtBounds locally
    onContentYChanged: if (contentY > maxContentY) contentY = maxContentY

    preferredHighlightBegin: 0
    preferredHighlightEnd: headerItem.height + cellSize
    highlightRangeMode: GridView.StrictlyEnforceRange

    quickScroll: false
    cacheBuffer: 1000
    cellWidth: cellSize
    cellHeight: cellSize

    // Make header visible if it exists.
    Component.onCompleted: if (header) grid.positionViewAtBeginning()

    maximumFlickVelocity: 5000*Theme.pixelRatio

    Private.Scrollbar {
        property var date: {
            if (grid.model) {

                // Disable on Gallery albums that don't use QtDocGallery
                if (typeof grid.model.get === "undefined") {
                    visible = false
                    return undefined
                }

                var item = grid.model.get(grid.currentIndex)
                if (item) {
                    return item[dateProperty]
                }
            }
            return undefined
        }

        text: date ? Format.formatDate(date, Format.MonthNameStandalone) : ""
        description: date ? date.getFullYear() : ""
        headerHeight: grid.headerItem ? grid.headerItem.height : 0
        stepSize: grid.cellHeight
    }
}
