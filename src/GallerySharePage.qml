import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.TransferEngine 1.0

Page {
    id: page

    property alias source: shareMethodList.source
    property alias mimeType: shareMethodList.filter
    property alias content: shareMethodList.content

    ShareMethodList {
        id: shareMethodList

        height: parent.height
        header: PageHeader {
            //: Page header for share method selection
            //% "Share"
            title: qsTrId("components_gallery-he-share")
        }
        serviceFilter: ["sharing", "e-mail"]
        containerPage: page
    }
}
