//获取本机ip地址列表
QList<QString> Utility::getAddrList() const
{
    LOG(INFO)<<"getAddrList start";
    QList<QString> ipList;
    QList<QNetworkInterface> interfaceList = QNetworkInterface::allInterfaces();

    foreach(QNetworkInterface interfaceItem, interfaceList)
    {
       if(interfaceItem.flags().testFlag(QNetworkInterface::IsUp)
               &&interfaceItem.flags().testFlag(QNetworkInterface::IsRunning)
               &&interfaceItem.flags().testFlag(QNetworkInterface::CanBroadcast)
               &&interfaceItem.flags().testFlag(QNetworkInterface::CanMulticast)
               &&interfaceItem.hardwareAddress()!="00:50:56:C0:00:01"
               &&interfaceItem.hardwareAddress()!="00:50:56:C0:00:08")
       {
           QString pppIp = value("isPPP","no").toString();
           if((pppIp!="yes"?interfaceItem.flags().testFlag(QNetworkInterface::IsLoopBack):false))
           {
                continue;
           }
           QList<QNetworkAddressEntry> addressEntryList=interfaceItem.addressEntries();
           foreach(QNetworkAddressEntry addressEntryItem, addressEntryList)
           {
               if(addressEntryItem.ip().protocol()==QAbstractSocket::IPv4Protocol)
               {
                   LOG(INFO)<<"------------------------------------------------------------";
                   LOG(INFO)<<"Adapter Name:"<<interfaceItem.name().toStdString();
                   LOG(INFO)<<"IP Address:"<<addressEntryItem.ip().toString().toStdString();
                   ipList.append(addressEntryItem.ip().toString());
               }
           }
       }
    }
    return ipList;
}
