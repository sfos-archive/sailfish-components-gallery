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

#ifndef DECLARATIVEIMAGEEDITOR_PRIVATE_H
#define DECLARATIVEIMAGEEDITOR_PRIVATE_H

#include <QObject>
#include <QUrl>
#include <QDir>

class QString;
class QSizeF;
class QPointF;

class DeclarativeImageEditorPrivate : public QObject
{
    Q_OBJECT
public:
    explicit DeclarativeImageEditorPrivate(QObject *parent = 0);
    virtual ~DeclarativeImageEditorPrivate();

    QString uniqueFilePath(const QString &sourceFilePath, const QString &path = QDir::tempPath());
    QString save(QImage &image, const QString &source, const QString &target, const QByteArray &format = QByteArray());

    // Member variables
    QUrl m_source;
    QUrl m_target;

public Q_SLOTS:
    void rotate(const QString &source, const QString &target, int rotation);
    void crop(const QString &source, const QString &target, const QSizeF &cropSize, const QSizeF &imageSize, const QPointF &position);
    void adjustLevels(const QString &source, const QString &target, double brightness, double contrast);

Q_SIGNALS:
    void cropped(bool success, const QString &targetFile = QString());
    void rotated(bool success, const QString &targetFile = QString());
    void levelsAdjusted(bool success, const QString &targetFile = QString());
};

#endif // DECLARATIVEIMAGEEDITOR_PRIVATE_H
