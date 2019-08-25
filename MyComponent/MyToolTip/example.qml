    MyToolTip{
        id:tooltips
        implicitHeight: 18
        implicitWidth: 18
        contentFF: myTranslator.currFF
        contentFS: 12
        visible: false
        z:300
    }

    Label{
        id:proName
	text:"xxxxxxxxxxxxxxxxxxxxxxxxxxx"

        MouseArea{
            anchors.fill: parent
            hoverEnabled: true
            onEntered: {
                tooltips.content = proName.text
                tooltips.visible = true
                tooltips.x = proName.x+mouseX+10
                tooltips.y = proName.y+mouseY+10
            }
            onExited: {
                tooltips.visible = false
            }
        }
    }
