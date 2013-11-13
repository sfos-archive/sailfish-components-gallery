/****************************************************************************
**
** Copyright (C) 2013 Jolla Ltd.
** Contact: Raine Mäkeläinen <raine.makelainen@jollamobile.com>
**
****************************************************************************/

import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Gallery 1.0
import Sailfish.Gallery.private 1.0

Item {
    id: preview

    property Item splitView
    property int editOperation
    property real explicitWidth
    property real explicitHeight    
    // Aspect ratio as width / height
    property real aspectRatio
    property string aspectRatioType: splitView.avatarCrop ? "avatar" : "original"
    property bool isPortrait: width < height
    property bool active
    property bool editInProgress
    property alias source: zoomableImage.source
    property alias target: editor.target
    //property alias orientation: zoomableImage.orientation
    property int orientation
    property alias previewRotation: zoomableImage.rotation

    function crop()
    {
        editInProgress = true
        editor.crop(Qt.size(editor.width, editor.height),
                    Qt.size(zoomableImage.contentWidth, zoomableImage.contentHeight),
                    Qt.point(zoomableImage.contentX, zoomableImage.contentY))
    }

    function rotateImage()
    {
        editInProgress = true
        editor.rotate(preview.previewRotation)
    }

    function resetScale()
    {
        zoomableImage.resetScale()
    }

    onAspectRatioTypeChanged: zoomableImage.resetImagePosition()
    onIsPortraitChanged: {
        // Reset back to original aspect ratio that needs to be calculated
        if (aspectRatioType == "original") {
            aspectRatio = -1.0
        }
    }

    // ImageMetadata is needed to track the real orientation
    // when the file is being edited.
    ImageMetadata {
        id: metadata
        source: preview.source
    }

    Label {
        id: header
        function headerText(type)
        {
            switch(type) {
            case ImageEditor.Crop:
                //% "Crop"
                return qsTrId("components_gallery-he-crop")
            case ImageEditor.Rotate:
                //% "Rotate"
                return qsTrId("components_gallery-he-rotate")
            default:
                return ""
            }
        }

        text: headerText(imageEditPreview.editOperation)
        height: Theme.itemSizeLarge
        color: Theme.highlightColor
        verticalAlignment: Text.AlignVCenter
        anchors.horizontalCenter: parent.horizontalCenter

        opacity: active && !splitView.splitOpen ? 1.0 : 0.0
        z: 1

        font {
            pixelSize: Theme.fontSizeLarge
            family: Theme.fontFamilyHeading
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

        orientation: metadata.orientation
        boundsBehavior: Flickable.StopAtBounds
        anchors.fill: editor
        initialImageWidth: explicitWidth
        initialImageHeight: explicitHeight
        maximumWidth: 4 * parent.width
        maximumHeight: 4 * parent.height
        minimumWidth: editor.width
        minimumHeight: editor.height
        imageWidth: metadata.width
        imageHeight: metadata.height
        interactive: active && editOperation == ImageEditor.Crop
        onClicked: splitView.splitOpen = !splitView.splitOpen
        onStatusChanged: resetImagePosition()
        Behavior on rotation { SmoothedAnimation { duration: 200 } }

    }

    ImageEditor {
        id : editor

        // As a function to avoid binding loops
        function setSize() {
            if (!aspectRatio || aspectRatio === -1.0) {
                aspectRatio = zoomableImage.contentWidth / zoomableImage.contentHeight
            }

            if (isPortrait) {
                var maxWidth = explicitWidth - Theme.itemSizeMedium
                var tmpHeight = maxWidth / aspectRatio
                var maxHeight = explicitHeight - header.height
                if (tmpHeight > maxHeight) {
                    maxWidth = maxHeight * aspectRatio
                }

                width = maxWidth
                height = width / aspectRatio
            } else {
                maxHeight = explicitHeight
                var tmpWidth = aspectRatio * maxHeight
                maxWidth = explicitWidth - Theme.itemSizeMedium
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
            editInProgress = false
            if (success) {
                 if (preview.source == preview.target) {
                    preview.source = ""
                    preview.source = editor.target
                 }
                 splitView.edited()
            }
        }

        onRotated: {
            editInProgress = false
            if (success) {
                preview.source = editor.target
            }
            preview.previewRotation = 0
        }
    }

    DimmedRegion {
        anchors.fill: parent
        color: Theme.highlightDimmerColor
        opacity: preview.editOperation == ImageEditor.Crop && active ? 0.5 : 0.0
        target: preview
        area: Qt.rect(0, 0, preview.width, preview.height)
        exclude: [ editor ]

        Behavior on opacity { FadeAnimation {} }
    }

    BusyIndicator {
        anchors.centerIn: parent
        running: editInProgress || zoomableImage.status != Image.Ready
    }
}
