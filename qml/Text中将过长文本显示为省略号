                Text{//具体内容
                    id:contentTxt
                    anchors.top: nameTxt.bottom
                    anchors.topMargin: 8
                    anchors.left: nameTxt.left
                    width: 294
                    height: 18
                    text: content
                    color: "#697d8d"
                    font.pixelSize: 12
                    font.family: myMDCCommand.Language?"微软雅黑":"Arial"
                    elide: Text.ElideRight      //如果超过width(这里是294)，那么后面的内容用省略号显示
                }


这里主要说明elide属性，如果当前组件的宽度不够显示，那么会显示省略号




elide : enumeration

Set this property to elide parts of the text fit to the Text item's width. The text will only elide if an explicit width has been set.
This property cannot be used with rich text.
Eliding can be:
Text.ElideNone - the default
Text.ElideLeft
Text.ElideMiddle
Text.ElideRight
If this property is set to Text.ElideRight, it can be used with wrapped text. The text will only elide if maximumLineCount, or height has been set. If both maximumLineCount and height are set, maximumLineCount will apply unless the lines do not fit in the height allowed.
If the text is a multi-length string, and the mode is not Text.ElideNone, the first string that fits will be used, otherwise the last will be elided.
Multi-length strings are ordered from longest to shortest, separated by the Unicode "String Terminator" character U009C (write this in QML with "\u009C" or "\x9C").
