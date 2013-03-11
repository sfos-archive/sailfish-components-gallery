TEMPLATE = lib
TARGET = jollacomponentsgalleryplugin
TARGET = $$qtLibraryTarget($$TARGET)

MODULENAME = com/jolla/components/gallery
TARGETPATH = $$[QT_INSTALL_IMPORTS]/$$MODULENAME

QT += declarative
CONFIG += plugin


import.files = *.qml qmldir scripts
import.path = $$TARGETPATH
target.path = $$TARGETPATH

OTHER_FILES += *.qml

HEADERS += \
    declarativecontenttype.h


SOURCES += \
    plugin.cpp

INSTALLS += import target
