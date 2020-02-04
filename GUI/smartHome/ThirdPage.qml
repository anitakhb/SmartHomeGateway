import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Universal 2.12
import QtQuick.Layouts 1.3
import QtWebSockets 1.0


Item {
    property int cVal: 16
    property bool ch: false
    property bool chp: false
    property int cnt: 0

    WebSocket {
            id: ws
            url: "ws://localhost:8765"
            onTextMessageReceived: {
                var JsonString = message;
                console.log(message);
                var JsonObject= JSON.parse(JsonString);

                if(!JsonObject.hasOwnProperty("name")){
                    control.value = JsonObject.temp;
                    if (JsonObject.ch === "cooler"){
                        ch = true;
                    }
                    else{
                        ch = false;
                    }

                    fan_text.text = JsonObject.mode
                }

                ws.active = false;
                ws.active = true;
            }
            onStatusChanged:
                             console.log("status change: ",ws.status)


            active: true

            Component.onCompleted: {
                console.log("Open status: ",WebSocket.Open)
                console.log("Connecting status: ",WebSocket.Connecting)
                console.log("Closed status: ",WebSocket.Closed)
                console.log("Closing status: ",WebSocket.Closing)
                console.log("*************DEPTH: ",myStackView.depth)
            }
        }


    Dial {
        width: 320
        height: 320
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        id: control
        background: Rectangle {
            x: control.width / 2 - width / 2
            y: control.height / 2 - height / 2
            width: Math.max(64, Math.min(control.width, control.height))
            height: width
            color: "transparent"
            radius: width / 2
            border.color: ch ? "#73C2FB" : "#E04006"
            border.width: 9
            opacity: control.enabled ? 1 : 0.3
        }
        from: 16
        to: 31
        stepSize: 1.0
        snapMode: Dial.SnapAlways
        Text{
            text: Math.floor(control.value) + "°C"
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            color: ch ? "#73C2FB" : "#E04006"
            font.pointSize: 30
        }

        handle: Rectangle {
            id: handleItem
            x: control.background.x + control.background.width / 2 - width / 2
            y: control.background.y + control.background.height / 2 - height / 2
            width: 24
            height: 24
            color: ch ? "#73C2FB" : "#E04006"
            radius: 12
            antialiasing: true
            opacity: control.enabled ? 1 : 0.3
            transform: [
                Translate {
                    y: -Math.min(control.background.width, control.background.height) * 0.4 + handleItem.height / 2
                },
                Rotation {
                    angle: control.angle
                    origin.x: handleItem.width / 2
                    origin.y: handleItem.height / 2
                }
            ]
        }
        onMoved: {
            console.log("real Value",control.value)
            console.log("if true: ",control.value == Math.floor(control.value))
            console.log("cVal: ", cVal)
            if((control.value == Math.floor(control.value)) && (Math.floor(control.value) != cVal)){
                var s = "{\"type\":\"Thermostatic\",\"temp\":" + control.value + "}";
                ws.sendTextMessage(s);
                cVal = Math.floor(control.value);
            }
        }
    }
    Item {
            Timer {
                interval: 700; running: true; repeat: true
                onTriggered: {

                        ws.sendTextMessage("Thermostatic-1");

                }
            }

        }
    Button{

        id: heater_button
        x: 80
        y: parent.height/2 - 75
        width: 150; height: 150

        onClicked: {
            chp = !ch;
            if(chp){
                ws.sendTextMessage("{\"type\":\"Thermostatic2\", \"ch\":\"cooler\"}");
            }
            else{
                ws.sendTextMessage("{\"type\":\"Thermostatic2\", \"ch\":\"heater\"}");
            }
            chp = !chp;
        }
    }
    Image {
        id: heater_img
        anchors.centerIn: heater_button
        width: 150; height: 150
        fillMode: Image.PreserveAspectFit
        source: (ch) ? "cooler.png" : "heater.png"
    }

    Button{

        id: fan_button
        x: parent.width - 230
        y: parent.height/2 - 75
        width: 150; height: 150

        onClicked: {
            cnt = cnt + 1;
            if(cnt%5 == 0){
                ws.sendTextMessage("{\"type\":\"Thermostatic1\", \"mode\":\"off\"}");
                fan_text.text = "off";
            }
            else if(cnt%5 == 1){
                ws.sendTextMessage("{\"type\":\"Thermostatic1\", \"mode\":\"low\"}");
                fan_text.text = "low";
            }
            else if(cnt%5 == 2){
                ws.sendTextMessage("{\"type\":\"Thermostatic1\", \"mode\":\"medium\"}");
                fan_text.text = "medium";
            }
            else if(cnt%5 == 3){
                ws.sendTextMessage("{\"type\":\"Thermostatic1\", \"mode\":\"high\"}");
                fan_text.text = "high";
            }
            else if(cnt%5 == 4){
                ws.sendTextMessage("{\"type\":\"Thermostatic1\", \"mode\":\"auto\"}");
                fan_text.text = "auto";
            }
        }
    }
    Image {
        id: fan_img
        anchors.centerIn: fan_button
        width: 150; height: 150
        fillMode: Image.PreserveAspectFit
        source: (ch) ? "fancold.png" : "fanhot.png"
        Component.onCompleted: console.log(fan_img.x, fan_img.y)
    }

    Text{
        anchors.horizontalCenter: fan_img.horizontalCenter
        x : 794 + 50
        y : 176 + 170
        id:fan_text
        text: ""
        color: ch ?"#42C0FB" : "#E04006"
        font.pointSize: 25
    }
}
