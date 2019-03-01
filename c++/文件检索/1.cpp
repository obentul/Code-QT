#include "searchfile.h"
#include <QDir>
#include <QStringList>
#include <QDirIterator>
#include <QFileInfo>
#include <QProcess>
#include <QApplication>

#include <QDebug>

SearchFile::SearchFile(QObject *parent) : QObject(parent)
{
}

QString SearchFile::FindFile(const QString &strFilePath, const QString &strNameFilters)
{
     if (strFilePath.isEmpty())
     {
         return QString();
     }

     QDir dir;
     QStringList filters;

     filters << strNameFilters;
     dir.setPath(strFilePath);
     dir.setNameFilters(filters);
     QDirIterator iter(dir,QDirIterator::Subdirectories);

     QStringList fileNames;

     while (iter.hasNext())
     {
         iter.next();
         QFileInfo info=iter.fileInfo();
         if (info.isFile())
         {
             fileNames << info.fileName();
         }
     }

     return fileNames.join(",");
}

void SearchFile::doWord(const QString &strFileName)
{
    QStringList list;
    list<<strFileName;

    QString filepath=strFileName;

    QAxWidget word("Word.Application");
    word.setWindowFlags(Qt::WindowStaysOnTopHint);
    QApplication::processEvents();
    QAxObject *document =word.querySubObject("Documents");
    QApplication::processEvents();
    document->dynamicCall("Open(const QString&)",QString(filepath));
    QApplication::processEvents();

    word.setProperty("Visible", true);
    word.setWindowFlags(Qt::WindowStaysOnTopHint);
    QApplication::processEvents();
}




