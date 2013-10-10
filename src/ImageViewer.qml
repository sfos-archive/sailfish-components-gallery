import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Gallery 1.0

SilicaFlickable {
    id: flickable

    property bool scaled: false
    property bool menuOpen
    property bool enableZoom: !menuOpen
    property alias source: photo.source

    property int fit

    property real _fittedScale
    property real _scale

    property int orientation

    readonly property bool _transpose: (orientation % 180) != 0

    signal clicked

    // Overrider SilicaFlickable's pressDelay because otherwise it will
    // block touch events going to PinchArea in certain cases.
    pressDelay: 0

    flickableDirection: Flickable.HorizontalAndVerticalFlick

    implicitWidth: !_transpose ? photo.implicitWidth : photo.implicitHeight
    implicitHeight: !_transpose ? photo.implicitHeight : photo.implicitWidth

    contentWidth: Math.max(width, !_transpose ? photo.width : photo.height)
    contentHeight: Math.max(height, !_transpose ? photo.height : photo.width)

    onMenuOpenChanged: setSplitMode()

    onFitChanged: _updateScale()

    interactive: scaled

    function setSplitMode()
    {
        if (menuOpen) {
            scaleBehavior.enabled = true
            _updateScale()
        } else {
            _updateScale()
            scaleBehavior.enabled = false
        }
    }

    function resetScale()
    {
        if (scaled) {
            _scale = _fittedScale
            contentX = 0
            contentY = 0
            scaled = false
        }
    }

    function _scaleImage(scale, center)
    {
        var newWidth
        var newHeight
        var oldWidth = contentWidth
        var oldHeight = contentHeight

        if (fit == Fit.Width) {
            // Scale and bounds check the width, and then apply the same scale to height.
            newWidth = contentWidth * scale
            if (newWidth <= Screen.width) {
                resetScale()
                return
            } else {
                newWidth = Math.min(newWidth, Screen.width * 3.5)
                _scale = newWidth / flickable.implicitWidth
                newHeight = Math.max(!_transpose ? photo.height : photo.width, Screen.height)
            }
        } else {
            // Scale and bounds check the height, and then apply the same scale to width.
            newHeight = contentHeight * scale
            if (newHeight <= Screen.width) {
                resetScale()
                return
            } else {
                newHeight = Math.min(newHeight, Screen.width * 3.5)
                _scale = newHeight / flickable.implicitHeight
                newWidth = Math.max(!_transpose ? photo.width : photo.height, Screen.height)
            }
        }
        // Fixup contentX and contentY
        contentX += (center.x * newWidth / oldWidth) - center.x
        contentY += (center.y * newHeight / oldHeight) - center.y

        scaled = true
    }

    function _updateScale() {
        if (photo.status != Image.Ready)
            return

        if (menuOpen) {
            _fittedScale = Screen.width / Math.min(photo.implicitWidth, photo.implicitHeight)
        } else {
            _fittedScale = (fit == Fit.Width)
                    ? Screen.width / flickable.implicitWidth
                    : Screen.width / flickable.implicitHeight
        }

        if (!scaled || _scale < _fittedScale) {
            _scale = _fittedScale
            contentX = 0
            contentY = 0
            scaled = false
        }
    }

    // This Behavior is used only when user has aligned image i.e. we are on a split screen mode
    Behavior on _scale { id: scaleBehavior; NumberAnimation {  duration: 300; alwaysRunToEnd: true } }

    children: ScrollDecorator {}
    PinchArea {
        id: pinchArea
        enabled: !flickable.menuOpen && flickable.enableZoom && photo.status == Image.Ready
        anchors.fill: parent
        onPinchUpdated: flickable._scaleImage(1.0 + pinch.scale - pinch.previousScale, pinch.center)
        onPinchFinished: flickable.returnToBounds()

        Image {
            id: photo

            objectName: "zoomableImage"

            smooth: !(flickable.movingVertically || flickable.movingHorizontally)
            width: implicitWidth * flickable._scale
            height: implicitHeight * flickable._scale
            sourceSize.width: Screen.width * 1.5
            fillMode:  Image.PreserveAspectFit
            asynchronous: true
            anchors.centerIn: parent

            onStatusChanged: flickable._updateScale()
            onSourceChanged: {
                scaleBehavior.enabled = false
                flickable._fittedScale = 0
                flickable.scaled = false
            }

            rotation: -flickable.orientation

            opacity: status == Image.Ready ? 1 : 0
            Behavior on opacity { FadeAnimation{} }
        }

        MouseArea {
            anchors.fill: parent
            enabled: !flickable.scaled

            onClicked: {
                flickable.clicked()
            }
        }
    }
}
