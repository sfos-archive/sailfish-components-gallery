import QtQuick 2.0
import Sailfish.Silica 1.0

Rectangle {
    id: root

    property bool active
    property string type: "original"
    property real ratio: -1

    property Item _highlightedItem
    property Item _selectedItem: repeater.itemAt(1)

    signal selected
    signal canceled

    onActiveChanged: if (active) highlightBar.highlight(_selectedItem, contentColumn)

    anchors.fill: parent
    color: Theme.colorScheme == Theme.LightOnDark ? Theme.rgba(Theme.highlightDimmerColor, 0.8)
                                                  : Theme.rgba(Theme.lightPrimaryColor, 0.8)

    MouseArea {
        enabled: root.active
        anchors.fill: parent

        onPressed: updateHighlight(mouse.y)
        onPositionChanged: updateHighlight(mouse.y)
        onReleased: {
            updateHighlight(mouse.y)
            if (_highlightedItem) {
                _highlightedItem.clicked()
                _selectedItem = _highlightedItem
            } else {
                root.canceled()
            }

            clearHighlight()
        }

        onCanceled: {
            clearHighlight()
            root.canceled()
        }

        function updateHighlight(yPos) {
            var pos = mapToItem(contentColumn, width/2, yPos)
            var child = contentColumn.childAt(pos.x, pos.y)
            if (child !== _highlightedItem) {
                if (_highlightedItem) {
                    _highlightedItem.down = false
                }
                _highlightedItem = child
                if (_highlightedItem) {
                    highlightBar.highlight(_highlightedItem, contentColumn)
                    _highlightedItem.down = true
                } else {
                    highlightBar.clearHighlight()
                }
            }
        }
        function clearHighlight() {
            if (_highlightedItem) {
                highlightBar.clearHighlight()
                _highlightedItem.down = false
                _highlightedItem = null
            }
        }
    }
    HighlightBar { id: highlightBar }
    Column {
        id: contentColumn
        width: parent.width
        anchors.verticalCenter: parent.verticalCenter

        Repeater {
            id: repeater
            model: AspectRatioModel {}
            MenuItem {
                text: model.text
                onClicked: {
                    root.type = model.type
                    root.ratio = model.ratio
                    root.selected()
                }
            }
        }
    }
}
