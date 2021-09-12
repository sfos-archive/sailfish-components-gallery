TEMPLATE = subdirs
SUBDIRS = tst_imageeditor

OTHER_FILES += auto/*.qml auto/*.js

check.commands += cd auto && qmltestrunner
QMAKE_EXTRA_TARGETS += check
