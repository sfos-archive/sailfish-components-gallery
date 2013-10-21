#include "declarativeimageeditor_p.h"

#include <QImage>
#include <QDebug>
#include <QFileInfo>
#include <QDir>
#include <QDateTime>

#include <quillmetadata-qt5/QuillMetadata>

DeclarativeImageEditorPrivate::DeclarativeImageEditorPrivate(QObject *parent) :
    QObject(parent)
{
}

DeclarativeImageEditorPrivate::~DeclarativeImageEditorPrivate()
{
}


QString DeclarativeImageEditorPrivate::uniqueFilePath(const QString &sourceFilePath, const QString &path)
{
    if (sourceFilePath.isEmpty() || !QFile::exists(sourceFilePath)) {
        qWarning() << Q_FUNC_INFO << sourceFilePath << "Doesn't exist or then the path is empty!";
        return QString();
    }

    if (path.isEmpty()) {
        qWarning() << Q_FUNC_INFO << "'path' argument is empty!";
        return QString();
    }

    QFileInfo fileInfo(sourceFilePath);

    // Construct target temp file path first:
    QDir dir(path);
    QStringList prevFiles = dir.entryList(QStringList() << fileInfo.baseName() + QLatin1String("*"), QDir::Files);
    int count = prevFiles.count();

    // Create temp file with increasing index in a file name e.g.
    // /var/temp/img_001_0.jpg, /var/temp/img_001_1.jpg
    // In a case there already is a file with the same filename
    QString filePath = dir.absolutePath() + QDir::separator();
    QString fileName = fileInfo.baseName() +
                        QLatin1String("_") +
                        QString::number(count) +
                        QLatin1String(".") +
                        fileInfo.suffix();

    // This makes sure that we don't generate a file name which already exists. E.g. there are files:
    // img_001_0, img_001_1, img_001_2 and img_001 gets deleted. Then this code would generate a
    // filename img_001_2 which already exists
    while(prevFiles.contains(fileName)) {
        ++count;
        fileName = fileInfo.baseName() +
                    QLatin1String("_") +
                    QString::number(count) +
                    QLatin1String(".") +
                    fileInfo.suffix();
    }

    return filePath + fileName;
}


void DeclarativeImageEditorPrivate::rotate(const QString &source, const QString &target, int rotation)
{
    if (!QuillMetadata::canRead(source)) {
        emit rotated(false);
        return;
    }

    QString tmpFile = uniqueFilePath(source);

    // Copy image content first
    if (!QFile::copy(source, tmpFile)) {
        qWarning() << Q_FUNC_INFO << "Failed to copy content!";
        QFile::remove(tmpFile);
        emit rotated(false);
        return;
    }

    QuillMetadata md(tmpFile);
    int oldAngle = 0;
    int oldExifOrientation = md.entry(QuillMetadata::Tag_Orientation).toInt();
    switch (oldExifOrientation) {
    case 1: oldAngle = 0; break;
    case 3: oldAngle = 180; break;
    case 6: oldAngle = 90; break;
    case 8: oldAngle = 270; break;
    default:
        qWarning() << Q_FUNC_INFO << "Unknown Exif orientation!";
        return;
    }
    // Just handle all the angles as positive angles
    if (rotation < 0) {
        rotation = (360 + rotation);
    }

    int exifOrientation = -1;
    switch ((oldAngle + rotation) % 360) {
    case 0:     exifOrientation = 1; break;
    case 90:    exifOrientation = 6; break;
    case 180:   exifOrientation = 3; break;
    case 270:   exifOrientation = 8; break;
    }

    md.setEntry(QuillMetadata::Tag_Orientation, exifOrientation);
    md.setEntry(QuillMetadata::Tag_Timestamp, QDateTime::currentDateTime().toString(Qt::ISODate));

    if (!md.write(tmpFile)) {
       qWarning() << Q_FUNC_INFO << "Failed to clear metadata!";
       QFile::remove(tmpFile);
       emit rotated(false);
       return;
    }

    QFileInfo info(source);
    QString targetFile = target;
    if (target.isEmpty() || !QFile::exists(tmpFile)) {
        targetFile = uniqueFilePath(source, info.canonicalPath());
    }

    if (targetFile.isEmpty()) {
        QFile::remove(tmpFile);
        emit rotated(false);
        return;
    }
    // Copy the tmpFile content to the final location and let tracker
    // to index it.
    if (!QFile::copy(tmpFile, targetFile)) {
        QFile::remove(tmpFile);
        QFile::remove(targetFile);
        emit rotated(false);
        return;
    }
    QFile::remove(tmpFile);
    emit rotated(true, targetFile);
}

// Run in QtConcurrent::run
void  DeclarativeImageEditorPrivate::crop(const QString &source, const QString &target, const QSizeF &cropSize, const QSizeF &imageSize, const QPointF &position)
{
    QImage sourceImage(source);
    if (!source.isEmpty() && !sourceImage.isNull() && !cropSize.isEmpty() && !imageSize.isEmpty()) {
        int rotate = 0;
        bool mirror = false;

        QuillMetadata md(source);
        int exifOrientation = md.entry(QuillMetadata::Tag_Orientation).toInt();
        switch (exifOrientation) {
        case 1: rotate = 0  ; mirror = false; break;
        case 2: rotate = 0  ; mirror = true  ; break;
        case 3: rotate = 180; mirror = false; break;
        case 4: rotate = 180; mirror = true ; break;
        case 5: rotate = 90 ; mirror = true ; break;
        case 6: rotate = 90 ; mirror = false; break;
        case 7: rotate = 270; mirror = true ; break;
        case 8: rotate = 270; mirror = false; break;
        default: break;
        }

        if (mirror) {
            sourceImage = sourceImage.mirrored(true, false);
        }
        if (rotate != 0) {
            QTransform transform;
            transform.rotate(rotate);
            sourceImage = sourceImage.transformed(transform);
        }

        qreal width = sourceImage.width() / imageSize.width() * cropSize.width();
        qreal height = sourceImage.height() / imageSize.height() * cropSize.height();

        qreal x = sourceImage.width() / imageSize.width() * position.x();
        qreal y = sourceImage.height() / imageSize.height() * position.y();
        QRect tmpRect(x, y, width, height);

        QString tmpTarget = target;
        if (tmpTarget.isEmpty()) {
            QFileInfo info(source);
            tmpTarget = uniqueFilePath(source, info.canonicalPath());
        }

        // If this is an avatar we might need to create the path first.
        QString targetPath = tmpTarget.left(tmpTarget.lastIndexOf("/"));
        if (!QDir().mkpath(targetPath)) {
           qWarning() << Q_FUNC_INFO << "failed to create target path";
           emit cropped(false);
           return;
        }

        QImage scaledImage = sourceImage.copy(tmpRect);
        bool success = scaledImage.save(tmpTarget);
        if (success) {
            // TODO: Copy all the metadata but this is better than nothing.
            // The previous version destroyed all the metadata and e.g. rotation
            // didn't work at all with once cropped images.
            if (rotate != 0) {
                // Reset rotated images to 1 ie. 0 angle to match the actual image rotation
                md.setEntry(QuillMetadata::Tag_Orientation, 1);
            }
            md.setEntry(QuillMetadata::Tag_ImageWidth, width);
            md.setEntry(QuillMetadata::Tag_ImageHeight, height);
            md.setEntry(QuillMetadata::Tag_Timestamp, QDateTime::currentDateTime().toString(Qt::ISODate));
            success = md.write(tmpTarget);
            if (!success) {
                qWarning() << Q_FUNC_INFO << "Failed to write metadata!" << tmpTarget;
            }
        }
        emit cropped(success, tmpTarget);
    } else {
        emit cropped(false);
    }

}
