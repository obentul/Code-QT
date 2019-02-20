#include <tchar.h>
#include <windows.h>
#include <Dbghelp.h>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QString>
#include "glogger.h"

#pragma comment( lib, "DbgHelp" )

LONG WINAPI MyUnhandledExceptionFilter(struct _EXCEPTION_POINTERS* ExceptionInfo)
{
    HANDLE lhDumpFile = CreateFile(TEXT(".\\MiniFile.dmp"), GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL);
    MINIDUMP_EXCEPTION_INFORMATION loExceptionInfo;
    loExceptionInfo.ExceptionPointers = ExceptionInfo;
    loExceptionInfo.ThreadId = GetCurrentThreadId();
    loExceptionInfo.ClientPointers = TRUE;
    MiniDumpWriteDump(GetCurrentProcess(), GetCurrentProcessId(), lhDumpFile, MiniDumpNormal, &loExceptionInfo, NULL, NULL);
    CloseHandle(lhDumpFile);
    return EXCEPTION_EXECUTE_HANDLER;
}

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    SetUnhandledExceptionFilter(MyUnhandledExceptionFilter);

    char appname[50] = "obt_MediaPlayer";
    Glogger* logger = new Glogger(appname);

    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    QString *p;
    p->chop(1);

    return app.exec();
}
