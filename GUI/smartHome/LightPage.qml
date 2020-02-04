import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.LocalStorage 2.12
import QtQuick.Controls.Universal 2.12
import QtQuick.Layouts 1.3
import QtWebSockets 1.0

Item {
    property bool isOn1: false
    property bool isOn2: false
    property bool isOn3: false
    property bool isOn4: false
    property bool isOn1p: false
    property bool isOn2p: false
    property bool isOn3p: false
    property bool isOn4p: false
    property bool c: false

    WebSocket {
            id: secureWebSocket
            url: "ws://localhost:8765"
            onTextMessageReceived: {
                var JsonString = message;
                console.log(message);
                var JsonObject= JSON.parse(JsonString);

                //retrieve values from JSON again
                if(!JsonObject.hasOwnProperty("name")){
                isOn1 = JsonObject.Light_final1==="true" ? true : false
                isOn2 = JsonObject.Light_final2==="true" ? true : false
                isOn3 = JsonObject.Light_final3==="true" ? true : false
                isOn4 = JsonObject.Light_final4==="true" ? true : false

                }

                //console.log(val);

                messageBox.text = messageBox.text + "\nReceived in light: " + message;
                secureWebSocket.active = false;
                secureWebSocket.active = true;
            }
            onStatusChanged:
                             console.log("status change: ",secureWebSocket.status)


            active: true

            Component.onCompleted: {
                console.log("Open status: ",WebSocket.Open)
                console.log("Connecting status: ",WebSocket.Connecting)
                console.log("Closed status: ",WebSocket.Closed)
                console.log("Closing status: ",WebSocket.Closing)
                console.log("*************DEPTH: ",myStackView.depth)
            }
        }


    Text {
            id: messageBox
            text: secureWebSocket.status == WebSocket.Open ? qsTr("Sending...") : qsTr("Welcome!")
            //anchors.centerIn: parent-100
        }


    Button{

        id: light_button1
        x: parent.width/4  +25
        y: parent.height/4 - 35
        width: parent.width/4 - 30; height: parent.height/4 + 30

        onClicked: {
            //isOn1 = !isOn1;
            isOn1p = !isOn1;
            isOn1p ? secureWebSocket.sendTextMessage("{\"type\":\"Light_final\",\"pol\":1 ,\"Light_final[1]\":true}"):secureWebSocket.sendTextMessage("{\"type\":\"Light_final\", \"pol\":1 ,\"Light_final[1]\":false}");
            isOn1p = !isOn1p;
        }

        /*Timer {
                interval: 500; running: true; repeat: false
                onTriggered:light_button1.findStatus();
            }*/

    }
    Item {
            Timer {
                interval: 700; running: true; repeat: true
                onTriggered: {

                        secureWebSocket.sendTextMessage("Light_final-4");

                }
            }


        }
    Button{

        id: light_button2
        x: 2*parent.width/4 + 5
        y: parent.height/4 - 35
        width: parent.width/4 - 30; height: parent.height/4 + 30

        onClicked: {
            isOn2p = !isOn2;
            if(isOn2p){
                secureWebSocket.sendTextMessage("{\"type\":\"Light_final\",\"pol\":2 , \"Light_final[2]\":true}");
            }
            else{
                secureWebSocket.sendTextMessage("{\"type\":\"Light_final\", \"pol\":2 ,\"Light_final[2]\":false}");
            }
            isOn2p = !isOn2p;
        }
    }
    Button{

        id: light_button3
        x: parent.width/4  +25
        y: parent.height/2 + 5
        width: parent.width/4 - 30; height: parent.height/4 + 30

        onClicked: {
            isOn3p = !isOn3;
            if(isOn3p){
                secureWebSocket.sendTextMessage("{\"type\":\"Light_final\", \"pol\":3 ,\"Light_final[3]\":true}");
            }
            else{
                secureWebSocket.sendTextMessage("{\"type\":\"Light_final\", \"pol\":3 ,\"Light_final[3]\":false}");
            }
            isOn3p = !isOn3p;
        }
    }
    Button{

        id: light_button4
        x: 2*parent.width/4 + 5
        y: parent.height/2 + 5
        width: parent.width/4 - 30; height: parent.height/4 + 30

        onClicked: {
            isOn4p = !isOn4;
            if(isOn4p){
                secureWebSocket.sendTextMessage("{\"type\":\"Light_final\", \"pol\":4 ,\"Light_final[4]\":true}");
            }
            else{
                secureWebSocket.sendTextMessage("{\"type\":\"Light_final\", \"pol\":4 ,\"Light_final[4]\":false}");
            }
            isOn4p = !isOn4p;
        }
    }
    Image {
        id: lamp1_img
        anchors.centerIn: light_button1
        width: 100; height: 100
        fillMode: Image.PreserveAspectFit
        source: (isOn1 ) ? "on.png" : "off.png"
    }
    Image {
        id: lamp2_img
        anchors.centerIn: light_button2
        width: 100; height: 100
        fillMode: Image.PreserveAspectFit
        source: (isOn2 ) ? "on.png" : "off.png"
    }
    Image {
        id: lamp3_img
        anchors.centerIn: light_button3
        width: 100; height: 100
        fillMode: Image.PreserveAspectFit
        source: (isOn3 ) ? "on.png" : "off.png"
    }
    Image {
        id: lamp4_img
        anchors.centerIn: light_button4
        width: 100; height: 100
        fillMode: Image.PreserveAspectFit
        source: (isOn4) ? "on.png" : "off.png"
    }


}
