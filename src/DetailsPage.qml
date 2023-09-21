/****************************************************************************************
** Copyright (c) 2014 - 2023 Jolla Ltd.
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
import Nemo.FileManager 1.0
import QtDocGallery 5.0
import Sailfish.Gallery.private 1.0
import "private"

/*!
  \inqmlmodule Sailfish.Gallery
*/
Page {
    id: page

    property url source
    property bool isImage: true
    property alias itemType: itemModel.rootType

    allowedOrientations: Orientation.All

    // https://developer.gnome.org/ontology/stable/nmm-Flash.html
    property var flashValues: {
        'http://tracker.api.gnome.org/ontology/v3/nmm#flash-on':
        //% "Did fire"
        qsTrId("components_gallery-value-flash-on"),
        'http://tracker.api.gnome.org/ontology/v3/nmm#flash-off':
        //% "Did not fire"
        qsTrId("components_gallery-value-flash-off")
    }

    // https://developer.gnome.org/ontology/stable/nmm-MeteringMode.html
    property var meteringModeValues: {
        'http://tracker.api.gnome.org/ontology/v3/nmm#metering-mode-other':
        //% "Other"
        qsTrId("components_gallery-value-metering-mode-other"),
        'http://tracker.api.gnome.org/ontology/v3/nmm#metering-mode-partial':
        //% "Partial"
        qsTrId("components_gallery-value-metring-mode-partial"),
        'http://tracker.api.gnome.org/ontology/v3/nmm#metering-mode-pattern':
        //% "Pattern"
        qsTrId("components_gallery-value-metering-mode-pattern"),
        'http://tracker.api.gnome.org/ontology/v3/nmm#metering-mode-multispot':
        //% "Multispot"
        qsTrId("components_gallery-value-metering-mode-multispot"),
        'http://tracker.api.gnome.org/ontology/v3/nmm#metering-mode-spot':
        //% "Spot"
        qsTrId("components_gallery-value-metering-mode-spot"),
        'http://tracker.api.gnome.org/ontology/v3/nmm#metering-mode-center-weighted-average':
        //% "Center Weighted Average"
        qsTrId("components_gallery-value-metering-mode-center-weighted-average"),
        'http://tracker.api.gnome.org/ontology/v3/nmm#metering-mode-average':
        //% "Average"
        qsTrId("components_gallery-value-metering-mode-average")
    }

    // https://developer.gnome.org/ontology/stable/nmm-WhiteBalance.html
    property var whiteBalanceValues: {
        'http://tracker.api.gnome.org/ontology/v3/nmm#white-balance-manual':
        //% "Manual"
        qsTrId("components_gallery-value-white-balance-manual"),
        'http://tracker.api.gnome.org/ontology/v3/nmm#white-balance-auto':
        //% "Auto"
        qsTrId("components_gallery-value-white-balance-auto")
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: details.height

        Column {
            id: details

            width: parent.width

            Repeater {
                model: DocumentGalleryModel {
                    id: itemModel

                    rootType: page.isImage ? DocumentGallery.Image : DocumentGallery.Video
                    properties: [ 'filePath', 'fileSize', 'mimeType',
                                  // Image & Video common
                                  'width', 'height',
                                  // Media
                                  'duration',
                                  // Photo
                                  'dateTaken', 'cameraManufacturer', 'cameraModel', 'orientation',
                                  // exposureProgram is not supported by Tracker thus not enabled.
                                  // https://github.com/qtproject/qtdocgallery/blob/0b9ca223d4d5539ff09ce49a841fec4c24077830/src/gallery/qdocumentgallery.cpp#L799
                                  'exposureTime',
                                  'fNumber', 'flashEnabled', 'focalLength', 'meteringMode', 'whiteBalance',
                                  'latitude', 'longitude', 'altitude',
                                  'description', 'copyright', 'author'
                                ]
                    filter: GalleryEqualsFilter {
                        id: filter

                        property: 'url'
                        value: page.source
                    }
                }
                delegate: model.rootType === DocumentGallery.Image ? imageDetails : videoDetails
            }

            Component {
                id: imageDetails

                ImageDetailsItem {
                    filePathDetail.value: model.filePath
                    fileSizeDetail.value: Format.formatFileSize(model.fileSize)
                    typeDetail.value: model.mimeType
                    sizeDetail.value: {
                        if (model.orientation === 90 || model.orientation === 270) {
                            return formatDimensions(model.height, model.width)
                        } else {
                            return formatDimensions(model.width, model.height)
                        }
                    }

                    dateTakenDetail.value: model.dateTaken != ""
                            ? Format.formatDate(model.dateTaken, Format.Timepoint)
                            : ""
                    cameraManufacturerDetail.value: model.cameraManufacturer
                    cameraModelDetail.value: model.cameraModel
                    exposureTimeDetail.value: model.exposureTime
                    fNumberDetail.value: model.fNumber != ""
                            ? formatFNumber(model.fNumber)
                            : ""
                    flashEnabledDetail.value: model.flashEnabled != ""
                            ? flashValues[model.flashEnabled]
                            : ""
                    focalLengthDetail.value: model.focalLength != ""
                            ? formatFocalLength(model.focalLength)
                            : ""
                    meteringModeDetail.value: model.meteringMode != ""
                            ? meteringModeValues[model.meteringMode]
                            : ""
                    whiteBalanceDetail.value: model.whiteBalance != ""
                              ? whiteBalanceValues[model.whiteBalance]
                              : ""
                    gpsDetail.value: model.latitude != ""
                            ? formatGpsCoordinates(model.latitude,
                                                   model.longitude,
                                                   model.altitude)
                            : ""
                    descriptionDetail.value: model.description
                    copyrightDetail.value: model.copyright
                    authorDetail.value: model.author
                }
            }
            Component {
                id: videoDetails

                ImageDetailsItem {
                    filePathDetail.value: model.filePath
                    fileSizeDetail.value: Format.formatFileSize(model.fileSize)
                    typeDetail.value: model.mimeType
                    sizeDetail.value: formatDimensions(model.width, model.height)

                    durationDetail.value: Format.formatDuration(model.duration, Formatter.DurationLong)

                }
            }

            // Limited fallback for when tracker has no entry for a file.
            Loader {
                width: parent.width
                active: itemModel.status === DocumentGalleryModel.Error
                        || (itemModel.status === DocumentGalleryModel.Finished && itemModel.count == 0)

                sourceComponent: ImageDetailsItem {
                    filePathDetail.value: fileInfo.file
                    fileSizeDetail.value: Format.formatFileSize(fileInfo.size)
                    typeDetail.value: fileInfo.mimeType
                    sizeDetail.value: {
                        if (metadata.valid) {
                            if (metadata.orientation === 90 || metadata.orientation === 270) {
                                formatDimensions(metadata.height, metadata.width)
                            } else {
                                formatDimensions(metadata.width, metadata.height)
                            }
                        } else {
                            return ""
                        }
                    }
                    FileInfo {
                        id: fileInfo

                        url: page.source
                    }

                    ImageMetadata {
                        id: metadata

                        source: page.source
                    }
                }
            }
        }

        VerticalScrollDecorator { }
    }
}
