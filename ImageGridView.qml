import QtQuick 1.1
import Sailfish.Silica 1.0

SilicaGridView {
    property real cellSize

    currentIndex: -1
    cellWidth: cellSize; cellHeight: cellSize
    cacheBuffer: 1000
    // Tested value and ~166px movement per frame (60fps) feels good during fast flick.
    // Default being 2500px/s
    maximumFlickVelocity: 10000

    VerticalScrollDecorator { }
}
