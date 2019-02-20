TEMPLATE = app

QT += qml quick
CONFIG += c++11

DEFINES += GLOG_NO_ABBREVIATED_SEVERITIES

SOURCES += main.cpp \
    src/utility/glogger.cpp

INCLUDEPATH += \
    src \
    src/utility \
    ../include \
    ../include/glog


RESOURCES += qml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Default rules for deployment.
include(deployment.pri)

win32: LIBS += -L$$PWD/../lib/glog/ -lglog

INCLUDEPATH += $$PWD/../include/glog
DEPENDPATH += $$PWD/../lib/glog

win32:!win32-g++: PRE_TARGETDEPS += $$PWD/../lib/glog/glog.lib
else:win32-g++: PRE_TARGETDEPS += $$PWD/../lib/glog/libglog.a

HEADERS += \
    src/utility/glogger.h \
    ../include/glog/log_severity.h \
    ../include/glog/logging.h \
    ../include/glog/raw_logging.h \
    ../include/glog/stl_logging.h \
    ../include/glog/vlog_is_on.h
