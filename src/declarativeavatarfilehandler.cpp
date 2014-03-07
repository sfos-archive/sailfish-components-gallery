#include "declarativeavatarfilehandler.h"
#include <QDir>
#include <QDateTime>
#include <QStandardPaths>
#include <QtDebug>

DeclarativeAvatarFileHandler::DeclarativeAvatarFileHandler(QObject *parent)
    : QObject(parent)
{
}


QUrl DeclarativeAvatarFileHandler::createNewAvatarFileName(const QString &id)
{
    if (id.isEmpty()) {
        qWarning() << Q_FUNC_INFO << "No name for contact. Can't create a new avatar file name!";
        return QUrl();
    }

    QDateTime time = QDateTime::currentDateTime();
    QString fileName("%1-%2.jpg");
    return QUrl::fromLocalFile(DeclarativeAvatarFileHandler::avatarPath() +
                               QDir::separator() +
                               fileName.arg(id).arg(time.toString(Qt::ISODate)));
}

bool DeclarativeAvatarFileHandler::removeOldAvatars(const QString &id,const QUrl &excludedFile)
{
    if (id.isEmpty()) {
        qWarning() << Q_FUNC_INFO << "No name for contact. Can't remove old avatars!";
        return false;
    }

    QDir path(DeclarativeAvatarFileHandler::avatarPath());
    QString filter("%1-*.*");
    const QString efn = excludedFile.toLocalFile();
    QFileInfoList files = path.entryInfoList(QStringList() << filter.arg(id), QDir::Files | QDir::NoDotAndDotDot);

    if (!files.isEmpty()) {
        // Delete files
        foreach(const QFileInfo &file, files) {
            if (efn != file.absoluteFilePath()) {
                if (!QFile::remove(file.absoluteFilePath())) {
                    qWarning() << Q_FUNC_INFO << "Failed to remove file: " << file.absolutePath();
                    return false;
                }
            }
        }
    }

    return true;
}

QString DeclarativeAvatarFileHandler::avatarPath()
{
    return QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation) +
           QDir::separator() +
           QLatin1String("data") +
           QDir::separator() +
           QLatin1String("avatars");
}

QObject *DeclarativeAvatarFileHandler::api_factory(QQmlEngine *, QJSEngine *)
{
    return new DeclarativeAvatarFileHandler;
}
