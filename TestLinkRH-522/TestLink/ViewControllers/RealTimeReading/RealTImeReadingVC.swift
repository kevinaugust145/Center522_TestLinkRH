//
//  RealTImeReadingVC.swift
//  TestLink
//
//  Created by Pritesh Pethani on 24/01/17.
//  Copyright © 2017 Pritesh Pethani. All rights reserved.
//

import UIKit

class CustomUISlider : UISlider {
    
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        
        var newBounds = super.trackRect(forBounds: bounds)
        newBounds.size.height = 10
        return newBounds
    }
    
    //while we are here, why not change the image here as well? (bonus material)
    override func awakeFromNib() {
        //self.setThumbImage(UIImage(named: "customThumb"), for: .normal)
        super.awakeFromNib()
    }
}

class RealTImeReadingVC: UIViewController, UITextFieldDelegate {
  
 
  @IBOutlet var viewAlarmTemp: UIView!

    @IBOutlet var lblRH: UILabel!
    @IBOutlet var btnCelsius: UIButton!
    @IBOutlet var btnK: UIButton!
    @IBOutlet var btnFH: UIButton!
    

    @IBOutlet var slider: UISlider!
    
    @IBOutlet var lblMinMaxTemp :UILabel!
  @IBOutlet var txtMinTemp :UITextField!
  @IBOutlet var txtMaxTemp :UITextField!
  
  
    @IBOutlet var lblCurrentPoint: UILabel!
    
    @IBOutlet var lblT1: UILabel!
    
    @IBOutlet var lblT2: UILabel!
    //Switch
    
    @IBOutlet var switchRH: UISwitch!
    @IBOutlet var switchT1: UISwitch!
    @IBOutlet var switchT2: UISwitch!
    
    @IBOutlet var lblRHAlarmStatus: UILabel!
    @IBOutlet var lblT1AlarmStatus: UILabel!
    @IBOutlet var lblT2AlarmStatus: UILabel!
    
    @IBOutlet var lblRHMin: UILabel!
    @IBOutlet var lblRHMax: UILabel!
    
    @IBOutlet var lblT1Min: UILabel!
    @IBOutlet var lblT1Max: UILabel!
    
    @IBOutlet var lblT2Min: UILabel!
    @IBOutlet var lblT2Max: UILabel!
    
    
    @IBOutlet var lblDataType: UILabel!
    
  var rangeData = NSMutableArray()
  var rangeDict = NSMutableDictionary()
    
    
    var temperatureRHAlertBool:Bool = true
    var temperatureT1AlertBool:Bool = true
    var temperatureT2AlertBool:Bool = true
    
    var isFahrenheit = false
    var isCelsius = false
    var isKelvin = false
  
  var indexID:Int!
  
  var viewAlertOutRange = viewAlertOutRangeViewController()
  override func viewDidLoad() {
    super.viewDidLoad()
    
   
    
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
      
      rangeDict.setValue("", forKey: "minValue")
      rangeDict.setValue("", forKey: "maxValue")
      rangeData.add(rangeDict)
      
      print("Range Data ", rangeData)
      
      USERDEFAULT.set(self.rangeData, forKey: "temperatureData")
      USERDEFAULT.synchronize()
    }
    
    self.addTapGestureInOurView()
    slider.isUserInteractionEnabled = false
    //self.SetData()
   
    //self.playSound()
  }
  
    
  
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        MainCenteralManager.sharedInstance().mainCenteralManagerDelegate = self
        SetData()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
  func SetData() {
    
    slider.minimumValue = 0
    slider.maximumValue = 100

    if MainCenteralManager.sharedInstance().data.isWetBulb {

        lblCurrentPoint.text = "Tw"
        self.slider.value = 0
 
    }else if MainCenteralManager.sharedInstance().data.isDewPoint {

        lblCurrentPoint.text = "Td"
        self.slider.value = 100
   
    }else{
        
        lblCurrentPoint.text = "T"
        self.slider.value = 50

    }
    
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
            btnFH.setImage(#imageLiteral(resourceName: "check"), for: .normal)
            btnCelsius.setImage(#imageLiteral(resourceName: "uncheck"), for: .normal)
            btnK.setImage(#imageLiteral(resourceName: "uncheck"), for: .normal)
            isFahrenheit = true
            isCelsius = false
            isKelvin = false
            //MainCenteralManager.sharedInstance().data.feh = "F"
        
    }
    else if USERDEFAULT.value(forKey: "isCelsius") as? Bool == true {
        
            USERDEFAULT.set(true, forKey: "isCelsius")
            USERDEFAULT.synchronize()
            btnFH.setImage(#imageLiteral(resourceName: "uncheck"), for: .normal)
            btnCelsius.setImage(#imageLiteral(resourceName: "check"), for: .normal)
            btnK.setImage(#imageLiteral(resourceName: "uncheck"), for: .normal)
            isCelsius = true
            isFahrenheit = false
            isKelvin = false
            //MainCenteralManager.sharedInstance().data.cels == "C"
        
    }
    else if USERDEFAULT.value(forKey: "isKelvin") as? Bool == true {
       
            USERDEFAULT.set(true, forKey: "isKelvin")
            USERDEFAULT.synchronize()
            btnFH.setImage(#imageLiteral(resourceName: "uncheck"), for: .normal)
            btnCelsius.setImage(#imageLiteral(resourceName: "uncheck"), for: .normal)
            btnK.setImage(#imageLiteral(resourceName: "check"), for: .normal)
            isKelvin = true
            isFahrenheit = false
            isCelsius = false
            //MainCenteralManager.sharedInstance().data.kel = "K"
        
    }
    else{
        
        if MainCenteralManager.sharedInstance().data.cOrFOrK == "C" {
            
            USERDEFAULT.set(true, forKey: "isCelsius")
            USERDEFAULT.synchronize()
            btnFH.setImage(#imageLiteral(resourceName: "uncheck"), for: .normal)
            btnCelsius.setImage(#imageLiteral(resourceName: "check"), for: .normal)
            btnK.setImage(#imageLiteral(resourceName: "uncheck"), for: .normal)
            isCelsius = false
            isKelvin = false
            isFahrenheit = false
            
        }else if MainCenteralManager.sharedInstance().data.cOrFOrK == "F" {
            
            USERDEFAULT.set(true, forKey: "isFahrenheit")
            USERDEFAULT.synchronize()
            btnFH.setImage(#imageLiteral(resourceName: "check"), for: .normal)
            btnCelsius.setImage(#imageLiteral(resourceName: "uncheck"), for: .normal)
            btnK.setImage(#imageLiteral(resourceName: "uncheck"), for: .normal)
            isFahrenheit = true
            isCelsius = false
            isKelvin = false
            
        }else if MainCenteralManager.sharedInstance().data.cOrFOrK == "K" {
            
            USERDEFAULT.set(true, forKey: "isKelvin")
            USERDEFAULT.synchronize()
            btnFH.setImage(#imageLiteral(resourceName: "uncheck"), for: .normal)
            btnCelsius.setImage(#imageLiteral(resourceName: "uncheck"), for: .normal)
            btnK.setImage(#imageLiteral(resourceName: "check"), for: .normal)
            isKelvin = true
            isFahrenheit = false
            isCelsius = false
           
        }else {
            
            btnFH.setImage(#imageLiteral(resourceName: "uncheck"), for: .normal)
            btnCelsius.setImage(#imageLiteral(resourceName: "uncheck"), for: .normal)
            btnK.setImage(#imageLiteral(resourceName: "uncheck"), for: .normal)
            isKelvin = false
            isFahrenheit = false
            isCelsius = false
        }
    }
    
    
    /*if (MainCenteralManager.sharedInstance().data.cels == "C"){
        
        btnCelsius.setImage(#imageLiteral(resourceName: "check"), for: .normal)
        btnFH.setImage(#imageLiteral(resourceName: "uncheck"), for: .normal)
        btnK.setImage(#imageLiteral(resourceName: "uncheck"), for: .normal)
        
    }else if MainCenteralManager.sharedInstance().data.feh == "F"{
        
        btnCelsius.setImage(#imageLiteral(resourceName: "uncheck"), for: .normal)
        btnFH.setImage(#imageLiteral(resourceName: "check"), for: .normal)
        btnK.setImage(#imageLiteral(resourceName: "uncheck"), for: .normal)
    }else{
        
        btnCelsius.setImage(#imageLiteral(resourceName: "uncheck"), for: .normal)
        btnFH.setImage(#imageLiteral(resourceName: "uncheck"), for: .normal)
        btnK.setImage(#imageLiteral(resourceName: "check"), for: .normal)
    }
    */
    
    self.lblDataType.text = MainCenteralManager.sharedInstance().data.DeviceType
    
    
    // Set data to RH
    
    lblRH.text = "\( MainCenteralManager.sharedInstance().data.RHtemperature )\(" %")"
    
    if let minVal = (rangeData.object(at: 0) as AnyObject).value(forKey: "minValue") as? String{
        var minimumValue = minVal
        
        if minimumValue == ""{
            lblRHMin.text = "MIN 00"
        }
        else{
            if isFahrenheit {
                
                minimumValue = String(format: "%.1f", (Float(minVal)! * 1.8) + 32)
            }else if  isKelvin {
                
                minimumValue = String(format: "%.1f", (Float(minVal)! + 273.15))
            }
            
            lblRHMin.text = "MIN \( String(format: "%.1f", Float(minimumValue)!) )"
        }
    }
    
    if let maxVal = (rangeData.object(at: 0) as AnyObject).value(forKey: "maxValue") as? String{
        var maximumValue = maxVal
        
        if maximumValue == ""{
            lblRHMax.text = "MAX 00"
        }
        else{
            if isFahrenheit {
                
                maximumValue = String(format: "%.1f", (Float(maxVal)! * 1.8) + 32)
                
            }else if  isKelvin {
                
                maximumValue = String(format: "%.1f", (Float(maxVal)! + 273.15))
            }
            lblRHMax.text = "MAX \(String(format: "%.1f", Float(maximumValue)!) )"
        }
    }
    
    if let RH = USERDEFAULT.value(forKey: "isRH") as? Bool{
        
        if  RH == true{
            USERDEFAULT.set(true, forKey: "isRH")
            USERDEFAULT.synchronize()
            switchRH.isOn = true
            
            lblRHMax.isHidden = false
            lblRHMin.isHidden = false
            lblRHAlarmStatus.text = "ALARM SET"
        }
        else{
            USERDEFAULT.set(false, forKey: "isRH")
            USERDEFAULT.synchronize()
            switchRH.isOn = false
            
            lblRHMax.isHidden = true
            lblRHMin.isHidden = true
            lblRHAlarmStatus.text = "ALARM UNSET"
        }
        
    }
    else{
        USERDEFAULT.set(false, forKey: "isRH")
        USERDEFAULT.synchronize()
        switchRH.isOn = false
        
        lblRHMax.isHidden = true
        lblRHMin.isHidden = true
        lblRHAlarmStatus.text = "ALARM UNSET"
    }
    
    
    // Set data to T1
    
    var tempType = ""
    var T1Value = ""
    var T2Value = ""
    
    
    if isCelsius {
        tempType = "C"
    }else if isFahrenheit {
        tempType = "F"
    }else if isKelvin {
        tempType = "K"
    }else{
        tempType = "C"
    }
    
    if MainCenteralManager.sharedInstance().data.temperatureT1 == "--" && MainCenteralManager.sharedInstance().data.temperatureT2 == "--"  {
        
        T1Value = "--"
        T2Value = "--"
        
    }else if MainCenteralManager.sharedInstance().data.temperatureT1 == "--" {
        
        T1Value = "--"
        if isCelsius {
    
            T2Value = String(format:"%.1f",Float(5.0 / 9.0 * (Double(MainCenteralManager.sharedInstance().data.temperatureT2)! - 32.0)))
            
        }else if isFahrenheit {
            
            T2Value = String(format:"%.1f",Double(MainCenteralManager.sharedInstance().data.temperatureT2)!)
            
        }else if isKelvin {
            
            T2Value = String(format:"%.1f",Float((5.0 / 9.0) * (Double(MainCenteralManager.sharedInstance().data.temperatureT2)! + 459.67)))
        }
        
    }else if MainCenteralManager.sharedInstance().data.temperatureT2 == "--" {
        
        T2Value = "--"
        if isCelsius {
            
            T1Value = String(format:"%.1f",Double(MainCenteralManager.sharedInstance().data.temperatureT1)!)
            
        }else if isFahrenheit {
            
            T1Value = String(format:"%.1f",Float((1.8 * Double(MainCenteralManager.sharedInstance().data.temperatureT1)!) + 32.0))
            
        }else if isKelvin {
            
            T1Value = String(format:"%.1f",Float(Float(MainCenteralManager.sharedInstance().data.temperatureT1)! + 273.15))
        }
    }
    else{
        
        if isCelsius {
            
            tempType = "C"
            T1Value = String(format:"%.1f",Double(MainCenteralManager.sharedInstance().data.temperatureT1)!)
            T2Value = String(format:"%.1f",Float(5.0 / 9.0 * (Double(MainCenteralManager.sharedInstance().data.temperatureT2)! - 32.0)))
            
        }else if isFahrenheit {
            
            tempType = "F"
            T1Value = String(format:"%.1f",Float((1.8 * Double(MainCenteralManager.sharedInstance().data.temperatureT1)!) + 32.0))
            T2Value = String(format:"%.1f",Double(MainCenteralManager.sharedInstance().data.temperatureT2)!)
            
        }else if isKelvin {
            
            tempType = "K"
            T1Value = String(format:"%.1f",Float(Float(MainCenteralManager.sharedInstance().data.temperatureT1)! + 273.15))
            T2Value = String(format:"%.1f",Float((5.0 / 9.0) * (Double(MainCenteralManager.sharedInstance().data.temperatureT2)! + 459.67)))
        }

    }
    
    
    lblT1.text = "\( T1Value ) \u{00B0} \(tempType)"
    
    if let minVal = (rangeData.object(at: 1) as AnyObject).value(forKey: "minValue") as? String{
        var minimumValue = minVal
        
        if minimumValue == ""{
            lblT1Min.text = "MIN 00"
        }
        else{
      
            if isFahrenheit {
                
                minimumValue = String(format: "%.1f", (Float(minVal)! * 1.8) + 32)
            }else if  isKelvin {
                
                minimumValue = String(format: "%.1f", (Float(minVal)! + 273.15))
            }
            
            lblT1Min.text = "MIN \( String(format: "%.1f", Float(minimumValue)!) )"
        }
    }
    
    if let maxVal = (rangeData.object(at: 1) as AnyObject).value(forKey: "maxValue") as? String{
        var maximumValue = maxVal
        
        if maximumValue == ""{
            lblT1Max.text = "MAX 00"
        }
        else{
            
            if isFahrenheit {
                
                maximumValue = String(format: "%.1f", (Float(maxVal)! * 1.8) + 32)
            }else if  isKelvin {
                
                maximumValue = String(format: "%.1f", (Float(maxVal)! + 273.15))
            }
            
            lblT1Max.text = "MAX \(String(format: "%.1f", Float(maximumValue)!) )"
        }
    }
    
    if let t1 = USERDEFAULT.value(forKey: "isT1") as? Bool{
        if  t1 == true{
            USERDEFAULT.set(true, forKey: "isT1")
            USERDEFAULT.synchronize()
            
            switchT1.isOn = true
            
            lblT1Max.isHidden = false
            lblT1Min.isHidden = false
            lblT1AlarmStatus.text = "ALARM SET"
        }
        else{
            
            USERDEFAULT.set(false, forKey: "isT1")
            USERDEFAULT.synchronize()
            switchT1.isOn = false
            lblT1Max.isHidden = true
            lblT1Min.isHidden = true
            lblT1AlarmStatus.text = "ALARM UNSET"
            
        }
        
    }
    else{
        
        USERDEFAULT.set(false, forKey: "isT1")
        USERDEFAULT.synchronize()
        switchT1.isOn = false
        lblT1Max.isHidden = true
        lblT1Min.isHidden = true
        lblT1AlarmStatus.text = "ALARM UNSET"
    }
    
    // Set data to T2
    
    lblT2.text = "\( T2Value ) \u{00B0} \(tempType)"
    
    if let minVal = (rangeData.object(at: 2) as AnyObject).value(forKey: "minValue") as? String{
        var minimumValue = minVal
        
        if minimumValue == ""{
            lblT2Min.text = "MIN 00"
        }
        else{
            
            if isFahrenheit {
                
                minimumValue = String(format: "%.1f", (Float(minVal)! * 1.8) + 32)
            }else if  isKelvin {
                
                minimumValue = String(format: "%.1f", (Float(minVal)! + 273.15))
            }
            lblT2Min.text = "MIN \(String(format: "%.1f", Float(minimumValue)!))"
        }
    }
    
    if let maxVal = (rangeData.object(at: 2) as AnyObject).value(forKey: "maxValue") as? String{
        var maximumValue = maxVal
        
        if maximumValue == ""{
            
            lblT2Max.text = "MAX 00"
        }
        else{
            
            if isFahrenheit {
                
                maximumValue = String(format: "%.1f", (Float(maxVal)! * 1.8) + 32)
            }else if  isKelvin {
                
                maximumValue = String(format: "%.1f", (Float(maxVal)! + 273.15))
            }
            
            lblT2Max.text = "MAX \(String(format: "%.1f", Float(maximumValue)!))"
        }
    }
    
    if let t2 = USERDEFAULT.value(forKey: "isT2") as? Bool{
        if  t2 == true{
            USERDEFAULT.set(true, forKey: "isT2")
            USERDEFAULT.synchronize()
            
            switchT2.isOn = true
            
            lblT2Max.isHidden = false
            lblT2Min.isHidden = false
            lblT2AlarmStatus.text = "ALARM SET"
        
        }
        else{
            USERDEFAULT.set(false, forKey: "isT2")
            USERDEFAULT.synchronize()
            
            switchT2.isOn = false
            lblT2Max.isHidden = true
            lblT2Min.isHidden = true
            lblT2AlarmStatus.text = "ALARM UNSET"
        }
    }
    else{
        USERDEFAULT.set(false, forKey: "isT2")
        USERDEFAULT.synchronize()
        switchT2.isOn = false
        lblT2Max.isHidden = true
        lblT2Min.isHidden = true
        lblT2AlarmStatus.text = "ALARM UNSET"
    }
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
  
  
  // MARK: - Button Action Methods
  
  @IBAction func btnBackliked(_ sender: UIButton) {
    _ = self.navigationController?.popViewController(animated: true)
  }
  
  @IBAction func btnClockliked(_ sender: UIButton) {
    self.view.addSubview(viewAlarmTemp)
  }
  
    @IBAction func btnCelsius_Tapped(_ sender: Any) {
        
        btnCelsius.setImage(#imageLiteral(resourceName: "check"), for: .normal)
        btnFH.setImage(#imageLiteral(resourceName: "uncheck"), for: .normal)
        btnK.setImage(#imageLiteral(resourceName: "uncheck"), for: .normal)
        
        isCelsius = true
        isFahrenheit = false
        isKelvin = false
        
        USERDEFAULT.set(true, forKey: "isCelsius")
        USERDEFAULT.set(false, forKey: "isFahrenheit")
        USERDEFAULT.set(false, forKey: "isKelvin")
        USERDEFAULT.synchronize()
        
        SetData()
    }
    @IBAction func btnFehrenheit_Tapped(_ sender: Any) {
        
        btnCelsius.setImage(#imageLiteral(resourceName: "uncheck"), for: .normal)
        btnFH.setImage(#imageLiteral(resourceName: "check"), for: .normal)
        btnK.setImage(#imageLiteral(resourceName: "uncheck"), for: .normal)
        
        isCelsius = false
        isFahrenheit = true
        isKelvin = false
        
        USERDEFAULT.set(false, forKey: "isCelsius")
        USERDEFAULT.set(true, forKey: "isFahrenheit")
        USERDEFAULT.set(false, forKey: "isKelvin")
        USERDEFAULT.synchronize()
        
        SetData()
        
    }
    @IBAction func btnKelvin_Tapped(_ sender: Any) {
        
        btnCelsius.setImage(#imageLiteral(resourceName: "uncheck"), for: .normal)
        btnFH.setImage(#imageLiteral(resourceName: "uncheck"), for: .normal)
        btnK.setImage(#imageLiteral(resourceName: "check"), for: .normal)
        
        isCelsius = false
        isFahrenheit = false
        isKelvin = true
        
        USERDEFAULT.set(false, forKey: "isCelsius")
        USERDEFAULT.set(false, forKey: "isFahrenheit")
        USERDEFAULT.set(true, forKey: "isKelvin")
        USERDEFAULT.synchronize()
        
        SetData()
    }
    
    @IBAction func btnWetBulb_Tapped(_ sender: Any) {
        
        if MainCenteralManager.sharedInstance().data.isWetBulb {
            
        }else if MainCenteralManager.sharedInstance().data.isDewPoint {

            MainCenteralManager.sharedInstance().CommandC()
            MainCenteralManager.sharedInstance().CommandC()
            MainCenteralManager.sharedInstance().CommandA()
            
        }else{
      
            MainCenteralManager.sharedInstance().CommandC()
            MainCenteralManager.sharedInstance().CommandA()
        }
        
        let notificationName = Notification.Name("settingDataNotification")
        NotificationCenter.default.post(name: notificationName, object: nil)
    }
    
    @IBAction func btnNormal_Tapped(_ sender: Any) {
        
        if MainCenteralManager.sharedInstance().data.isWetBulb {

            MainCenteralManager.sharedInstance().CommandC()
            MainCenteralManager.sharedInstance().CommandC()
            MainCenteralManager.sharedInstance().CommandA()
            
        }else if MainCenteralManager.sharedInstance().data.isDewPoint {
  
            MainCenteralManager.sharedInstance().CommandC()
            MainCenteralManager.sharedInstance().CommandA()
            
        }else{

        }
        
        let notificationName = Notification.Name("settingDataNotification")
        NotificationCenter.default.post(name: notificationName, object: nil)
    }
    @IBAction func btnDewBulb_Tapped(_ sender: Any) {
        
        if MainCenteralManager.sharedInstance().data.isWetBulb {

            MainCenteralManager.sharedInstance().CommandC()
            MainCenteralManager.sharedInstance().CommandA()
            
            
        }else if MainCenteralManager.sharedInstance().data.isDewPoint {

        }else{
            
            MainCenteralManager.sharedInstance().CommandC()
            MainCenteralManager.sharedInstance().CommandC()
            MainCenteralManager.sharedInstance().CommandA()
        }
        
        let notificationName = Notification.Name("settingDataNotification")
        NotificationCenter.default.post(name: notificationName, object: nil)
        
    }
    // MARK: - Other Methods
  
  func addTapGestureInOurView(){
    let tapRecognizer:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.backgroundTap(_:)))
    tapRecognizer.cancelsTouchesInView = false
    self.view.addGestureRecognizer(tapRecognizer)
  }
  @IBAction func backgroundTap(_ sender:UITapGestureRecognizer){
    
    let point:CGPoint = sender.location(in: sender.view)
    let viewTouched = view.hitTest(point, with: nil)
    
    if viewTouched!.isKind(of: UIButton.self){
      
    }
    else{
      self.view.endEditing(true)
    }
  }
  
 
 
  
  
  @IBAction func btnAlarmSetClicked(_ sender:UIButton){
    
 
  }
  
  @IBAction func btnAlarmCancelClicked(_ sender:UIButton){
   
  }
  

  func CheckingTemperature(){
    
    /*var isFahrenheit :Bool = false
    var isCelsius :Bool = false
    var isKelvin :Bool = false
    
    if MainCenteralManager.sharedInstance().data.cels == "C" {
        isCelsius = true
    }
    else if MainCenteralManager.sharedInstance().data.feh == "F"{
        isFahrenheit = true
        
    }else if MainCenteralManager.sharedInstance().data.kel == "K"{
        isKelvin = true
    }*/

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
                        viewAlertOutRange = viewAlertOutRangeViewController(AlertMsg: "Alert value reached below", AlertTemperature: "T1 : \(minVal!)")
                        
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
                        viewAlertOutRange = viewAlertOutRangeViewController(AlertMsg: "Alert value reached above", AlertTemperature: "T1 : \(maxVal!)")
                        
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
            
            if isFahrenheit {
                
                minVal = String((Float(minVal!)! * 1.8) + 32)
                maxVal = String((Float(maxVal!)! * 1.8) + 32)
            }else if isKelvin {
                
                minVal = String(Float(minVal!)! + 273.15)
                maxVal = String(Float(maxVal!)! + 273.15)
            }else{
                
                minVal = String(format: "%.1f",  Float(minVal!)!)
                maxVal = String(format: "%.1f",  Float(maxVal!)!)
                
            }
            
            let minIntValue = Float(minVal!)
            let maxIntValue = Float(maxVal!)
            let t1IntValue = Float(MainCenteralManager.sharedInstance().data.temperatureT1 as String)
            
            if t1IntValue != nil {
                
                if t1IntValue! < minIntValue! {
                    if temperatureT1AlertBool == true {
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
            
            if isFahrenheit {
                
                minVal = String((Float(minVal!)! * 1.8) + 32)
                maxVal = String((Float(maxVal!)! * 1.8) + 32)
            }else if isKelvin {
                
                minVal = String(Float(minVal!)! + 273.15)
                maxVal = String(Float(maxVal!)! + 273.15)
            }else{
                
                minVal = String(format: "%.1f",  Float(minVal!)!)
                maxVal = String(format: "%.1f",  Float(maxVal!)!)
                
            }
            
            let minIntValue = Float(minVal!)
            let maxIntValue = Float(maxVal!)
            
            let t2IntValue = Float(MainCenteralManager.sharedInstance().data.temperatureT2 as String)
            
            if t2IntValue != nil {
                if t2IntValue! < minIntValue! {
                    if temperatureT2AlertBool == true {
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

}


extension RealTImeReadingVC : MainCenteralManagerDelegate{
  func ReceiveCommand(){
    self.CheckingTemperature()
    self.SetData()
  }
}
