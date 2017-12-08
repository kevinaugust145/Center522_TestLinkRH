//
//  DetailViewController.swift
//  BtSample
//
//  Created by Yu chengJhuo on 1/10/17.
//  Copyright © 2017 Yu-cheng Jhuo. All rights reserved.
//

import UIKit
import CoreBluetooth


@objc class DetailViewController: UIViewController , CBPeripheralDelegate, CBCentralManagerDelegate { //UITableViewDataSource , UITableViewDelegate
    
    var centralManager: CBCentralManager? = nil
    var peripheral: CBPeripheral!
    @IBOutlet var bbConnect :UILabel!
    
    var btServices :[BTServiceInfo] = []
    var lastString :NSString = ""
    var savedCharacteristic : CBCharacteristic?
    
    @IBOutlet var textView :UITextView!
    
    //@IBOutlet var tableView:UITableView!
    
    var currentBTServiceInfo :BTServiceInfo!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.title = peripheral.name
        peripheral.delegate = self
        centralManager?.delegate = self
        centralManager?.connect(peripheral, options: nil)
        
        if peripheral.state == CBPeripheralState.connected {
            
        }
        
        //tableView.register(UINib(nibName: "DetailTableViewCell", bundle: nil), forCellReuseIdentifier: "DetailTableViewCell")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.centralManager = nil
    }
    
    // MARK: - CBCentralManager Methods
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if peripheral.state == CBPeripheralState.connected {
            //bbConnect.text = "Connected"
            peripheral.discoverServices(nil)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
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
    
//    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
//        
//        print("NAME:" + peripheral.name! )
//        print("RSSI:" + RSSI.description )
//        
//        if (peripheral.state == CBPeripheralState.connected){
//            print("isConnected: connected")
//        }else{
//            print("isConnected: disconnected")
//        }
//        
//        print("advertisementData:" + advertisementData.description)
//        
//        
////        if (peripheral.services != nil ){
////
////        }
//
//    }
    
    

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        let serviceCharacteristics = service.characteristics
        for item in btServices {
            if item.service.uuid == service.uuid {
                item.characteristics = serviceCharacteristics!
                let charitem = serviceCharacteristics?.first
                self.peripheral.setNotifyValue(true, for: charitem!)
                break
            }
        }
        
        //self.tableView.reloadData()
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        if (characteristic.value != nil){
            let resultStr = NSString(data: characteristic.value!, encoding: String.Encoding.utf8.rawValue)
            
            print("characteristic uuid:\(characteristic.uuid)   value:\(resultStr)")
            
            if let value = characteristic.value{
                let log = "read: \(value)"
                print(log)
                
//                let byteArray = [UInt8](value)
//                print(byteArray)
//
//                guard value.count == 36 else {
//                    return
//                }
//                
//                
//                
//                //if (characteristic.uuid.description == "49535343-1E4D-4BD9-BA61-23C647249616"){
//                    var text = ""
//                    
//                    text = text  + "\n" + String(format:"%.1f", byteArray[0])
//                    text = text  + "\n" + String(format:"%.1f", byteArray[1])
//                    text = text  + "\n" + String(format:"%.1f", byteArray[2])
//                    text = text  + "\n" + String(format:"%.1f", byteArray[3])
//                    text = text  + "\n" + String(format:"%.1f", byteArray[4])
//                    text = text  + "\n" + String(format:"%.1f", byteArray[5])
//                    text = text  + "\n" + String(format:"%.1f", byteArray[6])
//                    text = text  + "\n" + String(format:"%.1f", byteArray[7])
//                    text = text  + "\n" + String(format:"%.1f", byteArray[8])
//                    text = text  + "\n" + String(format:"%.1f", byteArray[9])
//                    
//                    self.textView.text = self.textView.text + "\n" + text
//                    let stringLength:Int = self.textView.text.characters.count
//                    self.textView.scrollRangeToVisible(NSMakeRange(stringLength-1, 0))
//                //}
                
                guard value.count == 64 else {
                    return
                }
                
                let byteArray = [UInt8](value)
                print(byteArray)
            
                if (characteristic.uuid.description == "49535343-1E4D-4BD9-BA61-23C647249616"){
                     var text = ""
                    
                    let byte3 = self.converToBinary(x1: byteArray[2])
                    
                    if (byte3[0] == "1"){
                        text = "C"
                        
                        text = text  + "\n" + self.getCelsius(x1: byteArray[9], x2: byteArray[10])
                        text = text + "\n" +  self.getCelsius(x1: byteArray[11], x2: byteArray[12])
                        text = text + "\n" +  self.getCelsius(x1: byteArray[13], x2: byteArray[14])
                        text = text + "\n" +  self.getCelsius(x1: byteArray[15], x2: byteArray[16])
                    }else{
                        text = "F"
                        
                        text = text  + "\n" + self.getFahrenheit(x1: byteArray[9], x2: byteArray[10])
                        text = text + "\n" +  self.getFahrenheit(x1: byteArray[11], x2: byteArray[12])
                        text = text + "\n" +  self.getFahrenheit(x1: byteArray[13], x2: byteArray[14])
                        text = text + "\n" +  self.getFahrenheit(x1: byteArray[15], x2: byteArray[16])
                        
                    }
                    self.textView.text = self.textView.text + "\n" + text
                    let stringLength:Int = self.textView.text.characters.count
                    self.textView.scrollRangeToVisible(NSMakeRange(stringLength-1, 0))
                }
            }
            
            if lastString == resultStr{
                return;
            }
            
            // 操作的characteristic 保存
            self.savedCharacteristic = characteristic
            
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        
        
        if error != nil{
            print("写入 characteristics 时 \(peripheral.name) 报错 \(error?.localizedDescription)")
            return
        }
        //Commented by Meet
//        if (characteristic.value != nil){
//
//            print("characteristic.value:", characteristic.value ?? "123")
//            
//            lastString = NSString(data: characteristic.value!, encoding: String.Encoding.utf8.rawValue)!
//
//            print("lastString:" + (lastString as String))
//        }
    }
    
    func viewController(characteristic: CBCharacteristic,value : Data ) -> () {
        
        //只有 characteristic.properties 有write的权限才可以写入
        if characteristic.properties.contains(CBCharacteristicProperties.write){
            //设置为  写入有反馈
            self.peripheral.writeValue(value, for: characteristic, type: .withResponse)
            
        }else{
            print("写入不可用~")
        }
    }
    
    // MARK: - Tableview Methods
    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return self.btServices.count
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//         let cell = tableView.dequeueReusableCell(withIdentifier: "DetailTableViewCell") as! DetailTableViewCell
//        
//        
//        cell.labUUID.text = btServices[indexPath.section].characteristics[indexPath.row].uuid.uuidString
//        cell.labDESC.text = btServices[indexPath.section].characteristics[indexPath.row].uuid.description
//        
//        cell.labProp.text = String(format: "0x%02X", btServices[indexPath.section].characteristics[indexPath.row].properties.rawValue)
//        cell.labValue.text = btServices[indexPath.section].characteristics[indexPath.row].value?.description ?? "null"
//        cell.labNoti.text = btServices[indexPath.section].characteristics[indexPath.row].isNotifying.description
//        //cell.labContent.text = btServices[indexPath.section].characteristics[indexPath.row].
//        return cell
//        
//    }
//    
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
//    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 170
//    }
//    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        
//        
//        let charItems = self.btServices[indexPath.row].characteristics
//        self.currentBTServiceInfo = self.btServices[indexPath.row]
//        
//        //获取Characteristic的值，读到数据会进入方法：
//        for characteristic in charItems {
//            peripheral.readValue(for: characteristic)
//            
//            //设置 characteristic 的 notifying 属性 为 true ， 表示接受广播
//            peripheral.setNotifyValue(true, for: characteristic)
//            
//        }
//    }
    
    // MARK: - Button Action Methods
    
    @IBAction func backButtonAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btncommandC(){
        
        //[  0x02 , 0x43 , 0x00 , 0x00 , 0x00 , 0x00 , 0x03 ]   C Command
        //[  0x02 , 0x50 , 0x00 , 0x00 , 0x00 , 0x00 , 0x03 ]   P Command
        let commandCbyte : [UInt8] = [  0x02 , 0x43 , 0x00 , 0x00 , 0x00 , 0x00 , 0x03 ]
        let data2 = Data(bytes:commandCbyte)
        
        if self.btServices.count > 1 {
            let charItems = self.btServices[1].characteristics
            for characteristic in charItems {
                peripheral.readValue(for: characteristic)
                
                //设置 characteristic 的 notifying 属性 为 true ， 表示接受广播
                peripheral.setNotifyValue(true, for: characteristic)
            }
            
            //for characteristic in self.currentBTServiceInfo.characteristics {
            for characteristic in charItems {
                if characteristic.properties.contains(CBCharacteristicProperties.writeWithoutResponse){
                    //设置为  写入有反馈
                    self.peripheral.writeValue(data2, for: characteristic, type: .withResponse)
                    //print("写入withoutResponse~")
                }else{
                    print("写入不可用~")
                }
            }
        }
    }
    
    @IBAction func btncommandP(){
        
        //[  0x02 , 0x43 , 0x00 , 0x00 , 0x00 , 0x00 , 0x03 ]   C Command
        //[  0x02 , 0x50 , 0x00 , 0x00 , 0x00 , 0x00 , 0x03 ]   P Command
        let commandCbyte : [UInt8] = [  0x02 , 0x50 , 0x00 , 0x00 , 0x00 , 0x00 , 0x03 ]
        let data2 = Data(bytes:commandCbyte)
        
        if self.btServices.count > 1 {
            let charItems = self.btServices[1].characteristics
            for characteristic in charItems {
                peripheral.readValue(for: characteristic)
                
                //设置 characteristic 的 notifying 属性 为 true ， 表示接受广播
                peripheral.setNotifyValue(true, for: characteristic)
            }
            
            //for characteristic in self.currentBTServiceInfo.characteristics {
            for characteristic in charItems {
                if characteristic.properties.contains(CBCharacteristicProperties.writeWithoutResponse){
                    //设置为  写入有反馈
                    self.peripheral.writeValue(data2, for: characteristic, type: .withResponse)
                    //print("写入withoutResponse~")
                }else{
                    print("写入不可用~")
                }
            }
        }
    }

    @IBAction func btncommandRepeatP(){
        
        //[  0x02 , 0x43 , 0x00 , 0x00 , 0x00 , 0x00 , 0x03 ]   C Command
        //[  0x02 , 0x50 , 0x00 , 0x00 , 0x00 , 0x00 , 0x03 ]   P Command
        let commandCbyte : [UInt8] = [  0x02 , 0x70 , 0x00 , 0x00 , 0x00 , 0x00 , 0x03 ]
        let data2 = Data(bytes:commandCbyte)
        
        if self.btServices.count > 1 {
            let charItems = self.btServices[1].characteristics
            for characteristic in charItems {
                peripheral.readValue(for: characteristic)
                
                //设置 characteristic 的 notifying 属性 为 true ， 表示接受广播
                peripheral.setNotifyValue(true, for: characteristic)
            }
            
            //for characteristic in self.currentBTServiceInfo.characteristics {
            for characteristic in charItems {
                if characteristic.properties.contains(CBCharacteristicProperties.writeWithoutResponse){
                    //设置为  写入有反馈
                    self.peripheral.writeValue(data2, for: characteristic, type: .withResponse)
                    //print("写入withoutResponse~")
                }else{
                    print("写入不可用~")
                }
            }
        }
    }
    
    @IBAction func btncommandA(){
        let commandAbyte : [UInt8] = [  0x02 , 0x41 , 0x00 , 0x00 , 0x00 , 0x00 , 0x03 ]
        let data1 = Data(bytes:commandAbyte)
        
        if self.btServices.count > 1 {
            let charItems = self.btServices[1].characteristics
            for characteristic in charItems {
                peripheral.readValue(for: characteristic)
                
                //设置 characteristic 的 notifying 属性 为 true ， 表示接受广播
                peripheral.setNotifyValue(true, for: characteristic)
                
            }
            
            for characteristic in charItems {
                self.viewController(characteristic: characteristic, value: data1)
            }
        }
    }
    
    @IBAction func btncommandWrongCommand(){
        let commandAbyte : [UInt8] = [  0x02 , 0x6e , 0x00 , 0x00 , 0x00 , 0x00 , 0x03 ]
        let data1 = Data(bytes:commandAbyte)
        
        if self.btServices.count > 1 {
            let charItems = self.btServices[1].characteristics
            for characteristic in charItems {
                peripheral.readValue(for: characteristic)
                
                //设置 characteristic 的 notifying 属性 为 true ， 表示接受广播
                peripheral.setNotifyValue(true, for: characteristic)
            }
            
            for characteristic in charItems {
                self.viewController(characteristic: characteristic, value: data1)
            }
        }
    }
    
    // MARK: - Other Methods
    
    private func getFahrenheit(x1:UInt8 , x2:UInt8) -> String {
        let x1_16 =  String(format:"%02X", x1)
        let x2_16 =  String(format:"%02X", x2)
        let x3 = x1_16 + x2_16
        return String(Float(UInt(x3, radix: 16)!) / 10)
    }
    
    private func converToBinary(x1:UInt8) -> [String] {
        var str = String(x1, radix: 2)
        while str.characters.count % 8 != 0 {
            str = "0" + str
        }
        return str.characters.map { String($0) }
    }
    
    private func getCelsius(x1:UInt8 , x2:UInt8) -> String {
        let fahrenheit = self.getFahrenheit(x1: x1, x2: x2)
        return String(format:"%.1f",Float(5.0 / 9.0 * (Double(fahrenheit)! - 32.0)))
    }
    
}
