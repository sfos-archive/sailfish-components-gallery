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

void DeclarativeImageEditor::cropResult(bool success, const QString &targetFile)
{
    Q_D(DeclarativeImageEditor);
    if (d->m_target.isEmpty()) {
        setTarget(targetFile);
    }
    emit cropped(success);
}

void DeclarativeImageEditor::rotateResult(bool success, const QString &targetFile)
{
    Q_D(DeclarativeImageEditor);
    if (d->m_target.isEmpty()) {
        setTarget(targetFile);
    }
    emit rotated(success);
}
