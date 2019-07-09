#ifndef DECLARATIVEAVATARFILEHANDLER_H
#define DECLARATIVEAVATARFILEHANDLER_H

#include <QObject>
#include <QUrl>
#include <QQmlEngine>

class DeclarativeAvatarFileHandler: public QObject
{
    Q_OBJECT
public:
    DeclarativeAvatarFileHandler(QObject *parent = 0);

    Q_INVOKABLE QString createNewAvatarFileName(const QString &base);

    static QObject *api_factory(QQmlEngine *, QJSEngine *);
};

#endif // DECLARATIVEAVATARFILEHANDLER_H
