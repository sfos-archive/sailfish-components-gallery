# The only purpose of this subproject is invocation of qmlplugindump. All other
# stuff should go to the parent project.

TEMPLATE = aux

# Invoke directly to deal with circular dependency with silica submodules - keep
# just the Sailfish.Silica.private dependency to break the cycle.
qtPrepareTool(QMLIMPORTSCANNER, qmlimportscanner)
qmltypes.commands = \
    echo -e $$shell_quote('import Sailfish.Gallery.private 1.0\nQtObject{}\n') \
        |$$QMLIMPORTSCANNER -qmlFiles - -importPath $$[QT_INSTALL_QML] \
        |sed -e $$shell_quote('/"Sailfish.Silica"/,/{/d') \
        |sed -e $$shell_quote('/"Sailfish.Silica.Background"/,/{/d') > dependencies.json && \
    qmlplugindump -noinstantiate -nonrelocatable -dependencies dependencies.json \
        Sailfish.Gallery.private 1.0 > $$PWD/plugins.qmltypes
QMAKE_EXTRA_TARGETS += qmltypes
