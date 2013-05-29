TEMPLATE = lib
TARGET = sailfishgalleryplugin
TARGET = $$qtLibraryTarget($$TARGET)

MODULENAME = Sailfish/Gallery
TARGETPATH = $$[QT_INSTALL_QML]/$$MODULENAME

QT += qml quick
CONFIG += plugin

import.files = *.qml qmldir scripts
import.path = $$TARGETPATH
target.path = $$TARGETPATH

OTHER_FILES += *.qml \
    ThumbnailBase.qml \
    ThumbnailCustom.qml


SOURCES += \
    plugin.cpp

INSTALLS += import target
