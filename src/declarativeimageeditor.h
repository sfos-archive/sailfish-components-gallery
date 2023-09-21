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

#ifndef DECLARATIVEIMAGEEDITOR_H
#define DECLARATIVEIMAGEEDITOR_H

#include <QtQml>
#include <QQuickItem>
#include <QString>

class DeclarativeImageEditorPrivate;

class DeclarativeImageEditor : public QQuickItem
{
    Q_OBJECT
    Q_PROPERTY(QUrl source READ source WRITE setSource NOTIFY sourceChanged)
    Q_PROPERTY(QUrl target READ target WRITE setTarget NOTIFY targetChanged)
    Q_ENUMS(EditOperationType)

public:

    enum EditOperationType {
        None,
        Crop,
        Rotate,
        AdjustLevels,
    };

    explicit DeclarativeImageEditor(QQuickItem *parent = 0);
    virtual ~DeclarativeImageEditor();

    QUrl source() const;
    void setSource(const QUrl &source);

    QUrl target() const;
    void setTarget(const QUrl &target);

    Q_INVOKABLE void crop(const QSizeF &cropSize, const QSizeF &imageSize, const QPointF &position);
    Q_INVOKABLE void rotate(int rotation);
    Q_INVOKABLE void adjustLevels(double brightness, double contrast);

Q_SIGNALS:
    void cropped(bool success);
    void rotated(bool success);
    void levelsAdjusted(bool success);
    void sourceChanged();
    void targetChanged();

private Q_SLOTS:
    void cropResult(bool success, const QString &targetFile);
    void rotateResult(bool success, const QString &targetFile);
    void adjustLevelsResult(bool success, const QString &targetFile);

private:
    DeclarativeImageEditorPrivate *d_ptr;
    Q_DECLARE_PRIVATE(DeclarativeImageEditor)
};

QML_DECLARE_TYPE(DeclarativeImageEditor)

#endif // DECLARATIVEIMAGEEDITOR_H
