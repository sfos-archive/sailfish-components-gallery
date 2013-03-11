import QtQuick 1.1

ListModel {
    function update(contentItem) {
        var row = _indexInModel(contentItem)
        if (row >= 0) {
            remove(row)
            return false
        }

        append(contentItem)
        return true
    }

    function selected(url) {
        for (var row = 0; row < count; row++) {
            if (get(row).url === url) {
                return true
            }
        }
        return false
    }

    function _indexInModel(contentItem) {
        for (var row = 0; row < count; row++) {
            if (get(row).url === contentItem.url) {
                return row
            }
        }
        return -1
    }
}
