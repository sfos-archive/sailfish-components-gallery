#include <QQmlExtensionPlugin>
#include <QQmlEngine>
#include <QGuiApplication>
#include <QTranslator>
#include "declarativeimageeditor.h"
#include "declarativeimagemetadata.h"
#include "declarativeavatarfilehandler.h"
#include "declarativefileinfo.h"

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


class FitNamespace : public QObject
{
    Q_OBJECT
    Q_ENUMS(Fit)
public:
    enum Fit {
        Width,
        Height
    };
};

class SailfishGalleryPlugin : public QQmlExtensionPlugin
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID "org.sailfish.components.gallery")

public:

    void initializeEngine(QQmlEngine *engine, const char *uri)
    {
        if (QLatin1String(uri) != QLatin1String("Sailfish.Gallery")) {
            return;
        }

        AppTranslator *engineeringEnglish = new AppTranslator(engine);
        AppTranslator *translator = new AppTranslator(engine);
        AppTranslator *galleryTranslator = new AppTranslator(engine);
        engineeringEnglish->load("sailfish_components_gallery_qt5_eng_en", "/usr/share/translations");
        translator->load(QLocale(), "sailfish_components_gallery_qt5", "-", "/usr/share/translations");
        galleryTranslator->load(QLocale(), "gallery", "-", "/usr/share/translations");
    }

    virtual void registerTypes(const char *uri)
    {
        if (QLatin1String(uri) == QLatin1String("Sailfish.Gallery")) {
            qmlRegisterType<DeclarativeFileInfo>("Sailfish.Gallery", 1, 0, "FileInfo");
            qmlRegisterUncreatableType<FitNamespace>("Sailfish.Gallery", 1, 0, "Fit", QString());
        } else if (QLatin1String(uri) == QLatin1String("Sailfish.Gallery.private")) {
            qmlRegisterType<DeclarativeImageEditor>("Sailfish.Gallery.private", 1, 0, "ImageEditor");
            qmlRegisterType<DeclarativeImageMetadata>("Sailfish.Gallery.private", 1, 0, "ImageMetadata");
            qmlRegisterSingletonType<DeclarativeAvatarFileHandler>("Sailfish.Gallery.private", 1, 0, "AvatarFileHandler", DeclarativeAvatarFileHandler::api_factory);
        }
    }
};

#include "plugin.moc"

