import QtQuick 2.0
import Sailfish.Silica 1.0

SilicaFlickable {
    id: flickable

    property bool itemScaled: scale != 1.0
    property alias source: photo.source
    property alias scale: photo.scale
    property real minimumWidth: width
    property real maximumWidth
    property real minimumHeight: height
    property real maximumHeight
    property real initialImageWidth: width
    property real initialImageHeight: height

    property int status: Image.Null

    property int orientation

    readonly property bool _transpose: (orientation % 180) != 0

    signal clicked

    flickableDirection: Flickable.HorizontalAndVerticalFlick

    implicitWidth: !_transpose ? photo.implicitWidth : photo.implicitHeight
    implicitHeight: !_transpose ? photo.implicitHeight : photo.implicitWidth

    contentWidth: flickable.implicitWidth * photo.scale
    contentHeight: flickable.implicitHeight * photo.scale

    function resetScale() {
        photo.updateScale()
    }

    function _centerImage(pinch) {
        var scale = 1.0 + pinch.scale - pinch.previousScale
        var newContentWidth = contentWidth * scale
        var newContentHeight = contentHeight * scale

        var dx = (pinch.center.x * newContentWidth / contentWidth) - pinch.center.x
        var dy = (pinch.center.y * newContentHeight / contentHeight) - pinch.center.y

        if (newContentWidth >= minimumWidth && newContentHeight >= minimumHeight &&
                newContentWidth <= maximumWidth && newContentHeight <= maximumHeight) {
            contentX += dx
            contentY += dy
        }
        // Do we want to keep pinch always inside the boundararies ?
    }

    PinchArea {
        id: pinchArea

        anchors.fill: parent
        enabled: interactive && photo.status == Image.Ready
        pinch.target: photo
        pinch.minimumScale: Math.max(minimumWidth / flickable.implicitWidth, minimumHeight / flickable.implicitHeight)
        pinch.maximumScale: Math.min(maximumWidth / flickable.implicitWidth, maximumHeight / flickable.implicitHeight)
        pinch.dragAxis: Pinch.XandYAxis

        onPinchUpdated: _centerImage(pinch)
        onPinchFinished: flickable.returnToBounds()

        Image {
            id: photo

            function updateScale() {
                if (status != Image.Ready)
                    return

                var fittedScale
                var isImagePortrait = flickable.implicitWidth < flickable.implicitHeight
                var minimumDimension = Math.min(initialImageHeight, initialImageWidth)
                fittedScale = minimumDimension / (isImagePortrait ? flickable.implicitWidth : flickable.implicitHeight)

                scale = fittedScale
                flickable.contentX = (flickable.implicitWidth * scale - flickable.width) / 2
                flickable.contentY = (flickable.implicitHeight * scale - flickable.height) / 2
            }

            objectName: "zoomableImage"
            cache: false
            smooth: !(flickable.movingVertically || flickable.movingHorizontally)
            fillMode:  Image.PreserveAspectFit
            asynchronous: true
            anchors.centerIn: parent
            sourceSize.width: Math.max(screen.height, screen.width) * 2

            rotation: -flickable.orientation

            onStatusChanged: {
                flickable.status = status
                updateScale()
            }
        }

        MouseArea {
            anchors.fill: parent
            enabled: !flickable.moving && !pinchArea.pinch.active
            onClicked: flickable.clicked()
        }
    }
}
