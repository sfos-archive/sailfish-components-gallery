#include "declarativeavatarfilehandler.h"
#include <QDir>
#include <QDateTime>
#include <QStandardPaths>
#include <QFileInfo>
#include <QtDebug>

static QString avatarPath()
{
    return QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation) +
           QDir::separator() +
           QLatin1String("data") +
           QDir::separator() +
           QLatin1String("avatars");
}

DeclarativeAvatarFileHandler::DeclarativeAvatarFileHandler(QObject *parent)
    : QObject(parent)
{
}

// takes a file name (without path) and returns target name (with path) for avatar image created from it.
QString DeclarativeAvatarFileHandler::createNewAvatarFileName(const QString &base)
{
    if (base.isEmpty()) {
        qWarning() << Q_FUNC_INFO << "No base name for avatar. Can't create a file name!";
        return QString();
    }

    QFileInfo fileInfo(base);
    QString fileName(fileInfo.baseName() + QLatin1String("-%1.") + fileInfo.completeSuffix());

    QDateTime time = QDateTime::currentDateTimeUtc();

    return avatarPath() + QDir::separator() + fileName.arg(time.toString("yyyyMMdd_HHmmss"));
}

QObject *DeclarativeAvatarFileHandler::api_factory(QQmlEngine *, QJSEngine *)
{
    return new DeclarativeAvatarFileHandler;
}
