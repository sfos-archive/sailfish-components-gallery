/****************************************************************************
**
** Copyright (C) 2013 Jolla Ltd.
** Contact: Raine Mäkeläinen <raine.makelainen@jollamobile.com>
**
****************************************************************************/

import QtQuick 1.1
import Sailfish.Silica 1.0

SplitViewDialog {
    id: aspectRatioDialog

    onDone: {
         if (result == DialogResult.Accepted) {
             cropView.crop()
         }
         pageStack.pop()
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
            selected: cropView.aspectRatio == model.ratio ||
                      model.ratio == -1.0 && cropView.originalAspectRatio

            onClicked: {
                cropView.aspectRatio = model.ratio
                aspectRatioDialog.splitOpen = !aspectRatioDialog.splitOpen
            }
        }

        model: AspectRatioModel {}
    }

    Component.onCompleted: _verifyPageIndicatorVisibility(aspectRatioDialog)
}
