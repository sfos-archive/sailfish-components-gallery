TEMPLATE = subdirs

OTHER_FILES += auto/*.qml

check.commands += cd auto && qmltestrunner
QMAKE_EXTRA_TARGETS += check
