////
////  BlueToothOptionVC.swift
////  TestLink
////
////  Created by Pritesh Pethani on 24/01/17.
////  Copyright © 2017 Pritesh Pethani. All rights reserved.
////
//
//import UIKit
//import CoreBluetooth
//
//@objc class BlueToothOptionVC: UIViewController, CBPeripheralDelegate, CBCentralManagerDelegate, UITextFieldDelegate {//
//
//    var centralManager: CBCentralManager? = nil
//    var peripheral: CBPeripheral!
//    var btServices :[BTServiceInfo] = []
//    var lastString :NSString = ""
//    var savedCharacteristic : CBCharacteristic?
//    
//    var currentBTServiceInfo :BTServiceInfo!
//    
//    @IBOutlet var btnConnect: UIButton!
//    
//    @IBOutlet var lblConnect: UILabel!
//    
//    @IBOutlet var imgbettery: UIImageView!
//    
//    @IBOutlet var lblT1Min: UILabel!
//    @IBOutlet var lblT1Max: UILabel!
//    @IBOutlet var lblT1Unset: UILabel!
//    
//    @IBOutlet var lblT2Min: UILabel!
//    @IBOutlet var lblT2Max: UILabel!
//    @IBOutlet var lblT2Unset: UILabel!
//    
//    @IBOutlet var lblT3Min: UILabel!
//    @IBOutlet var lblT3Max: UILabel!
//    @IBOutlet var lblT3Unset: UILabel!
//    
//    @IBOutlet var lblT4Min: UILabel!
//    @IBOutlet var lblT4Max: UILabel!
//    @IBOutlet var lblT4Unset: UILabel!
//    
//    @IBOutlet var swichT1: UISwitch!
//    @IBOutlet var swichT2: UISwitch!
//    @IBOutlet var swichT3: UISwitch!
//    @IBOutlet var swichT4: UISwitch!
//    @IBOutlet var swichScale: UISwitch!
//    
//    @IBOutlet var currentScale: UILabel!
//    @IBOutlet var btnClose: UIButton!
//
//    @IBOutlet var viewSetting: UIView!
//    @IBOutlet var viewUnderSetting: UIView!
//    
//    @IBOutlet var viewAlarmTemp: UIView!
//    
//    @IBOutlet var lblMinMaxTemp :UILabel!
//    @IBOutlet var txtMinTemp :UITextField!
//    @IBOutlet var txtMaxTemp :UITextField!
//    var indexID:Int!
//    
//    var rangeData = NSMutableArray()
//    var rangeDict = NSMutableDictionary()
//    
//    var statusTimer:Timer!
//    
//    @IBOutlet var temperatureButton:UIButton!
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        btnConnect.layer.borderWidth = 1.0
//        btnConnect.layer.borderColor = UIColor.white.cgColor
//        
//        
//        //imgbettery.image = UIImage.init(named: "Batterynull.png")
//
//
//        NotificationCenter.default.addObserver(self, selector: #selector(self.callingBtnCommandAMethod), name: NSNotification.Name(rawValue: "callingMethodForBetryStatus"), object: nil)
//        
//        self.callingBtnCommandAMethod()
//        
//        
//        
//        self.setSettingData()
//        let notificationName = Notification.Name("settingDataNotification")
//        NotificationCenter.default.addObserver(self, selector: #selector(self.setSettingData), name: notificationName, object: nil)
//        
//        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification(notification:)), name: Notification.Name("deviceDisconnected"), object: nil)
//    }
//    
//    func callingBtnCommandAMethod(){
//        print("Method called callingBtnCommandAMethod")
//        
//        if peripheral != nil {
//            self.settingDetails(connectedDeviceName: peripheral.name!)
//            self.title = peripheral.name
//            peripheral.delegate = self
//            centralManager?.delegate = self
//            centralManager?.connect(peripheral, options: nil)
//            
//            if peripheral.state == CBPeripheralState.connected {
//                
//            }
//            
//            statusTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(self.checkingStates), userInfo: nil, repeats: true)
//            
//            //Commented by Meet.
//            
//            Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(self.btncommandA), userInfo: nil, repeats: true)
//        }
//        else {
//            self.settingDetails(connectedDeviceName: "")
//        }
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(true)
//        
//        if USERDEFAULT.value(forKey: "temperatureData") != nil
//        {
//            if let tempData = USERDEFAULT.value(forKey: "temperatureData") as? NSArray
//            {
//                rangeData = NSMutableArray(array: tempData)
//            }
//            else{
//                rangeData = NSMutableArray()
//                
//                rangeDict.setValue("", forKey: "minValue")
//                rangeDict.setValue("", forKey: "maxValue")
//                rangeData.add(rangeDict)
//                
//                rangeDict.setValue("", forKey: "minValue")
//                rangeDict.setValue("", forKey: "maxValue")
//                rangeData.add(rangeDict)
//                
//                rangeDict.setValue("", forKey: "minValue")
//                rangeDict.setValue("", forKey: "maxValue")
//                rangeData.add(rangeDict)
//                
//                rangeDict.setValue("", forKey: "minValue")
//                rangeDict.setValue("", forKey: "maxValue")
//                rangeData.add(rangeDict)
//                
//                print("Range Data ", rangeData)
//            }
//        }
//        else{
//            rangeData = NSMutableArray()
//            
//            rangeDict.setValue("", forKey: "minValue")
//            rangeDict.setValue("", forKey: "maxValue")
//            rangeData.add(rangeDict)
//            
//            rangeDict.setValue("", forKey: "minValue")
//            rangeDict.setValue("", forKey: "maxValue")
//            rangeData.add(rangeDict)
//            
//            rangeDict.setValue("", forKey: "minValue")
//            rangeDict.setValue("", forKey: "maxValue")
//            rangeData.add(rangeDict)
//            
//            rangeDict.setValue("", forKey: "minValue")
//            rangeDict.setValue("", forKey: "maxValue")
//            rangeData.add(rangeDict)
//            
//            print("Range Data ", rangeData)
//            
//            USERDEFAULT.set(self.rangeData, forKey: "temperatureData")
//            USERDEFAULT.synchronize()
//        }
//        
//    }
//    
//    override func viewDidDisappear(_ animated: Bool) {
//        super.viewDidDisappear(animated)
//        //self.centralManager = nil
//    }
//    
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//    
//    func settingDetails (connectedDeviceName: String){
//        
//        if connectedDeviceName != "" {
//            self.lblConnect.text = "Connected to \(peripheral.name!)"
//            btnConnect.setTitle("Disconnect", for: .normal)
//        }
//        else{
//            peripheral = nil
//            centralManager = nil
//            self.lblConnect.text = "Not Connected to any bluetooth device"
//            btnConnect.setTitle("Connect", for: .normal)
//            self.settingBetryImg(betryStatus: 0)
//        }
//    }
//    
//    func setSettingData() {
//        
//        if let isFah = USERDEFAULT.value(forKey: "isFahrenheit") as? Bool{
//            if  isFah == true{
//                USERDEFAULT.set(true, forKey: "isFahrenheit")
//                USERDEFAULT.synchronize()
//                swichScale.isOn = true
//                temperatureButton.setImage(UIImage.init(named: "on.png"), for: .normal)
//                self.currentScale.text = "Current Scale : fahrenheit"
//            }
//            else{
//                USERDEFAULT.set(false, forKey: "isFahrenheit")
//                USERDEFAULT.synchronize()
//                swichScale.isOn = false
//                temperatureButton.setImage(UIImage.init(named: "off.png"), for: .normal)
//                self.currentScale.text = "Current Scale : celsius"
//            }
//        }
//        else{
//            USERDEFAULT.set(false, forKey: "isFahrenheit")
//            USERDEFAULT.synchronize()
//            swichScale.isOn = false
//            temperatureButton.setImage(UIImage.init(named: "off.png"), for: .normal)
//            self.currentScale.text = "Current Scale : celsius"
//        }
//        
//        var isFahrenheitSwitch:Bool = false
//        
//        if swichScale.isOn{
//            isFahrenheitSwitch = true
//        }
//        else{
//            isFahrenheitSwitch = false
//        }
//        
//        
//        
//        if let tempData = USERDEFAULT.value(forKey: "temperatureData") as? NSArray
//        {
//            let temperatureData = tempData as NSArray
//            
//            if (temperatureData.object(at: 0) as AnyObject).value(forKey: "minValue") as! String == ""{
//                lblT1Min.text = "MIN 00"
//            }
//            else{
//                var minTemp:String = "\((temperatureData.object(at: 0) as AnyObject).value(forKey: "minValue") as! String)"
//                
//                if isFahrenheitSwitch {
//                    minTemp = String((Float(minTemp)! * 1.8) + 32)
//                }
//                
//                lblT1Min.text = "MIN \(minTemp)"
//            }
//            
//            if (temperatureData.object(at: 0) as AnyObject).value(forKey: "maxValue") as! String == ""{
//                lblT1Max.text = "MAX 00"
//            }
//            else{
//                var maxTemp:String = "\((temperatureData.object(at: 0) as AnyObject).value(forKey: "maxValue") as! String)"
//                
//                if isFahrenheitSwitch {
//                    maxTemp = String((Float(maxTemp)! * 1.8) + 32)
//                }
//                
//                lblT1Max.text = "MAX \(maxTemp)"
//            }
//            
//            
//            if (temperatureData.object(at: 1) as AnyObject).value(forKey: "minValue") as! String == ""{
//                lblT2Min.text = "MIN 00"
//            }
//            else{
//                var minTemp:String = "\((temperatureData.object(at: 1) as AnyObject).value(forKey: "minValue") as! String)"
//                
//                if isFahrenheitSwitch {
//                    minTemp = String((Float(minTemp)! * 1.8) + 32)
//                }
//                
//                lblT2Min.text = "MIN \(minTemp)"
//            }
//            
//            if (temperatureData.object(at: 1) as AnyObject).value(forKey: "maxValue") as! String == ""{
//                lblT2Max.text = "MAX 00"
//            }
//            else{
//                var maxTemp:String = "\((temperatureData.object(at: 1) as AnyObject).value(forKey: "maxValue") as! String)"
//                
//                if isFahrenheitSwitch {
//                    maxTemp = String((Float(maxTemp)! * 1.8) + 32)
//                }
//                
//                lblT2Max.text = "MAX \(maxTemp)"
//            }
//            
//            
//            if (temperatureData.object(at: 2) as AnyObject).value(forKey: "minValue") as! String == ""{
//                lblT3Min.text = "MIN 00"
//            }
//            else{
//                var minTemp:String = "\((temperatureData.object(at: 2) as AnyObject).value(forKey: "minValue") as! String)"
//                
//                if isFahrenheitSwitch {
//                    minTemp = String((Float(minTemp)! * 1.8) + 32)
//                }
//                
//                lblT3Min.text = "MIN \(minTemp)"
//            }
//            
//            if (temperatureData.object(at: 2) as AnyObject).value(forKey: "maxValue") as! String == ""{
//                lblT3Max.text = "MAX 00"
//            }
//            else{
//                var maxTemp:String = "\((temperatureData.object(at: 2) as AnyObject).value(forKey: "maxValue") as! String)"
//                
//                if isFahrenheitSwitch {
//                    maxTemp = String((Float(maxTemp)! * 1.8) + 32)
//                }
//                
//                lblT3Max.text = "MAX \(maxTemp)"
//            }
//            
//            
//            if (temperatureData.object(at: 3) as AnyObject).value(forKey: "minValue") as! String == ""{
//                lblT4Min.text = "MIN 00"
//            }
//            else{
//                var minTemp:String = "\((temperatureData.object(at: 3) as AnyObject).value(forKey: "minValue") as! String)"
//                
//                if isFahrenheitSwitch {
//                    minTemp = String((Float(minTemp)! * 1.8) + 32)
//                }
//                
//                lblT4Min.text = "MIN \(minTemp)"
//            }
//            
//            if (temperatureData.object(at: 3) as AnyObject).value(forKey: "maxValue") as! String == ""{
//                lblT4Max.text = "MAX 00"
//            }
//            else{
//                var maxTemp:String = "\((temperatureData.object(at: 3) as AnyObject).value(forKey: "maxValue") as! String)"
//                
//                if isFahrenheitSwitch {
//                    maxTemp = String((Float(maxTemp)! * 1.8) + 32)
//                }
//                
//                lblT4Max.text = "MAX \(maxTemp)"
//            }
//        }
//        else{
//            //print("Setting tempratureData ",USERDEFAULT.value(forKey: "temperatureData") ?? "Not Data")
//        }
//        
//        
//        if let t1 = USERDEFAULT.value(forKey: "isT1") as? Bool{
//            if  t1 == true{
//                USERDEFAULT.set(true, forKey: "isT1")
//                USERDEFAULT.synchronize()
//                swichT1.isOn = true
//                lblT1Max.isHidden = false
//                lblT1Min.isHidden = false
//                lblT1Unset.isHidden = true
//
//            }
//            else{
//                USERDEFAULT.set(false, forKey: "isT1")
//                USERDEFAULT.synchronize()
//                swichT1.isOn = false
//                lblT1Max.isHidden = true
//                lblT1Min.isHidden = true
//                lblT1Unset.isHidden = false
//            }
//            
//        }
//        else{
//            USERDEFAULT.set(false, forKey: "isT1")
//            USERDEFAULT.synchronize()
//            swichT1.isOn = false
//            lblT1Max.isHidden = true
//            lblT1Min.isHidden = true
//            lblT1Unset.isHidden = false
//            
//        }
//        
//        if let t2 = USERDEFAULT.value(forKey: "isT2") as? Bool{
//            if  t2 == true{
//                USERDEFAULT.set(true, forKey: "isT2")
//                USERDEFAULT.synchronize()
//                swichT2.isOn = true
//                
//                lblT2Max.isHidden = false
//                lblT2Min.isHidden = false
//              lblT2Unset.isHidden = true
//
//                
//            }
//            else{
//                USERDEFAULT.set(false, forKey: "isT2")
//                USERDEFAULT.synchronize()
//                swichT2.isOn = false
//                
//                lblT2Max.isHidden = true
//                lblT2Min.isHidden = true
//                lblT2Unset.isHidden = false
//            }
//            
//        }
//        else{
//            USERDEFAULT.set(false, forKey: "isT2")
//            USERDEFAULT.synchronize()
//            swichT2.isOn = false
//            lblT2Max.isHidden = true
//            lblT2Min.isHidden = true
//            lblT2Unset.isHidden = false
//        }
//        
//
//        if let t3 = USERDEFAULT.value(forKey: "isT3") as? Bool{
//            if  t3 == true{
//                USERDEFAULT.set(true, forKey: "isT3")
//                USERDEFAULT.synchronize()
//                swichT3.isOn = true
//                lblT3Max.isHidden = false
//                lblT3Min.isHidden = false
//                lblT3Unset.isHidden = true
//            }
//            else{
//                USERDEFAULT.set(false, forKey: "isT3")
//                USERDEFAULT.synchronize()
//                swichT3.isOn = false
//                
//                lblT3Max.isHidden = true
//                lblT3Min.isHidden = true
//                lblT3Unset.isHidden = false
//            }
//            
//        }
//        else{
//            USERDEFAULT.set(false, forKey: "isT3")
//            USERDEFAULT.synchronize()
//            swichT3.isOn = false
//            lblT3Max.isHidden = true
//            lblT3Min.isHidden = true
//            lblT3Unset.isHidden = false
//
//        }
//
//        if let t4 = USERDEFAULT.value(forKey: "isT4") as? Bool{
//            if  t4 == true{
//                USERDEFAULT.set(true, forKey: "isT4")
//                USERDEFAULT.synchronize()
//                swichT4.isOn = true
//                lblT4Max.isHidden = false
//                lblT4Min.isHidden = false
//                lblT4Unset.isHidden = true
//
//            }
//            else{
//                USERDEFAULT.set(false, forKey: "isT4")
//                USERDEFAULT.synchronize()
//                swichT4.isOn = false
//                lblT4Max.isHidden = true
//                lblT4Min.isHidden = true
//                lblT4Unset.isHidden = false
//            }
//            
//        }
//        else{
//            USERDEFAULT.set(false, forKey: "isT4")
//            USERDEFAULT.synchronize()
//            swichT4.isOn = false
//            lblT4Max.isHidden = true
//            lblT4Min.isHidden = true
//            lblT4Unset.isHidden = false
//        }
//    }
//    
//    
//    // MARK: - Button Action Methods
//    
//    @IBAction func btnConnectCliked(_ sender: UIButton) {
//        
//        if sender.titleLabel?.text == "Disconnect" {
//            
//            let alert=UIAlertController(title: Appname, message: "Are you sure you want to disconnect?", preferredStyle: UIAlertControllerStyle.alert);
//            //default input textField (no configuration...)
//            //alert.addTextField(configurationHandler: nil);
//            //no event handler (just close dialog box)
//            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil));
//            //event handler with closure
//            alert.addAction(UIAlertAction(title: "Disconnect", style: UIAlertActionStyle.default, handler: {(action:UIAlertAction) in
//                self.centralManager?.cancelPeripheralConnection(self.peripheral)
//                self.settingDetails(connectedDeviceName: "")
//            }));
//            present(alert, animated: true, completion: nil);
//            
//        }
//        else{
//            _ =  self.navigationController?.popToRootViewController(animated: true)
//        }
//    }
//    
//    @IBAction func btnRTRCliked(_ sender: UIButton) {
//      
//      MainCenteralManager.sharedInstance().SetObject(centralManager: centralManager!, peripheral: peripheral)
//      MainCenteralManager.sharedInstance().managerType = .Temperature
//        let obj = RealTImeReadingVC()
//        //let obj = DetailViewController()
////        obj.peripheral = peripheral
////        obj.centralManager = centralManager
//        self.navigationController?.pushViewController(obj, animated: true)
//    }
//    
//    @IBAction func btnDDCliked(_ sender: UIButton) {
//      MainCenteralManager.sharedInstance().SetObject(centralManager: centralManager!, peripheral: peripheral)
//      MainCenteralManager.sharedInstance().managerType = .Download
//        let obj = DataDownloadVC()
////        obj.peripheral = peripheral
////        obj.centralManager = centralManager
//      
////        if self.btServices.count > 0 {
////            obj.btServices = self.btServices
////        }
//        
//        self.navigationController?.pushViewController(obj, animated: true)
//    }
//    
//    @IBAction func btnFOliked(_ sender: UIButton) {
//        let obj = FileOpenVC()
//        self.navigationController?.pushViewController(obj, animated: true)
//    }
//    
//    @IBAction func btnRTGCliked(_ sender: UIButton) {
//        let obj = RealTimeGraphVC()
//        obj.peripheral = peripheral
//        obj.centralManager = centralManager
//        self.navigationController?.pushViewController(obj, animated: true)
//    }
//    
//    @IBAction func btnSettingClicked(_ sender: UIButton) {
//        //let obj = SettingVC()
//        //self.navigationController?.pushViewController(obj, animated: true)
//        
//        let notificationName = Notification.Name("settingDataNotification")
//        NotificationCenter.default.post(name: notificationName, object: nil)
//        
//        self.view.addSubview(viewSetting)
//        
//    }
//    
//    @IBAction func btnCloseClicked(_ sender: UIButton) {
//        viewSetting.removeFromSuperview()
//    }
//    
//    
//    @IBAction func switchedButtonAction(_ sender:UIButton){
//        if sender.tag == 20{
//            if !swichScale.isOn{
//                USERDEFAULT.set(true, forKey: "isFahrenheit")
//                USERDEFAULT.synchronize()
//                self.swichScale.isOn = true
//                temperatureButton.setImage(UIImage.init(named: "on.png"), for: .normal)
//                self.currentScale.text = "Current Scale : fahrenheit"
//            }
//            else{
//                USERDEFAULT.set(false, forKey: "isFahrenheit")
//                USERDEFAULT.synchronize()
//                self.swichScale.isOn = false
//                temperatureButton.setImage(UIImage.init(named: "off.png"), for: .normal)
//                self.currentScale.text = "Current Scale : celsius"
//            }
//            
//            self.btncommandC()
//            
//            let notificationName = Notification.Name("settingDataNotification")
//            NotificationCenter.default.post(name: notificationName, object: nil)
//        }
//    }
//    
//    @IBAction func switched(_ sender:UISwitch){
//        
//        if swichScale.isOn{
//            lblMinMaxTemp.text = "Please enter value between -328 F to 2498 F."
//        }
//        else{
//            lblMinMaxTemp.text = "Please enter value between -200 C to 1370 C."
//        }
//        
//        
//        if sender.tag == 20{
//            if sender.isOn{
//                USERDEFAULT.set(true, forKey: "isFahrenheit")
//                USERDEFAULT.synchronize()
//                self.currentScale.text = "Current Scale : fahrenheit"
//
//            }
//            else{
//                USERDEFAULT.set(false, forKey: "isFahrenheit")
//                USERDEFAULT.synchronize()
//                self.currentScale.text = "Current Scale : celsius"
//            }
//            
//            let notificationName = Notification.Name("settingDataNotification")
//            NotificationCenter.default.post(name: notificationName, object: nil)
//        }
//        else if sender.tag == 21{
//            if sender.isOn{
//                
//                indexID = sender.tag
//                txtMinTemp.text = ""
//                txtMaxTemp.text = ""
//                self.view.addSubview(viewAlarmTemp)
//             
//            }
//            else{
//                USERDEFAULT.set(false, forKey: "isT1")
//                USERDEFAULT.synchronize()
//                
//                lblT1Max.isHidden = true
//                lblT1Min.isHidden = true
//                lblT1Unset.isHidden = false
//                
//            }
//        }
//        else if sender.tag == 22{
//            if sender.isOn{
//                
//                indexID = sender.tag
//                txtMinTemp.text = ""
//                txtMaxTemp.text = ""
//                self.view.addSubview(viewAlarmTemp)
//
//            }
//            else{
//                USERDEFAULT.set(false, forKey: "isT2")
//                USERDEFAULT.synchronize()
//                
//                lblT2Max.isHidden = true
//                lblT2Min.isHidden = true
//                lblT2Unset.isHidden = false
//
//            }
//            
//        }
//        else if sender.tag == 23{
//            if sender.isOn{
//                indexID = sender.tag
//                txtMinTemp.text = ""
//                txtMaxTemp.text = ""
//                self.view.addSubview(viewAlarmTemp)
//            }
//            else{
//                USERDEFAULT.set(false, forKey: "isT3")
//                USERDEFAULT.synchronize()
//                
//                lblT3Max.isHidden = true
//                lblT3Min.isHidden = true
//                lblT3Unset.isHidden = false
//
//            }
//            
//        }
//        else if sender.tag == 24{
//            if sender.isOn{
//                
//                indexID = sender.tag
//                self.view.addSubview(viewAlarmTemp)
//
//            }
//            else{
//                USERDEFAULT.set(false, forKey: "isT4")
//                USERDEFAULT.synchronize()
//                
//                lblT4Max.isHidden = true
//                lblT4Min.isHidden = true
//                lblT4Unset.isHidden = false
//            }
//            
//        }
//
//    }
//    
//    @IBAction func btnAlarmSetClicked(_ sender:UIButton){
//        
//        var isFahrenheitSwitch:Bool = false
//        
//        if swichScale.isOn{
//            isFahrenheitSwitch = true
//        }
//        else{
//            isFahrenheitSwitch = false
//        }
//        
//        
//        
//        if txtMinTemp.text == "" {
//            showAlert(Appname, title: "Please fill minimum field")
//        }
//        else if txtMaxTemp.text == ""{
//            showAlert(Appname, title: "Please fill maximum field")
//        }
//        else{
//            
//            var minTemp:String = txtMinTemp.text!
//            var maxTemp:String = txtMaxTemp.text!
//            //Please enter value between -200 C to 1370 C.
//            if Float(minTemp)! < -200 {
//                showAlert(Appname, title: "Please enter value between -200 C to 1370 C.")
//            }
//            else if Float(maxTemp)! > 1370 {
//                showAlert(Appname, title: "Please enter value between -200 C to 1370 C.")
//            }
//            else if Float(minTemp)! > Float(maxTemp)! {
//                showAlert(Appname, title: "Minimum value is not more then max")
//            }
//            else
//            {
//                if isFahrenheitSwitch {
//                    minTemp = String((Float(minTemp)! - 32) / 1.8)
//                    maxTemp = String((Float(maxTemp)! - 32) / 1.8)
//                }
//
//                if indexID == 21{
//                    
//                    USERDEFAULT.set(true, forKey: "isT1")
//                    USERDEFAULT.synchronize()
//                    
//                    lblT1Max.isHidden = false
//                    lblT1Min.isHidden = false
//                    lblT1Unset.isHidden = true
//                    
//                    lblT1Min.text = "MIN \(txtMinTemp.text!)"
//                    lblT1Max.text = "MAX \(txtMaxTemp.text!)"
//                    
//                    let temp = (self.rangeData[0] as! NSDictionary).mutableCopy() as! NSMutableDictionary
//                    print("Before Upadate Value : ",temp)
//                    temp.setValue(minTemp, forKey: "minValue")
//                    temp.setValue(maxTemp, forKey: "maxValue")
//                    print("After update Value : ",temp)
//                    if (self.rangeData.count > 0) {
//                        self.rangeData.replaceObject(at: 0, with: temp)
//                    }
//                }
//                else if indexID == 22{
//                    
//                    USERDEFAULT.set(true, forKey: "isT2")
//                    USERDEFAULT.synchronize()
//                    
//                    lblT2Max.isHidden = false
//                    lblT2Min.isHidden = false
//                    lblT2Unset.isHidden = true
//
//                    lblT2Min.text = "MIN \(txtMinTemp.text!)"
//                    lblT2Max.text = "MAX \(txtMaxTemp.text!)"
//                    
//                    let temp = (self.rangeData[1] as! NSDictionary).mutableCopy() as! NSMutableDictionary
//                    print("Before Upadate Value : ",temp)
//                    temp.setValue(minTemp, forKey: "minValue")
//                    temp.setValue(maxTemp, forKey: "maxValue")
//                    print("After update Value : ",temp)
//                    if (self.rangeData.count > 1) {
//                        self.rangeData.replaceObject(at: 1, with: temp)
//                    }
//                }
//                else if indexID == 23{
//                    
//                    USERDEFAULT.set(true, forKey: "isT3")
//                    USERDEFAULT.synchronize()
//                    
//                    lblT3Max.isHidden = false
//                    lblT3Min.isHidden = false
//                    lblT3Unset.isHidden = true
//                    
//                    lblT3Min.text = "MIN \(txtMinTemp.text!)"
//                    lblT3Max.text = "MAX \(txtMaxTemp.text!)"
//                    
//                    let temp = (self.rangeData[2] as! NSDictionary).mutableCopy() as! NSMutableDictionary
//                    print("Before Upadate Value : ",temp)
//                    temp.setValue(minTemp, forKey: "minValue")
//                    temp.setValue(maxTemp, forKey: "maxValue")
//                    print("After update Value : ",temp)
//                    if (self.rangeData.count > 2) {
//                        self.rangeData.replaceObject(at: 2, with: temp)
//                    }
//                }
//                else if indexID == 24{
//                    
//                    USERDEFAULT.set(true, forKey: "isT4")
//                    USERDEFAULT.synchronize()
//
//                    lblT4Max.isHidden = false
//                    lblT4Min.isHidden = false
//                    lblT4Unset.isHidden = true
//                    
//                    lblT4Min.text = "MIN \(txtMinTemp.text!)"
//                    lblT4Max.text = "MAX \(txtMaxTemp.text!)"
//                    
//                    let temp = (self.rangeData[3] as! NSDictionary).mutableCopy() as! NSMutableDictionary
//                    print("Before Upadate Value : ",temp)
//                    temp.setValue(minTemp, forKey: "minValue")
//                    temp.setValue(maxTemp, forKey: "maxValue")
//                    print("After update Value : ",temp)
//                    if (self.rangeData.count > 3) {
//                        self.rangeData.replaceObject(at: 3, with: temp)
//                    }
//                }
//                
//                USERDEFAULT.set(self.rangeData, forKey: "temperatureData")
//                USERDEFAULT.synchronize()
//
//                viewAlarmTemp.removeFromSuperview()
//            }
//        }
//    }
//    
//    @IBAction func btnAlarmCancelClicked(_ sender:UIButton){
//        if indexID == 21{
//            USERDEFAULT.set(false, forKey: "isT1")
//            USERDEFAULT.synchronize()
//            swichT1.isOn = false
//            
//            lblT1Max.isHidden = true
//            lblT1Min.isHidden = true
//            lblT1Unset.isHidden = false
//
//        }
//        else if indexID == 22{
//            USERDEFAULT.set(false, forKey: "isT2")
//            USERDEFAULT.synchronize()
//            swichT2.isOn = false
//
//            lblT2Max.isHidden = true
//            lblT2Min.isHidden = true
//            lblT2Unset.isHidden = false
//        }
//        else if indexID == 23{
//            USERDEFAULT.set(false, forKey: "isT3")
//            USERDEFAULT.synchronize()
//            swichT3.isOn = false
//            
//            lblT3Max.isHidden = true
//            lblT3Min.isHidden = true
//            lblT3Unset.isHidden = false
//
//        }
//        else if indexID == 24{
//            USERDEFAULT.set(false, forKey: "isT4")
//            USERDEFAULT.synchronize()
//            
//            swichT4.isOn = false
//            
//            lblT4Max.isHidden = true
//            lblT4Min.isHidden = true
//            lblT4Unset.isHidden = false
//
//        }
//        
//        viewAlarmTemp.removeFromSuperview()
//    }
//
//    // MARK: - CBCentralManager Methods
//    
//    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
//        if peripheral.state == CBPeripheralState.connected {
//            //bbConnect.text = "Connected"
//            peripheral.discoverServices(nil)
//        }
//    }
//    
//    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
//        for serviceObj in peripheral.services! {
//            let service:CBService = serviceObj
//            let isServiceIncluded = self.btServices.filter({ (item: BTServiceInfo) -> Bool in
//                return item.service.uuid == service.uuid
//            }).count
//            if isServiceIncluded == 0 {
//                btServices.append(BTServiceInfo(service: service, characteristics: []))
//            }
//            peripheral.discoverCharacteristics(nil, for: service)
//        }
//    }
//    
//    //    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
//    //
//    //        print("NAME:" + peripheral.name! )
//    //        print("RSSI:" + RSSI.description )
//    //
//    //        if (peripheral.state == CBPeripheralState.connected){
//    //            print("isConnected: connected")
//    //        }else{
//    //            print("isConnected: disconnected")
//    //        }
//    //
//    //        print("advertisementData:" + advertisementData.description)
//    //
//    //
//    ////        if (peripheral.services != nil ){
//    ////
//    ////        }
//    //
//    //    }
//    
//    func centralManagerDidUpdateState(_ central: CBCentralManager) {
//        
//    }
//    
//    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
//        let serviceCharacteristics = service.characteristics
//        for item in btServices {
//            if item.service.uuid == service.uuid {
//                item.characteristics = serviceCharacteristics!
//                let charitem = serviceCharacteristics?.first
//                self.peripheral.setNotifyValue(true, for: charitem!)
//                break
//            }
//        }
//        //self.tableView.reloadData()
//    }
//    
//    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
//        
//        if (characteristic.value != nil){
//            let resultStr = NSString(data: characteristic.value!, encoding: String.Encoding.utf8.rawValue)
//            
//            print("characteristic uuid:\(characteristic.uuid)   value:\(resultStr)")
//            
//            if let value = characteristic.value{
//                let log = "read: \(value)"
//                print(log)
//                
//                guard value.count == 64 else {
//                    return
//                }
//                
//                let byteArray = [UInt8](value)
//                print(byteArray)
//                
//                if (characteristic.uuid.description == "49535343-1E4D-4BD9-BA61-23C647249616"){
//
//                    print("2nd byte", byteArray[1])
//                    
//                    self.settingBetryImg(betryStatus: byteArray[1])
//                    
//                    let myString : [String] = self.converToBinary(x1: byteArray[2])
//                    print("myString", myString)
//                    print("myString[0]", myString[0])
//                    
//                    if myString.count > 0 {
//                        
//                        if myString[0] == "0" {
//                            print("Feranhit")
//                            self.swichScale.setOn(true, animated: true)
//                            temperatureButton.setImage(UIImage.init(named: "on.png"), for: .normal)
//                            USERDEFAULT.set(true, forKey: "isFahrenheit")
//                            USERDEFAULT.synchronize()
//                            self.currentScale.text = "Current Scale : fahrenheit"
//                        }
//                        else if myString[0] == "1" {
//                            print("celsius")
//                            temperatureButton.setImage(UIImage.init(named: "off.png"), for: .normal)
//                            self.swichScale.setOn(false, animated: true)
//                            USERDEFAULT.set(false, forKey: "isFahrenheit")
//                            USERDEFAULT.synchronize()
//                            self.currentScale.text = "Current Scale : celsius"
//                        }
//                        else {
//                            print("else")
//                        }
//                    }
//                    
////                    self.textView.text = self.textView.text + "\n" + text
////                    let stringLength:Int = self.textView.text.characters.count
////                    self.textView.scrollRangeToVisible(NSMakeRange(stringLength-1, 0))
//                }
//            }
//            
//            if lastString == resultStr{
//                return;
//            }
//            
//            // 操作的characteristic 保存
//            self.savedCharacteristic = characteristic
//            
//        }
//    }
//    
//    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
//        
//        
//        if error != nil{
//            print("写入 characteristics 时 \(peripheral.name) 报错 \(error?.localizedDescription)")
//            return
//        }
//        //Commented by Meet
//        //        if (characteristic.value != nil){
//        //
//        //            print("characteristic.value:", characteristic.value ?? "123")
//        //
//        //            lastString = NSString(data: characteristic.value!, encoding: String.Encoding.utf8.rawValue)!
//        //
//        //            print("lastString:" + (lastString as String))
//        //        }
//    }
//    
//    func viewController(characteristic: CBCharacteristic,value : Data ) -> () {
//        
//        //只有 characteristic.properties 有write的权限才可以写入
//        if characteristic.properties.contains(CBCharacteristicProperties.write){
//            //设置为  写入有反馈
//            self.peripheral.writeValue(value, for: characteristic, type: .withResponse)
//            
//        }else{
//            print("写入不可用~")
//        }
//    }
//
//    // MARK: - UITextField Methods
//    
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        return true
//    }
//    
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        
//        if(string == "." ){
//            let countdots = (textField.text?.components(separatedBy: ".").count)! - 1
//            
//            if countdots > 0 && string == "."
//            {
//                return false
//            }
//        }
//        return true
//    }
//
//    
//    // MARK: - Button Action Methods
//    @IBAction func btncommandC(){
//        
//        if !self.checkingStates() {
//            return
//        }
//        
//        //[  0x02 , 0x43 , 0x00 , 0x00 , 0x00 , 0x00 , 0x03 ]   C Command
//        //[  0x02 , 0x50 , 0x00 , 0x00 , 0x00 , 0x00 , 0x03 ]   P Command
//        let commandCbyte : [UInt8] = [  0x02 , 0x43 , 0x00 , 0x00 , 0x00 , 0x00 , 0x03 ]
//        let data2 = Data(bytes:commandCbyte)
//        
//        if self.btServices.count > 1 {
//            let charItems = self.btServices[1].characteristics
//            for characteristic in charItems {
//                peripheral.readValue(for: characteristic)
//                
//                //设置 characteristic 的 notifying 属性 为 true ， 表示接受广播
//                peripheral.setNotifyValue(true, for: characteristic)
//            }
//            
//            //for characteristic in self.currentBTServiceInfo.characteristics {
//            for characteristic in charItems {
//                if characteristic.properties.contains(CBCharacteristicProperties.writeWithoutResponse){
//                    //设置为  写入有反馈
//                    self.peripheral.writeValue(data2, for: characteristic, type: .withResponse)
//                    //print("写入withoutResponse~")
//                }else{
//                    print("写入不可用~")
//                }
//            }
//        }
//    }
//    
//    @IBAction func btncommandP(){
//        
//        //[  0x02 , 0x43 , 0x00 , 0x00 , 0x00 , 0x00 , 0x03 ]   C Command
//        //[  0x02 , 0x50 , 0x00 , 0x00 , 0x00 , 0x00 , 0x03 ]   P Command
//        let commandCbyte : [UInt8] = [  0x02 , 0x50 , 0x00 , 0x00 , 0x00 , 0x00 , 0x03 ]
//        let data2 = Data(bytes:commandCbyte)
//        
//        if self.btServices.count > 1 {
//            let charItems = self.btServices[1].characteristics
//            for characteristic in charItems {
//                peripheral.readValue(for: characteristic)
//                
//                //设置 characteristic 的 notifying 属性 为 true ， 表示接受广播
//                peripheral.setNotifyValue(true, for: characteristic)
//            }
//            
//            //for characteristic in self.currentBTServiceInfo.characteristics {
//            for characteristic in charItems {
//                if characteristic.properties.contains(CBCharacteristicProperties.writeWithoutResponse){
//                    //设置为  写入有反馈
//                    self.peripheral.writeValue(data2, for: characteristic, type: .withResponse)
//                    //print("写入withoutResponse~")
//                }else{
//                    print("写入不可用~")
//                }
//            }
//        }
//    }
//    
//    @IBAction func btncommandRepeatP(){
//        
//        //[  0x02 , 0x43 , 0x00 , 0x00 , 0x00 , 0x00 , 0x03 ]   C Command
//        //[  0x02 , 0x50 , 0x00 , 0x00 , 0x00 , 0x00 , 0x03 ]   P Command
//        let commandCbyte : [UInt8] = [  0x02 , 0x70 , 0x00 , 0x00 , 0x00 , 0x00 , 0x03 ]
//        let data2 = Data(bytes:commandCbyte)
//        
//        if self.btServices.count > 1 {
//            let charItems = self.btServices[1].characteristics
//            for characteristic in charItems {
//                peripheral.readValue(for: characteristic)
//                
//                //设置 characteristic 的 notifying 属性 为 true ， 表示接受广播
//                peripheral.setNotifyValue(true, for: characteristic)
//            }
//            
//            //for characteristic in self.currentBTServiceInfo.characteristics {
//            for characteristic in charItems {
//                if characteristic.properties.contains(CBCharacteristicProperties.writeWithoutResponse){
//                    //设置为  写入有反馈
//                    self.peripheral.writeValue(data2, for: characteristic, type: .withResponse)
//                    //print("写入withoutResponse~")
//                }else{
//                    print("写入不可用~")
//                }
//            }
//        }
//    }
//    
//    @IBAction func btncommandA(){
//        
//        if !self.checkingStates() {
//            return
//        }
//        
//        let commandAbyte : [UInt8] = [  0x02 , 0x41 , 0x00 , 0x00 , 0x00 , 0x00 , 0x03 ]
//        let data1 = Data(bytes:commandAbyte)
//        
//        if self.btServices.count > 1 {
//            let charItems = self.btServices[1].characteristics
//            for characteristic in charItems {
//                peripheral.readValue(for: characteristic)
//                
//                //设置 characteristic 的 notifying 属性 为 true ， 表示接受广播
//                peripheral.setNotifyValue(true, for: characteristic)
//            }
//            
//            for characteristic in charItems {
//                self.viewController(characteristic: characteristic, value: data1)
//            }
//        }
//    }
//    
//    @IBAction func btncommandWrongCommand(){
//        let commandAbyte : [UInt8] = [  0x02 , 0x6e , 0x00 , 0x00 , 0x00 , 0x00 , 0x03 ]
//        let data1 = Data(bytes:commandAbyte)
//        
//        if self.btServices.count > 1 {
//            let charItems = self.btServices[1].characteristics
//            for characteristic in charItems {
//                peripheral.readValue(for: characteristic)
//                
//                //设置 characteristic 的 notifying 属性 为 true ， 表示接受广播
//                peripheral.setNotifyValue(true, for: characteristic)
//                
//            }
//            
//            for characteristic in charItems {
//                self.viewController(characteristic: characteristic, value: data1)
//            }
//        }
//    }
//
//    
//    // MARK: - Other Methods
//    
//    private func getFahrenheit(x1:UInt8 , x2:UInt8) -> String {
//        let x1_16 =  String(format:"%02X", x1)
//        let x2_16 =  String(format:"%02X", x2)
//        let x3 = x1_16 + x2_16
//        return String(Float(UInt(x3, radix: 16)!) / 10)
//    }
//    
//    private func converToBinary(x1:UInt8) -> [String] {
//        var str = String(x1, radix: 2)
//        while str.characters.count % 8 != 0 {
//            str = "0" + str
//        }
//        return str.characters.map { String($0) }
//    }
//    
//    private func getCelsius(x1:UInt8 , x2:UInt8) -> String {
//        let fahrenheit = self.getFahrenheit(x1: x1, x2: x2)
//        return String(format:"%.1f",Float(5.0 / 9.0 * (Double(fahrenheit)! - 32.0)))
//    }
//    
//    func settingBetryImg (betryStatus:UInt8) {
//        
//        if betryStatus == 1 {
//            imgbettery.image = UIImage.init(named: "Battery1.png")
//        }
//        else if betryStatus == 2 {
//            imgbettery.image = UIImage.init(named: "Battery2.png")
//        }
//        else if betryStatus == 3 {
//            imgbettery.image = UIImage.init(named: "BatteryFull.png")
//        }
//        else{
//            imgbettery.image = UIImage.init(named: "Batterynull.png")
//        }
//    }
//
//    func checkingStates () -> Bool {
//        
//        if peripheral == nil {
//            statusTimer.invalidate()
//            return false
//        }
//        
//        if peripheral.state == CBPeripheralState.connected {
//            //print("connected")
//        }
//        else if peripheral.state == CBPeripheralState.connecting {
//            print("connecting")
//        }
//        else if peripheral.state == CBPeripheralState.disconnected {
//            statusTimer.invalidate()
//            //statusTimer = nil
//            NotificationCenter.default.post(name: Notification.Name("deviceDisconnected"), object: nil)
//            APPDELEGATE.window.makeToast("BT Device is disconnected")
//            print("disconnected")
//            return false
//        }
//        
//        return true
//    }
//    
//    func methodOfReceivedNotification(notification: Notification){
//        //Take Action on Notification
//        self.settingDetails(connectedDeviceName: "")
//    }
//
//}
