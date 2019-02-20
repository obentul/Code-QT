#include <iostream>
#include <fstream>
#include <direct.h>
#include "glogger.h"

int createDirect(const char * dirName)
{
    std::fstream _file;
    _file.open(dirName,std::ios::in);

    if(!_file)//打开失败，则创建日志目录
    {
        return _mkdir(dirName);
    }
    else
    {
        return 0;
    }
}


Glogger::Glogger()
{

}


static void writeCoreInfo(const char* data, int size)
{
    if ((NULL == data) || (size <= 0)) return;
    //static int coreID = 0;
    //char szFileName[100] = { 0 };
    //sprintf(szFileName, "%s.%d", "cs_core", coreID);
    //FILE* pCoreFile = fopen(szFileName, "w");
    //if (pCoreFile)
    //{
    //	fwrite(data, 1, size, pCoreFile);
    //	fflush(pCoreFile);
    //	fclose(pCoreFile);
    //}
    //++coreID;
}

Glogger::Glogger(char* program)
{
    google::InitGoogleLogging(program);

    //google::InstallFailureSignalHandler();
    //google::InstallFailureWriter(writeCoreInfo);

    createDirect(GLOG_FOLDER);

    //614004656562 mediaclient日志位置修改 wyk
    google::SetLogDestination(google::GLOG_INFO,    GLOG_INFO_PATH); //设置 google::INFO 级别的日志存储路径和文件名前缀
    //google::SetLogDestination(google::GLOG_WARNING, GLOG_WARN_PATH); //设置 google::WARNING 级别的日志存储路径和文件名前缀
    //google::SetLogDestination(google::GLOG_ERROR,   GLOG_ERROR_PATH); //设置 google::ERROR 级别的日志存储路径和文件名前缀

    FLAGS_logbufsecs = 0;                                             //缓冲日志输出，默认为30秒，此处改为立即输出
    FLAGS_max_log_size = 100;                                         //最大日志大小为 100MB
    FLAGS_stop_logging_if_full_disk = true;                           //当磁盘被写满时，停止日志输出
}


Glogger::~Glogger(void)
{
    google::ShutdownGoogleLogging();
}
