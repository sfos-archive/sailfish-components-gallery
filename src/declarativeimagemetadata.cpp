#include "declarativeimagemetadata.h"
#include <QFileSystemWatcher>
#include <QFile>
#include <QStringList>
#include <QuillMetadata>
#include <QtDebug>
#include <QImageReader>

#include <QElapsedTimer>

class ImageWatcher : public QFileSystemWatcher
{
    Q_OBJECT
public:
    ImageWatcher(QObject *parent = 0);
    ~ImageWatcher();

    void deregisterMetadata(const QString &fileName, DeclarativeImageMetadata *metadata);
    void registerMetadata(const QString &fileName, DeclarativeImageMetadata *metadata);

private slots:
    void imageChanged(const QString &fileName);

private:
    QHash<QString, DeclarativeImageMetadata *> m_metadata;
    typedef QHash<QString, DeclarativeImageMetadata *>::iterator iterator;
};

ImageWatcher::ImageWatcher(QObject *parent)
    : QFileSystemWatcher(parent)
{
    connect(this, &QFileSystemWatcher::fileChanged,
            this, &ImageWatcher::imageChanged);
}

ImageWatcher::~ImageWatcher()
{
}

void ImageWatcher::deregisterMetadata(const QString &fileName, DeclarativeImageMetadata *metadata)
{
    if (fileName.isEmpty()) {
        return;
    }

    for (iterator it = m_metadata.find(fileName); it != m_metadata.end() && it.key() == fileName; ++it) {
        if (it.value() == metadata) {
            m_metadata.erase(it);
            break;
        }
    }
    if (!m_metadata.contains(fileName)) {
        removePath(fileName);
    }
}

void ImageWatcher::registerMetadata(const QString &fileName, DeclarativeImageMetadata *metadata)
{
    if (fileName.isEmpty()) {
        return;
    }

    if (!m_metadata.contains(fileName)) {
        addPath(fileName);
    }
    m_metadata.insertMulti(fileName, metadata);
}

void ImageWatcher::imageChanged(const QString &fileName)
{
    for (iterator it = m_metadata.find(fileName); it != m_metadata.end() && it.key() == fileName; ++it) {
        it.value()->fileChanged(fileName);
    }
}

Q_GLOBAL_STATIC(ImageWatcher, image_metadata_watcher);

DeclarativeImageMetadata::DeclarativeImageMetadata(QObject *parent)
    : QObject(parent)
    , m_source()
    , m_orientation(0)
    , m_width(0)
    , m_height(0)
    , m_autoUpdate(true)
    , m_complete(false)
    , m_valid(false)
    , m_hasExif(false)
    , m_hasXmp(false)
    , m_wantTags(false)
    , m_wantDimensions(false)
{
}

DeclarativeImageMetadata::~DeclarativeImageMetadata()
{
    if (m_autoUpdate) {
        image_metadata_watcher()->deregisterMetadata(m_source.toLocalFile(), this);
    }
}

void DeclarativeImageMetadata::classBegin()
{
}

void DeclarativeImageMetadata::componentComplete()
{
    m_complete = true;
    if (m_autoUpdate) {
        image_metadata_watcher()->registerMetadata(m_source.toLocalFile(), this);
    }
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

        if (m_autoUpdate && m_complete) {
            image_metadata_watcher()->deregisterMetadata(m_source.toLocalFile(), this);
            image_metadata_watcher()->registerMetadata(path, this);
        }

        m_source = source;
        emit sourceChanged();

        fileChanged(path);
    }
}

bool DeclarativeImageMetadata::autoUpdate() const
{
    return m_autoUpdate;
}

void DeclarativeImageMetadata::setAutoUpdate(bool update)
{
    if (m_autoUpdate != update) {
        m_autoUpdate = update;

        if (m_autoUpdate && m_complete) {
            image_metadata_watcher()->registerMetadata(m_source.toLocalFile(), this);
        } else if (m_complete) {
            image_metadata_watcher()->deregisterMetadata(m_source.toLocalFile(), this);
        }
        emit autoUpdateChanged();
    }
}

int DeclarativeImageMetadata::orientation() const
{
    if (!m_wantTags) {
        const_cast<DeclarativeImageMetadata *>(this)->readTags(m_source.toLocalFile());
    }

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
    if (!m_wantDimensions) {
        const_cast<DeclarativeImageMetadata *>(this)->readDimensions(m_source.toLocalFile());
    }
    return m_width;
}

int DeclarativeImageMetadata::height() const
{
    if (!m_wantDimensions) {
        const_cast<DeclarativeImageMetadata *>(this)->readDimensions(m_source.toLocalFile());
    }
    return m_height;
}

bool DeclarativeImageMetadata::valid() const
{
    if (!m_wantTags) {
        const_cast<DeclarativeImageMetadata *>(this)->readTags(m_source.toLocalFile());
    }
    return m_valid;
}

bool DeclarativeImageMetadata::hasExif() const
{
    if (!m_wantTags) {
        const_cast<DeclarativeImageMetadata *>(this)->readTags(m_source.toLocalFile());
    }
    return m_hasExif;
}

bool DeclarativeImageMetadata::hasXmp() const
{
    if (!m_wantTags) {
        const_cast<DeclarativeImageMetadata *>(this)->readTags(m_source.toLocalFile());
    }
    return m_hasXmp;
}

void DeclarativeImageMetadata::fileChanged(const QString &fileName)
{
    const bool wasValid = m_valid;
    const bool hadExif = m_hasExif;
    const bool hadXmp = m_hasXmp;
    const int orientation = m_orientation;
    const int width = m_width;
    const int height = m_height;

    m_valid = false;
    m_hasExif = false;
    m_hasXmp = false;
    m_orientation = 0;
    m_width = 0;
    m_height = 0;

    // Reading file data can be costly, just getting the width and height of an image can
    // take between 0.5 to 1 ms and the accumulative costs have a noticeable impact when panning
    // between images. So only do reads that have been requested.
    if (m_wantTags) {
        readTags(fileName);
    }

    if (m_wantDimensions) {
        readDimensions(fileName);
    }

    if (wasValid != m_valid) {
        emit validChanged();
    }
    if (hadExif != m_hasExif) {
        emit hasExifChanged();
    }
    if (hadXmp != m_hasXmp) {
        emit hasXmpChanged();
    }
    if (orientation != m_orientation) {
        emit orientationChanged();
    }
    if (width != m_width) {
        emit widthChanged();
    }
    if (height != m_height) {
        emit heightChanged();
    }
}

void DeclarativeImageMetadata::readTags(const QString &fileName)
{
    m_wantTags = true;

    if (!fileName.isEmpty()) {
        QuillMetadata md(fileName);
        if (md.isValid()) {
            m_valid = true;
            m_hasExif = md.hasExif();
            m_hasXmp = md.hasXmp();
            m_orientation = md.entry(QuillMetadata::Tag_Orientation).toInt();
        } else {
            qWarning() << Q_FUNC_INFO;
            qWarning() << "Failed to read image metadata: " << fileName;
        }
    }
}

void DeclarativeImageMetadata::readDimensions(const QString &fileName)
{
    m_wantDimensions = true;

    if (!fileName.isEmpty()) {
        QImageReader ir(fileName);
        if (ir.canRead()) {
            const  QSize size = ir.size();
            m_width = size.width();
            m_height = size.height();
        } else {
            qWarning() << Q_FUNC_INFO;
            qWarning() << "Failed to read image data: " << fileName;
        }
    }
}

#include "declarativeimagemetadata.moc"
