#include "declarativeimagemetadata.h"
#include <QFileSystemWatcher>
#include <QFile>
#include <QStringList>
#include <QuillMetadata>
#include <QtDebug>
#include <QImageReader>

DeclarativeImageMetadata::DeclarativeImageMetadata(QObject *parent)
    : QObject(parent)
    , m_source()
    , m_watcher(new QFileSystemWatcher(this))
    , m_orientation(0)
    , m_width(0)
    , m_height(0)
{
    connect(m_watcher, &QFileSystemWatcher::fileChanged,
            this, &DeclarativeImageMetadata::fileChanged);
}

QUrl DeclarativeImageMetadata::source() const
{
    return m_source;
}

void DeclarativeImageMetadata::setSource(const QUrl &source)
{
    // Let user also reset this object by setting "" as a string
    if (m_source != source) {
        const QString path = source.toLocalFile();
        QStringList paths = m_watcher->files();

        // Remove the old path first
        if (paths.contains(path)) {
            m_watcher->removePath(path);
        }

        m_source = source;
        emit sourceChanged();

        if (!path.isEmpty() && QFile::exists(path)) {
            m_watcher->addPath(path);
            fileChanged();
        }
    }
}

int DeclarativeImageMetadata::orientation() const
{
    switch (m_orientation) {
    case 0: return 0;
    case 1: return 0;
    case 2: return 0;
    case 3: return 180;
    case 4: return 180;
    case 5: return 270;
    case 6: return 270;
    case 7: return 90;
    case 8: return 90;
    default: return -1;
    }
}

int DeclarativeImageMetadata::width() const
{
    return m_width;
}

int DeclarativeImageMetadata::height() const
{
    return m_height;
}

bool DeclarativeImageMetadata::valid() const
{
    return m_valid;
}

bool DeclarativeImageMetadata::hasExif() const
{
    return m_hasExif;
}

bool DeclarativeImageMetadata::hasXmp() const
{
    return m_hasXmp;
}

void DeclarativeImageMetadata::fileChanged()
{
    const QString path = m_source.toLocalFile();
    if (QuillMetadata::canRead(path)) {
        QuillMetadata md(path);

        bool valid = md.isValid();
        if (valid != m_valid) {
            m_valid = valid;
            emit validChanged();
        }

        bool hasExif = md.hasExif();
        if (hasExif != m_hasExif) {
            m_hasExif = hasExif;
            emit hasExifChanged();
        }

        bool hasXmp = md.hasXmp();
        if (hasXmp != m_hasXmp) {
            m_hasXmp = hasXmp;
            emit hasXmpChanged();
        }

        int orientation = md.entry(QuillMetadata::Tag_Orientation).toInt();
        if (m_orientation != orientation) {
            m_orientation = orientation;
            emit orientationChanged();
        }
    } else {
        qWarning() << Q_FUNC_INFO;
        qWarning() << "Failed to read image metadata: " << path;
        m_orientation = 0;
        emit orientationChanged();
    }

    // Looks like width and height are quite often left out from the metadata
    // so it's safer to read them using QImageReader
    QImageReader ir(path);
    if (ir.canRead()) {
        const int width = ir.size().width();
        if (m_width != width) {
            m_width = width;
            emit widthChanged();
        }
        const int height = ir.size().height();
        if (m_height != height) {
            m_height = height;
            emit heightChanged();
        }

    } else {
        qWarning() << Q_FUNC_INFO;
        qWarning() << "Failed to read image data: " << path;
    }
}
