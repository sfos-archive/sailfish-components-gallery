#include "declarativefileinfo.h"
#include <QMimeDatabase>
#include <QMimeType>
#include <QFileInfo>
#include <QImageWriter>

class DeclarativeFileInfoPrivate
{
public:
    QUrl m_url;
    QFileInfo m_info;
    QString m_mimeType;
    QString m_mimeFileType;

    void refreshMimeType()
    {
        if (m_url.isEmpty()) {
            return;
        }

        QMimeDatabase db;
        QMimeType mimeType;
        if (m_url.isLocalFile()) {
            mimeType = db.mimeTypeForFile(m_info);
        } else {
            mimeType = db.mimeTypeForUrl(m_url);
        }

        m_mimeType = mimeType.name();

        if (!m_mimeType.contains(QLatin1String("/"))) {
            return;
        }

        m_mimeFileType = m_mimeType.left(m_mimeType.indexOf(QLatin1String("/")));
    }
};

DeclarativeFileInfo::DeclarativeFileInfo(QObject *parent) :
    QObject(parent),
    d_ptr(new DeclarativeFileInfoPrivate)
{
}

DeclarativeFileInfo::~DeclarativeFileInfo()
{
    delete d_ptr;
}

void DeclarativeFileInfo::setSource(const QUrl &url)
{
    Q_D(DeclarativeFileInfo);
    bool isLocalFile = localFile();
    QString oldMimeType = mimeType();
    QString oldMimeFileType = mimeFileType();
    QString oldFileName = fileName();
    qint32 oldSize = size();

    if (d->m_url != url) {
        d->m_url = url;
        d->m_info.setFile(d->m_url.toLocalFile());
        emit sourceChanged();
    }

    d->refreshMimeType();

    if (isLocalFile != localFile()) {
        emit localFileChanged();
    }

    if (oldMimeFileType != mimeFileType()) {
        emit mimeFileTypeChanged();
    }

    if (oldMimeType != mimeType()) {
        emit mimeTypeChanged();
    }

    if (oldFileName != fileName()) {
        emit fileNameChanged();
    }

    if (oldSize != size()) {
        emit sizeChanged();
    }
}

QUrl DeclarativeFileInfo::source() const
{
    Q_D(const DeclarativeFileInfo);
    return d->m_url;
}

bool DeclarativeFileInfo::localFile() const
{
    Q_D(const DeclarativeFileInfo);
    return d->m_url.isLocalFile();
}

QString DeclarativeFileInfo::mimeType() const
{
    Q_D(const DeclarativeFileInfo);
    return d->m_mimeType;
}

QString DeclarativeFileInfo::fileName() const
{
    Q_D(const DeclarativeFileInfo);
    if (d->m_url.isEmpty()) {
        return QString();
    }
    return d->m_info.fileName();
}

QString DeclarativeFileInfo::mimeFileType() const
{
    Q_D(const DeclarativeFileInfo);
    return d->m_mimeFileType;
}

qint64 DeclarativeFileInfo::size() const
{
    Q_D(const DeclarativeFileInfo);
    return d->m_info.size();
}

bool DeclarativeFileInfo::editableImage() const
{
    Q_D(const DeclarativeFileInfo);
    return QImageWriter::supportedMimeTypes().contains(d->m_mimeType.toUtf8());
}

bool DeclarativeFileInfo::exists() const
{
    Q_D(const DeclarativeFileInfo);
    return d->m_info.exists();
}
