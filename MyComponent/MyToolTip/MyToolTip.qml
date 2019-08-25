import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4

Rectangle {
    id:root

    property alias bg_color:root.color                  //背景色
    property alias content:disp.text                    //需要显示的内容
    property alias contentFF:disp.font.family           //内容字体FF
    property alias contentFS:disp.font.pixelSize        //内容字体大小
//    property alias border_color:root.border.color     //找不到border.color，这里不能用,
    property alias warpmode: disp.wrapMode

    color:"#EBEEEF"
    border.color: "#767676"

    Label{
        id:disp
        text:""
        clip:true
        font.family:"Arial"
        font.pixelSize: 18
        anchors.left: root.left
        anchors.leftMargin: 6
        anchors.top: root.top
        anchors.topMargin: 4
        horizontalAlignment:Text.AlignHCenter
        verticalAlignment:Text.AlignVCenter
        wrapMode: Text.NoWrap
        onContentWidthChanged: {            //Label以内容宽度为优先，在确保内容宽度填满Label宽度的前提下才会扩展高度
            if(contentWidth>300){
                width = 300 + 4             //Label要比内容宽4
            }else{
                width = contentWidth + 4    //Label要比内容宽4
            }
            root.width = width + 16         //外包裹比Label宽16
        }
        onContentHeightChanged: {
            height = contentHeight + 4
            root.height = height + 8
        }
    }
}


