import QtQuick 2.0
import Sailfish.Silica 1.0

SilicaGridView {
    id: grid

    property real cellSize: Math.floor(width / columnCount)
    property int columnCount: Math.floor(width / Theme.itemSizeHuge)

    cacheBuffer: 1000
    cellWidth: cellSize
    cellHeight: cellSize

    // Make header visible if it exists.
    Component.onCompleted: if (header) grid.positionViewAtBeginning()

    maximumFlickVelocity: 5000*Theme.pixelRatio

    VerticalScrollDecorator { }
}
