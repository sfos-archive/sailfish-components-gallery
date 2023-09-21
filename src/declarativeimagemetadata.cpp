/****************************************************************************************
** Copyright (c) 2013 - 2023 Jolla Ltd.
**
** All rights reserved.
**
** This file is part of Sailfish Gallery components package.
**
** You may use this file under the terms of BSD license as follows:
**
** Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions are met:
**
** 1. Redistributions of source code must retain the above copyright notice, this
**    list of conditions and the following disclaimer.
**
** 2. Redistributions in binary form must reproduce the above copyright notice,
**    this list of conditions and the following disclaimer in the documentation
**    and/or other materials provided with the distribution.
**
** 3. Neither the name of the copyright holder nor the names of its
**    contributors may be used to endorse or promote products derived from
**    this software without specific prior written permission.
**
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
** AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
** IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
** DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
** FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
** DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
** SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
** CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
** OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
** OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**
****************************************************************************************/

#include "declarativeimagemetadata.h"
#include <QFileSystemWatcher>
#include <QFile>
#include <QStringList>
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
    if (!m_wantDimensions) {
        const_cast<DeclarativeImageMetadata *>(this)->readDimensions(m_source.toLocalFile());
    }

    return m_orientation;
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
    if (!m_wantDimensions) {
        const_cast<DeclarativeImageMetadata *>(this)->readDimensions(m_source.toLocalFile());
    }
    return m_valid;
}

void DeclarativeImageMetadata::fileChanged(const QString &fileName)
{
    const bool wasValid = m_valid;
    const int orientation = m_orientation;
    const int width = m_width;
    const int height = m_height;

    m_valid = false;
    m_orientation = 0;
    m_width = 0;
    m_height = 0;


    if (m_wantDimensions) {
        readDimensions(fileName);
    }

    if (wasValid != m_valid) {
        emit validChanged();
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

void DeclarativeImageMetadata::readDimensions(const QString &fileName)
{
    m_wantDimensions = true;

    if (!fileName.isEmpty()) {
        QImageReader ir(fileName);
        if (ir.canRead()) {
            const  QSize size = ir.size();
            m_valid = true;
            m_width = size.width();
            m_height = size.height();

            switch (ir.transformation()) {
            case QImageIOHandler::TransformationNone:
            case QImageIOHandler::TransformationMirror:
                m_orientation = 0;
                break;
            case QImageIOHandler::TransformationFlip:
            case QImageIOHandler::TransformationRotate180:
                m_orientation = 180;
                break;
            case QImageIOHandler::TransformationRotate90:
            case QImageIOHandler::TransformationFlipAndRotate90:
                m_orientation = 270;
                break;
            case QImageIOHandler::TransformationMirrorAndRotate90:
            case QImageIOHandler::TransformationRotate270:
                m_orientation = 90;
                break;
            }
        } else {
            qWarning() << Q_FUNC_INFO;
            qWarning() << "Failed to read image data: " << fileName;
        }
    }
}

#include "declarativeimagemetadata.moc"
