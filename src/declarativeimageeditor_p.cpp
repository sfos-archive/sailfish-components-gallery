#include "declarativeimageeditor_p.h"

#include <QImage>
#include <QImageReader>
#include <QDebug>
#include <QFileInfo>
#include <QDir>
#include <QDateTime>
#include <QRgb>

#include <quillmetadata-qt5/QuillMetadata>

#include <cmath>

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
    QuillMetadata md(source);
    bool hasExif = md.hasExif();
    int oldAngle = 0;

    // Just handle all the angles as positive angles
    if (rotation < 0) {
        rotation = (360 + rotation);
    }

    if (hasExif) {
        switch (md.entry(QuillMetadata::Tag_Orientation).toInt()) {
        case 1: oldAngle = 0; break;
        case 3: oldAngle = 180; break;
        case 6: oldAngle = 90; break;
        case 8: oldAngle = 270; break;
        default:
            qWarning() << Q_FUNC_INFO;
            qWarning() << "Unknown Exif orientation: " << md.entry(QuillMetadata::Tag_Orientation).toInt();
            qWarning() << "Using 0 angle as a fallback!";
        }
        // Always set the orientation to 0 degrees. ie. to 1
        md.setEntry(QuillMetadata::Tag_Orientation, 1);
        md.setEntry(QuillMetadata::Tag_Timestamp, QDateTime::currentDateTime().toString(Qt::ISODate));
    }

    // Scale down large images before rotating them.
    QImageReader reader(source);
    QSize scaledSize = reader.size();
    if (scaledSize.width() > 3264 || scaledSize.height() > 3264) {
        scaledSize = scaledSize.scaled(3264, 3264, Qt::KeepAspectRatio);
    }

    reader.setScaledSize(scaledSize);
    QImage img = reader.read();
    QTransform x;
    x.rotate((oldAngle + rotation) % 360);
    img = img.transformed(x);

    QString tmpFile = uniqueFilePath(source);
    if (!tmpFile.isEmpty() && !img.save(tmpFile)) {
        qWarning() << Q_FUNC_INFO << "Failed to save image";
        QFile::remove(tmpFile);
        emit rotated(false);
        return;
    }

    if (hasExif && !md.write(tmpFile)) {
        qWarning() << Q_FUNC_INFO << "Failed to write metadata!";
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
    QImageReader reader(source);
    if (reader.canRead() && !cropSize.isEmpty() && !imageSize.isEmpty()) {
        int rotate = 0;
        bool mirror = false;

        QuillMetadata md(source);
        if (md.hasExif()) {
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
        }

        QSize scaledSize = reader.size();
        if (scaledSize.width() > 3264 || scaledSize.height() > 3264) {
            scaledSize = scaledSize.scaled(3264, 3264, Qt::KeepAspectRatio);
        }

        const qreal scaleX = rotate % 180 == 0
                ? scaledSize.width() / imageSize.width()
                : scaledSize.width() / imageSize.height();
        qreal scaleY = rotate % 180 == 0
                ? scaledSize.height() / imageSize.height()
                : scaledSize.height() / imageSize.width();

        QRect cropRect(
                    qRound(position.x() * scaleX),
                    qRound(position.y() * scaleY),
                    qRound(cropSize.width() * scaleX),
                    qRound(cropSize.height() * scaleY));

        switch (rotate) {
        case 90:
            cropRect = QRect(
                        cropRect.top(),
                        scaledSize.height() - cropRect.right(),
                        cropRect.height(),
                        cropRect.width());
            break;
        case 180:
            cropRect = QRect(
                        scaledSize.width() - cropRect.right(),
                        scaledSize.height() - cropRect.bottom(),
                        cropRect.width(),
                        cropRect.height());
            break;
        case 270:
            cropRect = QRect(
                        scaledSize.width() - cropRect.bottom(),
                        cropRect.left(),
                        cropRect.height(),
                        cropRect.width());
            break;
        default:
            break;
        }

        if (mirror) {
            cropRect.setLeft(scaledSize.width() - cropRect.right());
        }

        reader.setScaledSize(scaledSize);
        reader.setScaledClipRect(cropRect);

        QImage croppedImage = reader.read();

        if (mirror) {
            croppedImage = croppedImage.mirrored(true, false);
        }
        if (rotate != 0) {
            QTransform transform;
            transform.rotate(rotate);
            croppedImage = croppedImage.transformed(transform);
        }

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

        bool success = croppedImage.save(tmpTarget);
        if (success && md.hasExif()) {
            // TODO: Copy all the metadata but this is better than nothing.
            // The previous version destroyed all the metadata and e.g. rotation
            // didn't work at all with once cropped images.
            if (rotate != 0) {
                // Reset rotated images to 1 ie. 0 angle to match the actual image rotation
                md.setEntry(QuillMetadata::Tag_Orientation, 1);
            }
            md.setEntry(QuillMetadata::Tag_ImageWidth, scaledSize.width());
            md.setEntry(QuillMetadata::Tag_ImageHeight, scaledSize.height());
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

void DeclarativeImageEditorPrivate::adjustLevels(const QString &source, const QString &target, double brightness, double contrast)
{
    // Scale down large images before adjusting them.
    QImageReader reader(source);
    QSize scaledSize = reader.size();
    if (scaledSize.width() > 3264 || scaledSize.height() > 3264) {
        scaledSize = scaledSize.scaled(3264, 3264, Qt::KeepAspectRatio);
    }

    reader.setScaledSize(scaledSize);
    QImage img = reader.read();
    if (img.format() != QImage::Format_RGB32 && img.format() != QImage::Format_ARGB32) {
        img = img.convertToFormat(QImage::Format_ARGB32);
    }

    // Note: manual processing to match QtGraphicalEffects (there is an suitable filter provided
    // by quillimagefilter-qt5, but it uses a different algorithm whose results do not match...)
    //
    // The shader is:
    //  void main() {
    //      highp vec4 pixelColor = texture2D(source, qt_TexCoord0);
    //      pixelColor.rgb /= max(1.0/256.0, pixelColor.a);
    //      highp float c = 1.0 + contrast;
    //      highp float contrastGainFactor = 1.0 + c * c * c * c * step(0.0, contrast);
    //      pixelColor.rgb = ((pixelColor.rgb - 0.5) * (contrastGainFactor * contrast + 1.0)) + 0.5;
    //      pixelColor.rgb = mix(pixelColor.rgb, vec3(step(0.0, brightness)), abs(brightness));
    //      gl_FragColor = vec4(pixelColor.rgb * pixelColor.a, pixelColor.a) * qt_Opacity;
    //  }
    const bool brightnessModification(contrast != 0.0);
    const bool contrastModification(contrast != 0.0);
    const float intScalar = 256.0f;
    const float fpScalar = 1.0f / intScalar;
    const double c = 1.0 + contrast;
    const float contrastGainFactor = 1.0f + static_cast<float>(std::pow(c, 4)) * (contrast < 0.0 ? 0.0f : 1.0f);
    const float contrastScalar = contrastGainFactor * contrast + 1.0f;
    const float brightnessLimit = (brightness < 0.0 ? 0.0f : 1.0f);
    const float brightnessFraction = std::abs(brightness);
    const float brightnessComplement = 1.0f - brightnessFraction;
    const float brightnessAdjustment = brightnessLimit * brightnessFraction;

    QRgb *it = reinterpret_cast<QRgb *>(img.bits());
    for (QRgb *end = it + (img.width() * img.height()); it != end; ++it) {
        QRgb &pixel(*it);

        const float alpha = qAlpha(pixel) * fpScalar;
        const float alphaScalar = std::max(fpScalar, alpha);

        float components[3] = { qRed(pixel) * fpScalar, qGreen(pixel) * fpScalar, qBlue(pixel) * fpScalar };
        for (int i = 0; i < 3; ++i) {
            float &component(components[i]);
            component /= alphaScalar;

            if (contrastModification) {
                component = (component - 0.5f) * contrastScalar + 0.5f;
            }
            if (brightnessModification) {
                // mix(x,y,a) is defined as: x*(1-a) + y*a
                component = component * brightnessComplement + brightnessAdjustment;
            }

            // Note: I don't know why this is required, but it must happen precisely at this point,
            // otherwise combined modifications of brightness and contrast fail:
            component = std::min(1.0f, std::max(0.0f, component));

            component *= alpha;
        }

        pixel = qRgba(components[0] * intScalar, components[1] * intScalar, components[2] * intScalar, alpha * intScalar);
    }

    QString tmpFile = uniqueFilePath(source);
    if (!tmpFile.isEmpty() && !img.save(tmpFile)) {
        qWarning() << Q_FUNC_INFO << "Failed to save image";
        QFile::remove(tmpFile);
        emit levelsAdjusted(false);
        return;
    }

    QuillMetadata md(source);
    if (md.hasExif()) {
        // Copy the metadata into the new file
        if (!md.write(tmpFile)) {
            qWarning() << Q_FUNC_INFO << "Failed to write metadata";
            QFile::remove(tmpFile);
            emit levelsAdjusted(false);
            return;
        }
    }

    QFileInfo info(source);
    QString targetFile = target;
    if (target.isEmpty() || !QFile::exists(tmpFile)) {
        targetFile = uniqueFilePath(source, info.canonicalPath());
    }
    if (targetFile.isEmpty()) {
        QFile::remove(tmpFile);
        emit levelsAdjusted(false);
        return;
    }

    if (!QFile::copy(tmpFile, targetFile)) {
        QFile::remove(tmpFile);
        QFile::remove(targetFile);
        emit levelsAdjusted(false);
        return;
    }

    QFile::remove(tmpFile);
    emit levelsAdjusted(true, targetFile);
}

