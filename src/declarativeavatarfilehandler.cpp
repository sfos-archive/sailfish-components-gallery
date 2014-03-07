#include "declarativeavatarfilehandler.h"
#include <QDir>
#include <QDateTime>
#include <QtDebug>

#define DEFAULT_PATH QStringLiteral("/home/nemo/.local/share/data/avatars")

DeclarativeAvatarFileHandler::DeclarativeAvatarFileHandler(QObject *parent)
    : QObject(parent)
{
}


QUrl DeclarativeAvatarFileHandler::createNewAvatarFileName(const QString &firstName, const QString &lastName)
{
    if (firstName.isEmpty() && lastName.isEmpty()) {
        qWarning() << Q_FUNC_INFO << "No name for contact. Can't create a new avatar file name!";
        return QUrl();
    }

    QDateTime time = QDateTime::currentDateTime();
    QString fileName("%1-%2-%3.jpg");
    return QUrl::fromLocalFile(DEFAULT_PATH + QDir::separator() + fileName.arg(firstName).arg(lastName).arg(time.toString(Qt::ISODate)));
}

bool DeclarativeAvatarFileHandler::removeOldAvatars(const QString &firstName, const QString &lastName, const QUrl &excludedFile)
{
    if (firstName.isEmpty() && lastName.isEmpty()) {
        qWarning() << Q_FUNC_INFO << "No name for contact. Can't remove old avatars!";
        return false;
    }

    QDir path(DEFAULT_PATH);
    QString filter("%1-%2-*.*");
    const QString efn = excludedFile.toLocalFile();
    QFileInfoList files = path.entryInfoList(QStringList() << filter.arg(firstName).arg(lastName), QDir::Files | QDir::NoDotAndDotDot);

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

QObject *DeclarativeAvatarFileHandler::api_factory(QQmlEngine *, QJSEngine *)
{
    return new DeclarativeAvatarFileHandler;
}
