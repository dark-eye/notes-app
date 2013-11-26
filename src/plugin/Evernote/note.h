#ifndef NOTE_H
#define NOTE_H

#include <QObject>

class Note : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString guid READ guid NOTIFY guidChanged)
    Q_PROPERTY(QString notebookGuid READ notebookGuid WRITE setNotebookGuid NOTIFY notebookGuidChanged)
    Q_PROPERTY(QString title READ title WRITE setTitle NOTIFY titleChanged)
    Q_PROPERTY(QString content READ content WRITE setContent NOTIFY contentChanged)
public:
    explicit Note(const QString &guid = QString(), QObject *parent = 0);

    QString guid() const;
    void setGuid(const QString &guid);

    QString notebookGuid() const;
    void setNotebookGuid(const QString &notebookGuid);

    QString title() const;
    void setTitle(const QString &title);

    QString content() const;
    void setContent(const QString &content);

public slots:
    void save();
    void remove();

signals:
    void guidChanged();
    void titleChanged();
    void notebookGuidChanged();
    void contentChanged();

private:
    QString m_guid;
    QString m_notebookGuid;
    QString m_title;
    QString m_content;
};

#endif // NOTE_H