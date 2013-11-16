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
    Q_PROPERTY(int width READ width NOTIFY widthChanged)
    Q_PROPERTY(int height READ height NOTIFY heightChanged)
    Q_PROPERTY(bool valid READ valid NOTIFY validChanged)
    Q_PROPERTY(bool hasExif READ hasExif NOTIFY hasExifChanged)
    Q_PROPERTY(bool hasXmp READ hasXmp NOTIFY hasXmpChanged)

public:
    explicit DeclarativeImageMetadata(QObject *parent = 0);
    
    QUrl source() const;
    void setSource(const QUrl &source);

    int orientation() const;
    int width() const;
    int height() const;
    bool valid() const;
    bool hasExif() const;
    bool hasXmp() const;

Q_SIGNALS:
    void sourceChanged();
    void orientationChanged();
    void widthChanged();
    void heightChanged();
    void validChanged();
    void hasExifChanged();
    void hasXmpChanged();

private Q_SLOTS:
    void fileChanged();

private:
    QUrl m_source;
    QFileSystemWatcher *m_watcher;
    int m_orientation;
    int m_width;
    int m_height;
    bool m_valid;
    bool m_hasExif;
    bool m_hasXmp;
};

#endif // DECLARATIVEIMAGEMETADATA_H
