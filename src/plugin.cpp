#include <qdeclarative.h>
#include <QDeclarativeExtensionPlugin>
#include <QDeclarativeEngine>

class SailfishGalleryPlugin : public QDeclarativeExtensionPlugin
{
    Q_OBJECT

public:

    virtual void registerTypes(const char *uri)
    {
        Q_UNUSED(uri)
        Q_ASSERT(QLatin1String(uri) == QLatin1String("Sailfish.Gallery"));
        // TODO: Add gallery specific types here
    }
};

#include "plugin.moc"

Q_EXPORT_PLUGIN2(sailfishgalleryplugin, SailfishGalleryPlugin);

