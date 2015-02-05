import QtTest 1.0
import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Gallery 1.0
import "utils.js" as Utils

Item {
    width: screen.width; height: screen.height

    // Grid needs this, usually it comes from Page
    property bool isPortrait: true
    property variant thumbnail

    ImageGridView {
        id: imageGridView
        anchors.fill: parent

        delegate: ThumbnailImage {
            source: url
            mimeType: model.mimeType

        }
        model: testModel
    }

    ListModel {
        id: testModel
        ListElement { url: "file:///home/nemo/Pictures/image1.jpg"; mimeType: "image/jpeg" }
    }


    SignalSpy {
        id: clickedSpy
        signalName: "clicked"
    }

    SignalSpy {
        // WORKAROUND: Compared to the other SignalSpy items, this one deals
        // with the fact that MouseArea contains one property and one signal
        // sharing the same name "pressed" - SignalSpy fails with such a target.
        id: pressedSpy_
        target: pressedSpy
        signalName: "targetPressed"

        Connections {
            id: pressedSpy
            target: pressedSpyFakeTarget
            onPressed: targetPressed()
            signal targetPressed()
            property alias count: pressedSpy_.count
            function clear() { pressedSpy_.clear() }
        }

        // Used to suppress warning about nonexisting signal during initialization
        Item {
            id: pressedSpyFakeTarget
            signal pressed()
        }
    }

    SignalSpy {
        id: releasedSpy
        signalName: "released"
    }

    SignalSpy {
        id: pressAndHoldSpy
        signalName: "pressAndHold"
    }

    TestCase {
        name: "ThumbnailImage"
        when: windowShown

        function test_init()
        {
            isPortrait = true
            thumbnail = Utils.findChild(imageGridView, "ThumbnailBase_QMLTYPE")
            clickedSpy.target = thumbnail
            pressedSpy.target = thumbnail
            releasedSpy.target = thumbnail
            pressAndHoldSpy.target = thumbnail
        }

        function test_thumbnailImage() {
            verify(thumbnail != null)

            compare(thumbnail.size, imageGridView.cellSize)
            compare(thumbnail.width, thumbnail.size)
            compare(thumbnail.height, thumbnail.size)
            compare(thumbnail.source, "file:///home/nemo/Pictures/image1.jpg")
            compare(thumbnail.mimeType, "image/jpeg")
            compare(thumbnail.contentYOffset, 0)
            compare(thumbnail.contentXOffset, 0)


            // Get the actual Thumbnail item from ThumbnailBase
            var thumbnailImage = Utils.findChild(thumbnail, "NemoThumbnailItem")
            verify(thumbnailImage != null)
            compare(thumbnailImage.sourceSize.height, thumbnail.size)
            compare(thumbnailImage.sourceSize.width, thumbnail.size)

            isPortrait = false
            compare(thumbnail.size, imageGridView.cellSize)
            compare(thumbnail.width, thumbnail.size)
            compare(thumbnail.height, thumbnail.size)
            compare(thumbnailImage.sourceSize.height, thumbnail.size)
            compare(thumbnailImage.sourceSize.width, thumbnail.size)

        }


        function test_thumbnailImageClicked() {
            verify(thumbnail != null)

            pressedSpy.clear()

            mouseClick(thumbnail, thumbnail.x, thumbnail.y)
            tryCompare(clickedSpy, "count", 1)
            tryCompare(pressedSpy, "count", 1)
            tryCompare(releasedSpy, "count", 1)
        }

        function test_thumbnailImagePressedReleased() {
            verify(thumbnail != null)

            pressedSpy.clear()
            releasedSpy.clear()

            mousePress(thumbnail, thumbnail.x, thumbnail.y)
            tryCompare(pressedSpy, "count", 1)

            mouseRelease(thumbnail, thumbnail.x, thumbnail.y)
            tryCompare(releasedSpy, "count", 1)
        }

        function test_thumbnailImagePressAndHold() {
            verify(thumbnail != null)

            compare(thumbnail.pressedAndHolded, false)
            pressedSpy.clear()
            releasedSpy.clear()
            clickedSpy.clear()

            mousePress(thumbnail, thumbnail.x, thumbnail.y)
            wait(1200) // Thresshold is 800

            tryCompare(pressAndHoldSpy, "count", 1)
            compare(thumbnail.pressedAndHolded, true)

            mouseRelease(thumbnail, thumbnail.x, thumbnail.y)
            tryCompare(pressedSpy, "count", 1)
            tryCompare(releasedSpy, "count", 1)
            compare(thumbnail.pressedAndHolded, false)
        }
    }
}

