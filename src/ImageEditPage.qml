/****************************************************************************
**
** Copyright (C) 2013 Jolla Ltd.
** Contact: Raine Mäkeläinen <raine.makelainen@jollamobile.com>
**
****************************************************************************/

import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Contacts 1.0
import "private"

SplitViewPage {
    id: imageEditor

    property alias source: cropView.source
    property alias target: cropView.target
    property alias cropping: cropView.cropping
    // To align this with SplitViewDialog
    property alias splitOpen: imageEditor.open
    property alias splitOpened: imageEditor.opened

    property alias orientation: cropView.orientation

    property Page _contactPicker
    property bool _contactSaveRequested

    signal edited

    function _pageActivating() {
        imageEditor.foreground = cropView
        cropView.resetParent(imageEditor.foregroundItem)
        cropView.splitView = imageEditor
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
                if (model.type === "crop") {
                    cropView.splitView = pageStack.push(aspectRatioDialogComponent, {splitOpen: false})
                    cropView.resetParent(cropView.splitView.foregroundItem)
                }
            }
        }

        model: ImageEditOperationModel {}
    }

    // Shared between ImageEditPage and CropDialog so that state
    // of zoom is correct.
    foreground: CropView {
        id: cropView

        function resetParent(parentItem) {
            parent = null
            parent = parentItem
        }

        isPortrait: splitView.isPortrait
        splitView: imageEditor
        anchors.fill: parent
        showTitle: !splitView.splitOpen
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
                if (cropView.aspectRatioType == "avatar") {
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
            foreground: cropView
            onEdited: imageEditor.edited()
            onSplitOpenedChanged: {
                if (!splitOpened) {
                    prepareAcceptDestination()
                }
            }

            onCropRequested: {
                if (cropView.aspectRatioType != "avatar") {
                    // Reset back to empty
                    cropView.target = ""
                    cropView.crop()
                }
                // For avatars crop will be triggered when contact selected
            }

            Component.onCompleted: prepareAcceptDestination()
        }
    }

    Component {
        id: contactPickerPage

        ContactSelectPage {
            property variant unsavedContact

            onContactClicked: {
                // Hardcoded path will be removed once get JB5266 fixed
                cropView.target = "/home/nemo/.local/share/data/avatars/" + contact.firstName + "-" + contact.lastName + ".png"
                cropView.crop()
                _contactSaveRequested = true
                unsavedContact = contact
                unsavedContact.avatarPath = cropView.target
                // Do all needed page activation states before popping pages
                imageEditor._pageActivating()
                _navigation = PageNavigation.Forward
                pageStack.pop(imageEditor)
            }
        }
    }
}
