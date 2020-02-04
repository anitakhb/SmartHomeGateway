import paho.mqtt.client as mqtt
import time
import serial



import asyncio
import websockets

import threading

import json
import redis

ser = serial.Serial(
        port='/dev/ttyS0',
        baudrate = 115200,
        parity=serial.PARITY_NONE,
        stopbits=serial.STOPBITS_ONE,
        bytesize=serial.EIGHTBITS,
        timeout=0.01
    )
ser_flag = False
qt_flag = False
qt_pol = 0
qt_stat = False
qt_thermo = False
qt_temp = False
qt_ch = False
qt_mode = False
qt_ch_val = 0
qt_mode_val = 0
c_mode = 'off'
c_ch = 'cooler'
c_temp = 16
#DATA IS DECIMAL

def checkStatus(client, data, stage):


    msg = "{\"serialNumber\":\"LightNew\",\"sensorType\":\"Light\",\"sensorModel\":\"Light4\",\"light" + str(stage) +"\":"
    print(data)

    temp = data
    for i in range(stage-1):
        print(data%2)
        data = data // 2
    
    
    b = data % 2
    if b == 1:
        temp = temp - 2 ** (stage-1)
        msg = msg + "false}"

        #client.publish("/sensor/data", msg )
        return temp
    else :
        temp = temp + 2 ** (stage-1)
        msg = msg + "true}"

        #client.publish("/sensor/data", msg )

        return temp

def on_message(client, userdata, message):
    global ser
    print("rpc")
    data = str(message.payload.decode("utf-8")).split("}")
    data2 = data[0].split(":")

    x = []
    #print("are 1 e")
    ser.write(b')')
    ser.write(b'\x80')

    ser.write(bytes([1]))
    while ser.inWaiting() == 0:
        cnt = 0  
    x = ser.read()
     
    status = checkStatus(client, ord(x),int(data2[1]))
    print(status)

    ser.write(b')')
    ser.write(b'\x00')
    ser.write(bytes([status]))

def handleLight(client, name, pol, data):
    s = '{\"serialNumber\":\"' + name + '\",\"sensorType\":\"Light\",\"sensorModel\":\"Light4\"'
    cnt = 0
    while data > 0:
        cnt+=1
        b = data % 2  
        if b == 1:
            s += ',\"light' + str(cnt) +'\":true'
            key = name + '['+ str(cnt) +']'
            print('key is : ', key)
            red_db.set(key,'true')

        else:
            s += ',\"light' + str(cnt) +'\":false'
            key = name + '['+ str(cnt) +']'
            print('key is : ', key)
            red_db.set(key,'false')

        data = int(data/2)

    if cnt < pol:
        for i in range(cnt +1, pol +1):
            s += ',\"light' + str(i) +'\":false'
            key = name + '['+ str(i) +']'
            print('key is : ', key)
            red_db.set(key,'false')
    s+='}'

    client.publish("/sensor/data", s)
    print(s)


def handleThermostat(client, name, register, data):  
    global c_ch
    global c_mode
    global c_temp
    name1 = 'termo4'  
    s = '{\"serialNumber\":\"' + name1 + '\",\"sensorType\":\"Thermostatic\",\"sensorModel\":\"Thermostat1\"'
    if register == 0:
        #fan speed
        fs = data % 4
        data = int(data/4)

        if fs == 0:
            s += ',\"temp\":'
            s += str(c_temp)

            #s += ',\"ch\":'
            #s +='\"'+ c_ch + '\"'
            s += ',\"mode\":\"off\"'
            red_db.set('thermo_mode','off')
            c_mode = 'off'

        elif fs == 1:
            s += ',\"temp\":'
            s += str(c_temp)

            s += ',\"mode\":\"low\"'
            red_db.set('thermo_mode','low')
            c_mode = 'low'

        elif fs == 2:
            s += ',\"temp\":'
            s += str(c_temp)

            s += ',\"mode\":\"medium\"'
            red_db.set('thermo_mode','medium')
            c_mode = 'medium'

        elif fs == 3:
            s += ',\"temp\":'
            s += str(c_temp)

            s += ',\"mode\":\"high\"'
            red_db.set('thermo_mode','high')
            c_mode = 'high'

        #cool-heat

        ch = data % 4
        data = int(data/4)
        if ch == 0:
        

            s += ',\"ch\":\"off\"'
            red_db.set('thermo_ch','off')
            
            c_ch = 'off'
        elif ch == 1:
            
            s += ',\"ch\":\"cooler\"'
            red_db.set('thermo_ch','cooler')
            
            c_ch = 'cooler'
        elif ch == 2:

            s += ',\"ch\":\"heater\"'
            red_db.set('thermo_ch','heater')
           
            c_ch = 'heater'
        #hand/auto
    elif register == 3:
        s += ',\"temp\":'
        s += str(data/2)
        print(data/2)
        red_db.set('thermo_temp',(data/2))
        #print(int(str(red_db.get('thermo_temp')).split('\'')[1].split('\'')[0])+1)
        c_temp = str(data/2)
        s+=',\"mode\":'
        s+= '\"'+c_mode+'\"'
        s+=',\"ch\":'
        s+= '\"'+ c_ch+ '\"'

    if register != 2:
        s+='}'
        client.publish("/sensor/temp", s)
        #red_db.set('',)
        print (s)


def publishEvent(client, p_addr, register, data):

    if p_addr == 11:
        #light 1-1
        handleLight(client, "Light 1-1", 1, data)

    elif p_addr == 21:
        #light 2-1
        handleLight(client, "Light 2-1", 2, data)

    elif p_addr == 22:
        #light 2-2
        handleLight(client, "Light 2-2", 2, data)

    elif p_addr == 41:
        #light 4-1
        handleLight(client, "Light_final", 4, data)

    elif p_addr == 42:
        #light 4-2-T
        handleLight(client, "Light 4-2-T", 4, data)

    elif p_addr == 43:
        #light 4-3-T
        handleLight(client, "Light 4-3-T", 4, data)

    elif p_addr == 44:
        #light 4-4-T
         handleLight(client, "Light 4-3-4", 4, data)

    elif p_addr == 253:
        #Thermostat 1
        handleThermostat(client, "Thermostat", register, data )

    elif p_addr == 2:
        #Thermostat 2
        handleThermostat(client, "Thermostat 2", register, data )

    elif p_addr == 3:
        #Thermostat 3
        handleThermostat(client, "Thermostat 3", register, data )

    else:
        return null


def smart_home():
    global ser
    global ser_flag
    global qt_flag
    global qt_pol
    global qt_stat
    global qt_thermo
    global qt_temp
    global qt_ch
    global qt_mode
    global qt_ch_val
    global qt_mode_val

    broker_address="10.42.0.248"
    print("creating new instance")
    client = mqtt.Client() #create new instance
   
    print("connecting to broker")
    client.connect(broker_address,1883) #connect to broker

    run = True
    while run:
        #event_driven
        client.loop()
        client.subscribe("sensor/Light_final/request/set_light/+")
        client.on_message=on_message #attach function to callback
        
        
        x = []
        r = ser.read(1)
        if r:
            print("areeeeeeee")
            x.append(r)
            for i in range(2):
                x.append(ser.read(1))

            for i in range(3):
                print(ord(x[i]))

            if ord(x[0]) == 41:
                print("bal")
                publishEvent(client, ord(x[0]), ord(x[1]),ord(x[2]))
            if ord(x[0]) == 253:
                publishEvent(client, ord(x[0]), ord(x[1]),ord(x[2]))

        if qt_flag:
            ser.write(b')')
            ser.write(b'\x80')

            ser.write(bytes([1]))
            while ser.inWaiting() == 0:
                cnt1 = 0  
            x1 = ser.read()
            data_to_serial = from_ui(ord(x1),qt_pol,qt_stat)
            print(data_to_serial)

            ser.write(b')')
            ser.write(b'\x00')
            ser.write(bytes([data_to_serial]))
            qt_flag = False
            
        if qt_thermo:
            print('AAAAAAAARRRRRRRRRRRRRRREEEEEEEEEE')
            ser.write(bytes([253]))
            ser.write(bytes([3]))
            #ser.write(bytes([253]))
            ser.write(bytes([qt_temp]))
            qt_thermo = False
        
        if qt_ch:
            ser.write(bytes([253]))
            ser.write(b'\x80')
            ser.write(bytes([1]))
            while ser.inWaiting() == 0:
                cnt1 = 0  
            x1 = ser.read()
            print('ghabl:   ',str(ord(x1)))
            remain = ord(x1)%4
            if qt_ch_val == 'cooler':
                print('remain:       ',str(remain))
                data_to_serial = remain + 4
                print('++++++++++++++')
                print(data_to_serial)
                print('++++++++++++++')

            else:
                print('remain:       ',str(remain))

                data_to_serial = remain + 8
                print('---------------')
                print(data_to_serial)
                print('---------------')


            ser.write(bytes([253]))
            ser.write(b'\x00')
            ser.write(bytes([data_to_serial]))
            qt_ch = False
            
        if qt_mode:
            ser.write(bytes([253]))
            ser.write(b'\x80')
            ser.write(bytes([1]))
            while ser.inWaiting() == 0:
                cnt1 = 0  
            x1 = ser.read()
            remain = ord(x1)%4
            if qt_mode_val == 'off':
                data_to_serial = ord(x1) - remain
            elif qt_mode_val == 'low':
                data_to_serial = ord(x1) - remain + 1
            elif qt_mode_val == 'medium':
                data_to_serial = ord(x1) - remain + 2
            else:
                data_to_serial = ord(x1) - remain + 3
            

            ser.write(bytes([253]))
            ser.write(b'\x00')
            ser.write(bytes([data_to_serial]))
            qt_mode = False






t1 = threading.Thread(target=smart_home)
t1.start()
def str2bool(v):
   return str(v).lower() in ("true")
def bool2int(b):
    if b:
        return 1
    else:
        return -1

def from_ui(old, pol, val):
    print("-------"+str(bool2int(True)))
    temp = old + (2 ** (pol-1)) * bool2int(val)
    return temp

def bool2str(b):
    if b:
        return 'true'
    else:
        return 'false'

def cleaning(s):
    sp = s.split('\'')[1].split('\'')[0]
    return sp

def handlePooling(status):
    global ser
    global ser_flag
    global qt_flag
    global qt_pol
    global qt_stat
    global qt_thermo
    global qt_temp
    global qt_ch
    global qt_mode
    global qt_ch_val
    global qt_mode_val

    non_json_data = {}
    if status == 'Light_final-4':
        print('dare pooling mishe..')
        m = status.split('-')
        for i in range(1,int(m[1])+1):
            key = m[0] + str(i) 
            red_key = m[0] + '['+str(i)+']' 
            non_json_data[key] = red_db.get(red_key).decode("utf-8")
        json_data = json.dumps(non_json_data)
        return json_data
    elif status == 'Thermostatic-1':
        dString = float(str(red_db.get('thermo_temp')).split('\'')[1].split('\'')[0])
        print((dString))
        chString = cleaning(str(red_db.get('thermo_ch')))
        modeString = cleaning(str(red_db.get('thermo_mode')))
        #dInt = int(str(dString))
        x = {
          "temp": dString,
          "ch": chString,
          "mode": modeString
        }

        json_data = json.dumps(x)
        return json_data        
    else:
        
        j = json.loads(status)
        if j['type']=='Light_final':
            k = j['type'] +'[' + str(j['pol']) + ']'
            print('--------------------' , type(j[k]))
            red_db.set(k,bool2str(str2bool(j[k])))
            qt_pol = int(j['pol'])
            qt_stat = str2bool(j[k])
            qt_flag = True
            #time.sleep(0.5)
            '''
            print('====================',x1)
            data_to_serial = from_ui(ord(x1),int(j['pol']),str2bool(j[k]))
            print(data_to_serial)

            ser.write(b')')
            ser.write(b'\x00')
            ser.write(bytes([data_to_serial]))
            ser_flag = False
            '''
        '''

        if j["light_final[1]"]==True:
            red_db.set('Light_final[1]','true')  
        if j["light_final[1]"]!=True:
            red_db.set('Light_final[1]','false')    
        '''
        if j['type']=='Thermostatic':
            print('EEEEEEEEEEEEEEEEEEEEEE')
            red_db.set('thermo_temp',str(j['temp']))
            qt_temp = j['temp'] * 2
            print(qt_temp)
            qt_thermo = True
        
        if j['type'] == 'Thermostatic2':
            red_db.set('thermo_ch',str(j['ch']))
            qt_ch_val = str(j['ch'])
            qt_ch = True
        
        if j['type'] == 'Thermostatic1':
            red_db.set('thermo_mode',str(j['mode']))
            qt_mode_val = str(j['mode'])
            qt_mode = True


        x = {
          "name": "dummy"
        }
        json_data = json.dumps(x)

        return json_data   



async def hello(websocket, path):
    try:
        status = await websocket.recv()
        print(f"< {status}")
        j_data = handlePooling(status)
        #if not j_data == None:
            #print('--------------------------------------------------------')
        await websocket.send(j_data)

    except websockets.ConnectionClosedError:
        print("Connection closed")   


    except websockets.ConnectionClosedOK:
        print("halle.")
    
    

red_db = redis.Redis(host='localhost', port=6379, db=0)
red_db.set('thermo_temp',16)
start_server = websockets.serve(hello, "localhost", 8765)
asyncio.get_event_loop().run_until_complete(start_server)
asyncio.get_event_loop().run_forever()





