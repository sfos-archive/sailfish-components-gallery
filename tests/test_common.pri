TEMPLATE = app
QT += declarative testlib

MODULENAME = Sailfish/Gallery
DEFINES *= MODULENAME=\"\\\"\"$${MODULENAME}\"\\\"\"

DEFINES += COMPONENTDIR=\\\"$$[QT_INSTALL_IMPORTS]/$$MODULENAME\\\"

contains(CONFIG, desktop) {
    DEFINES += APPLICATIONDIR=\\\"$$PWD/../../applications/\\\"
} else {
    DEFINES += APPLICATIONDIR=\\\"/usr/share/\\\"

    # install the test
    target.path = /opt/tests/sailfish-components-gallery
    INSTALLS += target
}
