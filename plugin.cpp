#include <qdeclarative.h>
#include <QDeclarativeExtensionPlugin>
#include <QDeclarativeEngine>

#include "declarativecontenttype.h"

class ComponentsGalleryPlugin : public QDeclarativeExtensionPlugin
{
    Q_OBJECT

public:

    virtual void registerTypes(const char *uri)
    {
        Q_UNUSED(uri)
        Q_ASSERT(QLatin1String(uri) == QLatin1String("com.jolla.components.gallery"));
        qmlRegisterUncreatableType<DeclarativeContentType>(uri, 1, 0, "ContentType", "");
    }
};

#include "plugin.moc"

Q_EXPORT_PLUGIN2(componentsgalleryplugin, ComponentsGalleryPlugin);

