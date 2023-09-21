/****************************************************************************************
** Copyright (c) 2013 - 2023 Jolla Ltd.
**
** All rights reserved.
**
** This file is part of Sailfish Transfer Engine component package.
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

#include <QQmlExtensionPlugin>
#include <QQmlEngine>
#include <QGuiApplication>
#include <QTranslator>
#include <QImageWriter>
#include "declarativeimageeditor.h"
#include "declarativeimagemetadata.h"
#include "declarativeavatarfilehandler.h"

namespace
{

// using custom translator so it gets properly removed from qApp when engine is deleted
class AppTranslator: public QTranslator
{
    Q_OBJECT
public:
    AppTranslator(QObject *parent)
        : QTranslator(parent)
    {
        qApp->installTranslator(this);
    }

    virtual ~AppTranslator()
    {
        qApp->removeTranslator(this);
    }
};

class ImageWriter : public QObject
{
    Q_OBJECT
public:
    Q_INVOKABLE bool isMimeTypeSupported(const QString &mimeType)
    {
        return QImageWriter::supportedMimeTypes().contains(mimeType.toUtf8());
    }

    static QObject *api_factory(QQmlEngine *, QJSEngine *)
    {
        return new ImageWriter;
    }
};

}

class SailfishGalleryPlugin : public QQmlExtensionPlugin
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID "org.sailfish.components.gallery")

public:

    void initializeEngine(QQmlEngine *engine, const char *uri)
    {
        if (QLatin1String(uri) != QLatin1String("Sailfish.Gallery")) {
            return;
        }

        AppTranslator *engineeringEnglish = new AppTranslator(engine);
        AppTranslator *translator = new AppTranslator(engine);
        AppTranslator *galleryTranslator = new AppTranslator(engine);
        engineeringEnglish->load("sailfish_components_gallery_qt5_eng_en", "/usr/share/translations");
        translator->load(QLocale(), "sailfish_components_gallery_qt5", "-", "/usr/share/translations");
        galleryTranslator->load(QLocale(), "gallery", "-", "/usr/share/translations");
    }

    virtual void registerTypes(const char *uri)
    {
        if (QLatin1String(uri) == QLatin1String("Sailfish.Gallery.private")) {
            qmlRegisterType<DeclarativeImageEditor>("Sailfish.Gallery.private", 1, 0, "ImageEditor");
            qmlRegisterType<DeclarativeImageMetadata>("Sailfish.Gallery.private", 1, 0, "ImageMetadata");
            qmlRegisterSingletonType<DeclarativeAvatarFileHandler>("Sailfish.Gallery.private", 1, 0, "AvatarFileHandler", DeclarativeAvatarFileHandler::api_factory);
            qmlRegisterSingletonType<ImageWriter>("Sailfish.Gallery.private", 1, 0, "ImageWriter", ImageWriter::api_factory);
        }
    }
};

#include "plugin.moc"

