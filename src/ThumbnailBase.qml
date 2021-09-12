import QtQuick 2.0
import Sailfish.Silica 1.0

GridItem {
    id: thumbnail

    property url source
    property string mimeType: model && model.mimeType ? model.mimeType : ""
    width: GridView.view.cellSize
    contentHeight: GridView.view.cellSize
}
