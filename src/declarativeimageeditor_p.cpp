#include "declarativeimageeditor_p.h"

#include <QImage>
#include <QDebug>
#include <QFileInfo>
#include <QDir>

#ifdef USE_QUILLMETADATA
#include <quillmetadata-qt5/QuillMetadata>
#endif

DeclarativeImageEditorPrivate::DeclarativeImageEditorPrivate(QObject *parent) :
    QObject(parent)
{
}

DeclarativeImageEditorPrivate::~DeclarativeImageEditorPrivate()
{
#ifndef USE_QIMAGE
    if (m_file) {
        delete m_file;
        m_file = 0;
    }
#endif
}

#ifndef USE_QIMAGE
void DeclarativeImageEditorPrivate::releaseImage(QString fileName)
{
    if (m_source == fileName && m_file) {
        delete m_file;
        m_file = 0;
    }
}
#endif

// Run in QtConcurrent::run
void  DeclarativeImageEditorPrivate::crop(const QString &source, const QString &target, const QSizeF &cropSize, const QSizeF &imageSize, const QPointF &position)
{
    QImage sourceImage(source);
    if (!source.isEmpty() && !sourceImage.isNull() && !cropSize.isEmpty() && !imageSize.isEmpty()) {
#ifdef USE_QUILLMETADATA
        int rotate = 0;
        bool mirror = false;

        QuillMetadata md(source);
        switch (md.entry(QuillMetadata::Tag_Orientation).toInt()) {
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
#endif

        QString tmpTarget = target;
        if (tmpTarget.isEmpty()) {
            QFileInfo tmpFile(source);
            QString completeSuffix = tmpFile.completeSuffix();
            QString fullFileBase = source;
            fullFileBase = fullFileBase.left(source.length() - completeSuffix.length());
            QString dot;
            if (fullFileBase.endsWith(".")) {
                fullFileBase = fullFileBase.left(fullFileBase.length() - 1);
                dot = ".";
            }

            // Find name with running number
            int i = 0;
            do {
                tmpTarget = QString(fullFileBase + "_%1" + dot + completeSuffix).arg(i);
                tmpFile.setFile(tmpTarget);
                ++i;
            } while (tmpFile.exists());
        }

        QString targetPath = tmpTarget.left(tmpTarget.lastIndexOf("/"));
        if (!QDir().mkpath(targetPath)) {
            qWarning() << Q_FUNC_INFO << "failed to create target path";
            emit cropped(false);
            return;
        }

        qreal width = sourceImage.width() / imageSize.width() * cropSize.width();
        qreal height = sourceImage.height() / imageSize.height() * cropSize.height();

        qreal x = sourceImage.width() / imageSize.width() * position.x();
        qreal y = sourceImage.height() / imageSize.height() * position.y();
        QRect tmpRect(x, y, width, height);

        QImage scaledImage = sourceImage.copy(tmpRect);
        bool success = scaledImage.save(tmpTarget);
        emit cropped(success);
    } else {
        emit cropped(false);
    }
}
