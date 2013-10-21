#include "declarativeimagemetadata.h"
#include <QFileSystemWatcher>
#include <QFile>
#include <QStringList>
#include <QuillMetadata>
#include <QtDebug>

DeclarativeImageMetadata::DeclarativeImageMetadata(QObject *parent)
    : QObject(parent)
    , m_source()
    , m_watcher(new QFileSystemWatcher(this))
    , m_orientation(0)
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

            QuillMetadata md(path);
            m_orientation = md.entry(QuillMetadata::Tag_Orientation).toInt();
            emit orientationChanged();
        }
    }
}

int DeclarativeImageMetadata::orientation() const
{
    switch (m_orientation) {
    case 1: return 0;
    case 2: return 0;
    case 3: return 180;
    case 4: return 180;
    case 5: return 90;
    case 6: return 90;
    case 7: return 270;
    case 8: return 270;
    default: return -1;
    }
}

void DeclarativeImageMetadata::fileChanged()
{
    QuillMetadata md(m_source.toLocalFile());
    int orientation = md.entry(QuillMetadata::Tag_Orientation).toInt();
    if (m_orientation != orientation) {
        m_orientation = orientation;
        emit orientationChanged();
    }
}
