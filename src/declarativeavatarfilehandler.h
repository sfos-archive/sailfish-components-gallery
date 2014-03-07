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

    Q_INVOKABLE QUrl createNewAvatarFileName(const QString &firstname, const QString &lastName);
    Q_INVOKABLE bool removeOldAvatars(const QString &firstName, const QString &lastName, const QUrl &excludedFile);

    static QObject *api_factory(QQmlEngine *, QJSEngine *);
};

#endif // DECLARATIVEAVATARFILEHANDLER_H
