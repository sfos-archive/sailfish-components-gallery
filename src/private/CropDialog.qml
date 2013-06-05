/****************************************************************************
**
** Copyright (C) 2013 Jolla Ltd.
** Contact: Raine Mäkeläinen <raine.makelainen@jollamobile.com>
**
****************************************************************************/

import QtQuick 1.1
import Sailfish.Silica 1.0
import Sailfish.Gallery 1.0

SplitViewDialog {
    id: aspectRatioDialog

    property bool avatarCrop

    signal edited
    signal cropRequested

    function _verifyPageIndicatorVisibility(splitView) {
        var enabled = true
        if (!splitView.splitOpened) {
            enabled = false
        }

        if (pageStack._pageStackIndicator) {
            pageStack._pageStackIndicator.enabled = enabled
        }
    }

    // Clip zoomed part of the image
    clip: true
    onDone: {
        if (result == DialogResult.Accepted) {
            cropRequested()
        }
    }

    onSplitOpenedChanged: _verifyPageIndicatorVisibility(aspectRatioDialog)

    background: SilicaListView {
        anchors.fill: parent

        header: DialogHeader {
            dialog: aspectRatioDialog
        }

        delegate: LabelItem {
            text: model.text
            //: Label that is shown for currently selected aspect ratio.
            //% "Aspect ratio"
            sectionLabel: qsTrId("components_gallery-li-aspect_ratio")
            selected: cropView.aspectRatioType == model.type

            onClicked: {
                aspectRatioDialog.splitOpen = !aspectRatioDialog.splitOpen
                cropView.aspectRatio = model.ratio
                cropView.aspectRatioType = model.type
            }
        }

        model: AspectRatioModel {}
    }

    Component.onCompleted: _verifyPageIndicatorVisibility(aspectRatioDialog)
}
