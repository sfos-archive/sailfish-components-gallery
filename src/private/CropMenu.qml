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
    id: root

    property bool active
    property string type: "original"
    property real ratio: -1

    property Item _highlightedItem
    property Item _selectedItem: repeater.itemAt(1)

    signal selected
    signal canceled

    onActiveChanged: if (active) highlightBar.highlight(_selectedItem, contentColumn)

    anchors.fill: parent
    color: Theme.colorScheme == Theme.LightOnDark ? Theme.rgba(Theme.highlightDimmerColor, Theme.opacityOverlay)
                                                  : Theme.rgba(Theme.lightPrimaryColor, Theme.opacityOverlay)

    MouseArea {
        anchors.fill: parent
        onClicked: root.canceled()
    }

    SilicaFlickable {
        id: flickable
        width: parent.width
        height: Math.min(parent.height, contentHeight)
        anchors.verticalCenter: parent.verticalCenter
        contentHeight: contentColumn.y + contentColumn.height + Theme.paddingLarge

        HighlightBar { id: highlightBar }

        Label {
            id: titleLabel

            //% "Aspect ratio"
            text: qsTrId("components_gallery-he-aspect_ratio")
            width: parent.width - x
            y: Theme.paddingLarge
            x: Theme.horizontalPageMargin
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: Theme.fontSizeExtraLarge
            color: Theme.highlightColor
            wrapMode: Text.Wrap
            height: Theme.itemSizeSmall
        }

        Column {
            id: contentColumn

            width: parent.width
            anchors.top: titleLabel.bottom

            Repeater {
                id: repeater
                model: AspectRatioModel {}
                MenuItem {
                    text: model.text
                    onClicked: {
                        root.type = model.type
                        root.ratio = model.ratio
                        root.selected()
                    }
                }
            }
        }

        MouseArea {
            parent: flickable
            enabled: root.active
            anchors.fill: parent

            function itemAt(yPos) {
                var pos = mapToItem(contentColumn, width/2, yPos)
                var item = contentColumn.childAt(pos.x, pos.y)
                return item && item.__silica_menuitem !== undefined ? item : null
            }
            function updateHighlight(yPos) {
                if (_highlightedItem && itemAt(yPos) !== _highlightedItem) {
                    clearHighlight()
                }
            }
            function clearHighlight() {
                if (_highlightedItem) {
                    highlightBar.clearHighlight()
                    _highlightedItem.down = false
                    _highlightedItem = null
                }
            }

            onPressed: {
                _highlightedItem = itemAt(mouse.y)
                if (_highlightedItem) {
                    highlightBar.highlight(_highlightedItem, contentColumn)
                    _highlightedItem.down = true
                }
            }
            onPositionChanged: updateHighlight(mouse.y)
            onClicked: {
                updateHighlight(mouse.y)
                if (_highlightedItem) {
                    _highlightedItem.clicked()
                    _selectedItem = _highlightedItem
                } else {
                    root.canceled()
                }
                clearHighlight()
            }
            onCanceled: {
                clearHighlight()
            }
        }
        VerticalScrollDecorator {}
    }
}
