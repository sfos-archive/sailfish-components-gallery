import QtQuick 2.0
import org.nemomobile.thumbnailer 1.0

ThumbnailBase {

    Thumbnail {

        property bool gridMoving: grid.moving

        source: parent.source
        mimeType: model.mimeType
        width:  size
        height: size
        sourceSize.width: width
        sourceSize.height: height
        y: contentYOffset
        x: contentXOffset
        priority: Thumbnail.NormalPriority

        onGridMovingChanged: {
            if (!gridMoving) {
                var visibleIndex = Math.floor(grid.contentY / size) * grid.columnCount

                if (visibleIndex <= index && index <= visibleIndex + 18) {
                    priority = Thumbnail.HighPriority
                } else {
                    priority = Thumbnail.LowPriority
                }
            }
        }
    }
}
