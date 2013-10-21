#ifndef DECLARATIVEIMAGEMETADATA_H
#define DECLARATIVEIMAGEMETADATA_H

#include <QObject>
#include <QUrl>

class QFileSystemWatcher;
class DeclarativeImageMetadata : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUrl source READ source WRITE setSource NOTIFY sourceChanged)
    Q_PROPERTY(int orientation READ orientation NOTIFY orientationChanged)
public:
    explicit DeclarativeImageMetadata(QObject *parent = 0);
    
    QUrl source() const;
    void setSource(const QUrl &source);

    int orientation() const;

Q_SIGNALS:
    void sourceChanged();
    void orientationChanged();

private Q_SLOTS:
    void fileChanged();

private:
    QUrl m_source;
    QFileSystemWatcher *m_watcher;
    int m_orientation;
};

#endif // DECLARATIVEIMAGEMETADATA_H
