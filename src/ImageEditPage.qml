/****************************************************************************
**
** Copyright (C) 2013 Jolla Ltd.
** Contact: Raine Mäkeläinen <raine.makelainen@jollamobile.com>
**
****************************************************************************/

import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Contacts 1.0
import Sailfish.Gallery.private 1.0
import "private"

SplitViewPage {
    id: imageEditor

    property alias source: imageEditPreview.source
    property alias target: imageEditPreview.target
    // To align this with SplitViewDialog
    property alias splitOpen: imageEditor.open
    property alias splitOpened: imageEditor.opened
    // TODO: Remove orientation, it won't be used anymore but it's needed
    // to prevent this QML element loading to fail.
    property int orientation

    property Page _contactPicker
    property bool _contactSaveRequested

    signal edited

    function _pageActivating() {
        imageEditor.foreground = imageEditPreview
        imageEditPreview.resetParent(imageEditor.foregroundItem)
        imageEditPreview.splitView = imageEditor
        imageEditPreview.editOperation = ImageEditor.None
        splitOpen = true
    }

    onStatusChanged: {
        if (status == PageStatus.Activating) {
            _pageActivating()
        }
    }

    onEdited: {
        if (_contactSaveRequested) {
            _contactPicker.allContactsModel.savePerson(_contactPicker.unsavedContact)
        }
    }

    // Clip zoomed part of the image
    clip: true
    background: SilicaListView {
        anchors.fill: parent
        header: PageHeader {
            //: "Image editing page title"
            //% "Edit"
            title: qsTrId("components_gallery-he-edit")
        }

        delegate: BackgroundItem {
            id: operationDelegate

            enabled: !imageEditPreview.editInProgress

            IconButton {
                id: icon
                x: Theme.paddingLarge
                icon.source: model.icon
                icon.opacity: 1.0
                down: operationDelegate.highlighted
                enabled: false
                anchors.verticalCenter: parent.verticalCenter
            }

            Label {
                color: highlighted ? Theme.highlightColor : Theme.primaryColor
                text: model.text
                anchors {
                    left: icon.right
                    right: parent.right
                    rightMargin: Theme.paddingLarge
                    verticalCenter: parent.verticalCenter
                }
            }

            onClicked: {
                if (model.type === ImageEditor.Crop) {
                    imageEditPreview.splitView = pageStack.push(aspectRatioDialogComponent,
                                                                { splitOpen: false })
                    imageEditPreview.editOperation = model.type
                    imageEditPreview.resetParent(imageEditPreview.splitView.foregroundItem)
                } else
                if (model.type === ImageEditor.Rotate) {
                    imageEditPreview.splitView = pageStack.push(rotateDialogComponent,
                                                                { splitOpen: true })
                    imageEditPreview.editOperation = model.type
                    imageEditPreview.resetParent(imageEditPreview.splitView.foregroundItem)
                }
            }
        }

        model: ImageEditOperationModel {}
    }

    // Shared between ImageEditPage and CropDialog so that state
    // of zoom is correct.
    foreground: ImageEditPreview {
        id: imageEditPreview

        function resetParent(parentItem) {
            parent = null
            parent = parentItem
        }

        isPortrait: splitView.isPortrait
        splitView: imageEditor
        anchors.fill: parent
        active: pageStack.currentPage === imageEditor ? false : !splitView.splitOpen
        explicitWidth: imageEditor.width
        explicitHeight: imageEditor.height
    }

    Binding {
        target: pageStack._pageStackIndicator
        property: "enabled"
        value: imageEditor.splitOpened
        when: imageEditor.status === PageStatus.Activating || imageEditor.status === PageStatus.Active
    }

    Component {
        id: aspectRatioDialogComponent
        CropDialog {
            // Prepare acceptDestionation for contact picking
            function prepareAcceptDestination() {
                if (imageEditPreview.aspectRatioType == "avatar") {
                    if (!_contactPicker) {
                        _contactPicker = contactPickerPage.createObject(imageEditor)
                    }
                    acceptDestinationAction = PageStackAction.Push
                    acceptDestination = _contactPicker
                    _contactSaveRequested = false
                } else {
                    acceptDestinationAction = PageStackAction.Pop
                    acceptDestination = undefined
                }
            }

            allowedOrientations: imageEditor.allowedOrientations
            foreground: imageEditPreview
            onEdited: imageEditor.edited()
            onSplitOpenedChanged: {
                if (!splitOpened) {
                    prepareAcceptDestination()
                }
            }

            onCropRequested: {
                if (imageEditPreview.aspectRatioType != "avatar") {
                    // Reset back to empty
                    imageEditPreview.target = ""
                    imageEditPreview.crop()
                }
                // For avatars crop will be triggered when contact selected
            }

            onCropCanceled: {
                imageEditPreview.resetScale()
            }

            Component.onCompleted: prepareAcceptDestination()
        }
    }

    Component {
        id: rotateDialogComponent
        RotateDialog {
            id: rotateDialog
            foreground: imageEditPreview

            onRotate: {
                // Rotate in steps, but not when there's an ongoing transition
                if (imageEditPreview.previewRotation % 90 == 0) {
                    imageEditPreview.previewRotation = imageEditPreview.previewRotation + angle
                }
            }

            onRotateRequested: {
                imageEditPreview.target = ""
                imageEditPreview.rotateImage()
            }

            onRotateCanceled: {
                imageEditPreview.previewRotation = 0
            }
        }
    }


    Component {
        id: contactPickerPage

        ContactSelectPage {
            property variant unsavedContact

            onContactClicked: {
                // Hardcoded path will be removed once get JB5266 fixed
                imageEditPreview.target = "/home/nemo/.local/share/data/avatars/" + contact.firstName + "-" + contact.lastName + ".jpeg"
                imageEditPreview.crop()
                _contactSaveRequested = true
                unsavedContact = contact
                unsavedContact.avatarPath = imageEditPreview.target
                // Do all needed page activation states before popping pages
                imageEditor._pageActivating()
                _navigation = PageNavigation.Forward
                pageStack.pop(imageEditor)
            }
        }
    }
}
