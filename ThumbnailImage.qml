import QtQuick 1.1
import org.nemomobile.thumbnailer 1.0

Thumbnail {
    id: image

    property bool selected
    property real size

    signal clicked
    signal pressAndHold
    signal pressed
    signal released

    width: size
    height: size
    sourceSize.height: size
    sourceSize.width: size

    priority: index >= 0 && index < 15 ?
                  Thumbnail.NormalPriority : Thumbnail.LowPriority

    MouseArea {
        anchors.fill: parent
        onClicked: image.clicked()
        onPressAndHold: image.pressAndHold()
        onPressed: image.pressed()
        onReleased: image.released()
    }
}
