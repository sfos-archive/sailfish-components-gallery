import QtQuick 2.0
import Sailfish.Silica 1.0
import QtDocGallery 5.0
import "private"

Page {
    id: detailsPage
    property alias modelItem: galleryItem.item

    allowedOrientations: Orientation.All

    DocumentGalleryItem {
        id: galleryItem
        autoUpdate: false
        properties: [ 'fileName', 'fileSize', 'mimeType', 'width', 'height', 'duration' ]

        onStatusChanged: {
            if (status == DocumentGalleryItem.Finished) {
                nameItem.value = galleryItem.metaData.fileName
                sizeItem.value = Format.formatFileSize(galleryItem.metaData.fileSize)
                typeItem.value = galleryItem.metaData.mimeType
                widthItem.value = galleryItem.metaData.width
                heightItem.value = galleryItem.metaData.height

                if (itemType == DocumentGallery.Video) {
                    durationItem.value = Format.formatDuration(galleryItem.metaData.duration, Formatter.DurationLong)
                }
            }
        }
    }
    SilicaListView {
        anchors.fill: parent
        header: PageHeader {
            //% "Details"
            title: qsTrId("components_gallery-he-details")
        }
        model: VisualItemModel {
            GalleryDetailsItem {
                id: nameItem
                //% "Filename"
                detail: qsTrId("components_gallery-la-filename")
            }
            GalleryDetailsItem {
                id: sizeItem
                //% "Size"
                detail: qsTrId("components_gallery-la-size")
            }
            GalleryDetailsItem {
                id: typeItem
                //% "Type"
                detail: qsTrId("components_gallery-la-type")
            }
            GalleryDetailsItem {
                id: widthItem
                //% "Width"
                detail: qsTrId("components_gallery-la-width")
            }
            GalleryDetailsItem {
                id: heightItem
                //% "Height"
                detail: qsTrId("components_gallery-la-height")
            }
            GalleryDetailsItem {
                id: durationItem
                //% "Duration"
                detail: qsTrId("components_gallery-la-duration")
                visible: value.length > 0
            }
        }

        VerticalScrollDecorator { }
    }
}
