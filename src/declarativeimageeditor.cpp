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

#include "declarativeimageeditor.h"
#include "declarativeimageeditor_p.h"

#include <QImage>
#include <QtConcurrentRun>
#include <QRectF>

DeclarativeImageEditor::DeclarativeImageEditor(QQuickItem *parent) :
    QQuickItem(parent),
    d_ptr(new DeclarativeImageEditorPrivate)
{
    setFlag(QQuickItem::ItemHasContents, true);
    connect(d_ptr, SIGNAL(cropped(bool,QString)), this, SLOT(cropResult(bool,QString)));
    connect(d_ptr, SIGNAL(rotated(bool,QString)), this, SLOT(rotateResult(bool,QString)));
    connect(d_ptr, SIGNAL(levelsAdjusted(bool,QString)), this, SLOT(adjustLevelsResult(bool,QString)));
}

DeclarativeImageEditor::~DeclarativeImageEditor()
{
    delete d_ptr;
}

void DeclarativeImageEditor::setSource(const QUrl &url)
{
    Q_D(DeclarativeImageEditor);

    if (d->m_source != url) {
        d->m_source = url;
        emit sourceChanged();
    }
}

QUrl DeclarativeImageEditor::source() const
{
    Q_D(const DeclarativeImageEditor);
    return d->m_source;
}

void DeclarativeImageEditor::setTarget(const QUrl &target)
{
    Q_D(DeclarativeImageEditor);
    if (d->m_target != target) {
        d->m_target = target;
        emit targetChanged();
    }
}

QUrl DeclarativeImageEditor::target() const
{
    Q_D(const DeclarativeImageEditor);
    return d->m_target;
}

void DeclarativeImageEditor::rotate(int rotation)
{
    Q_D(DeclarativeImageEditor);
    QString source = d->m_source.toLocalFile();
    QString target = d->m_target.toLocalFile();
    QtConcurrent::run(d, &DeclarativeImageEditorPrivate::rotate, source, target, rotation);
}

void DeclarativeImageEditor::crop(const QSizeF &cropSize, const QSizeF &imageSize, const QPointF &position)
{
    Q_D(DeclarativeImageEditor);
    QString source = d->m_source.toLocalFile();
    QString target = d->m_target.toLocalFile();
    QtConcurrent::run(d, &DeclarativeImageEditorPrivate::crop, source, target, cropSize, imageSize, position);
}

void DeclarativeImageEditor::adjustLevels(double brightness, double contrast)
{
    Q_D(DeclarativeImageEditor);
    QString source = d->m_source.toLocalFile();
    QString target = d->m_target.toLocalFile();

    QtConcurrent::run(d, &DeclarativeImageEditorPrivate::adjustLevels, source, target, brightness, contrast);
}

void DeclarativeImageEditor::cropResult(bool success, const QString &targetFile)
{
    Q_D(DeclarativeImageEditor);
    if (d->m_target.isEmpty()) {
        setTarget(QUrl::fromLocalFile(targetFile));
    }
    emit cropped(success);
}

void DeclarativeImageEditor::rotateResult(bool success, const QString &targetFile)
{
    Q_D(DeclarativeImageEditor);
    if (d->m_target.isEmpty()) {
        setTarget(QUrl::fromLocalFile(targetFile));
    }
    emit rotated(success);
}

void DeclarativeImageEditor::adjustLevelsResult(bool success, const QString &targetFile)
{
    Q_D(DeclarativeImageEditor);
    if (d->m_target.isEmpty()) {
        setTarget(QUrl::fromLocalFile(targetFile));
    }
    emit levelsAdjusted(success);
}
