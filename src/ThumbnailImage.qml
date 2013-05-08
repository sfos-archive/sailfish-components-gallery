import QtQuick 1.1
import org.nemomobile.thumbnailer 1.0

ThumbnailBase {

    Thumbnail {
        source: parent.source
        mimeType: mimeType
        width:  size
        height: size
        sourceSize.width: width
        sourceSize.height: height
        y: contentYOffset
        x: contentXOffset
        priority: index >= firstVisibleIndex && index < firstVisibleIndex + 15
                  ? Thumbnail.NormalPriority
                  : Thumbnail.LowPriority
    }

}
