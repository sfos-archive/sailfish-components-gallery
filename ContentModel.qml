import QtQuick 1.1
import QtMobility.gallery 1.1
import com.jolla.components.gallery 1.0

QtObject {
    id: contentModel

    property string filter
    property ListModel model: ListModel {}
    property int contentType: ContentType.InvalidType
    property string contentPath
    property alias rootType: galleryModel.rootType
    property alias properties: galleryModel.properties
    property alias sortProperties: galleryModel.sortProperties
    property ListModel selectedModel

    onFilterChanged: _update()

    function updateSelected(index, selected) {
        if (index >= 0 && index < model.count) {
            model.setProperty(index, "selected", selected)
            if (selectedModel) {
                selectedModel.update(model.get(index))
            }
        }
    }

    function get(index) {
        return model.get(index)
    }

    function count() {
        return model.count
    }

    function _update() {
        var filteredContent = _contentQuery(contentModel._filter)
        var filteredContentLen = filteredContent.length
        var modelCount = model.count
        while (modelCount > filteredContentLen) {
            model.remove(modelCount - 1)
            --modelCount
        }
        for (var index = 0; index < filteredContent.length; index++) {
            if (index < model.count) {
                for (var propIndex in contentModel.properties) {
                    var prop = contentModel.properties[propIndex]
                    model.setProperty(index, prop, filteredContent[index][prop])
                }
            } else {
                model.append(filteredContent[index])
            }
        }
    }

    function _filter(contentItem) {
        return contentItem.fileName.toLowerCase().indexOf(filter) !== -1
    }

    function _contentQuery(filterFunction) {
        var len = _documentGalleryModel.count;
        var filteredContent = [];
        for (var i = 0; i < len; ++i) {
            var contentItem = _documentGalleryModel.get(i)
            if (filterFunction(contentItem)) {
                var selected = false
                if (selectedModel) {
                    selected = selectedModel.selected(contentItem.url)
                }

                contentItem["selected"] = selected
                contentItem["contentType"] = contentModel.contentType
                filteredContent.push(contentItem)
            }
        }
        return filteredContent
    }

    property QtObject _documentGalleryModel: DocumentGalleryModel {
        id: galleryModel

        property bool ready

        //rootType: contentModel.rootType
        //properties: contentModel.properties
        //sortProperties: contentModel.sortProperties
        filter: GalleryStartsWithFilter { property: "filePath"; value: contentModel.contentPath }
        onCountChanged: {
            if (ready) {
                _update()
            }
        }

        Component.onCompleted: {
            _update()
            ready = true
        }
    }
}
