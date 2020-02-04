import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.LocalStorage 2.12
import QtWebSockets 1.0


Item {
    id: ii
    WebSocket {
            id: secureWebSocket1
            url: "ws://localhost:8765"
            onTextMessageReceived: {
                var JsonString = message;
                console.log(message);
                var JsonObject= JSON.parse(JsonString);

                //retrieve values from JSON again
                var val = JsonObject.Light_final1;



                console.log(val);

                messageBox.text = messageBox.text + "\nReceived in main: " + message;
                secureWebSocket1.active = false;
                secureWebSocket1.active = true;
            }
            onStatusChanged:
                             console.log("status change: ",secureWebSocket1.status)


            active: false

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
            text: secureWebSocket1.status == WebSocket.Open ? qsTr("Sending...") : qsTr("Welcome!")
            //anchors.centerIn: parent-100
        }

    Item {
            Timer {
                interval: 1000; running: true; repeat: true
                onTriggered: {
                    secureWebSocket1.sendTextMessage("Light_final-4");
                    if(myStackView.depth > 1){
                        secureWebSocket1.active=false;
                    }
                    else{
                        secureWebSocket1.active=true;
                    }


                }
            }


        }

    Image {
        id: bg
        width: 270; height: 270
        fillMode: Image.PreserveAspectFit
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        source: "cpu.png"
    }

    Button{
        id: light_button
        anchors.verticalCenter: light_img.verticalCenter
        anchors.horizontalCenter: light_img.horizontalCenter
        width: 270; height: 70

        onClicked: {
            myStackView.push(light_page);

        }
    }
    Image {
        id: light_img
        x: 20
        y: parent.height/2 - 150 + 50
        width: 300; height: 200
        fillMode: Image.PreserveAspectFit
        source: "light.png"
    }

    Button{
        id: thermo_button
        anchors.verticalCenter: thermo.verticalCenter
        anchors.horizontalCenter: thermo.horizontalCenter
        width: 270; height: 70

        onClicked: {
            myStackView.push(third_page)
        }
    }
    Image {
        id: thermo
        x: parent.width - 329
        y: parent.height/2 - 150 + 50
        width: 300; height: 200
        fillMode: Image.PreserveAspectFit
        source: "thermos.png"
    }


}
