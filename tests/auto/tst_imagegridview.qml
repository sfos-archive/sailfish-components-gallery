import QtTest 1.0
import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Gallery 1.0

Item {
    width: screen.width; height: screen.height
    property bool isPortrait: true

    ImageGridView {
        id: imageGridView
        anchors.fill: parent
    }

    resources: TestCase {
        name: "ImageGridView"
        when: windowShown
        function test_imageGridView() {
            compare(imageGridView.cellSize, Math.floor(screen.width / 3))
            compare(imageGridView.cellWidth, imageGridView.cellSize)
            compare(imageGridView.cellHeight, imageGridView.cellSize)
            compare(imageGridView.cacheBuffer, 1000)
            compare(imageGridView.maximumFlickVelocity, 5000)
            compare(imageGridView.highlightEnabled, true)
            compare(imageGridView.unfocusHighlightEnabled, false)
            compare(imageGridView.columnCount, 3)

            isPortrait = false
            compare(imageGridView.cellSize, Math.floor(screen.width / 5))
            compare(imageGridView.cellWidth, imageGridView.cellSize)
            compare(imageGridView.cellHeight, imageGridView.cellSize)
            compare(imageGridView.columnCount, 5)

        }
    }
}

