import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtQuick.Controls.Universal 2.12
import QtQuick.Layouts 1.3
import QtWebSockets 1.0

ApplicationWindow {
    visible: true

    Universal.theme: Universal.Dark
    Universal.accent: Universal.Violet


    width: 640
    height: 480
    title: qsTr("Hello World")

    header: ToolBar{
        RowLayout{
            anchors.fill: parent
            ToolButton{
                text: qsTr("←")
                font.pixelSize: 40
                onClicked: myStackView.pop()
            }
            Label{
                text: "•Smart Home•         "
                elide: Label.ElideRight
                horizontalAlignment: Qt.AlignHCenter
                verticalAlignment: Qt.AlignVCenter
                Layout.fillWidth: true
                color: "#C2C5CC"
                font.italic: true
                font.pixelSize: 28
            }
        }
    }

    StackView{
        anchors{
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            top: header.bottom

        }

        id: myStackView
        initialItem:starting_page
    }
    Component{

        id:starting_page
        StartingPage{}
    }
    Component{
        id:light_page
        LightPage{}
    }
    Component{
        id:third_page
        ThirdPage{}
    }
    Component{
        id:fourth_page
        FourthPage{}
    }
}
