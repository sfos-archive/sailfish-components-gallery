import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Gallery 1.0
import Sailfish.Gallery.private 1.0

SilicaFlickable {
    id: flickable

    property bool scaled: false
    property bool menuOpen
    property bool enableZoom: !menuOpen
    property alias source: photo.source
    property int fit

    property bool active: true

    property real _fittedScale: Math.min(width / _originalPhotoWidth, height / _originalPhotoHeight)
    property real _menuOpenScale: Math.max(Screen.width / _originalPhotoWidth, (Screen.height / 2) / _originalPhotoHeight)
    property real _scale

    property int orientation

    property int maximumWidth: photo.implicitWidth
    property int maximumHeight: photo.implicitHeight

    property int _viewOrientation: width === Screen.width && height === Screen.height
                                 ? Orientation.Portrait
                                 : width === Screen.height && height === Screen.width
                                 ? Orientation.Landscape
                                 : Orientation.None // In the middle of Portrait and Landscape transitions

    readonly property bool _transpose: (orientation % 180) != 0
    readonly property real _originalPhotoWidth: !_transpose ? maximumWidth : maximumHeight
    readonly property real _originalPhotoHeight: !_transpose ? maximumHeight : maximumWidth

    signal clicked

    // Override SilicaFlickable's pressDelay because otherwise it will
    // block touch events going to PinchArea in certain cases.
    pressDelay: 0

    flickableDirection: Flickable.HorizontalAndVerticalFlick

    implicitWidth: !_transpose ? maximumWidth : maximumHeight
    implicitHeight: !_transpose ? maximumHeight : maximumWidth

    contentWidth: container.width
    contentHeight: container.height

    // Only update the scale when width and height are properly set by Silica.
    // If we do it too early, then calculating a new _fittedScale goes wrong
    on_ViewOrientationChanged: {
        _updateScale()
    }

    onActiveChanged: {
        if (!active) {
            _resetScale()
            largePhoto.source = ""
        }
    }

    interactive: scaled

    function _resetScale()
    {
        if (scaled) {
            _scale = _fittedScale
            scaled = false
        }
    }

    function _scaleImage(scale, center, prevCenter)
    {
        if (largePhoto.source != photo.source) {
            largePhoto.source = photo.source
        }
        var newWidth
        var newHeight
        var oldWidth = contentWidth
        var oldHeight = contentHeight

        // move center
        contentX += prevCenter.x - center.x
        contentY += prevCenter.y - center.y

        if (fit == Fit.Width) {
            // Scale and bounds check the width, and then apply the same scale to height.
            newWidth = (!flickable._transpose ? photo.width : photo.height) * scale

            if (newWidth <= _fittedScale * _originalPhotoWidth) {
                _resetScale()
                return
            } else {
                newWidth = Math.min(newWidth, flickable.maximumWidth)
                _scale = newWidth / flickable.implicitWidth
                newHeight = Math.max(!_transpose ? photo.height : photo.width, Screen.height)
            }
        } else {
            // Scale and bounds check the height, and then apply the same scale to width.
            newHeight = (!flickable._transpose ? photo.height: photo.width) * scale
            if (newHeight <= _fittedScale * _originalPhotoHeight) {
                _resetScale()
                return
            } else {
                newHeight = Math.min(newHeight, flickable.maximumHeight)
                _scale = newHeight / flickable.implicitHeight
                newWidth = Math.max(!_transpose ? photo.width : photo.height, Screen.height)
            }
        }

        // scale about center
        if (newWidth > flickable.width)
            contentX -= (oldWidth - newWidth)/(oldWidth/prevCenter.x)
        if (newHeight > flickable.height)
            contentY -= (oldHeight - newHeight)/(oldHeight/prevCenter.y)

        scaled = true
    }

    function _updateScale() {
        if (photo.status != Image.Ready) {
            return
        }
        state = menuOpen
                ? "menuOpen"
                : _viewOrientation == Orientation.Portrait
                ? "portrait"
                : _viewOrientation == Orientation.Landscape
                ? "landscape"
                : "fullscreen" // fallback
    }

    children: ScrollDecorator {}

    PinchArea {
        id: container
        enabled: !flickable.menuOpen && flickable.enableZoom && photo.status == Image.Ready
        onPinchUpdated: flickable._scaleImage(1.0 + pinch.scale - pinch.previousScale, pinch.center, pinch.previousCenter)
        onPinchFinished: flickable.returnToBounds()
        width: Math.max(flickable.width, !flickable._transpose ? photo.width : photo.height)
        height: Math.max(flickable.height, !flickable._transpose ? photo.height : photo.width)

        Image {
            id: photo
            property var errorLabel
            objectName: "zoomableImage"

            smooth: !(flickable.movingVertically || flickable.movingHorizontally)
            width: flickable.maximumWidth * flickable._scale
            height: flickable.maximumHeight * flickable._scale
            sourceSize.width: Screen.height
            fillMode:  Image.PreserveAspectFit
            asynchronous: true
            anchors.centerIn: parent
            cache: false

            onStatusChanged: {

                if (status == Image.Ready) {
                    flickable._updateScale()
                }

                if (status == Image.Error) {
                   errorLabel = errorLabelComponent.createObject(photo)
                }
            }

            onSourceChanged: {
                if (errorLabel) {
                    errorLabel.destroy()
                }

                flickable.scaled = false
            }

            rotation: -flickable.orientation

            opacity: status == Image.Ready ? 1 : 0
            Behavior on opacity { FadeAnimation{} }
        }
        Image {
            id: largePhoto
            sourceSize {
                width: photo.implicitWidth >= photo.implicitHeight ? 3264 : -1
                height: photo.implicitWidth < photo.implicitHeight ? 3264 : -1
            }
            cache: false
            asynchronous: true
            anchors.fill: photo
            rotation: -flickable.orientation
        }

        MouseArea {
            anchors.fill: parent
            enabled: !flickable.scaled

            onClicked: {
                flickable.clicked()
            }
        }
    }

    Component {
        id: errorLabelComponent
        Label {
            //: Image loading failed
            //% "Oops, can't display the image"
            text: qsTrId("components_gallery-la-image-loading-failed")
            anchors.centerIn: parent
            width: parent.width - 2 * Theme.paddingMedium
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter
        }
    }

    // Let the states handle switching between menu open and fullscreen states.
    // We need to extend fullscreen state with two different states: portrait and
    // landscape to make it actually reset the fitted scale via state changes when
    // the orientation changes. Ie. state change from "fullscreen" to "fullscreen"
    // doesn't reset the fitted scale.
    states: [
        State {
            name: "menuOpen"
            when: flickable.menuOpen && photo.status == Image.Ready
            PropertyChanges {
                target: flickable
                _scale: flickable._menuOpenScale
                scaled: false
                contentX: (flickable._originalPhotoWidth  * flickable._menuOpenScale - flickable.width ) / 2.0

            }
        },
        State {
            name: "fullscreen"
            when: !flickable.menuOpen && photo.status == Image.Ready
            PropertyChanges {
                target: flickable
                // 1.0 for smaller images. _fittedScale for images which are larger than view
                _scale: flickable._fittedScale >= 1 ? 1.0 : flickable._fittedScale
                scaled: false
                contentX: 0
            }
        },
        State {
            name: "portrait"
            extend: "fullscreen"
        },
        State {
            name: "landscape"
            extend: "fullscreen"
        }
    ]

    transitions: [
        Transition {
            from: '*'
            to: 'menuOpen'
            PropertyAnimation {
                target: flickable
                properties: "_scale,contentX"
                duration: 150
                easing.type: Easing.InQuad
            }
        },
        Transition {
            from: 'menuOpen'
            to: '*'
            PropertyAnimation {
                target: flickable
                properties: "_scale,contentX"
                duration: 150
                easing.type: Easing.InQuad
            }
        }

    ]
}
