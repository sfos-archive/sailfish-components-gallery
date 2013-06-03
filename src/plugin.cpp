#include <QApplication>
#include <qdeclarative.h>
#include <QDeclarativeExtensionPlugin>
#include <QDeclarativeEngine>
#include <QTranslator>
#include "declarativeimageeditor.h"

// using custom translator so it gets properly removed from qApp when engine is deleted
class AppTranslator: public QTranslator
{
    Q_OBJECT
public:
    AppTranslator(QObject *parent)
        : QTranslator(parent)
    {
        qApp->installTranslator(this);
    }

    virtual ~AppTranslator()
    {
        qApp->removeTranslator(this);
    }
};

class SailfishGalleryPlugin : public QDeclarativeExtensionPlugin
{
    Q_OBJECT

public:

    void initializeEngine(QDeclarativeEngine *engine, const char *uri)
    {
        Q_UNUSED(uri)
        Q_ASSERT(QLatin1String(uri) == QLatin1String("Sailfish.Gallery"));

        AppTranslator *engineeringEnglish = new AppTranslator(engine);
        AppTranslator *translator = new AppTranslator(engine);
        engineeringEnglish->load("sailfish_components_gallery_eng_en", "/usr/share/translations");
        translator->load(QLocale(), "sailfish_components_gallery", "-", "/usr/share/translations");
    }

    virtual void registerTypes(const char *uri)
    {
        Q_ASSERT(QLatin1String(uri) == QLatin1String("Sailfish.Gallery"));
        qmlRegisterType<DeclarativeImageEditor>("Sailfish.Gallery.private", 1, 0, "ImageEditor");
    }
};

#include "plugin.moc"

Q_EXPORT_PLUGIN2(sailfishgalleryplugin, SailfishGalleryPlugin);
