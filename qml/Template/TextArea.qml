                TextArea {
                    id:input
                    anchors.fill: parent
                    anchors.margins: 5
                    //height: 80
                    //width: 300
                    height: 100
                    width: 320
                    clip:true
                    selectByMouse: true
                    menu:null

                    wrapMode: TextEdit.Wrap
                    property int maxLength: 512//最大输入长度
                    text: myMDCCommand.Language?"请输入消息内容(最长512字符)":"Please enter the message content(up to 512 characters)"

                    font.pixelSize: 14
                    font.family: myMDCCommand.Language?"微软雅黑":"Arial"
                    textColor:activeFocus?"#24344e":"#557392"

                    Keys.onPressed: {
                        if (event.key == Qt.Key_Enter || event.key == Qt.Key_Return)
                        {
                            if (myuid == "")
                            {
                                myMDCCommand.showWarningInfo(myMDCCommand.Language?"请从组织树中选择发送对象！":"Please select the sending object from the organization tree!");
                                return;
                            }

                            var senddata = input.text

                            if (senddata === "" || senddata === "请输入消息内容(最长512字符)" || senddata === "Please enter the message content(up to 512 characters)")
                            {
                                myMDCCommand.showWarningInfo(myMDCCommand.Language?"请输入发送内容！":"please input content to be sent");
                                input.text = "";
                                event.accepted = true;
                                return;
                            }
                            console.log("Keys.onPressed")
                            //myMMediaCommand.sendmessage(myuid, senddata);
                            //input.text = "";
                            //event.accepted = true;
                        }
                    }

                    onActiveFocusChanged: {
                        if (activeFocus)
                        {
                            if ((text == "请输入消息内容(最长512字符)") || (text =="Please enter the message content(up to 512 characters)"))
                            {
                                text = ""
                            }
                        }
                        else
                        {
                            if (text === "")
                            {
                                text = myMDCCommand.Language?"请输入消息内容(最长512字符)":"Please enter the message content(up to 512 characters)"
                            }
                        }
                    }

                    onTextChanged:
                    {
                        var i,sum;
                        sum=0;
                        var strTemp = input.text;
                        for(i=0;i<strTemp.length;i++){
                            if ((strTemp.charCodeAt(i)>=0) && (strTemp.charCodeAt(i)<=255)){
                                sum=sum+1;
                            }else{
                                sum=sum+2;
                            }
                            if (sum > maxLength)
                            {
                                break;
                            }
                        }

                        if (sum > maxLength)
                        {
                            var prePosition = cursorPosition;
                            input.text = input.text.substring(0, i);
                            cursorPosition = Math.min(prePosition, i);
                            myMDCCommand.showWarningInfo(myMDCCommand.Language?"最大输入512个字符":"Limit 512 characters");
                        }
                    }
                }
            }
