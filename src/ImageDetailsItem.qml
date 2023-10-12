/****************************************************************************************
** Copyright (c) 2019 - 2023 Jolla Ltd.
**
** All rights reserved.
**
** This file is part of Sailfish Gallery components package.
**
** You may use this file under the terms of BSD license as follows:
**
** Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions are met:
**
** 1. Redistributions of source code must retain the above copyright notice, this
**    list of conditions and the following disclaimer.
**
** 2. Redistributions in binary form must reproduce the above copyright notice,
**    this list of conditions and the following disclaimer in the documentation
**    and/or other materials provided with the distribution.
**
** 3. Neither the name of the copyright holder nor the names of its
**    contributors may be used to endorse or promote products derived from
**    this software without specific prior written permission.
**
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
** AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
** IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
** DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
** FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
** DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
** SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
** CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
** OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
** OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**
****************************************************************************************/

import QtQuick 2.6
import Sailfish.Silica 1.0

/*!
  \inqmlmodule Sailfish.Gallery
*/
Column {
    property alias filePathDetail: filePathItem
    property alias fileSizeDetail: fileSizeItem
    property alias typeDetail: typeItem
    property alias sizeDetail: sizeItem
    property alias dateTakenDetail: dateTakenItem
    property alias cameraManufacturerDetail: cameraManufacturerItem
    property alias cameraModelDetail: cameraModelItem
    property alias exposureTimeDetail: exposureTimeItem
    property alias fNumberDetail: fNumberItem
    property alias flashEnabledDetail: flashEnabledItem
    property alias focalLengthDetail: focalLengthItem
    property alias meteringModeDetail: meteringModeItem
    property alias whiteBalanceDetail: whiteBalanceItem
    property alias gpsDetail: gpsItem
    property alias durationDetail: durationItem
    property alias descriptionDetail: descriptionItem
    property alias copyrightDetail: copyrightItem
    property alias authorDetail: authorItem

    function formatDimensions(w, h) {
        //: Pattern for image resolution, width x height
        //% "%1 × %2"
        return qsTrId("components_gallery-size_format").arg(w).arg(h)
    }

    function formatFNumber(fNumber) {
        //: Camera aperture value
        //% "f/%1"
        return qsTrId("components_gallery-value-fnumber").arg(fNumber)
    }

    function formatFocalLength(focalLength) {
        //: Camera focal length in millimeters
        //% "%1 mm"
        return qsTrId("components_gallery-value-focal-length").arg(focalLength)
    }

    function formatGpsCoordinates(latitude, longitude, altitude) {
        //: GPS coordinates
        //% "Latitude %1 - Longitude %2 - Altitude %3"
        return qsTrId("components_gallery-value-gps")
                .arg(latitude)
                .arg(longitude)
                .arg(altitude)
    }

    width: parent.width
    bottomPadding: Theme.paddingLarge

    PageHeader {
        //% "Details"
        title: qsTrId("components_gallery-he-details")
    }
    DetailItem {
        id: filePathItem
        //% "File path"
        label: qsTrId("components_gallery-la-file_path")
        alignment: Qt.AlignLeft
    }
    DetailItem {
        id: fileSizeItem
        //% "File size"
        label: qsTrId("components_gallery-la-file_size")
        alignment: Qt.AlignLeft
    }
    DetailItem {
        id: typeItem
        //% "Type"
        label: qsTrId("components_gallery-la-type")
        alignment: Qt.AlignLeft
    }
    DetailItem {
        id: sizeItem
        //% "Size"
        label: qsTrId("components_gallery-la-size")
        alignment: Qt.AlignLeft
    }
    DetailItem {
        id: dateTakenItem
        //% "Date Taken"
        label: qsTrId("components_gallery-la-date-taken")
        visible: value.length > 0
        alignment: Qt.AlignLeft
    }
    DetailItem {
        id: gpsItem
        //% "GPS"
        label: qsTrId("components_gallery-la-gps")
        visible: value.length > 0
        alignment: Qt.AlignLeft
    }
    DetailItem {
        id: durationItem
        //% "Duration"
        label: qsTrId("components_gallery-la-duration")
        visible: value.length > 0
        alignment: Qt.AlignLeft
    }
    DetailItem {
        id: descriptionItem
        //% "Description"
        label: qsTrId("components_gallery-la-description")
        visible: value.length > 0
        alignment: Qt.AlignLeft
    }
    DetailItem {
        id: copyrightItem
        //% "Copyright"
        label: qsTrId("components_gallery-la-copyright")
        visible: value.length > 0
        alignment: Qt.AlignLeft
    }
    DetailItem {
        id: authorItem
        //% "Author"
        label: qsTrId("components_gallery-la-author")
        visible: value.length > 0
        alignment: Qt.AlignLeft
    }

    SectionHeader {
        //% "Camera info"
        text: qsTrId("components_gallery-la-camera_info")
        visible: cameraManufacturerItem.visible
                 || cameraModelItem.visible
                 || exposureTimeItem.visible
                 || fNumberItem.visible
                 || flashEnabledItem.visible
                 || focalLengthItem.visible
                 || meteringModeItem.visible
                 || whiteBalanceItem.visible
    }

    DetailItem {
        id: cameraManufacturerItem
        //% "Camera Manufacturer"
        label: qsTrId("components_gallery-la-camera-manufacturer")
        visible: value.length > 0
        alignment: Qt.AlignLeft
    }
    DetailItem {
        id: cameraModelItem
        //% "Camera Model"
        label: qsTrId("components_gallery-la-camera-model")
        visible: value.length > 0
        alignment: Qt.AlignLeft
    }
    DetailItem {
        id: exposureTimeItem
        //% "Exposure Time"
        label: qsTrId("components_gallery-la-exposure-time")
        visible: value.length > 0 && value != "0"
        alignment: Qt.AlignLeft
    }
    DetailItem {
        id: fNumberItem
        //% "Aperture"
        label: qsTrId("components_gallery-la-aperture")
        visible: value.length > 0
        alignment: Qt.AlignLeft
    }
    DetailItem {
        id: flashEnabledItem
        //% "Flash"
        label: qsTrId("components_gallery-la-flash-enabled")
        visible: value.length > 0
        alignment: Qt.AlignLeft
    }
    DetailItem {
        id: focalLengthItem
        //% "Focal Length"
        label: qsTrId("components_gallery-la-focal-length")
        visible: value.length > 0
        alignment: Qt.AlignLeft
    }
    DetailItem {
        id: meteringModeItem
        //% "Metering Mode"
        label: qsTrId("components_gallery-la-metering-mode")
        visible: value.length > 0
        alignment: Qt.AlignLeft
    }
    DetailItem {
        id: whiteBalanceItem
        //% "White Balance"
        label: qsTrId("components_gallery-la-white-balance")
        visible: value.length > 0
        alignment: Qt.AlignLeft
    }
}
