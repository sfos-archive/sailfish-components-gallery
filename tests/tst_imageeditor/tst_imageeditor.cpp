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

#include <QtTest>
#include <QImage>
#include <QUrl>
#include <QVariant>

#include "declarativeimageeditor.h"

int colorPalette[16][3] =
{{255, 0, 0}, {255, 0, 0}, {0, 0, 255}, {0, 0, 255},       // red | red | blue | blue
 {255, 0, 0}, {255, 0, 0}, {0, 0, 255}, {0, 0, 255},       // red | red | blue | blue
 {0, 255, 0}, {0, 255, 0}, {255, 255, 0}, {255, 255, 0},   // green | green | yellow | yellow
 {0, 255, 0}, {0, 255, 0}, {255, 255, 0}, {255, 255, 0}};  // green | green | yellow | yellow

class tst_imageeditor : public QObject
{
    Q_OBJECT

public:
    tst_imageeditor();
    ~tst_imageeditor();

    QString sourceImagePath;
    QString targetImagePath;

private Q_SLOTS:
    void initTestCase();
    void crop();

private:
    QUrl createColorPalette();
};

tst_imageeditor::tst_imageeditor() :
    sourceImagePath(QDir::tempPath() + "/test_image.jpg"),
    targetImagePath(QDir::tempPath() + "/test_cropped.jpg")
{
}

tst_imageeditor::~tst_imageeditor()
{
    return;
    QFile source(sourceImagePath);
    if (source.exists()) {
        source.remove();
    }
    QFile target(targetImagePath);
    if (target.exists()) {
        target.remove();
    }
}

QUrl tst_imageeditor::createColorPalette()
{
    QImage image(QSize(4, 4), QImage::Format_RGB32);
    for (int pixel = 0; pixel < 16; pixel++) {
        image.setPixel(pixel % 4, pixel / 4,
                       qRgb(colorPalette[pixel][0],
                            colorPalette[pixel][1],
                            colorPalette[pixel][2]));
    }
    QString testImage(sourceImagePath);
    image.save(testImage);
    return QUrl::fromLocalFile(testImage);
}

void tst_imageeditor::initTestCase()
{
}

void tst_imageeditor::crop()
{
    QUrl sourceFile = createColorPalette();
    QUrl targetFile = QUrl::fromLocalFile(targetImagePath);

    DeclarativeImageEditor editor;
    editor.setSource(sourceFile);
    editor.setTarget(targetFile);

    QSignalSpy croppedSpy(&editor, SIGNAL(cropped(bool)));
    editor.crop(QSizeF(2.0, 2.0), QSizeF(4.0, 4.0), QPointF(1.0, 1.0));
    QTest::qWait(100);
    QCOMPARE(croppedSpy.count(), 1);
    QCOMPARE(qvariant_cast<QVariant>(croppedSpy.at(0).first()).toBool(), true);
    QCOMPARE(QImage(targetImagePath).size(), QImage(sourceImagePath).size()/2);

    croppedSpy.clear();
    editor.crop(QSizeF(1.0, 1.0), QSizeF(4.0, 4.0), QPointF(3.0, 3.0));
    QTest::qWait(100);
    QCOMPARE(croppedSpy.count(), 1);
    QCOMPARE(qvariant_cast<QVariant>(croppedSpy.at(0).first()).toBool(), true);
    QCOMPARE(QImage(targetImagePath), QImage(sourceImagePath).copy(3, 3, 1, 1));
}

QTEST_MAIN(tst_imageeditor)

#include "tst_imageeditor.moc"
