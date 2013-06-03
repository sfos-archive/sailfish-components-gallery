/****************************************************************************
**
** Copyright (C) 2013 Jolla Ltd.
** Contact: Raine Mäkeläinen <raine.makelainen@jollamobile.com>
**
****************************************************************************/

import QtQuick 1.1
import Sailfish.Silica 1.0
import Sailfish.Gallery 1.0

Item {
    id: cropView

    property Item splitView
    property real explicitWidth
    property real explicitHeight
    // Aspect ratio as width / height
    property real aspectRatio
    property string aspectRatioType: splitView.avatarAspectRatio ? "avatar" : "original"
    property bool isPortrait: width < height
    property bool active
    property bool showTitle: active
    property bool cropping
    property alias source: zoomableImage.source
    property alias target: editor.target
    property alias scale: zoomableImage.scale

    function crop() {
        cropping = true
        editor.crop(Qt.size(editor.width, editor.height),
                    Qt.size(zoomableImage.contentWidth, zoomableImage.contentHeight),
                    Qt.point(zoomableImage.contentX, zoomableImage.contentY))
    }

    onAspectRatioChanged: zoomableImage.resetImagePosition()
    onIsPortraitChanged: {
        // Reset back to original aspect ratio that needs to be calculated
        if (aspectRatioType == "original") {
            aspectRatio = -1.0
        }
    }

    Label {
        id: cropHeader

        //% "Crop"
        text: qsTrId("components_gallery-he-crop")
        height: theme.itemSizeLarge
        color: theme.highlightColor
        verticalAlignment: Text.AlignVCenter
        anchors.horizontalCenter: parent.horizontalCenter
        opacity: active && showTitle ? 1.0 : 0.0
        z: 1

        font {
            pixelSize: theme.fontSizeLarge
            family: theme.fontFamilyHeading
        }

        Behavior on opacity { FadeAnimation {} }
    }

    ZoomableImage {
        id: zoomableImage

        function resetImagePosition() {
            if (status != Image.Ready) {
                return
            }

            editor.setSize()
            resetScale()
        }

        boundsBehavior: Flickable.StopAtBounds
        anchors.fill: editor
        initialImageWidth: explicitWidth
        initialImageHeight: explicitHeight
        maximumWidth: 4 * parent.width
        maximumHeight: 4 * parent.height
        minimumWidth: editor.width
        minimumHeight: editor.height
        interactive: active
        onClicked: splitView.splitOpen = !splitView.splitOpen
        onStatusChanged: resetImagePosition()
    }

    ImageEditor {
        id : editor

        // As a function to avoid binding loops
        function setSize() {
            if (!aspectRatio || aspectRatio === -1.0) {
                aspectRatio = zoomableImage.contentWidth / zoomableImage.contentHeight
            }

            if (isPortrait) {
                var maxWidth = explicitWidth - theme.itemSizeMedium
                var tmpHeight = maxWidth / aspectRatio
                var maxHeight = explicitHeight - cropHeader.height
                if (tmpHeight > maxHeight) {
                    maxWidth = maxHeight * aspectRatio
                }

                width = maxWidth
                height = width / aspectRatio
            } else {
                maxHeight = explicitHeight
                var tmpWidth = aspectRatio * maxHeight
                maxWidth = explicitWidth - theme.itemSizeMedium
                if (tmpWidth > maxWidth) {
                    maxHeight = maxWidth / aspectRatio
                }
                height = maxHeight
                width = aspectRatio * height
            }
        }

        anchors.centerIn: parent
        source: zoomableImage.source
        onCropped: {
            cropping = false
            if (success) {
                cropView.targetChanged()
                if (cropView.source == cropView.target) {
                    // Force source image to be reloaded
                    cropView.source = ""
                    cropView.source = cropView.target
                }
                splitView.edited()
            }
        }
    }

    DimmedRegion {
        anchors.fill: parent
        color: theme.highlightDimmerColor
        opacity: active ? 0.5 : 0.0
        target: cropView
        area: Qt.rect(0, 0, cropView.width, cropView.height)
        exclude: [ editor ]

        Behavior on opacity { FadeAnimation {} }
    }
}
