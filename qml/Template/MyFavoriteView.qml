import QtQuick 2.0
import mywindow 1.0
import utility 1.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import addrCommand 1.0
import "../pages"
import "../panels"
import "./"

Rectangle {
        id:favorPanel
        objectName: "favorPanel"
        anchors.margins: 2
        anchors.fill: parent
        radius: 4
        visible: true//可视的
        property var tmpfavorinfo
        property var curAddrInfo
        property var tmpaddrinfoutype       //在添加到收藏夹的时候，选择的时候是不能入数据库的，但是此时又必须实时更新待入model和数据库的item，所以需要存一些临时变量
                                            //但是考虑到对象的深浅拷贝问题，为了简化代码，这里就把必要的字段单独拉出来暂存(而不是一次性暂存一个对象)
        property int m_oprBtnStatus
        property var e_StatusType
        property string m_curUid:"null"
        property string m_oldUid:"null"
        property int m_processNUM:0//记录分发中（等待中或成功的）个数，用于改变按键状态
        property bool m_isGotResult:true
        property var e_nodeType : {
            "UE_NODE": "1",         //终端
            "GROUP_NODE": "2",      //组(预留，防止以后要求整个组收藏)
            "DAC_NODE": "4",        //？？？
            "CAMERA_NODE": "5",     //摄像头
            "ORG_NODE": "100",      //？？？
            "LEVAL_ORG_NODE":"200", //？？？
            "FAVORITE_NODE":"400"   //收藏夹
        }
        property string currentID   //当前选中column的id，用来实现“选中变色”功能

        property string showwhat: "ALL"
        property string showwhere: "AddrPanel"
        property bool m_isinput:false

        property FavoriteInfo tmpItem


//-------------------------function-----------------------------------------

        //-----------------删除按键------------------
        function deleteItem(item){//从视图和数据库中删除item对应的节点
            console.log("deleteItem")
            //1 - 从视图中删除
            if(item.utype==="400")
            {
//                console.log("--------removeFromRoot--------")
//                console.log("favorgroupid:"+item.favorgroupid)
//                console.log("uid:"+item.uid)
//                console.log("favorgroupname:"+item.favorgroupname)
//                console.log("name:"+item.name)
//                console.log("utype:"+item.utype)
//                console.log("id:"+item.id)
                removeFromRoot(item)
            }
            if(item.utype===e_nodeType.UE_NODE||item.utype===e_nodeType.CAMERA_NODE)
            {
//                console.log("--------removeFromDir--------")
//                console.log("favorgroupid:"+item.favorgroupid)
//                console.log("uid:"+item.uid)
//                console.log("favorgroupname:"+item.favorgroupname)
//                console.log("name:"+item.name)
//                console.log("utype:"+item.utype)
//                console.log("id:"+item.id)
                removeFromDir(item)
            }
            //2 - 从数据库中删除
            myDbHelper.deleteData("T_Favorite",item);
        }
        function removeFromRoot(item){//删除目录节点
            var index=indexOfDir(item)
            favorListModel.remove(index);
        }
        function removeFromDir(item){//删除设备节点
            var index_dir=indexOfDir(item)
            var index=indexOfItem(item)
            favorListModel.get(index_dir).subNode.remove(index);
        }
        //-----------------删除按键------------------

        //-----------------改名按键-----------------
        function updateItem(item_src,item_dest){//更新视图和数据库中item对应节点
            //update数据库中所有groupid为item的记录
            console.log("updateItem")
            if(item_src.utype==="400")
            {
                console.log("favorgroupid:"+item_src.favorgroupid+"->"+item_dest.favorgroupid)
                console.log("uid:"+item_src.uid+"->"+item_dest.uid)
                console.log("favorgroupname:"+item_src.favorgroupname+"->"+item_dest.favorgroupname)
                console.log("name:"+item_src.name+"->"+item_dest.name)
                console.log("utype:"+item_src.utype+"->"+item_dest.utype)
                console.log("id:"+item_src.id+"->"+item_dest.id)
                setDir(item_src,item_dest)
            }
            if(item_src.utype===e_nodeType.UE_NODE||item_src.utype===e_nodeType.CAMERA_NODE)
            {
                console.log("favorgroupid:"+item_src.favorgroupid+"->"+item_dest.favorgroupid)
                console.log("uid:"+item_src.uid+"->"+item_dest.uid)
                console.log("favorgroupname:"+item_src.favorgroupname+"->"+item_dest.favorgroupname)
                console.log("name:"+item_src.name+"->"+item_dest.name)
                console.log("utype:"+item_src.utype+"->"+item_dest.utype)
                console.log("id:"+item_src.id+"->"+item_dest.id)
                setItem(item_src,item_dest)
            }
            //发送数据库操作
            myDbHelper.updateData("T_Favorite",item_src,item_dest);
        }
        function setDir(item_src,item_dest){//更新目录节点
            var index = indexOfDir(item_src)
            console.log("setDir:"+index)
            favorListModel.set(index,{"name":item_dest.favorgroupname,"obj_item":item_dest});
        }
        function setItem(item_src,item_dest){//更新设备节点
            var index_dir = indexOfDir(item_src)
            var index=indexOfItem(item_src)
            console.log("setItem")
            favorListModel.get(index_dir).subNode.set(index,{"name":item_dest.name,"obj_item":item_dest});
        }
        //-----------------改名按键-----------------

        //-----------------插树操作--------------------
        function insertItem(item){//插入一条数据到视图和数据库中
            console.log("insertItem")
            console.log("favorgroupid:"+item.favorgroupid)
            console.log("uid:"+item.uid)
            console.log("favorgroupname:"+item.favorgroupname)
            console.log("name:"+item.name)
            console.log("utype:"+item.utype)
            console.log("id:"+item.id)

            //写入model(可以考虑省去)
            appendItem(item);
            //写入数据库
            myDbHelper.insertData("T_Favorite",item);
            //给panel的树发送一个刷新数据的信号，重新从数据库中获取数据
        }
        function appendItem(item){//向树中加入一个节点(可以是dir，也可以是node)
            if(item.utype==="400")
            {
                appendToRoot(item);
            }
            if(item.utype===e_nodeType.UE_NODE||item.utype===e_nodeType.CAMERA_NODE)
            {
                appendToDir(item);
            }
        }
        function appendToRoot(item){//向树中增加一个dir
            console.log("--------appendToRoot--------")
            console.log("username:"+item.username)
            console.log("favorgroupid:"+item.favorgroupid)
            console.log("uid:"+item.uid)
            console.log("favorgroupname:"+item.favorgroupname)
            console.log("name:"+item.name)
            console.log("utype:"+item.utype)
            console.log("id:"+item.id)
            favorListModel.append({"name":item.favorgroupname,"obj_item":item,"level":0,"subNode":[]})
        }
        function appendToDir(item){//向dir中增加一个节点
            var index = indexOfDir(item)
            console.log("--------appendToDir--------")
            console.log("username:"+item.username)
            console.log("favorgroupid:"+item.favorgroupid)
            console.log("uid:"+item.uid)
            console.log("favorgroupname:"+item.favorgroupname)
            console.log("name:"+item.name)
            console.log("utype:"+item.utype)
            console.log("id:"+item.id)
            favorListModel.get(index).subNode.append({"name":item.name,"obj_item":item,"level":1,"subNode":[]});
        }
        //-----------------插树操作--------------------

        function createdir(){
            var n=1;
            console.log("createdir");

            var tmp = myAddrCommand.createFavoriteInfo();
            tmp.utype="400"
            tmp.favorgroupid=myMDCCommand.Language?"新建文件夹":"New Directory";
            tmp.favorgroupname=myMDCCommand.Language?"新建文件夹":"New Directory";
            tmp.id=tmp.name+tmp.uid+tmp.favorgroupname;

            while(1){
                if(conflictcheck(tmp)===0)//找到，冲突，不可用
                {
                    console.log("冲突，不可用："+tmp.favorgroupname);
                    tmp.favorgroupid=myMDCCommand.Language?"新建文件夹":"New Directory"+n.toString();
                    tmp.favorgroupname=myMDCCommand.Language?"新建文件夹":"New Directory"+n.toString();
                    tmp.id=tmp.name+tmp.uid+tmp.favorgroupname;
                    console.log("再次尝试："+tmp.favorgroupname);
                    n++;
                    continue;
                }
                else
                {
                    console.log("不冲突，可用："+tmp.favorgroupname);
                    break;
                }
            }
            insertItem(tmp);
        }
        function indexOfDir(item){//根据收藏夹名，查找对应的index
            var favorgroupname=item.favorgroupname;
            for(var i=0,len=favorListModel.count;i<len;i++){
                if(favorListModel.get(i).name===favorgroupname)
                {
                    console.log("[indexOfDir]matched index:"+i);
                    return i;
                }
                else
                continue;
            }
            console.log("can not find "+favorgroupname+"'s index");
            return -1;
        }
        function indexOfItem(item){//根据节点名,查找对应的index
            var name=item.name;
            var i = indexOfDir(item)
            //找到在自己组中的index
            for(var j=0,lenj=favorListModel.get(i).subNode.count;j<lenj;j++){
                if(favorListModel.get(i).subNode.get(j).name===name){
                    console.log("[indexOfItem]matched index j:"+j);
                    return j;
                }
                else
                continue;
            }
            console.log("can not find "+id+"'s index");
            return -1;
        }
        function refreshdir(){//刷新树
            //myFavorCommand.queryFavoriteDir(myMDCCommand.userName);
            console.log("refreshdir")
        }
        function conflictcheck(item){//检查item在model中是否已经存在
            if(indexOfDir(item)===-1)
            {
                console.log("没找到"+item.favorgroupname)
                return 1;
            }
            else
            {
                console.log("找到"+item.favorgroupname)
                return 0;
            }
        }
        function deepClone(initalObj, finalObj) {
          var obj = finalObj || {};
          for (var i in initalObj) {
            var prop = initalObj[i];        // 避免相互引用对象导致死循环，如initalObj.a = initalObj的情况
            if(prop === obj) {
              continue;
            }
            if (typeof prop === 'object') {
              obj[i] = (prop.constructor === Array) ? [] : Object.create(prop);
            } else {
              obj[i] = prop;
            }
          }
          return obj;
        }
        function favoriteTreeInit(){
            console.log("favoriteTreeInit start");
            //必须先加载dir，否则节点找不到对应的index
            myAddrCommand.queryFavoriteDir(myMDCCommand.userName);
            myAddrCommand.showFavoriteDir();
            myAddrCommand.queryFavoriteTree(myMDCCommand.userName);
            myAddrCommand.showFavoriteTree();
            console.log("favoriteTreeInit end");
        }
//-------------------------function-----------------------------------------


        MouseArea{
            anchors.fill: parent
            onPressed: {
                console.log("myfavoriteview");
                myVideoCommand.showFavorViewTop();
                mouse.accepted = false;
            }
        }

        //加个定时器保护一下
        Timer {
             interval: 2*1000;
             running: !m_isGotResult;
             repeat: false
             triggeredOnStart: false
             onTriggered: {
                 m_isGotResult = true;
             }
        }

        //绑定槽函数
        Connections{
            target: myAddrCommand
            onAddFavorItem:{
                //数据库中每一条数据
                console.log("onAddFavorItem")
                appendToDir(item)
            }
            onAddFavorItemDir:{
                //所有收藏夹信息
                console.log("onAddFavorItemDir")
                appendToRoot(item)
            }
        }

        Connections{
            target:myVideoCommand
            onResetFavorListModel:{
                console.log("onClearModel")
                favorListModel.clear();
                favoriteTreeInit();
            }
            onShowWhat:{
                showwhat = viewname;    //viewname由信号传递过来
                console.log("showView:"+showwhat);
            }
            onShowWhere:{
                showwhere = appendto;
                console.log("appendto:"+showwhere)
            }
            onCurUidChanged:{
                m_curUid = uid;
                console.log("CurUid:"+m_curUid);
                curAddrInfo = myAddrCommand.getAddrInfoByUId(m_curUid);
            }
        }

        Component.onCompleted:{
            console.log("MyFavoriteView.qml Component.onCompleted");
            favorListModel.clear();
            favoriteTreeInit();
        }

        Rectangle{ //标题，最上面那一行
            id:titalBar
            anchors.left: parent.left
            anchors.top: parent.top
            width:parent.width
            height:36
            color:"#D9DBDC"

            Label {//收藏/收藏管理
                anchors.left: parent.left
                anchors.leftMargin: 18
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: 14
                font.family: myMDCCommand.Language?"微软雅黑":"Arial"
                color:"#697d8d"
                text:showwhat==="DIR1"?(myMDCCommand.Language?"收藏":"Favorite"):(myMDCCommand.Language?"收藏管理":"Favorite Management")
            }

            Button{//关闭窗口的按钮
                id:image_quit_icon
                width: 24
                height:24
                anchors.right: parent.right
                anchors.rightMargin: 4
                anchors.top: parent.top
                anchors.topMargin: 6
                style: ButtonStyle{
                    background: Item{
                        anchors.fill: parent
                        Image{
                            source:(control.hovered)?"qrc:/images/popup/popup_exit_h.png":(control.pressed?"qrc:/images/popup/popup_exit_p.png":"qrc:/images/popup/popup_exit_n.png")
                        }
                    }
                }
                onClicked:{
                    currentID="null"                        //清除当前指向，避免每次弹窗都是上次离开时的选择条目
                    SingletonDevOperaForMap.closeView()     //清除收藏管理底纹
                    myVideoCommand.isFavorPanelVis = false  //[yangkun][注释]关闭窗口
                    myDbHelper.rollback();
                }
            }
        }

        Canvas {//标题下面的那条线
              id: line
              width: parent.width
              height: 1
              anchors.left:parent.left
              anchors.top:titalBar.bottom
              onPaint: {
                  var ctx = getContext("2d");
                  ctx.fillStyle = "#b8c7d3";
                  ctx.fillRect(0, 0, width, height);
              }
        }

        Rectangle{//摄像头那一行
            id:videoSourceRect
            anchors.top: line.bottom
            anchors.topMargin: 14
            anchors.left: parent.left
            anchors.leftMargin: 18
            anchors.right: parent.right
            anchors.rightMargin: 18
            height:showwhat==="DIR1"?(16+14):0  //字高+14
            color:"white"
            visible: showwhat==="DIR1"?true:false

            Label {//文字"摄像头"
                id:videoSourceLab
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: 16
                font.family: myMDCCommand.Language?"微软雅黑":"Arial"
                color:"#000000"
                text:curAddrInfo.name
            }
        }

        Text {//新建文件夹
             id:newdir
             anchors.top:videoSourceRect.bottom
             anchors.left: videoSourceRect.left
             text:myMDCCommand.Language?"新建文件夹":"New Directory"
             font.family: myMDCCommand.Language?"微软雅黑":"Arial"
             color: "#1299ff"
             MouseArea{
                 anchors.fill: parent
                 hoverEnabled: true
                 onEntered: {
                     newdir.color="#0078da"
                 }
                 onExited: {
                     newdir.color="#1299ff"
                 }
                 onClicked:{
                     createdir();
                 }
             }
         }

        Canvas {//新建文件夹下面那条线
                id: line_1
                height: 1
                anchors.left:newdir.left
                anchors.right:newdir.right
                anchors.top:newdir.bottom
                onPaint: {
                      var ctx = getContext("2d");
                      ctx.fillStyle = newdir.color;
                      ctx.fillRect(0, 0, width, height);
                }
        }

        Rectangle{//保存按钮 - alltree
            id:s_btn
            width:parent.width/2
            height: 51
            anchors.right: parent.right
            anchors.bottom: favorPanel.bottom
            color: "#57abeb"
            visible:showwhat==="ALL"?true:false
            Text{
                anchors.centerIn: parent
                color: "white"
                text:myMDCCommand.Language?"保存":"Save"
                font.pixelSize: 18
                font.family: myMDCCommand.Language?"微软雅黑":"Arial"
            }
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    console.log("click save button - 1")
                    SingletonDevOperaForMap.closeView()     //清除收藏管理底纹
                    currentID="null"
                    myVideoCommand.isFavorPanelVis = false
                    myDbHelper.commit();
                    myAddrCommand.refreshFavor();
                }
            }
        }

        Rectangle{//保存按钮 - dironly
            id:s_btn_1
            width:parent.width/2
            height: 51
            anchors.right: parent.right
            anchors.bottom: favorPanel.bottom
            color: "#57abeb"
            visible:showwhat==="DIR1"?true:false

            Text{
                anchors.centerIn: parent
                color: "white"
                text:myMDCCommand.Language?"保存":"Save"
                font.pixelSize: 18
                font.family: myMDCCommand.Language?"微软雅黑":"Arial"
            }
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    console.log("click save button - 2"+s_btn_1.height);
                    SingletonDevOperaForMap.closeView()     //清除收藏管理底纹
                    currentID="null";
                    myVideoCommand.isFavorPanelVis = false
                    myDbHelper.commit();
                    tmpfavorinfo.utype=tmpaddrinfoutype   //还原到可以入数据库的数据结构(这里的utype为当前uid在addrinfo中的utype)
                    insertItem(tmpfavorinfo);
                    myDbHelper.commit();
                    myAddrCommand.refreshFavor();
                }
            }
        }

        Rectangle{//取消按钮
            id:c_btn
            width:parent.width/2
            height: 51
            anchors.left: parent.left
            anchors.bottom: favorPanel.bottom
            color:"#D9DBDC"
            Text{
                anchors.centerIn: parent
                text:myMDCCommand.Language?"取消":"Cancle"
                font.pixelSize: 18
                font.family: myMDCCommand.Language?"微软雅黑":"Arial"
            }
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    SingletonDevOperaForMap.closeView()
                    currentID="null"
                    myVideoCommand.isFavorPanelVis = false
                    myDbHelper.rollback();
                }
            }
        }

        Rectangle{//View
            id:rec_view
            anchors.top: newdir.bottom
            anchors.topMargin: 10
            anchors.left: parent.left
            anchors.leftMargin: 18
            anchors.right: parent.right
            anchors.rightMargin: 18
            anchors.bottom: c_btn.top
            anchors.bottomMargin: 18
            //color: "#D9DBDC"
            visible:showwhat==="ALL"?true:false

            MyScrollView{//滑动窗体View
                id:scrollView
                anchors.fill: parent        //填充满wapper
                bgColor:"#000000"
                selColor: "#0779d0"
                normalColor: "#57abeb"
                visible: showwhat==="ALL"?true:false

                ListView{//展示整棵树
                   id: wholetree
                   anchors.fill: parent
                   orientation:  ListView.Vertical
                   cacheBuffer:  20
                   clip:true
                   visible: showwhat==="ALL"?true:false
                   model:favorListModel
                   delegate:wholetreeDelegate
                   Component.onCompleted: {
                       console.log("wholetree:"+visible)
                   }
                }
            }
        }

        Rectangle{//View
            id:rec_view_1
            anchors.top: newdir.bottom
            anchors.topMargin: 10
            anchors.left: parent.left
            anchors.leftMargin: 18
            anchors.right: parent.right
            anchors.rightMargin: 18
            anchors.bottom: c_btn.top
            anchors.bottomMargin: 18
            visible:showwhat==="DIR1"?true:false
            //color: "#D9DBDC"

            MyScrollView{//滑动窗体View
                id:scrollView_1
                anchors.fill: parent        //填充满wapper
                bgColor:"#000000"
                selColor: "#0779d0"
                normalColor: "#57abeb"
                visible: showwhat==="DIR1"?true:false

                ListView{//只展示一级目录
                   id: dironly
                   anchors.fill: parent
                   orientation:  ListView.Vertical
                   cacheBuffer:  20
                   clip:true
                   visible: showwhat==="DIR1"?true:false
                   model:favorListModel
                   delegate:dir1onlyDelegate
                   Component.onCompleted: {
                       console.log("dironly:"+visible)
                   }
                }
            }
        }


        ListModel{//model
            id:favorListModel
        }

        Component{//delegate -- alltree
            id:wholetreeDelegate
            Column{
                id:objRecursiveColumn
                clip:true
                property FavoriteInfo curItem: obj_item
                property string utype: curItem.utype
                property bool isSelected:wholetree.currentIndex === index ? true : false
                property bool isFocused:false
                property bool iscliped:false

                MouseArea {//wrapper的MouseArea
                   width: objRow.implicitWidth
                   height: objRow.implicitHeight
                   propagateComposedEvents:true //向下传递
                   onEntered: {
                           isFocused = true
                   }
                   onExited:  {
                           isFocused = false
                   }
                   onClicked:{
                       currentID=curItem.id
                       iscliped=!iscliped;
                       if(curItem.utype==="400")
                       {
                           for(var i = 1; i < parent.children.length - 1; ++i) {
                              parent.children[i].visible = !parent.children[i].visible;
                           }
                       }
                   }

                   Row {
                     id: objRow
                     Rectangle{
                            id:objDisplayRowRect
                            height: 24
                            width:340-36-12
                            color: currentID===curItem.id?"#bbddf6":"#EAEDEE"

                            Rectangle{//缩进
                                id:objIndentation
                                width: level*20
                                height: parent.height
                                anchors.left: parent.left
                                color: objDisplayRowRect.color
                            }
                            Rectangle{//三角图标
                                id:favortriangleImg
                                width:18
                                height:18
                                anchors.left: objIndentation.right
                                anchors.leftMargin: 6
                                visible: curItem.utype==="400"?true:false
                                color:objDisplayRowRect.color
                                Image{
                                    anchors.fill: parent
                                    source:
                                    {
                                        if(iscliped)
                                        {
                                            return "/images/treeview/tree_triangle2.png"
                                        }
                                        else
                                        {
                                            return "/images/treeview/tree_triangle.png"
                                        }
                                    }
                                }
                            }
                            Text{//name/favoritegroupname
                                id:objNodeName
                                text:curItem.utype==="400"?curItem.favorgroupname:curItem.name
                                anchors.left: favortriangleImg.right;
                                anchors.leftMargin: 5;
                                anchors.top: parent.top;
                                anchors.bottom: parent.bottom;
                                font { pixelSize: 14 }
                                font.family: myMDCCommand.Language?"微软雅黑":"Arial"
                                color: "#24344e"
                                verticalAlignment: Text.AlignVCenter
                                visible: true
                            }
                            Rectangle{
                                id:renameRect
                                anchors.left: objNodeName.left;
                                anchors.leftMargin: -2
                                anchors.top: parent.top;
                                anchors.bottom: parent.bottom;
                                width:180
                                border.color: "#bbddf6"
                                border.width:1
                                visible:false
                                color:"white"

                                TextInput{
                                    id:rename
                                    visible:false
                                    text: curItem.utype==="400"?curItem.favorgroupname:curItem.name
                                    anchors.left: parent.left
                                    anchors.leftMargin: 2
                                    anchors.top: parent.top
                                    anchors.topMargin: 2
                                    anchors.bottom: parent.bottom
                                    anchors.bottomMargin: 2
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.fill: parent
                                    selectByMouse: true
                                    selectedTextColor: "#bbddf6"
                                    font { pixelSize: 14 }
                                    font.family: myMDCCommand.Language?"微软雅黑":"Arial"
                                    color:"#000000"

                                    onActiveFocusChanged:{
                                        if (activeFocus){
                                            rename.selectAll();//选择所有文本
                                        }
                                        else{
                                            emit: rename.onAccepted();
                                        }
                                    }

                                    onAccepted:{
                                        var destItem=myAddrCommand.createFavoriteInfo()
                                        if(curItem.utype==="400"){
                                           destItem.favorgroupname=rename.text;
                                           destItem.favorgroupid=rename.text;
                                           destItem.utype="400"
                                           destItem.id=destItem.favorgroupname  //这里的id暂时只需要收藏夹名，lineNo会在从数据库中拿数据的时候添加到前面
                                                                                //因为在当前树下面，数据会被默认append，所以不需要考虑排序问题
                                        }
                                        //改终端名字暂未开放
                                        if(curItem.utype===e_nodeType.UE_NODE||curItem.utype===e_nodeType.CAMERA_NODE){
                                           destItem.name=rename.text
                                           destItem.utype=curItem.utype
                                           destItem.id=curItem.name+curItem.uid+destItem.favorgroupname
                                        }
                                        updateItem(curItem,destItem);
                                        rename.visible=false
                                        renameRect.visible=false
                                        objNodeName.visible=true
                                    }
                                }
                            }

                            Button{//改名图标
                                id:modiBt
                                width:18
                                height:18
                                tooltip:myMDCCommand.Language?"修改":"Rename"
                                anchors.right: delBt.left
                                anchors.rightMargin: 3
                                anchors.verticalCenter: parent.verticalCenter
                                visible:curItem.utype==="400"?true:false    //节点暂不开放改名
                                style: ButtonStyle{
                                        background: Rectangle{
                                        color:objDisplayRowRect.color
                                        anchors.fill: parent
                                        Image{
                                            source:(control.hovered || control.pressed)?"qrc:/images/elecFence/icon18px_edit_h.png":"qrc:/images/elecFence/icon18px_edit.png"
                                        }
                                    }
                                }
                                onClicked:{
                                        renameRect.visible=true
                                        rename.visible=true
                                        rename.z=renameRect.z+1
                                        objNodeName.visible=false
                                }
                            }
                            Button{//删除图标
                                id:delBt
                                tooltip:myMDCCommand.Language?"删除":"Delete"
                                width:18
                                height:18
                                anchors.right: parent.right
                                anchors.rightMargin: 3
                                anchors.verticalCenter: parent.verticalCenter
                                style: ButtonStyle{
                                        background: Rectangle{
                                        color:objDisplayRowRect.color
                                        anchors.fill: parent
                                        Image{
                                            source:(control.hovered || control.pressed)?"qrc:/images/elecFence/icon18px_del_h.png":"qrc:/images/elecFence/icon18px_del.png"
                                        }
                                    }
                                }
                                onClicked:{
                                        deleteItem(curItem);
                                }
                           }
                        }
                    }
                }
                Repeater{
                    anchors.fill: parent
                    model:subNode
                    delegate: wholetreeDelegate
                }
            }
        }

        Component{//delegate -- 一级目录
            id:dir1onlyDelegate
            Column{
                id:objRecursiveColumn_1
                clip:true
                property FavoriteInfo curItem: obj_item
                property string utype: curItem.utype
                property bool isSelected:dironly.currentIndex === index ? true : false
                property bool isFocused:false
                property bool iscliped:false

                MouseArea {//wrapper的MouseArea
                   width: objRow_1.implicitWidth
                   height: objRow_1.implicitHeight
                   propagateComposedEvents:true
                   onEntered: {
                           isFocused = true
                   }
                   onExited:  {
                           isFocused = false
                   }
                   onClicked:{
                       tmpfavorinfo =curItem;
                       var tmpaddrinfo = myAddrCommand.getAddrInfoByUId(m_curUid);
                       currentID=curItem.id
                       tmpfavorinfo.uid=m_curUid;
                       tmpfavorinfo.name=tmpaddrinfo.name;
                       tmpaddrinfoutype=tmpaddrinfo.utype;
                   }

                   Row {
                     id: objRow_1
                     Rectangle{
                            id:objDisplayRowRect_1
                            height: 24
                            width:340-36-12
                            color: currentID===curItem.id?"#bbddf6":"#D9DBDC"

                            Text{//favoritegroupname
                                id:objNodeName_1
                                text:curItem.utype==="400"?curItem.favorgroupname:curItem.name
                                anchors.left: objDisplayRowRect_1.left;
                                anchors.leftMargin: 5
                                anchors.top: parent.top;
                                anchors.bottom: parent.bottom;
                                font { pixelSize: 14 }
                                font.family: myMDCCommand.Language?"微软雅黑":"Arial"
                                color: "#24344e"
                                verticalAlignment: Text.AlignVCenter
                                visible: true
                            }

                            Rectangle{
                                id:renameRect_1
                                anchors.left: objNodeName_1.left;
                                anchors.leftMargin: -2
                                anchors.top: parent.top;
                                anchors.bottom: parent.bottom;
                                width:180
                                border.color: "#bbddf6"
                                border.width:1
                                visible:false
                                color:"white"

                                TextInput{
                                    id:rename_1
                                    visible:false
                                    text: curItem.favorgroupname
                                    anchors.leftMargin: 2
                                    anchors.top: parent.top
                                    anchors.topMargin: 2
                                    anchors.bottom: parent.bottom
                                    anchors.bottomMargin: 2
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.fill: parent
                                    selectByMouse: true
                                    selectedTextColor: "#bbddf6"
                                    font { pixelSize: 14 }
                                    font.family: myMDCCommand.Language?"微软雅黑":"Arial"
                                    color:"#000000"

                                    onAccepted:{
                                        var destItem=myAddrCommand.createFavoriteInfo()
                                        if(curItem.utype==="400"){
                                           destItem.favorgroupname=rename_1.text;
                                           destItem.favorgroupid=rename_1.text;
                                           destItem.utype="400"
                                           destItem.id=destItem.favorgroupname
                                        }
                                        if(curItem.utype===e_nodeType.UE_NODE||curItem.utype===e_nodeType.CAMERA_NODE){
                                           destItem.name=rename_1.text
                                           destItem.utype=curItem.utype
                                           destItem.id=curItem.name+curItem.uid+destItem.favorgroupname
                                        }
                                        updateItem(curItem,destItem);
                                        rename_1.visible=false
                                        renameRect_1.visible=false
                                        objNodeName_1.visible=true
                                    }
                                }
                            }

                            Button{//改名图标
                                id:modiBt
                                width:18
                                height:18
                                tooltip:myMDCCommand.Language?"修改":"Rename"
                                anchors.right: delBt.left
                                anchors.rightMargin: 3
                                anchors.verticalCenter: parent.verticalCenter
                                style: ButtonStyle{
                                        background: Rectangle{
                                        color: objDisplayRowRect_1.color
                                        anchors.fill: parent
                                        Image{
                                            source:(control.hovered || control.pressed)?"qrc:/images/elecFence/icon18px_edit_h.png":"qrc:/images/elecFence/icon18px_edit.png"
                                        }
                                    }
                                }
                                onClicked:{
                                    renameRect_1.visible=true
                                    rename_1.visible=true
                                    rename_1.z=renameRect_1.z+1
                                    objNodeName_1.visible=false
                                }
                            }
                            Button{//删除图标
                                id:delBt
                                tooltip:myMDCCommand.Language?"删除":"Delete"
                                width:18
                                height:18
                                anchors.right: parent.right
                                anchors.rightMargin: 3
                                anchors.verticalCenter: parent.verticalCenter
                                style: ButtonStyle{
                                        background: Rectangle{
                                        color: objDisplayRowRect_1.color
                                        anchors.fill: parent
                                        Image{
                                            source:(control.hovered || control.pressed)?"qrc:/images/elecFence/icon18px_del_h.png":"qrc:/images/elecFence/icon18px_del.png"
                                        }
                                    }
                                }
                                onClicked:{
                                        deleteItem(curItem);
                                }
                            }
                        }
                    }
                }
            }
        }
}










