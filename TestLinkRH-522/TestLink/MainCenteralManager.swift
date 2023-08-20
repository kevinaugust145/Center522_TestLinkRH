//
//  MainCenteralManager.swift
//  TestLink
//
//

import UIKit


enum ManageType {
    case Temperature
    case Download
}

protocol MainCenteralManagerDelegate: class {
    func ReceiveCommand()
}

protocol MainCenteralManagerForCommandPDelegate: class {
    func ReceiveCommand()
    func ReceiveFinish()
}


class MainCenteralManager: NSObject{
    
    weak var mainCenteralManagerDelegate: MainCenteralManagerDelegate?
    weak var mainCenteralManagerForCommandPDelegate: MainCenteralManagerForCommandPDelegate?
    
    private static var mInstance:MainCenteralManager?
    static func sharedInstance() -> MainCenteralManager {
        if mInstance == nil {
            mInstance = MainCenteralManager()
        }
        return mInstance!
    }
    var centralManager: CBCentralManager?
    var peripheral: CBPeripheral?
    
    var btServices :[BTServiceInfo] = []
    var data : CommandAViewModel = CommandAViewModel()
    var dataP : CommandPViewModel = CommandPViewModel()
    var timer = Timer()
    
    var DataCheckTimer = Timer()
    
    var managerType = ManageType.Temperature
    
    var isGotDataFromDevice : Bool = false
    var counter = 0
    
    func SetObject(centralManager: CBCentralManager , peripheral: CBPeripheral){
        
        self.centralManager = centralManager
        self.peripheral = peripheral
        self.peripheral!.delegate = self
        self.centralManager!.delegate = self
        self.centralManager!.connect(self.peripheral!, options: nil)
        
        data.peripheralName = self.peripheral!.name == nil ? "" : self.peripheral!.name!
    }
    
    
    func ClearnObject() {
        self.timer.invalidate()
        self.centralManager?.cancelPeripheralConnection(self.peripheral!)
        self.centralManager?.delegate = nil
        self.peripheral?.delegate = nil
        self.centralManager = nil
        self.peripheral = nil
    }
    
    
    func SendData() {
        
        switch managerType {
        case .Download:
            self.dataP =  CommandPViewModel()
            //開始發送指令
            timer.invalidate()
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.CommandP), userInfo: nil, repeats: false)
            break
        case .Temperature:
            //開始發送指令
            timer.invalidate()
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.CommandA), userInfo: nil, repeats: false)
            break
        }
    }
    
    
    func checkingStates () -> Bool {
        
        guard peripheral != nil else {
            return false
        }
        guard peripheral!.state ==  CBPeripheralState.connected else {
            return false
        }
        return true
    }
    
    
    // MARK: - Button Action Methods
    func CommandC(){
        
        timer.invalidate()
        
        //檢查裝置是否連線中
        if !self.checkingStates() {
            return
        }
        
        //isCommandCCalled = false
        
        //[  0x02 , 0x43 , 0x00 , 0x00 , 0x00 , 0x00 , 0x03 ]   C Command
        //[  0x02 , 0x50 , 0x00 , 0x00 , 0x00 , 0x00 , 0x03 ]   P Command
        let commandCbyte : [UInt8] = [  0x02 , 0x43 , 0x00 , 0x00 , 0x00 , 0x00 , 0x03 ]
        let data2 = Data(bytes:commandCbyte)
        
        if self.btServices.count > 1 {
            let charItems = self.btServices[1].characteristics
            for characteristic in charItems {
                if characteristic.properties.contains(CBCharacteristicProperties.writeWithoutResponse){
                    //设置为  写入有反馈
                    self.peripheral!.writeValue(data2, for: characteristic, type: .withResponse)
                    //print("写入withoutResponse~")
                }else{
                    print("CommandC 写入不可用~")
                }
            }
            
            //if(self.isChangeTemperaturing){
            //self.btncommandA()
            //}
            
           // self.CommandA() Commeted by Mitesh Nov 30 2017
        }
    }
    
    
 
    func CommandF(finished: () -> Void){
        
        timer.invalidate()
        
        //檢查裝置是否連線中
        if !self.checkingStates() {
            return
        }

        let commandFbyte : [UInt8] = [  0x02 , 0x46 , 0x00 , 0x00 , 0x00 , 0x00 , 0x03 ]
        let data2 = Data(bytes:commandFbyte)
        
        if self.btServices.count > 1 {
            let charItems = self.btServices[1].characteristics
            for characteristic in charItems {
                if characteristic.properties.contains(CBCharacteristicProperties.writeWithoutResponse){
                    //设置为  写入有反馈
                    self.peripheral!.writeValue(data2, for: characteristic, type: .withResponse)
                    //print("写入withoutResponse~")
                    finished()
                }else{
                    print("CommandF 写入不可用~")
                }
            }
            
        }
    }
    
    
    func SwitchCommandA() {
        timer.invalidate()
        self.managerType = .Temperature
        SendData()
    }
    
    func SwitchCommandP() {
       
        self.timer.invalidate()
        self.managerType = .Download
        self.SendData()
    }
    
    @objc func CommandP(){
        
        print("CommandP")
        //檢查是否連線
        if !self.checkingStates() {
            print("checkingStates")
            return
        }
        let command : [UInt8] = [  0x02 , 0x50 , 0x00 , 0x00 , 0x00 , 0x00 , 0x03 ]
        let data1 = Data(bytes:command)
        
        if self.btServices.count > 1 {
            let charItems = self.btServices[1].characteristics
            for characteristic in charItems {
                peripheral?.setNotifyValue(true, for: characteristic)
            }
            
            print("charItems is \(charItems)")
            
            for characteristic in charItems {
                self.viewController(characteristic: characteristic, value: data1)
            }
        }
    }
    
    func CommandP_Finish() {
        
        print("CommandP_Finish")
        //檢查是否連線
        if !self.checkingStates() {
            print("checkingStates")
            return
        }
        let command : [UInt8] = [  0x02 , 0x71 , 0x00 , 0x00 , 0x00 , 0x00 , 0x03 ]
        let data1 = Data(bytes:command)
        
        if self.btServices.count > 1 {
            let charItems = self.btServices[1].characteristics
            
            for characteristic in charItems {
                self.viewController(characteristic: characteristic, value: data1)
            }
        }
    }
    
    @IBAction func CommandRepeatP(){
        
        print("CommandRepeatP")
        //檢查是否連線
        if !self.checkingStates() {
            print("checkingStates")
            return
        }
        let command : [UInt8] = [  0x02 , 0x70 , 0x00 , 0x00 , 0x00 , 0x00 , 0x03 ]
        let data1 = Data(bytes:command)
        
        if self.btServices.count > 1 {
            let charItems = self.btServices[1].characteristics
            for characteristic in charItems {
                self.viewController(characteristic: characteristic, value: data1)
            }
        }
        
    }
    
    @objc func CommandA(){
        
        isGotDataFromDevice = false
        
        print("CommandA")
        //檢查是否連線
        if !self.checkingStates() {
            print("checkingStates")
            return
        }
        let command : [UInt8] = [  0x02 , 0x41 , 0x00 , 0x00 , 0x00 , 0x00 , 0x03 ]
        let data1 = Data(bytes:command)
        
        if self.btServices.count > 1 {
            let charItems = self.btServices[1].characteristics
            for characteristic in charItems {
                peripheral?.setNotifyValue(true, for: characteristic)
            }
            for characteristic in charItems {
                self.viewController(characteristic: characteristic, value: data1)
            }
        }
    }
    
    //  func setNotify() {
    //    if self.btServices.count > 1 {
    //      let charItems = self.btServices[1].characteristics
    //      for characteristic in charItems {
    //        peripheral?.readValue(for: characteristic)
    //        //设置 characteristic 的 notifying 属性 为 true ， 表示接受广播
    //        peripheral?.setNotifyValue(true, for: characteristic)
    //      }
    //    }
    //  }
    
    
    func CommandWrongCommand(){
        let command : [UInt8] = [  0x02 , 0x72 , 0x00 , 0x00 , 0x00 , 0x00 , 0x03 ]
        let data1 = Data(bytes:command)
        
        if self.btServices.count > 1 {
            let charItems = self.btServices[1].characteristics
            for characteristic in charItems {
                if characteristic.properties.contains(CBCharacteristicProperties.writeWithoutResponse){
                    //设置为  写入有反馈
                    self.peripheral!.writeValue(data1, for: characteristic, type: .withResponse)
                    //print("写入withoutResponse~")
                }else{
                    print("CommandWrongCommand 写入不可用~")
                }
            }
        }
    }
}


extension MainCenteralManager : CBCentralManagerDelegate{
    
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
    }
    
    
    // MARK: - CBCentralManager Methods
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        //1
        if peripheral.state == CBPeripheralState.connected {
            //bbConnect.text = "Connected"
            peripheral.discoverServices(nil)
        }
    }
    
    func viewController(characteristic: CBCharacteristic,value : Data ) -> () {
        
        //只有 characteristic.properties 有write的权限才可以写入
        if characteristic.properties.contains(CBCharacteristicProperties.write){
            //设置为  写入有反馈
            self.peripheral!.writeValue(value, for: characteristic, type: .withResponse)
            
        }else{
            print("viewController characteristic 写入不可用~")
        }
    }
    
    
    
}


extension MainCenteralManager : CBPeripheralDelegate{
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        //2
        for serviceObj in peripheral.services! {
            let service:CBService = serviceObj
            let isServiceIncluded = self.btServices.filter({ (item: BTServiceInfo) -> Bool in
                return item.service.uuid == service.uuid
            }).count
            if isServiceIncluded == 0 {
                btServices.append(BTServiceInfo(service: service, characteristics: []))
                
            }
            peripheral.discoverCharacteristics(nil, for: service)
        }
        
        
        
    }
    
    
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        //3
        let serviceCharacteristics = service.characteristics
        for item in btServices {
            if item.service.uuid == service.uuid {
                item.characteristics = serviceCharacteristics!
                let charitem = serviceCharacteristics?.first
                self.peripheral!.setNotifyValue(true, for: charitem!)
                break
            }
        }
        
        
        self.SendData()
    }
    
    
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        
        //5
        if error != nil{
            print("写入 characteristics 时 \(peripheral.name) 报错 \(error?.localizedDescription)")
            return
        }
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        //4
        if (characteristic.value != nil){
            let resultStr = NSString(data: characteristic.value!, encoding: String.Encoding.utf8.rawValue)
            
            print("characteristic uuid:\(characteristic.uuid)   value:\(resultStr)")
            
            if let value = characteristic.value{
                let log = "read: \(value)"
                print(log)
                
                let byteArray = [UInt8](value)
                print(byteArray)
                
                if (characteristic.uuid.description == "49535343-1E4D-4BD9-BA61-23C647249616"){
                    
                    if (managerType == .Temperature && value.count == 64){
                        DoCommandA(byteArray: byteArray)
                        
                        //開始發送指令
                        timer.invalidate()
                        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.CommandA), userInfo: nil, repeats: false)
                        DataCheckTimer.invalidate()
                        DataCheckTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.checkDataArrived), userInfo: nil, repeats: true)
                        
                    }else if (managerType == .Download){
                        if (value.count == 36){
                            DoCommandP(byteArray: byteArray)
                        }else if (value.count == 64 && !self.dataP.isFinish){
                            DoCommandA(byteArray: byteArray)
                            SendData()
                        }
                    } else {
                        
                        // 2023/07/18
                        timer.invalidate()
                        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.CommandA), userInfo: nil, repeats: false)
                        DataCheckTimer.invalidate()
                        DataCheckTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.checkDataArrived), userInfo: nil, repeats: true)
                    }
//                    else  if (managerType == .Temperature && value.count == 32){
//
//                        print("Command Failed Got 32 bytes")
//                    }
                    
                }
            }
        }
    }
    
    // This logic is for when sometime Command A not giving response so at this time if data is not received within 10 second after fail of COMMAND A then we are calling Command A for retrive data from device. 
    @objc func checkDataArrived()  {
        
        if !isGotDataFromDevice {
            counter += 1
            //print("This is counter " ,counter)
            if counter == 5 {
                self.CommandA()
            }
        }else{
            
            counter = 0
            //print("This is counter " ,counter)
        }
    }
    
    func DoCommandP(byteArray :[UInt8]) {
        
        if (self.dataP.totalBytes == 0){
            self.dataP.totalBytes = (Int((byteArray[10])) * 65536) + (Int((byteArray[11])) * 256) + (Int((byteArray[12])) + 1);
            
            if self.dataP.totalBytes == 0 {
                APPDELEGATE.window.makeToast("Getting zero bytes")
                return
            }
            
            if (self.dataP.totalBytes > 0x40000 || self.dataP.totalBytes < 256) {
                self.dataP.totalBytes = 0x40000;
            }
            
            if (self.dataP.totalBytes % 32 == 0) {
                self.dataP.totalBytes = self.dataP.totalBytes - self.dataP.totalBytes % 32 + 32;
            }
        }
        
        if (self.dataP.totalBytesReceived >= self.dataP.totalBytes && !self.dataP.isFinish){
            print("finish command p")
            self.dataP.isFinish = true
            self.CommandP_Finish()
            self.mainCenteralManagerForCommandPDelegate?.ReceiveFinish()
            self.timer.invalidate()
            self.timer = Timer();
            self.managerType = .Temperature
            self.SendData()
        }
        if (!self.dataP.isFinish){
            //self.dataP.totalBytesReceived += 32
            self.set32Byte(byteArray: byteArray)
        }
        
    }
    
    func DoCommandA(byteArray :[UInt8]) {
        
        isGotDataFromDevice = true
        
        let byte3 = self.converToBinary(x1: byteArray[2])
        
        _ = self.getDeviceType(value: byteArray[5])
        
        
        let byte7 = self.converToBinary(x1: byteArray[6])
        
        if (byte7[3] == "1"){
            self.data.isRHConnected = false
        }
        else{
            self.data.isRHConnected = true
        }
        
        if (byte7[2] == "1"){
            self.data.isT1Connected = false
        }
        else{
            self.data.isT1Connected = true
        }
        
        if (byte7[1] == "1"){
            self.data.isT2Connected = false
        }
        else{
            self.data.isT2Connected = true
        }
        
        _ = self.getMaxValue(temperatureType: "", deviceType: "")
        _ = self.getMinValue(temperatureType: "", deviceType: "")
        
        let byte42 = self.converToBinary(x1: byteArray[42])
   
        let byte43 = self.converToBinary(x1: byteArray[43])

        if (byte42[0] == "1"){ // This is for Wet Bulb
            
            self.setTextForTemperatures(RH: self.getFahrenheit(x1: byteArray[9], x2: byteArray[10]), t1: self.getFahrenheit(x1: byteArray[15], x2: byteArray[16]), t2: self.getFahrenheit(x1: byteArray[13], x2: byteArray[14]))
            
            
            self.data.isWetBulb = true
            self.data.isNormal = false
            self.data.isDewPoint = false
            
        }else if (byte43[0] == "1") { // This is for Dew Point
            
            self.setTextForTemperatures(RH: self.getFahrenheit(x1: byteArray[9], x2: byteArray[10]), t1: self.getFahrenheit(x1: byteArray[17], x2: byteArray[18]), t2: self.getFahrenheit(x1: byteArray[13], x2: byteArray[14]))
            
            self.data.isDewPoint = true
            self.data.isWetBulb = false
            self.data.isNormal = false
            
        }else { // This is for Normal
            
             self.setTextForTemperatures(RH: self.getFahrenheit(x1: byteArray[9], x2: byteArray[10]), t1: self.getFahrenheit(x1: byteArray[11], x2: byteArray[12]), t2: self.getFahrenheit(x1: byteArray[13], x2: byteArray[14]))
            
            self.data.isNormal = true
            self.data.isDewPoint = false
            self.data.isWetBulb = false
        }
        
       /* if (byte3[2] == "0" && byte3[3] == "0"){ //00 Fahrenheit
            
            self.data.feh = "F"
            self.setTextForTemperatures(RH: self.getFahrenheit(x1: byteArray[9], x2: byteArray[10]), t1: self.getT1Celisus(x1: byteArray[11], x2: byteArray[12]), t2: self.getFahrenheit(x1: byteArray[13], x2: byteArray[14]))
            
        }else if (byte3[2] == "0" && byte3[3] == "1"){ //01 Celsius
            
            self.data.cels = "C"
            self.setTextForTemperatures(RH: self.getFahrenheit(x1: byteArray[9], x2: byteArray[10]), t1: self.getFahrenheit(x1: byteArray[11], x2: byteArray[12]), t2: self.getCelsius(x1: byteArray[13], x2: byteArray[14]))
            
        }else{ //10 Kelvin T(K) = 20°C + 273.15 = 293.15 K
            
            self.data.kel = "K"
            self.setTextForTemperatures(RH: self.getFahrenheit(x1: byteArray[9], x2: byteArray[10]), t1: self.getT1Kelvin(x1: byteArray[11], x2: byteArray[12]), t2: self.getKelvin(x1: byteArray[13], x2: byteArray[14]))
        }
        */
        
        if (byte3[2] == "0" && byte3[3] == "0"){ //00 Fahrenheit
            
            self.data.isFeh = "F"
            self.data.isCels = ""
            self.data.isKel = ""
            self.data.cOrFOrK = "F"
   
        }else if (byte3[2] == "0" && byte3[3] == "1"){ //01 Celsius
            
            self.data.isCels = "C"
            self.data.isFeh = ""
            self.data.isKel = ""
            self.data.cOrFOrK = "C"
            
        }else{ //10 Kelvin T(K) = 20°C + 273.15 = 293.15 K
            
            self.data.isKel = "K"
            self.data.isCels = ""
            self.data.isFeh = ""
            self.data.cOrFOrK = "K"
           
        }
        
        self.settingBetryImg(betryStatus: byteArray[1])
        self.mainCenteralManagerDelegate?.ReceiveCommand()
        
        
    }
    
    func getRoundValue(value:Double) -> Double {
        
        return value
        
    }
    
    func getDeviceType(value :UInt8) -> String {
        
        switch value {
        case 0:
            self.data.DeviceType = "K"
            return self.data.DeviceType
        case 16:
            self.data.DeviceType = "K"
            return self.data.DeviceType
        case 1:
            self.data.DeviceType = "J"
            return self.data.DeviceType
        case 17:
            self.data.DeviceType = "J"
            return self.data.DeviceType
        case 2:
            self.data.DeviceType = "E"
            return self.data.DeviceType
        case 18:
            self.data.DeviceType = "E"
            return self.data.DeviceType
        case 3:
            self.data.DeviceType = "T"
            return self.data.DeviceType
        case 19:
            self.data.DeviceType = "T"
            return self.data.DeviceType
        case 4:
            self.data.DeviceType = "N"
            return self.data.DeviceType
        case 20:
            self.data.DeviceType = "N"
            return self.data.DeviceType
        case 5:
            self.data.DeviceType = "R"
            return self.data.DeviceType
        case 21:
            self.data.DeviceType = "R"
            return self.data.DeviceType
        case 6:
            self.data.DeviceType = "S"
            return self.data.DeviceType
        case 22:
            self.data.DeviceType = "S"
            return self.data.DeviceType
        default:
            self.data.DeviceType = "T"
            return self.data.DeviceType
        }
        
        //return ""
    }
    
    
    func getMaxValue(temperatureType :String, deviceType :String) -> Float {
        
        var myDeviceType = ""
        
        if deviceType != "" {
            myDeviceType = deviceType
        }
        else {
            myDeviceType = self.data.DeviceType
        }
        
        
        if temperatureType != "" {
            
            if temperatureType == "F" {
                switch myDeviceType {
                case "K":
                    return 2501
                case "J":
                    return 1832
                case "E":
                    return 1382
                case "T":
                    return 752
                case "N":
                    return 2372
                case "R":
                    return 3212
                case "S":
                    return 3212
                default:
                    return 2500
                }
            }else if temperatureType == "K" {
                
                switch myDeviceType {
                case "K":
                    return 1645.15
                case "J":
                    return 1273.15
                case "E":
                    return 1023.15
                case "T":
                    return 673.15
                case "N":
                    return 1573.15
                case "R":
                    return 2040.15
                case "S":
                    return 2040.15
                default:
                    return 2500
                }
                
            }
            else {
                switch myDeviceType {
                case "K":
                    return 1372
                case "J":
                    return 1000
                case "E":
                    return 750
                case "T":
                    return 400
                case "N":
                    return 1300
                case "R":
                    return 1767
                case "S":
                    return 1767
                default:
                    return 2500
                }
            }
        }
        else {
            if self.data.cOrFOrK == "F" {
                switch myDeviceType {
                case "K":
                    self.data.deviceMaxValueRange = 2501
                    break
                case "J":
                    self.data.deviceMaxValueRange = 1832
                    break
                case "E":
                    self.data.deviceMaxValueRange = 1382
                    break
                case "T":
                    self.data.deviceMaxValueRange = 752
                    break
                case "N":
                    self.data.deviceMaxValueRange = 2372
                    break
                case "R":
                    self.data.deviceMaxValueRange = 3212
                    break
                case "S":
                    self.data.deviceMaxValueRange = 3212
                    break
                default:
                    self.data.deviceMaxValueRange = 2500
                    break
                }
            }else if self.data.cOrFOrK == "K" {
                switch myDeviceType {
                case "K":
                    self.data.deviceMaxValueRange = 1645.15
                    break
                case "J":
                    self.data.deviceMaxValueRange = 1273.15
                    break
                case "E":
                    self.data.deviceMaxValueRange = 1023.15
                    break
                case "T":
                    self.data.deviceMaxValueRange = 673.15
                    break
                case "N":
                    self.data.deviceMaxValueRange = 1573.15
                    break
                case "R":
                    self.data.deviceMaxValueRange = 2040.15
                    break
                case "S":
                    self.data.deviceMaxValueRange = 2040.15
                    break
                default:
                    self.data.deviceMaxValueRange = 2500
                    break
                }
            }
            else {
                switch myDeviceType {
                case "K":
                    self.data.deviceMaxValueRange = 1372
                    break
                case "J":
                    self.data.deviceMaxValueRange = 1000
                    break
                case "E":
                    self.data.deviceMaxValueRange = 750
                    break
                case "T":
                    self.data.deviceMaxValueRange = 400
                    break
                case "N":
                    self.data.deviceMaxValueRange = 1300
                    break
                case "R":
                    self.data.deviceMaxValueRange = 1767
                    break
                case "S":
                    self.data.deviceMaxValueRange = 1767
                    break
                default:
                    self.data.deviceMaxValueRange = 2500
                    break
                }
            }
        }
        
        return self.data.deviceMaxValueRange
    }
    
    func getMinValue(temperatureType :String, deviceType :String) -> Float {
        
        var myDeviceType = ""
        
        if deviceType != "" {
            myDeviceType = deviceType
        }
        else {
            myDeviceType = self.data.DeviceType
        }
        
        if temperatureType != "" {
            
            if temperatureType == "F" {
                switch myDeviceType {
                case "K":
                    return -328
                case "J":
                    return -328
                case "E":
                    return -328
                case "T":
                    return -328
                case "N":
                    return -328
                case "R":
                    return 32
                case "S":
                    return 32
                default:
                    return -328
                }
            }else if temperatureType == "K" {
                switch myDeviceType {
                case "K":
                    return 73.15
                case "J":
                    return 73.15
                case "E":
                    return 73.15
                case "T":
                    return 73.15
                case "N":
                    return 73.15
                case "R":
                    return 273.15
                case "S":
                    return 273.15
                default:
                    return 73.15
                }
            }
            else {
                switch myDeviceType {
                case "K":
                    return -200
                case "J":
                    return -200
                case "E":
                    return -200
                case "T":
                    return -200
                case "N":
                    return -200
                case "R":
                    return 0
                case "S":
                    return 0
                default:
                    return -200
                }
            }
        }
        else
        {
            if self.data.cOrFOrK == "F" {
                switch myDeviceType {
                case "K":
                    self.data.deviceMinValueRange = -328
                    break
                case "J":
                    self.data.deviceMinValueRange = -328
                    break
                case "E":
                    self.data.deviceMinValueRange = -328
                    break
                case "T":
                    self.data.deviceMinValueRange = -328
                    break
                case "N":
                    self.data.deviceMinValueRange = -328
                    break
                case "R":
                    self.data.deviceMinValueRange = 32
                    break
                case "S":
                    self.data.deviceMinValueRange = 32
                    break
                default:
                    self.data.deviceMinValueRange = -328
                    break
                }
            }else if self.data.cOrFOrK == "K" {
                switch myDeviceType {
                case "K":
                    self.data.deviceMinValueRange = 73.15
                    break
                case "J":
                    self.data.deviceMinValueRange = 73.15
                    break
                case "E":
                    self.data.deviceMinValueRange = 73.15
                    break
                case "T":
                    self.data.deviceMinValueRange = 73.15
                    break
                case "N":
                    self.data.deviceMinValueRange = 73.15
                    break
                case "R":
                    self.data.deviceMinValueRange = 273.15
                    break
                case "S":
                    self.data.deviceMinValueRange = 273.15
                    break
                default:
                    self.data.deviceMinValueRange = 73.15
                    break
                }
            }
            else {
                switch myDeviceType {
                case "K":
                    self.data.deviceMinValueRange = -200
                    break
                case "J":
                    self.data.deviceMinValueRange = -200
                    break
                case "E":
                    self.data.deviceMinValueRange = -200
                    break
                case "T":
                    self.data.deviceMinValueRange = -200
                    break
                case "N":
                    self.data.deviceMinValueRange = -200
                    break
                case "R":
                    self.data.deviceMinValueRange = 0
                    break
                case "S":
                    self.data.deviceMinValueRange = 0
                    break
                default:
                    self.data.deviceMinValueRange = -200
                    break
                }
            }
        }
        
        return self.data.deviceMinValueRange
    }
    
    
    // Here is for T1 we need to set min and max for alarm is -20(Min) to 60(Max)
    
    func getT1MaxValue(temperatureType :String) -> Float {
        
        if temperatureType == "C" {
            return 60
        }else if temperatureType == "F" {
            return 140
        }else if temperatureType == "K" {
            return 333.15
        }
        return 0.0
    }
    func getT1MinValue(temperatureType :String) -> Float {
        
        if temperatureType == "C" {
            return -20
        }else if temperatureType == "F" {
            return -4
        }else if temperatureType == "K" {
            return 253.15
        }
        return 0.0
    }
    
    // MARK: - Other Methods
    
    func getT1Celisus(x1:UInt8 , x2:UInt8) -> String {
        
        let x1_16 =  String(format:"%02X", x1)
        let x2_16 =  String(format:"%02X", x2)
        let x3 = x1_16 + x2_16
        let u3 = UInt16(x3, radix: 16)!
        var s3 = Int16(bitPattern: u3)
        s3 = s3 / 10
        //28.7°C×9/5+32
        print(Float((1.8 * Double(s3)) + 32.0))
        return String(format:"%.1f",Float((1.8 * Double(s3)) + 32.0))
    }
    func getT1Kelvin(x1:UInt8 , x2:UInt8) -> String {
        
        let fahrenheit = self.getFahrenheit(x1: x1, x2: x2)
        return String(format:"%.1f",Float(Float(fahrenheit)! + 273.15))
    }
    func getFahrenheit(x1:UInt8 , x2:UInt8) -> String {
        let x1_16 =  String(format:"%02X", x1)
        let x2_16 =  String(format:"%02X", x2)
        let x3 = x1_16 + x2_16
        let u3 = UInt16(x3, radix: 16)!
        let s3 = Int16(bitPattern: u3)
        
        print(Float(s3) / 10)
        return String(Float(s3) / 10)
    }
    
    func getCelsius(x1:UInt8 , x2:UInt8) -> String {
        let fahrenheit = self.getFahrenheit(x1: x1, x2: x2)
        print(fahrenheit)
        return String(format:"%.1f",Float(5.0 / 9.0 * (Double(fahrenheit)! - 32.0)))
    }
    
    func getKelvin(x1:UInt8 , x2:UInt8) -> String {
        let fahrenheit = self.getFahrenheit(x1: x1, x2: x2)
        return String(format:"%.1f",Float((5.0 / 9.0) * (Double(fahrenheit)! + 459.67)))
    }
    
    func setTextForTemperatures (RH:String , t1:String, t2:String) {
        
        print("Value of RH ", RH)
        print("Value of t1 ", t1)
        print("Value of t2 ", t2)
        self.data.RHtemperature = RH;
        self.data.temperatureT1 = t1; // Always degree C Reading
        self.data.temperatureT2 = t2; // Always degrre F Reading
        
    }
    
    
    
    func converToBinary(x1:UInt8) -> [String] {
        var str = String(x1, radix: 2)
        while str.characters.count % 8 != 0 {
            str = "0" + str
        }
        return str.characters.map { String($0) }
    }
    
    func set32Byte(byteArray :[UInt8])
    {
        var checkSum: Int = 0
        
        self.dataP.totalBytesReceived += 32
        print("TotalBytesReceived: \(self.dataP.totalBytesReceived) Total Bytes: \(self.dataP.totalBytes)")
        self.mainCenteralManagerForCommandPDelegate?.ReceiveCommand()
        for i in 0 ..< 32  {
            
            // Total Check Sum Value
            checkSum = checkSum + Int(byteArray[i])
            
            // Add Data to array
            let myData : NSMutableDictionary = NSMutableDictionary()
            myData.setValue(String(format:"%02X", byteArray[i]), forKey: "Hexa")
            myData.setValue("\(byteArray[i])", forKey: "Int")
            myData.setValue("\(self.converToBinary(x1: byteArray[i]))", forKey: "Binary")
            myData.setValue("\(Int8(bitPattern: byteArray[i]))", forKey: "Decimal")
            self.dataP.myDownloadedData.add(myData)
        }
        if (Int((byteArray[34] & 0xFF)) == (checkSum & 0xFF) && byteArray[35] == 5) {
            self.CommandRepeatP()
        }
        else {
            self.CommandWrongCommand()
        }
    }
    
    func settingBetryImg (betryStatus:UInt8) {
        
        if betryStatus == 1 {
            self.data.imgbettery = "Battery1.png"
        }
        else if betryStatus == 2 {
            self.data.imgbettery = "Battery2.png"
        }
        else if betryStatus == 3 {
            self.data.imgbettery = "BatteryFull.png"
        }
        else{
            self.data.imgbettery = "Batterynull.png"
        }
    }
}
