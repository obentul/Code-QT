#ifndef GLOGGER_H
#define GLOGGER_H

#include "../include/glog/logging.h"
#include "../include/glog/raw_logging.h"

#define GLOG_FOLDER ".//log//"     //./log
#define GLOG_INFO_PATH ".//log//info" //设置 google::INFO 级别的日志存储路径和文件名前缀

class Glogger
{
public:
    Glogger();
    Glogger(char* program);
    ~Glogger(void);
};

#endif // GLOGGER_H
