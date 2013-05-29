#include <QQmlExtensionPlugin>
#include <QQmlEngine>

class SailfishGalleryPlugin : public QQmlExtensionPlugin
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID "org.sailfish.components.gallery")

public:

    virtual void registerTypes(const char *uri)
    {
        Q_UNUSED(uri)
        Q_ASSERT(QLatin1String(uri) == QLatin1String("Sailfish.Gallery"));
        // TODO: Add gallery specific types here
    }
};

#include "plugin.moc"

