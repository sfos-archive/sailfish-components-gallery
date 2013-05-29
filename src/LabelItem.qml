/****************************************************************************
**
** Copyright (C) 2013 Jolla Ltd.
** Contact: Raine Mäkeläinen <raine.makelainen@jollamobile.com>
**
****************************************************************************/

import QtQuick 1.1
import Sailfish.Silica 1.0

BackgroundItem {
    id: backgroundItem

    property alias text: label.text
    property alias sectionLabel: section.text
    property bool selected

    _showPress: false

    HighlightItem {
        anchors.fill: parent
        highlightOpacity: theme.highlightBackgroundOpacity
        active: highlighted
    }

    Label {
        id: label

        color: selected || highlighted ? theme.highlightColor : theme.primaryColor
        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            leftMargin: theme.paddingLarge
            right: section.left
            rightMargin: theme.paddingSmall
        }
    }

    Label {
        id: section

        visible: selected
        color: selected || highlighted ? theme.highlightColor : theme.primaryColor
        anchors {
            verticalCenter: parent.verticalCenter
            right: parent.right
            rightMargin: theme.paddingLarge
        }
    }
}
