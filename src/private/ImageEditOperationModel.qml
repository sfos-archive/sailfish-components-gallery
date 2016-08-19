/****************************************************************************
**
** Copyright (C) 2013 Jolla Ltd.
** Contact: Raine Mäkeläinen <raine.makelainen@jollamobile.com>
**
****************************************************************************/

import QtQuick 2.0
import Sailfish.Gallery.private 1.0

ListModel {
    function _operation(index) {
        if (_operation["list"] === undefined) {
            _operation.list = [

                        {
                            //: Rotate the image edit operations
                            //% "Rotate"
                            text: qsTrId("components_gallery-li-rotate"),
                            type: ImageEditor.Rotate,
                            icon: "image://theme/icon-m-rotate"
                        },
                        {
                            //: Crop the image. This opens separete cropping view
                            //% "Crop"
                            text: qsTrId("components_gallery-li-crop"),
                            type: ImageEditor.Crop,
                            icon: "image://theme/icon-m-crop"
                        },
                        {
                            //: Adjust the brightness and contrast
                            //% "Adjust Levels"
                            text: qsTrId("components_gallery-li-levels"),
                            type: ImageEditor.AdjustLevels,
                            // TODO: needs a real icon
                            icon: "image://theme/icon-m-shuffle"
                        }
                    ]
        }
        return _operation.list[index]
    }

    Component.onCompleted: {
        var index = 0
        for (; index < 3; ++index) {
            append(_operation(index))
        }
    }
}
