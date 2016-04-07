#ifndef DECLARATIVEFILEINFO_H
#define DECLARATIVEFILEINFO_H

#include <QObject>
#include <QUrl>

class DeclarativeFileInfoPrivate;

class DeclarativeFileInfo : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUrl source READ source WRITE setSource NOTIFY sourceChanged)
    Q_PROPERTY(bool localFile READ localFile NOTIFY localFileChanged)
    Q_PROPERTY(QString mimeFileType READ mimeFileType NOTIFY mimeFileTypeChanged)
    Q_PROPERTY(QString mimeType READ mimeType NOTIFY mimeTypeChanged)
    Q_PROPERTY(QString fileName READ fileName NOTIFY fileNameChanged)
    Q_PROPERTY(qint64 size READ size NOTIFY sizeChanged)
    Q_PROPERTY(bool editableImage READ editableImage NOTIFY mimeTypeChanged)

public:

    explicit DeclarativeFileInfo(QObject *parent = 0);
    ~DeclarativeFileInfo();

    void setSource(const QUrl &url);
    QUrl source() const;

    bool localFile() const;

    QString mimeFileType() const;
    QString mimeType() const;
    QString fileName() const;
    qint64 size() const;

    bool editableImage() const;

Q_SIGNALS:
    void sourceChanged();
    void localFileChanged();
    void mimeFileTypeChanged();
    void mimeTypeChanged();
    void fileNameChanged();
    void sizeChanged();

private:
    DeclarativeFileInfoPrivate *d_ptr;
    Q_DECLARE_PRIVATE(DeclarativeFileInfo)
};

#endif // DECLARATIVEFILEINFO_H
