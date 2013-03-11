import QtQuick 1.1
import Sailfish.Silica 1.0

Page {
    id: root

    property variant contentItem
    property bool splitActive

    property real _progress: splitActive ? 1.0 : 0.0
    property Item _content

    function toggleSplit()
    {
        if (splitActive) {
            // First animate split to fullscreen and then hide the children
            splitActive = !splitActive
        } else {
            // Make sure that all the children are visible before splitting the view
            _setChildrenVisibility(!splitActive)
            splitActive = !splitActive
        }
    }

    function _setChildrenVisibility(visible)
    {
        // Iterate children to make them visible
        for (var i=0; i < children.length; i++) {
            if (children[i] === _content ||
                children[i] === container ||
                children[i] === bgFade) {
                continue;
            }

            children[i].visible = visible
        }
    }

    backNavigation: splitActive

    Behavior on _progress {
        id: menuProgressBehavior
        NumberAnimation { duration: 200; easing.type: Easing.InOutQuad; onRunningChanged: if(!running && !root.splitActive) _setChildrenVisibility(false) }
    }

    onStatusChanged: {
        if (status === PageStatus.Inactive) {
            splitActive = false
        }
    }

    // Toggle off the split mode if application goes to the background
    Connections {
        target: Qt.application
        onActiveChanged: if (Qt.application.active) splitActive = false
    }

    Component.onCompleted: {
        if (!contentItem)
            return;

        var component
        if (contentItem.createObject) {
            // component
            component = contentItem
        } else if (typeof contentItem === "string") {
            // url
            component = Qt.createComponent(contentItem)
        } else {
            // ready component
            _content = contentItem
            _content.parent = container
        }

        if (component) {
            if (component.status === Component.Error) {
                throw new Error("Error while loading SplitView's contentItem: " + component.errorString());
            } else {
                _content = component.createObject(container)
            }
        }

        _content.anchors.fill = container
        _setChildrenVisibility(false)
    }

    onChildrenChanged: {
        // Make sure that our container hides the pulley menu or other children too
        for (var i=0;i<children.length;i++) {
            if (container.z <= children[i].z) {
                container.z = children[i].z + 1
            }
        }
    }

    // Fade out the background image so it isn't visually conflicting
    Rectangle {
        id: bgFade
        anchors.fill: parent
        opacity: root.splitActive ? 0 : 0.5
        color: theme.highlightDimmerColor
        Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }}
    }

    Item {
        id: container
        clip: root.splitActive ? true : false

        anchors {
            fill: parent
            leftMargin: isPortrait ? 0 : _progress * root.width / 2
            topMargin: isPortrait ? _progress * root.height / 2 : 0
        }
    }
}
