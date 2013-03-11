#ifndef DECLARATIVECONTENTTYPE_H
#define DECLARATIVECONTENTTYPE_H

#include <QObject>

class DeclarativeContentType : public QObject
{
    Q_OBJECT
    Q_ENUMS(ContentType)
public:
    enum ContentType { Document, Image, Video, Music, Person, InvalidType };
};

#endif // VIEWSCONTENTTYPE_H
