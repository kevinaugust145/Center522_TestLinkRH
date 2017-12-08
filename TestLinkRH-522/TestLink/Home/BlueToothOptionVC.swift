//
//  BlueToothOptionVC.swift
//  TestLink
//
//  Created by Pritesh Pethani on 24/01/17.
//  Copyright © 2017 Pritesh Pethani. All rights reserved.
//

import UIKit
import CoreBluetooth

@objc class BlueToothOptionVC: UIViewController , UITextFieldDelegate {//
    
    @IBOutlet var btnConnect: UIButton!
    @IBOutlet var lblConnect: UILabel!
    
    @IBOutlet var imgbettery: UIImageView!
    
    @IBOutlet var lblRHMin: UILabel!
    @IBOutlet var lblRHMax: UILabel!
    @IBOutlet var lblRHUnset: UILabel!
    
    @IBOutlet var lblT1Min: UILabel!
    @IBOutlet var lblT1Max: UILabel!
    @IBOutlet var lblT1Unset: UILabel!
    
    @IBOutlet var lblT2Min: UILabel!
    @IBOutlet var lblT2Max: UILabel!
    @IBOutlet var lblT2Unset: UILabel!
    
    @IBOutlet var swichRH: UISwitch!
    @IBOutlet var swichT1: UISwitch!
    @IBOutlet var swichT2: UISwitch!
    
    @IBOutlet var btnCelsius: UIButton!
    @IBOutlet var btnFahrenheit: UIButton!
    @IBOutlet var btnKelvin: UIButton!
    
    @IBOutlet var currentScale: UILabel!
    @IBOutlet var btnClose: UIButton!

    @IBOutlet var viewSetting: UIView!
    @IBOutlet var viewUnderSetting: UIView!
    
    @IBOutlet var viewAlarmTemp: UIView!
    
    @IBOutlet var lblMinMaxTemp :UILabel!
    @IBOutlet var txtMinTemp :UITextField!
    @IBOutlet var txtMaxTemp :UITextField!
    
    var indexID:Int!
    
    var rangeData = NSMutableArray()
    var rangeDict = NSMutableDictionary()
    
    var statusTimer:Timer!
  
    var isCelSelected = false
    var isFahSelected = false
    var isKelvin = false
    
  var temperatureRHAlertBool:Bool = true
  var temperatureT1AlertBool:Bool = true
  var temperatureT2AlertBool:Bool = true
  
    
    var viewAlertOutRange = viewAlertOutRangeViewController()
    @IBOutlet var temperatureButton:UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        
        btnConnect.layer.borderWidth = 1.0
        btnConnect.layer.borderColor = UIColor.white.cgColor
        self.setSettingData()
        let notificationName = Notification.Name("settingDataNotification")
        NotificationCenter.default.addObserver(self, selector: #selector(self.setSettingData), name: notificationName, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification(notification:)), name: Notification.Name("deviceDisconnected"), object: nil)
        
        viewAlarmTemp.frame = CGRect(x: 0, y: 0, width: ScreenSize.SCREEN_WIDTH, height: ScreenSize.SCREEN_HEIGHT)
    }
  
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
       MainCenteralManager.sharedInstance().mainCenteralManagerDelegate = self
      self.settingDetails(connectedDeviceName: MainCenteralManager.sharedInstance().peripheral == nil ? "" : MainCenteralManager.sharedInstance().peripheral!.name! )
        if USERDEFAULT.value(forKey: "temperatureData") != nil
        {
            if let tempData = USERDEFAULT.value(forKey: "temperatureData") as? NSArray
            {
                rangeData = NSMutableArray(array: tempData)
            }
            else{
                rangeData = NSMutableArray()
                
                rangeDict.setValue("", forKey: "minValue")
                rangeDict.setValue("", forKey: "maxValue")
                rangeData.add(rangeDict)
                
                rangeDict.setValue("", forKey: "minValue")
                rangeDict.setValue("", forKey: "maxValue")
                rangeData.add(rangeDict)
                
                rangeDict.setValue("", forKey: "minValue")
                rangeDict.setValue("", forKey: "maxValue")
                rangeData.add(rangeDict)

                print("Range Data ", rangeData)
            }
        }
        else{
            rangeData = NSMutableArray()
            
            rangeDict.setValue("", forKey: "minValue")
            rangeDict.setValue("", forKey: "maxValue")
            rangeData.add(rangeDict)
            
            rangeDict.setValue("", forKey: "minValue")
            rangeDict.setValue("", forKey: "maxValue")
            rangeData.add(rangeDict)
            
            rangeDict.setValue("", forKey: "minValue")
            rangeDict.setValue("", forKey: "maxValue")
            rangeData.add(rangeDict)
            
            
            print("Range Data ", rangeData)
            
            USERDEFAULT.set(self.rangeData, forKey: "temperatureData")
            USERDEFAULT.synchronize()
        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func settingDetails (connectedDeviceName: String){
      
        if connectedDeviceName != "" {
            self.lblConnect.text = "Connected to \( connectedDeviceName )"
            btnConnect.setTitle("Disconnect", for: .normal)
        }
        else{
            MainCenteralManager.sharedInstance().peripheral = nil
            MainCenteralManager.sharedInstance().centralManager = nil
            self.lblConnect.text = "Not Connected to any bluetooth device"
            btnConnect.setTitle("Connect", for: .normal)
            self.settingBetryImg(betryStatus: 0)
        }
    }
    
    @objc func setSettingData() {
    
        var isFahrenheit = false
        var isCelsius = false
        var isKelvin = false
        
        if USERDEFAULT.value(forKey: "isFahrenheit") as? Bool == true {
           
            USERDEFAULT.set(true, forKey: "isFahrenheit")
            USERDEFAULT.synchronize()
            btnFahrenheit.setImage(#imageLiteral(resourceName: "check"), for: .normal)
            btnCelsius.setImage(#imageLiteral(resourceName: "uncheck"), for: .normal)
            btnKelvin.setImage(#imageLiteral(resourceName: "uncheck"), for: .normal)
            self.currentScale.text = "Current Scale : Fahrenheit"
            isFahrenheit = true
            
        }
        else if USERDEFAULT.value(forKey: "isCelsius") as? Bool == true {
            
            USERDEFAULT.set(true, forKey: "isCelsius")
            USERDEFAULT.synchronize()
            btnFahrenheit.setImage(#imageLiteral(resourceName: "uncheck"), for: .normal)
            btnCelsius.setImage(#imageLiteral(resourceName: "check"), for: .normal)
            btnKelvin.setImage(#imageLiteral(resourceName: "uncheck"), for: .normal)
            self.currentScale.text = "Current Scale : Celsius"
            isCelsius = true
            
        }
        else if USERDEFAULT.value(forKey: "isKelvin") as? Bool == true {
           
            USERDEFAULT.set(true, forKey: "isKelvin")
            USERDEFAULT.synchronize()
            btnFahrenheit.setImage(#imageLiteral(resourceName: "uncheck"), for: .normal)
            btnCelsius.setImage(#imageLiteral(resourceName: "uncheck"), for: .normal)
            btnKelvin.setImage(#imageLiteral(resourceName: "check"), for: .normal)
            self.currentScale.text = "Current Scale : Kelvin"
            isKelvin = true
            
        }
        else{
            
            if MainCenteralManager.sharedInstance().data.cOrFOrK == "F" {
                
                USERDEFAULT.set(true, forKey: "isFahrenheit")
                USERDEFAULT.synchronize()
                btnFahrenheit.setImage(#imageLiteral(resourceName: "check"), for: .normal)
                btnCelsius.setImage(#imageLiteral(resourceName: "uncheck"), for: .normal)
                btnKelvin.setImage(#imageLiteral(resourceName: "uncheck"), for: .normal)
                self.currentScale.text = "Current Scale : Fahrenheit"
                isFahrenheit = true
                
            }else if MainCenteralManager.sharedInstance().data.cOrFOrK == "C" {
                
                USERDEFAULT.set(true, forKey: "isCelsius")
                USERDEFAULT.synchronize()
                btnFahrenheit.setImage(#imageLiteral(resourceName: "uncheck"), for: .normal)
                btnCelsius.setImage(#imageLiteral(resourceName: "check"), for: .normal)
                btnKelvin.setImage(#imageLiteral(resourceName: "uncheck"), for: .normal)
                self.currentScale.text = "Current Scale : Celsius"
                isCelsius = true
                
            }else if MainCenteralManager.sharedInstance().data.cOrFOrK == "K"{
                
                USERDEFAULT.set(true, forKey: "isKelvin")
                USERDEFAULT.synchronize()
                btnFahrenheit.setImage(#imageLiteral(resourceName: "uncheck"), for: .normal)
                btnCelsius.setImage(#imageLiteral(resourceName: "uncheck"), for: .normal)
                btnKelvin.setImage(#imageLiteral(resourceName: "check"), for: .normal)
                self.currentScale.text = "Current Scale : Kelvin"
                isKelvin = true
            }
          
        }
        
        
        if let tempData = USERDEFAULT.value(forKey: "temperatureData") as? NSArray
        {
            let temperatureData = tempData as NSArray
            
            if (temperatureData.object(at: 0) as AnyObject).value(forKey: "minValue") as! String == ""{
                lblRHMin.text = "MIN 00"
            }
            else{
                var minTemp:String = "\((temperatureData.object(at: 0) as AnyObject).value(forKey: "minValue") as! String)"
                minTemp = String(format: "%.1f",  Float(minTemp)!)
                lblRHMin.text = "MIN \(minTemp)"
            }
            
            if (temperatureData.object(at: 0) as AnyObject).value(forKey: "maxValue") as! String == ""{
                lblRHMax.text = "MAX 00"
            }
            else{
                var maxTemp:String = "\((temperatureData.object(at: 0) as AnyObject).value(forKey: "maxValue") as! String)"
                maxTemp = String(format: "%.1f",  Float(maxTemp)!)
                lblRHMax.text = "MAX \(maxTemp)"
            }
            
            if (temperatureData.object(at: 1) as AnyObject).value(forKey: "minValue") as! String == ""{
                lblT1Min.text = "MIN 00"
            }
            else{
                var minTemp:String = "\((temperatureData.object(at: 1) as AnyObject).value(forKey: "minValue") as! String)"
                
                if isFahrenheit {
                    minTemp = String((Float(minTemp)! * 1.8) + 32) //Celsius to Fahrenheit
                }else if isKelvin {
                    minTemp = String(Float(minTemp)! + 273.15) //Celsius to Kelvin
                }
                minTemp = String(format: "%.1f",  Float(minTemp)!)
                lblT1Min.text = "MIN \(minTemp)"
            }
            
            if (temperatureData.object(at: 1) as AnyObject).value(forKey: "maxValue") as! String == ""{
                lblT1Max.text = "MAX 00"
            }
            else{
                var maxTemp:String = "\((temperatureData.object(at: 1) as AnyObject).value(forKey: "maxValue") as! String)"
                
                if isFahrenheit {
                    maxTemp = String((Float(maxTemp)! * 1.8) + 32)
                }else if isKelvin {
                    maxTemp = String(Float(maxTemp)! + 273.15)
                }
                maxTemp = String(format: "%.1f",  Float(maxTemp)!)
                lblT1Max.text = "MAX \(maxTemp)"
            }
            
            
            
            
            if (temperatureData.object(at: 2) as AnyObject).value(forKey: "minValue") as! String == ""{
                lblT2Min.text = "MIN 00"
            }
            else{
                var minTemp:String = "\((temperatureData.object(at: 2) as AnyObject).value(forKey: "minValue") as! String)"
                
                if isCelsius {
                    minTemp = String(format: "%.1f", (Float(minTemp)! - 32) / 1.8)
                }else if isKelvin {
                    minTemp = String(format: "%.1f", (Float(minTemp)! + 459.67) * (5/9))
                }
                minTemp = String(format: "%.1f",  Float(minTemp)!)
                lblT2Min.text = "MIN \(minTemp)"
            }
            
            if (temperatureData.object(at: 2) as AnyObject).value(forKey: "maxValue") as! String == ""{
                lblT2Max.text = "MAX 00"
            }
            else{
                var maxTemp:String = "\((temperatureData.object(at: 2) as AnyObject).value(forKey: "maxValue") as! String)"
                
                if isCelsius {
                    maxTemp = String(format: "%.1f", (Float(maxTemp)! - 32) / 1.8)
                }else if isKelvin {
                    maxTemp = String(format: "%.1f", (Float(maxTemp)! + 459.67) * (5/9))
                }
                maxTemp = String(format: "%.1f",  Float(maxTemp)!)
                lblT2Max.text = "MAX \(maxTemp)"
            }
            
        }
        else{
            //print("Setting tempratureData ",USERDEFAULT.value(forKey: "temperatureData") ?? "Not Data")
        }
        
        
        if let RH = USERDEFAULT.value(forKey: "isRH") as? Bool{
            if  RH == true{
                USERDEFAULT.set(true, forKey: "isRH")
                USERDEFAULT.synchronize()
                swichRH.isOn = true
                lblRHMax.isHidden = false
                lblRHMin.isHidden = false
                lblRHUnset.isHidden = true
            }
            else{
                USERDEFAULT.set(false, forKey: "isRH")
                USERDEFAULT.synchronize()
                swichRH.isOn = false
                
                lblRHMax.isHidden = true
                lblRHMin.isHidden = true
                lblRHUnset.isHidden = false
            }
            
        }
        else{
            USERDEFAULT.set(false, forKey: "isRH")
            USERDEFAULT.synchronize()
            swichRH.isOn = false
            lblRHMax.isHidden = true
            lblRHMin.isHidden = true
            lblRHUnset.isHidden = false
            
        }
        
        if let t1 = USERDEFAULT.value(forKey: "isT1") as? Bool{
            if  t1 == true{
                USERDEFAULT.set(true, forKey: "isT1")
                USERDEFAULT.synchronize()
                swichT1.isOn = true
                lblT1Max.isHidden = false
                lblT1Min.isHidden = false
                lblT1Unset.isHidden = true

            }
            else{
                USERDEFAULT.set(false, forKey: "isT1")
                USERDEFAULT.synchronize()
                swichT1.isOn = false
                lblT1Max.isHidden = true
                lblT1Min.isHidden = true
                lblT1Unset.isHidden = false
            }
            
        }
        else{
            USERDEFAULT.set(false, forKey: "isT1")
            USERDEFAULT.synchronize()
            swichT1.isOn = false
            lblT1Max.isHidden = true
            lblT1Min.isHidden = true
            lblT1Unset.isHidden = false
            
        }
        
        if let t2 = USERDEFAULT.value(forKey: "isT2") as? Bool{
            if  t2 == true{
                USERDEFAULT.set(true, forKey: "isT2")
                USERDEFAULT.synchronize()
                swichT2.isOn = true
                
                lblT2Max.isHidden = false
                lblT2Min.isHidden = false
              lblT2Unset.isHidden = true

                
            }
            else{
                USERDEFAULT.set(false, forKey: "isT2")
                USERDEFAULT.synchronize()
                swichT2.isOn = false
                
                lblT2Max.isHidden = true
                lblT2Min.isHidden = true
                lblT2Unset.isHidden = false
            }
            
        }
        else{
            USERDEFAULT.set(false, forKey: "isT2")
            USERDEFAULT.synchronize()
            swichT2.isOn = false
            lblT2Max.isHidden = true
            lblT2Min.isHidden = true
            lblT2Unset.isHidden = false
        }

    }
    
    
    // MARK: - Button Action Methods
    
    @IBAction func btnConnectCliked(_ sender: UIButton) {
        
        if sender.titleLabel?.text == "Disconnect" {
            
            let alert=UIAlertController(title: Appname, message: "Are you sure you want to disconnect?", preferredStyle: UIAlertControllerStyle.alert);
            //default input textField (no configuration...)
            //alert.addTextField(configurationHandler: nil);
            //no event handler (just close dialog box)
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil));
            //event handler with closure
            alert.addAction(UIAlertAction(title: "Disconnect", style: UIAlertActionStyle.default, handler: {(action:UIAlertAction) in
              
              MainCenteralManager.sharedInstance().ClearnObject()
                //self.centralManager?.cancelPeripheralConnection(self.peripheral)
                self.settingDetails(connectedDeviceName: "")
            }));
            present(alert, animated: true, completion: nil);
            
        }
        else{
            _ =  self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    @IBAction func btnRTRCliked(_ sender: UIButton) {
       let obj = RealTImeReadingVC()
       self.navigationController?.pushViewController(obj, animated: true)
    }
    
    @IBAction func btnDDCliked(_ sender: UIButton) {
    
      
      MainCenteralManager.sharedInstance().SwitchCommandP()
        let obj = DataDownloadVC()
        self.navigationController?.pushViewController(obj, animated: true)
    }
    
    @IBAction func btnFOliked(_ sender: UIButton) {
        let obj = FileOpenVC()
        self.navigationController?.pushViewController(obj, animated: true)
    }
    
    @IBAction func btnRTGCliked(_ sender: UIButton) {
        let obj = RealTimeGraphVC()
        obj.peripheral = MainCenteralManager.sharedInstance().peripheral
        obj.centralManager = MainCenteralManager.sharedInstance().centralManager
        self.navigationController?.pushViewController(obj, animated: true)
    }
    
    @IBAction func btnSettingClicked(_ sender: UIButton) {
        //let obj = SettingVC()
        //self.navigationController?.pushViewController(obj, animated: true)
        
        let notificationName = Notification.Name("settingDataNotification")
        NotificationCenter.default.post(name: notificationName, object: nil)
        
        viewSetting.frame = CGRect(x: 0, y: 0, width: ScreenSize.SCREEN_WIDTH, height: ScreenSize.SCREEN_HEIGHT)
        self.view.addSubview(viewSetting)
        
    }
    
    @IBAction func btnCloseClicked(_ sender: UIButton) {
        viewSetting.removeFromSuperview()
    }
    
    
    @IBAction func switchedButtonAction(_ sender:UIButton){
       
        if sender.tag == 101 {
          
            if !isCelSelected {
                
                btnCelsius.setImage(#imageLiteral(resourceName: "check"), for: .normal)
                btnFahrenheit.setImage(#imageLiteral(resourceName: "uncheck"), for: .normal)
                btnKelvin.setImage(#imageLiteral(resourceName: "uncheck"), for: .normal)
                USERDEFAULT.set(true, forKey: "isCelsius")
                USERDEFAULT.set(false, forKey: "isFahrenheit")
                USERDEFAULT.set(false, forKey: "isKelvin")
                USERDEFAULT.synchronize()
                self.currentScale.text = "Current Scale : Celsius"
                SetData()
                setSettingData()
            }
            
        }else if sender.tag == 102 {
            
            if !isFahSelected {
                
                btnCelsius.setImage(#imageLiteral(resourceName: "uncheck"), for: .normal)
                btnFahrenheit.setImage(#imageLiteral(resourceName: "check"), for: .normal)
                btnKelvin.setImage(#imageLiteral(resourceName: "uncheck"), for: .normal)
                USERDEFAULT.set(false, forKey: "isCelsius")
                USERDEFAULT.set(true, forKey: "isFahrenheit")
                USERDEFAULT.set(false, forKey: "isKelvin")
                USERDEFAULT.synchronize()
                self.currentScale.text = "Current Scale : Fahrenheit"
                SetData()
                setSettingData()
            }
            
        }else if sender.tag == 103 {
            
            if !isKelvin {
                
                btnCelsius.setImage(#imageLiteral(resourceName: "uncheck"), for: .normal)
                btnFahrenheit.setImage(#imageLiteral(resourceName: "uncheck"), for: .normal)
                btnKelvin.setImage(#imageLiteral(resourceName: "check"), for: .normal)
                USERDEFAULT.set(false, forKey: "isCelsius")
                USERDEFAULT.set(false, forKey: "isFahrenheit")
                USERDEFAULT.set(true, forKey: "isKelvin")
                USERDEFAULT.synchronize()
                self.currentScale.text = "Current Scale : Kelvin"
                SetData()
                setSettingData()
            }
        }
    }
    
    @IBAction func switched(_ sender:UISwitch){
        
        
        if isCelSelected {
            
            lblMinMaxTemp.text = "Please enter value between -200 C to 1370 C."
            
        }else if isFahSelected {
            
            lblMinMaxTemp.text = "Please enter value between -328 F to 2498 F."
            
        }else if isKelvin {
            
            lblMinMaxTemp.text = "Please enter value between 73.15 K to 1643.15 K."
        }
       
        

         if sender.tag == 21{
            if sender.isOn{
                
                lblMinMaxTemp.text = "Please enter value between 0 to 100."
                indexID = sender.tag
                txtMinTemp.text = ""
                txtMaxTemp.text = ""
                self.view.addSubview(viewAlarmTemp)
             
            }
            else{
                USERDEFAULT.set(false, forKey: "isRH")
                USERDEFAULT.synchronize()
                
                lblRHMax.isHidden = true
                lblRHMin.isHidden = true
                lblRHUnset.isHidden = false
                
            }
        }
        else if sender.tag == 22{
            if sender.isOn{
                
                indexID = sender.tag
                txtMinTemp.text = ""
                txtMaxTemp.text = ""
                self.view.addSubview(viewAlarmTemp)

            }
            else{
                USERDEFAULT.set(false, forKey: "isT1")
                USERDEFAULT.synchronize()
                
                lblT1Max.isHidden = true
                lblT1Min.isHidden = true
                lblT1Unset.isHidden = false

            }
            
        }
        else if sender.tag == 23{
            if sender.isOn{
                indexID = sender.tag
                txtMinTemp.text = ""
                txtMaxTemp.text = ""
                self.view.addSubview(viewAlarmTemp)
            }
            else{
                USERDEFAULT.set(false, forKey: "isT2")
                USERDEFAULT.synchronize()
                
                lblT2Max.isHidden = true
                lblT2Min.isHidden = true
                lblT2Unset.isHidden = false

            }
            
        }

    }
    
    @IBAction func btnAlarmSetClicked(_ sender:UIButton){
        

        if txtMinTemp.text == "" {
            showAlert(Appname, title: "Please fill minimum field")
        }
        else if txtMaxTemp.text == ""{
            showAlert(Appname, title: "Please fill maximum field")
        }
        else{
            
            var minTemp:String = txtMinTemp.text!
            var maxTemp:String = txtMaxTemp.text!
        

            var alertMsg = "Please enter value between -200 C to 1370 C."
           /* var min : Float = 0
            var max : Float = 0
            
            if isCelSelected {
                
                alertMsg = "Please enter value between -200 C to 1370 C."
                max = -200
                min = 1370
                
            }else if isFahSelected {
                
                alertMsg = "Please enter value between -328 F to 2498 F."
                max = -328
                min = 2498
                

            }else if isKelvin {
                
                alertMsg = "Please enter value between -73.15 K to 1643.15 K."
                max = -73.15
                min = 1643.15
            }
            */
            
            if indexID == 21{
                
                if Float(minTemp)! < 0 {
                    alertMsg = "Please enter value between 0 to 100."
                    showAlert(Appname, title: alertMsg)
                    return
                }
                else if Float(maxTemp)! > 100 {
                    alertMsg = "Please enter value between 0 to 100."
                    showAlert(Appname, title: alertMsg)
                    return
                }
                else if Float(minTemp)! > Float(maxTemp)! {
                    alertMsg = "Minimum value is not more then max"
                    showAlert(Appname, title: alertMsg)
                    return
                }
                else
                {
                    USERDEFAULT.set(true, forKey: "isRH")
                    USERDEFAULT.synchronize()
                    
                    lblRHMax.isHidden = false
                    lblRHMin.isHidden = false
                    lblRHUnset.isHidden = true
                    
                    lblRHMin.text = "MIN \(txtMinTemp.text!)"
                    lblRHMax.text = "MAX \(txtMaxTemp.text!)"
                    
                    swichRH.isOn = true
                    
                    let temp = (self.rangeData[0] as! NSDictionary).mutableCopy() as! NSMutableDictionary
                    print("Before Upadate Value : ",temp)
                    temp.setValue(minTemp, forKey: "minValue")
                    temp.setValue(maxTemp, forKey: "maxValue")
                    print("After update Value : ",temp)
                    if (self.rangeData.count > 0) {
                        self.rangeData.replaceObject(at: 0, with: temp)
                    }
                    
                    USERDEFAULT.set(self.rangeData, forKey: "temperatureData")
                    USERDEFAULT.synchronize()
                    
                    viewAlarmTemp.removeFromSuperview()
                }
            }
            else{
                
                //Please enter value between -200 C to 1370 C.
                if Float(minTemp)! < -200 {
                    showAlert(Appname, title: alertMsg)
                    return
                }
                else if Float(maxTemp)! > 1370 {
                    showAlert(Appname, title: alertMsg)
                    return
                }
                else if Float(minTemp)! > Float(maxTemp)! {
                    showAlert(Appname, title: alertMsg)
                    return
                }
                else
                {
                    
                    if indexID == 22{
                        
                        if isFahSelected {
                            minTemp = String((Float(minTemp)! - 32) / 1.8)
                            maxTemp = String((Float(maxTemp)! - 32) / 1.8)
                        }else if isKelvin {
                            
                            minTemp = String((Float(minTemp)! - 273.15))
                            maxTemp = String((Float(maxTemp)! - 273.15))
                            
                        }
                        
                        USERDEFAULT.set(true, forKey: "isT1")
                        USERDEFAULT.synchronize()
                        
                        lblT1Max.isHidden = false
                        lblT1Min.isHidden = false
                        lblT1Unset.isHidden = true
                        
                        lblT1Min.text = "MIN \(txtMinTemp.text!)"
                        lblT1Max.text = "MAX \(txtMaxTemp.text!)"
                        
                        swichT1.isOn = true
                        
                        let temp = (self.rangeData[1] as! NSDictionary).mutableCopy() as! NSMutableDictionary
                        print("Before Upadate Value : ",temp)
                        temp.setValue(minTemp, forKey: "minValue")
                        temp.setValue(maxTemp, forKey: "maxValue")
                        print("After update Value : ",temp)
                        if (self.rangeData.count > 1) {
                            self.rangeData.replaceObject(at: 1, with: temp)
                        }
                    }
                    else if indexID == 23{
                        
                        if isCelSelected {
                  
                            minTemp = String((Float(minTemp)! * 1.8) + 32)
                            maxTemp = String((Float(maxTemp)! * 1.8) + 32)
                            
                        }else if isKelvin {
                        
                            minTemp = String((Float(minTemp)! * 1.8) - 459.67)
                            maxTemp = String((Float(maxTemp)! * 1.8) - 459.67)
                        }
                        
                        USERDEFAULT.set(true, forKey: "isT2")
                        USERDEFAULT.synchronize()
                        
                        lblT2Max.isHidden = false
                        lblT2Min.isHidden = false
                        lblT2Unset.isHidden = true
                        
                        lblT2Min.text = "MIN \(txtMinTemp.text!)"
                        lblT2Max.text = "MAX \(txtMaxTemp.text!)"
                        
                        swichT2.isOn = true
                        
                        let temp = (self.rangeData[2] as! NSDictionary).mutableCopy() as! NSMutableDictionary
                        print("Before Upadate Value : ",temp)
                        temp.setValue(minTemp, forKey: "minValue")
                        temp.setValue(maxTemp, forKey: "maxValue")
                        print("After update Value : ",temp)
                        if (self.rangeData.count > 2) {
                            self.rangeData.replaceObject(at: 2, with: temp)
                        }
                    }
                    
                    USERDEFAULT.set(self.rangeData, forKey: "temperatureData")
                    USERDEFAULT.synchronize()
                    
                    viewAlarmTemp.removeFromSuperview()
                }
            }
            
        }
    }
    
    @IBAction func btnAlarmCancelClicked(_ sender:UIButton){
        if indexID == 21{
            USERDEFAULT.set(false, forKey: "isRH")
            USERDEFAULT.synchronize()
            swichRH.isOn = false
            
            lblRHMax.isHidden = true
            lblRHMin.isHidden = true
            lblRHUnset.isHidden = false

        }
        else if indexID == 22{
            USERDEFAULT.set(false, forKey: "isT1")
            USERDEFAULT.synchronize()
            swichT1.isOn = false

            lblT1Max.isHidden = true
            lblT1Min.isHidden = true
            lblT1Unset.isHidden = false
        }
        else if indexID == 23{
            USERDEFAULT.set(false, forKey: "isT2")
            USERDEFAULT.synchronize()
            swichT2.isOn = false
            
            lblT2Max.isHidden = true
            lblT2Min.isHidden = true
            lblT2Unset.isHidden = false

        }
        
        viewAlarmTemp.removeFromSuperview()
    }


    // MARK: - UITextField Methods
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
  
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if(string == "." ){
            let countdots = (textField.text?.components(separatedBy: ".").count)! - 1
            
            if countdots > 0 && string == "."
            {
                return false
            }
        }
        return true
    }
  


  func CheckingTemperature(){
    
    var isFahrenheit :Bool = false
    var isCelsius :Bool = false
    var isKelvin :Bool = false
    
    if MainCenteralManager.sharedInstance().data.isCels == "C" {
      isCelsius = true
    }
    else if MainCenteralManager.sharedInstance().data.isFeh == "F"{
      isFahrenheit = true
      
    }else if MainCenteralManager.sharedInstance().data.isKel == "K"{
        isKelvin = true
    }else{
        isCelsius = true
    }
    
    
    
    if let RH = USERDEFAULT.value(forKey: "isRH") as? Bool{

        if  RH == true{
            
            var minVal = (rangeData.object(at: 0) as AnyObject).value(forKey: "minValue") as? String
            var maxVal = (rangeData.object(at: 0) as AnyObject).value(forKey: "maxValue") as? String
            
            minVal = String(format: "%.1f",  Float(minVal!)!)
            maxVal = String(format: "%.1f",  Float(maxVal!)!)
 
            let minIntValue = Float(minVal!)
            let maxIntValue = Float(maxVal!)
            let RHIntValue = Float(MainCenteralManager.sharedInstance().data.RHtemperature as String)
            
            if RHIntValue != nil {
                
                if RHIntValue! < minIntValue! {
                    if temperatureRHAlertBool == true {
                        viewAlertOutRange = viewAlertOutRangeViewController(AlertMsg: "Alert value reached below", AlertTemperature: "RH : \(minVal!)")
              
                        if self.view.isDescendant(of: viewAlertOutRange.view) {
                            
                        } else {
                    
                            self.present(viewAlertOutRange, animated: false, completion: nil)
                        }
                        temperatureRHAlertBool = false
                        print("Play sound")
                    }
                }
                else if RHIntValue! > maxIntValue! {
                    if temperatureRHAlertBool == true {
                        viewAlertOutRange = viewAlertOutRangeViewController(AlertMsg: "Alert value reached above", AlertTemperature: "RH : \(maxVal!)")
                       
                        if self.view.isDescendant(of: viewAlertOutRange.view) {
                            
                        } else {
                            
                            self.present(viewAlertOutRange, animated: false, completion: nil)
                        }
                        
                        temperatureRHAlertBool = false
                        print("Play sound")
                    }
                }
                else{
                    temperatureRHAlertBool = true
                    print("Stop Playing")
                }
            }
        }
    }
    
    
    if let t1 = USERDEFAULT.value(forKey: "isT1") as? Bool{
        
        if  t1 == true{
            var minVal = (rangeData.object(at: 1) as AnyObject).value(forKey: "minValue") as? String
            var maxVal = (rangeData.object(at: 1) as AnyObject).value(forKey: "maxValue") as? String
            
            /*if isFahrenheit {
                
                minVal = String((Float(minVal!)! * 1.8) + 32)
                maxVal = String((Float(maxVal!)! * 1.8) + 32)
            }else if isKelvin {
                
                minVal = String(Float(minVal!)! + 273.15)
                maxVal = String(Float(maxVal!)! + 273.15)
            }else{
                
                minVal = String(format: "%.1f",  Float(minVal!)!)
                maxVal = String(format: "%.1f",  Float(maxVal!)!)
                
            }*/
            
            minVal = String(format: "%.1f",  Float(minVal!)!)
            maxVal = String(format: "%.1f",  Float(maxVal!)!)
            
            let minIntValue = Float(minVal!)
            let maxIntValue = Float(maxVal!)
            let t1IntValue = Float(MainCenteralManager.sharedInstance().data.temperatureT1 as String)
            
            if t1IntValue != nil {
                
                if t1IntValue! < minIntValue! {
                    if temperatureT1AlertBool == true {
                        
                        if isFahrenheit {
                            
                            minVal = celToFeh(degree: minVal!)
                        }else if isKelvin {
                            
                           minVal = celToKel(degree: minVal!)
                        }
                        
                        viewAlertOutRange = viewAlertOutRangeViewController(AlertMsg: "Alert value reached below", AlertTemperature: "T1 : \(minVal!)")
                        
                        if self.view.isDescendant(of: viewAlertOutRange.view) {
                            
                        } else {
                           
                            self.present(viewAlertOutRange, animated: false, completion: nil)
                        }
                        temperatureT1AlertBool = false
                        print("Play sound")
                    }
                }
                else if t1IntValue! > maxIntValue! {
                    if temperatureT1AlertBool == true {
                        
                        if isFahrenheit {
                            
                            maxVal = celToFeh(degree: maxVal!)
                        }else if isKelvin {
                            
                            maxVal = celToKel(degree: maxVal!)
                        }
                        
                        viewAlertOutRange = viewAlertOutRangeViewController(AlertMsg: "Alert value reached above", AlertTemperature: "T1 : \(maxVal!)")
                       
                        if self.view.isDescendant(of: viewAlertOutRange.view) {
                            
                        } else {
                           
                            self.present(viewAlertOutRange, animated: false, completion: nil)
                        }
                        
                        temperatureT1AlertBool = false
                        print("Play sound")
                    }
                }
                else{
                    temperatureT1AlertBool = true
                    print("Stop Playing")
                }
            }
        }
    }
    
    
    
    if let t2 = USERDEFAULT.value(forKey: "isT2") as? Bool{
        if  t2 == true{
            var minVal = (rangeData.object(at: 2) as AnyObject).value(forKey: "minValue") as? String
            var maxVal = (rangeData.object(at: 2) as AnyObject).value(forKey: "maxValue") as? String
            
            /*if isFahrenheit {
                
                minVal = String((Float(minVal!)! * 1.8) + 32)
                maxVal = String((Float(maxVal!)! * 1.8) + 32)
            }else if isKelvin {
                
                minVal = String(Float(minVal!)! + 273.15)
                maxVal = String(Float(maxVal!)! + 273.15)
            }else{
                
                minVal = String(format: "%.1f",  Float(minVal!)!)
                maxVal = String(format: "%.1f",  Float(maxVal!)!)
                
            }*/
            minVal = String(format: "%.1f",  Float(minVal!)!)
            maxVal = String(format: "%.1f",  Float(maxVal!)!)
            
            let minIntValue = Float(minVal!)
            let maxIntValue = Float(maxVal!)
            
            let t2IntValue = Float(MainCenteralManager.sharedInstance().data.temperatureT2 as String)
            
            if t2IntValue != nil {
                if t2IntValue! < minIntValue! {
                    if temperatureT2AlertBool == true {
                        
                        if isCelsius {
                            
                            minVal = FehToCel(degree: minVal!)
                        }else if isKelvin {
                            
                            minVal = FehToKel(degree: minVal!)
                        }
                        
                        viewAlertOutRange = viewAlertOutRangeViewController(AlertMsg: "Alert value reached below", AlertTemperature: "T2 : \(minVal!)")
                       
                        if self.view.isDescendant(of: viewAlertOutRange.view) {
                            
                        } else {
                            self.present(viewAlertOutRange, animated: false, completion: nil)
                            
                        }
                        temperatureT2AlertBool = false
                        print("Play sound")
                    }
                }
                else if t2IntValue! > maxIntValue! {
                    if temperatureT2AlertBool == true {
                        
                        if isCelsius {
                            
                            maxVal = FehToCel(degree: maxVal!)
                        }else if isKelvin {
                            
                            maxVal = FehToKel(degree: maxVal!)
                        }
                        viewAlertOutRange = viewAlertOutRangeViewController(AlertMsg: "Alert value reached above", AlertTemperature: "T2 : \(maxVal!)")
                       
                        if self.view.isDescendant(of: viewAlertOutRange.view) {
                            
                        } else {
                            self.present(viewAlertOutRange, animated: false, completion: nil)
                            
                        }
                        temperatureT2AlertBool = false
                        print("Play sound")
                    }
                }
                else{
                    temperatureT2AlertBool = true
                    print("Stop Playing")
                }
            }
        }
    }
    
  }
  
    func celToFeh(degree : String) -> String {
        
        return String(format:"%.1f",(Float(degree)! * 1.8) + 32)
    }
    func celToKel(degree : String) -> String {
        
        return String(format:"%.1f",Float(degree)! + 273.15)
    }
    
    func FehToCel(degree : String) -> String {
        
        return String(format:"%.1f",(Float(degree)! - 32) / 1.8)
    }
    
    func FehToKel(degree : String) -> String {
        
        return String(format:"%.1f",(Float(degree)! + 459.67) * (5/9))
    }
    
    
    func settingBetryImg (betryStatus:UInt8) {
        
        if betryStatus == 1 {
            imgbettery.image = UIImage.init(named: "Battery1.png")
        }
        else if betryStatus == 2 {
            imgbettery.image = UIImage.init(named: "Battery2.png")
        }
        else if betryStatus == 3 {
            imgbettery.image = UIImage.init(named: "BatteryFull.png")
        }
        else{
            imgbettery.image = UIImage.init(named: "Batterynull.png")
        }
    }
  
    @objc func methodOfReceivedNotification(notification: Notification){
        //Take Action on Notification
        self.settingDetails(connectedDeviceName: "")
    }
  
  
  func SetData() {
    
    
    let deviceTempType = USERDEFAULT.string(forKey: "tempType")//USERDEFAULT.value(forKey: "tempType")
    if  deviceTempType == MainCenteralManager.sharedInstance().data.cOrFOrK {
        
        
    }else{
        
        USERDEFAULT.set(MainCenteralManager.sharedInstance().data.cOrFOrK, forKey: "tempType")
        USERDEFAULT.synchronize()
        
        if MainCenteralManager.sharedInstance().data.cOrFOrK == "C" {
            
            USERDEFAULT.set(true, forKey: "isCelsius")
            USERDEFAULT.set(false, forKey: "isKelvin")
            USERDEFAULT.set(false, forKey: "isFahrenheit")
            USERDEFAULT.synchronize()
            
        }else if MainCenteralManager.sharedInstance().data.cOrFOrK == "F" {
            
            USERDEFAULT.set(true, forKey: "isFahrenheit")
            USERDEFAULT.set(false, forKey: "isCelsius")
            USERDEFAULT.set(false, forKey: "isKelvin")
            USERDEFAULT.synchronize()
            
        }else if MainCenteralManager.sharedInstance().data.cOrFOrK == "K" {
            
            USERDEFAULT.set(true, forKey: "isKelvin")
            USERDEFAULT.set(false, forKey: "isFahrenheit")
            USERDEFAULT.set(false, forKey: "isCelsius")
            USERDEFAULT.synchronize()
        }
    }
    
    if USERDEFAULT.value(forKey: "isFahrenheit") as? Bool == true {
        
        USERDEFAULT.set(true, forKey: "isFahrenheit")
        USERDEFAULT.synchronize()
        btnFahrenheit.setImage(#imageLiteral(resourceName: "check"), for: .normal)
        btnCelsius.setImage(#imageLiteral(resourceName: "uncheck"), for: .normal)
        btnKelvin.setImage(#imageLiteral(resourceName: "uncheck"), for: .normal)
        isFahSelected = true
        isCelSelected = false
        isKelvin = false
        //MainCenteralManager.sharedInstance().data.feh = "F"
        self.currentScale.text = "Current Scale : Fahrenheit"

    }
    else if USERDEFAULT.value(forKey: "isCelsius") as? Bool == true {
        
        USERDEFAULT.set(true, forKey: "isCelsius")
        USERDEFAULT.synchronize()
        btnFahrenheit.setImage(#imageLiteral(resourceName: "uncheck"), for: .normal)
        btnCelsius.setImage(#imageLiteral(resourceName: "check"), for: .normal)
        btnKelvin.setImage(#imageLiteral(resourceName: "uncheck"), for: .normal)
        isCelSelected = true
        isFahSelected = false
        isKelvin = false
        //MainCenteralManager.sharedInstance().data.cels == "C"
        self.currentScale.text = "Current Scale : Celsius"
 
        
    }
    else if USERDEFAULT.value(forKey: "isKelvin") as? Bool == true {
        
        USERDEFAULT.set(true, forKey: "isKelvin")
        USERDEFAULT.synchronize()
        btnFahrenheit.setImage(#imageLiteral(resourceName: "uncheck"), for: .normal)
        btnCelsius.setImage(#imageLiteral(resourceName: "uncheck"), for: .normal)
        btnKelvin.setImage(#imageLiteral(resourceName: "check"), for: .normal)
        isKelvin = true
        isFahSelected = false
        isCelSelected = false
        //MainCenteralManager.sharedInstance().data.kel = "K"
        self.currentScale.text = "Current Scale : Kelvin"
    }
    else{
        
        if MainCenteralManager.sharedInstance().data.cOrFOrK == "C" {
            
            USERDEFAULT.set(true, forKey: "isCelsius")
            USERDEFAULT.synchronize()
            btnFahrenheit.setImage(#imageLiteral(resourceName: "uncheck"), for: .normal)
            btnCelsius.setImage(#imageLiteral(resourceName: "check"), for: .normal)
            btnKelvin.setImage(#imageLiteral(resourceName: "uncheck"), for: .normal)
            isCelSelected = false
            isKelvin = false
            isFahSelected = false
            self.currentScale.text = "Current Scale : Celsius"

        }else if MainCenteralManager.sharedInstance().data.cOrFOrK == "F" {
            
            USERDEFAULT.set(true, forKey: "isFahrenheit")
            USERDEFAULT.synchronize()
            btnFahrenheit.setImage(#imageLiteral(resourceName: "check"), for: .normal)
            btnCelsius.setImage(#imageLiteral(resourceName: "uncheck"), for: .normal)
            btnKelvin.setImage(#imageLiteral(resourceName: "uncheck"), for: .normal)
            isFahSelected = true
            isCelSelected = false
            isKelvin = false
            self.currentScale.text = "Current Scale : Fahrenheit"

            
        }else if MainCenteralManager.sharedInstance().data.cOrFOrK == "K" {
            
            USERDEFAULT.set(true, forKey: "isKelvin")
            USERDEFAULT.synchronize()
            btnFahrenheit.setImage(#imageLiteral(resourceName: "uncheck"), for: .normal)
            btnCelsius.setImage(#imageLiteral(resourceName: "uncheck"), for: .normal)
            btnKelvin.setImage(#imageLiteral(resourceName: "check"), for: .normal)
            isKelvin = true
            isFahSelected = false
            isCelSelected = false
            self.currentScale.text = "Current Scale : Kelvin"
            
        }else {
            
            btnFahrenheit.setImage(#imageLiteral(resourceName: "uncheck"), for: .normal)
            btnCelsius.setImage(#imageLiteral(resourceName: "uncheck"), for: .normal)
            btnKelvin.setImage(#imageLiteral(resourceName: "uncheck"), for: .normal)
            isKelvin = false
            isFahSelected = false
            isCelSelected = false
            self.currentScale.text = "Current Scale : -- "
        }
    }
    

    
    /*
    
    if  USERDEFAULT.value(forKey: "isCelsius") as? Bool == true {
        
        btnCelsius.setImage(#imageLiteral(resourceName: "check"), for: .normal)
        btnFahrenheit.setImage(#imageLiteral(resourceName: "uncheck"), for: .normal)
        btnKelvin.setImage(#imageLiteral(resourceName: "uncheck"), for: .normal)
        isCelSelected = true
        isFahSelected = false
        isKelvin = false
        self.currentScale.text = "Current Scale : Celsius"
        USERDEFAULT.set(true, forKey: "isCelsius")
        USERDEFAULT.set(false, forKey: "isFahrenheit")
        USERDEFAULT.set(false, forKey: "isKelvin")
        USERDEFAULT.synchronize()
        
    }else if USERDEFAULT.value(forKey: "isFahrenheit") as? Bool == true {
        
        btnCelsius.setImage(#imageLiteral(resourceName: "uncheck"), for: .normal)
        btnFahrenheit.setImage(#imageLiteral(resourceName: "check"), for: .normal)
        btnKelvin.setImage(#imageLiteral(resourceName: "uncheck"), for: .normal)
        isCelSelected = false
        isFahSelected = true
        isKelvin = false
        self.currentScale.text = "Current Scale : Fahrenheit"
        USERDEFAULT.set(true, forKey: "isFahrenheit")
        USERDEFAULT.set(false, forKey: "isCelsius")
        USERDEFAULT.set(false, forKey: "isKelvin")
        USERDEFAULT.synchronize()
        

        
    }else if USERDEFAULT.value(forKey: "isKelvin") as? Bool == true{
        
        btnCelsius.setImage(#imageLiteral(resourceName: "uncheck"), for: .normal)
        btnFahrenheit.setImage(#imageLiteral(resourceName: "uncheck"), for: .normal)
        btnKelvin.setImage(#imageLiteral(resourceName: "check"), for: .normal)
        isCelSelected = false
        isFahSelected = false
        isKelvin = true
        self.currentScale.text = "Current Scale : Kelvin"
        USERDEFAULT.set(false, forKey: "isFahrenheit")
        USERDEFAULT.set(false, forKey: "isCelsius")
        USERDEFAULT.set(true, forKey: "isKelvin")
        USERDEFAULT.synchronize()
        
    }else{
        
        
        btnCelsius.setImage(#imageLiteral(resourceName: "check"), for: .normal)
        btnFahrenheit.setImage(#imageLiteral(resourceName: "uncheck"), for: .normal)
        btnKelvin.setImage(#imageLiteral(resourceName: "uncheck"), for: .normal)
        isCelSelected = true
        isFahSelected = false
        isCelSelected = false
        self.currentScale.text = "Current Scale : Celsius"
        USERDEFAULT.set(true, forKey: "isCelsius")
        USERDEFAULT.set(false, forKey: "isFahrenheit")
        USERDEFAULT.set(false, forKey: "isKelvin")
        USERDEFAULT.synchronize()
    }*/
    
    self.imgbettery.image = UIImage.init(named: MainCenteralManager.sharedInstance().data.imgbettery)
    
  }
  

}

extension BlueToothOptionVC : MainCenteralManagerDelegate{
  func ReceiveCommand(){
    self.CheckingTemperature()
    self.SetData()
    self.setSettingData()
  }
}
