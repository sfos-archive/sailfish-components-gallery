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

#ifndef DECLARATIVEIMAGEMETADATA_H
#define DECLARATIVEIMAGEMETADATA_H

#include <QObject>
#include <QUrl>
#include <QQmlParserStatus>

class DeclarativeImageMetadata : public QObject, public QQmlParserStatus
{
    Q_OBJECT
    Q_PROPERTY(QUrl source READ source WRITE setSource NOTIFY sourceChanged)
    Q_PROPERTY(bool autoUpdate READ autoUpdate WRITE setAutoUpdate NOTIFY autoUpdateChanged)
    Q_PROPERTY(int orientation READ orientation NOTIFY orientationChanged)
    Q_PROPERTY(int width READ width NOTIFY widthChanged)
    Q_PROPERTY(int height READ height NOTIFY heightChanged)
    Q_PROPERTY(bool valid READ valid NOTIFY validChanged)
    Q_INTERFACES(QQmlParserStatus)
public:
    explicit DeclarativeImageMetadata(QObject *parent = 0);
    ~DeclarativeImageMetadata();

    void componentComplete();
    void classBegin();

    QUrl source() const;
    void setSource(const QUrl &source);

    bool autoUpdate() const;
    void setAutoUpdate(bool update);

    int orientation() const;
    int width() const;
    int height() const;
    bool valid() const;

Q_SIGNALS:
    void sourceChanged();
    void autoUpdateChanged();
    void orientationChanged();
    void widthChanged();
    void heightChanged();
    void validChanged();
    void hasExifChanged();
    void hasXmpChanged();

private:
    void fileChanged(const QString &fileName);
    void readDimensions(const QString &fileName);

private:
    QUrl m_source;
    int m_orientation;
    int m_width;
    int m_height;
    bool m_autoUpdate;
    bool m_complete;
    bool m_valid;
    bool m_wantDimensions;

    friend class ImageWatcher;
};

#endif // DECLARATIVEIMAGEMETADATA_H
