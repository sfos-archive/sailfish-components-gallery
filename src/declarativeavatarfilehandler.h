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

    Q_INVOKABLE QUrl createNewAvatarFileName(const QString &id);
    Q_INVOKABLE bool removeOldAvatars(const QString &id, const QUrl &excludedFile);

    static QString avatarPath();
    static QObject *api_factory(QQmlEngine *, QJSEngine *);
};

#endif // DECLARATIVEAVATARFILEHANDLER_H
