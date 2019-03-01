#ifndef SEARCHFILE_H
#define SEARCHFILE_H
#include <QObject>
#include <QAxWidget>
#include <QAxObject>

class SearchFile : public QObject
{
    Q_OBJECT
public:
    explicit SearchFile(QObject *parent = 0);

signals:

public slots:
    QString FindFile(const QString &strFilePath, const QString &strNameFilters);
    void doWord(const QString &strFileName);
};

#endif // SEARCHFILE_H

