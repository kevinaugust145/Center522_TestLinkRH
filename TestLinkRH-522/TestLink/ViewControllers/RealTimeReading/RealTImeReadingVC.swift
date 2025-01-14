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
    
    @IBOutlet var lblAlarmViewTitle: UILabel!
    @IBOutlet var lblMinMaxTemp :UILabel!
  @IBOutlet var txtMinTemp :UITextField!
  @IBOutlet var txtMaxTemp :UITextField!
  
    @IBOutlet var viewRHData: UIView!
    
    @IBOutlet var viewT2Data: UIView!
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
    
    @IBOutlet var btnClickHere: UIButton!
    
    @IBOutlet var lblDataType: UILabel!
    
    @IBOutlet var nslcTopView: NSLayoutConstraint!
    @IBOutlet var topView: UIView!
    
    
    @IBOutlet var viewProgress: UIView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    var interactionController: UIPercentDrivenInteractiveTransition?
    
    var objAlertView : AlertOutOfRangeView!
    var objAlertViewT1 : AlertOutOfRangeViewT1!
    var objAlertViewT2 : AlertOutOfRangeViewT2!
    
    var rangeData = NSMutableArray()
    var rangeDict = NSMutableDictionary()
    
    
    var temperatureRHAlertBool:Bool = true
    var temperatureT1AlertBool:Bool = true
    var temperatureT2AlertBool:Bool = true
    
    var arrViews : [Int] = []
    
    var isRHAlarmPlaying : Bool = false
    var isT1AlarmPlaying : Bool = false
    var isT2AlarmPlaying : Bool = false
    
    var isFahrenheit = false
    var isCelsius = false
    var isKelvin = false
  
    var isSlidingStart : Bool = false
    var isChangingTemp : Bool = false
    
    var isRHMinActive : Bool = false
    var isRHMaxActive : Bool = false
    var isT1MinActive : Bool = false
    var isT1MaxActive : Bool = false
    var isT2MinActive : Bool = false
    var isT2MaxActive : Bool = false
    
    
    var RHTimer = Timer()
    var RHCount = 0
    var isRHAlarmActive = true
    
    var T1Timer = Timer()
    var T1Count = 0
    var isT1AlarmActive = true
    
    var T2Timer = Timer()
    var T2Count = 0
    var isT2AlarmActive = true
    
    var indexID:Int!
  
    //var viewAlertOutRange = viewAlertOutRangeViewController()  // This is global alert view for showing high/low temp alerts. This is now not used as we need to show all alerts of alarm. Also this is viewcontroller which was presenting modally. So we can not present same view controller multiple times.
    
    
  override func viewDidLoad() {
    super.viewDidLoad()
    
   
    viewProgress.isHidden = true
    
    viewAlarmTemp.frame = CGRect(x: 0, y: 0, width: ScreenSize.SCREEN_WIDTH, height: ScreenSize.SCREEN_HEIGHT)
    
    viewRHData.layer.shadowColor = UIColor(red: 226/255, green: 226/255, blue: 226/255, alpha: 1.0).cgColor
    viewRHData.layer.shadowOffset =  CGSize(width: 0.0, height: 2.0)
    viewRHData.layer.shadowOpacity = 1.0
    viewRHData.layer.shadowRadius = 0.0
    viewRHData.layer.masksToBounds = false
    
    viewT2Data.layer.shadowColor = UIColor(red: 226/255, green: 226/255, blue: 226/255, alpha: 1.0).cgColor
    viewT2Data.layer.shadowOffset =  CGSize(width: 0.0, height: 2.0)
    viewT2Data.layer.shadowOpacity = 1.0
    viewT2Data.layer.shadowRadius = 0.0
    viewT2Data.layer.masksToBounds = false
 
    
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
    //slider.isUserInteractionEnabled = false
    //self.SetData()
   
    //self.playSound()
    
    slider.addTarget(self, action: #selector(onSliderValChanged(slider:event:)), for: .valueChanged)
    
    
   /* let animatedImageView = UIImageView(frame: btnClickHere.bounds)
    animatedImageView.animationImages = [UIImage(named: "1.gif")!, UIImage(named: "2.gif")!, UIImage(named: "3.gif")!, UIImage(named: "4.gif")!, UIImage(named: "5.gif")!, UIImage(named: "6.gif")!, UIImage(named: "7.gif")!, UIImage(named: "8.gif")!, UIImage(named: "9.gif")!]
    animatedImageView.animationDuration = 1.0
    animatedImageView.animationRepeatCount = 0
    animatedImageView.startAnimating()
    btnClickHere.addSubview(animatedImageView)*/
    
    let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: 44))
    let minusButton = UIBarButtonItem(title: "-", style: .plain, target: self, action: #selector(toggleMinus))
    toolbar.items = [minusButton]
    txtMaxTemp.inputAccessoryView = toolbar
    
    let toolbar1 = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: 44))
    let minusButton1 = UIBarButtonItem(title: "-", style: .plain, target: self, action: #selector(toggleMinus1))
    toolbar1.items = [minusButton1]
    txtMinTemp.inputAccessoryView = toolbar1

  }
  
    @objc func toggleMinus(){
        
        // Get text from text field
        if var text = txtMaxTemp.text , text.isEmpty == false{
            
            // Toggle
            if text.hasPrefix("-") {
                text = text.replacingOccurrences(of: "-", with: "")
            }
            else
            {
                text = "-\(text)"
            }
            
            // Set text in text field
            txtMaxTemp.text = text
            
        }
    }
    @objc func toggleMinus1(){
        
        // Get text from text field
        if var text = txtMinTemp.text , text.isEmpty == false{
            
            // Toggle
            if text.hasPrefix("-") {
                text = text.replacingOccurrences(of: "-", with: "")
            }
            else
            {
                text = "-\(text)"
            }
            
            // Set text in text field
            txtMinTemp.text = text
            
        }
    }
    
    override func viewDidLayoutSubviews() {
        
        Utility.set_TopLayout_VesionRelated(nslcTopView, topView, self)
    }
    
    @objc func onSliderValChanged(slider: UISlider, event: UIEvent) {
        if let touchEvent = event.allTouches?.first {
            switch touchEvent.phase {
            case .began:
                 print(slider.value)
                print("began")
                
            // handle drag began
            case .moved:
                 print(slider.value)
                 isSlidingStart = true
                print("moved")
            // handle drag moved
            case .ended:
                print(slider.value)
                isSlidingStart = false
                if slider.value >= 0 && slider.value <= 33.0 {
                    self.btnWetBulb_Tapped(slider)
                    break
                }else if slider.value > 33.0 && slider.value <= 66.0 {
                    self.btnNormal_Tapped(slider)
                    break
                }else if slider.value > 66.0 && slider.value <= 100.0 {
                    self.btnDewBulb_Tapped(slider)
                    break
                }
                print("ended")
            // handle drag ended
            default:
                break
            }
        }
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
        if !isSlidingStart {
            self.slider.value = 0
        }
    
    }else if MainCenteralManager.sharedInstance().data.isDewPoint {

        lblCurrentPoint.text = "Td"
        if !isSlidingStart {
             self.slider.value = 100
        }
      
    }else{
        
        lblCurrentPoint.text = ""
        if !isSlidingStart {
            self.slider.value = 50
        }
        

    }

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
        
        /*if MainCenteralManager.sharedInstance().data.cOrFOrK == "C" {
            
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
        }*/
            btnFH.setImage(#imageLiteral(resourceName: "uncheck"), for: .normal)
            btnCelsius.setImage(#imageLiteral(resourceName: "uncheck"), for: .normal)
            btnK.setImage(#imageLiteral(resourceName: "uncheck"), for: .normal)
            isKelvin = false
            isFahrenheit = false
            isCelsius = false
       
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
        let minimumValue = minVal
        
        if minimumValue == ""{
            lblRHMin.text = "MIN 00"
        }
        else{
     
            lblRHMin.text = "MIN \( String(format: "%.1f", Float(minimumValue)!) )"
        }
    }
    
    if let maxVal = (rangeData.object(at: 0) as AnyObject).value(forKey: "maxValue") as? String{
        let maximumValue = maxVal
        
        if maximumValue == ""{
            lblRHMax.text = "MAX 00"
        }
        else{
       
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
      
      
      T1Value = MainCenteralManager.sharedInstance().data.temperatureT1
      T2Value = MainCenteralManager.sharedInstance().data.temperatureT2
      
      if T1Value != "--" && T1Value != "OL" && T1Value != "-OL" {
          if isCelsius {
              T1Value = String(format:"%.1f",Double(MainCenteralManager.sharedInstance().data.temperatureT1)!)
          }else if isFahrenheit {
              T1Value = String(format:"%.1f",Float((1.8 * Double(MainCenteralManager.sharedInstance().data.temperatureT1)!) + 32.0))
          }else if isKelvin {
              T1Value = String(format:"%.1f",Float(Float(MainCenteralManager.sharedInstance().data.temperatureT1)! + 273.15))
          }
      }
      
      if T2Value != "--" && T2Value != "OL" && T2Value != "-OL" {
          if isCelsius {
              let val = Float(5.0 / 9.0 * (Double(MainCenteralManager.sharedInstance().data.temperatureT2)! - 32.0)) >= 600 ? String(format: "%.1f", floor(Float(5.0 / 9.0 * (Double(MainCenteralManager.sharedInstance().data.temperatureT2)! - 32.0)))) : String(format: "%.1f", Float(5.0 / 9.0 * (Double(MainCenteralManager.sharedInstance().data.temperatureT2)! - 32.0)))
              T2Value = val
          }else if isFahrenheit {
              let val = Double(MainCenteralManager.sharedInstance().data.temperatureT2)! >= 1000 ? String(format: "%.1f", floor(Double(MainCenteralManager.sharedInstance().data.temperatureT2)!)) : String(format: "%.1f", Double(MainCenteralManager.sharedInstance().data.temperatureT2)!)
              T2Value = val
          }else if isKelvin {
              T2Value = String(format:"%.1f",Float((5.0 / 9.0) * (Double(MainCenteralManager.sharedInstance().data.temperatureT2)! + 459.67)))
          }
      }

//    if MainCenteralManager.sharedInstance().data.temperatureT1 == "--" && MainCenteralManager.sharedInstance().data.temperatureT2 == "--"  {
//
//        T1Value = "--"
//        T2Value = "--"
//
//    }else if MainCenteralManager.sharedInstance().data.temperatureT1 == "--" {
//
//        T1Value = "--"
//        if isCelsius {
//
//            let val = Float(5.0 / 9.0 * (Double(MainCenteralManager.sharedInstance().data.temperatureT2)! - 32.0)) >= 600 ? String(format: "%.1f", floor(Float(5.0 / 9.0 * (Double(MainCenteralManager.sharedInstance().data.temperatureT2)! - 32.0)))) : String(format: "%.1f", Float(5.0 / 9.0 * (Double(MainCenteralManager.sharedInstance().data.temperatureT2)! - 32.0)))
//            T2Value = val
//            //T2Value = String(format:"%.1f",Float(5.0 / 9.0 * (Double(MainCenteralManager.sharedInstance().data.temperatureT2)! - 32.0)))
//
//        }else if isFahrenheit {
//            let val = Double(MainCenteralManager.sharedInstance().data.temperatureT2)! >= 1000 ? String(format: "%.1f", floor(Double(MainCenteralManager.sharedInstance().data.temperatureT2)!)) : String(format: "%.1f", Double(MainCenteralManager.sharedInstance().data.temperatureT2)!)
//            T2Value = val
//            //T2Value = String(format:"%.1f",Double(MainCenteralManager.sharedInstance().data.temperatureT2)!)
//
//        }else if isKelvin {
//
//            T2Value = String(format:"%.1f",Float((5.0 / 9.0) * (Double(MainCenteralManager.sharedInstance().data.temperatureT2)! + 459.67)))
//        }
//
//    }else if MainCenteralManager.sharedInstance().data.temperatureT2 == "--" {
//
//        T2Value = "--"
//        if isCelsius {
//
//            T1Value = String(format:"%.1f",Double(MainCenteralManager.sharedInstance().data.temperatureT1)!)
//
//        }else if isFahrenheit {
//
//            T1Value = String(format:"%.1f",Float((1.8 * Double(MainCenteralManager.sharedInstance().data.temperatureT1)!) + 32.0))
//
//        }else if isKelvin {
//
//            T1Value = String(format:"%.1f",Float(Float(MainCenteralManager.sharedInstance().data.temperatureT1)! + 273.15))
//        }
//    }
//    else{
//
//        if isCelsius {
//
//            tempType = "C"
//            T1Value = String(format:"%.1f",Double(MainCenteralManager.sharedInstance().data.temperatureT1)!)
//            let val = Float(5.0 / 9.0 * (Double(MainCenteralManager.sharedInstance().data.temperatureT2)! - 32.0)) >= 600 ? String(format: "%.1f", floor(Float(5.0 / 9.0 * (Double(MainCenteralManager.sharedInstance().data.temperatureT2)! - 32.0)))) : String(format: "%.1f", Float(5.0 / 9.0 * (Double(MainCenteralManager.sharedInstance().data.temperatureT2)! - 32.0)))
//            T2Value = val
//
//        }else if isFahrenheit {
//
//            tempType = "F"
//            T1Value = String(format:"%.1f",Float((1.8 * Double(MainCenteralManager.sharedInstance().data.temperatureT1)!) + 32.0))
//            let val = Double(MainCenteralManager.sharedInstance().data.temperatureT2)! >= 1000 ? String(format: "%.1f", floor(Double(MainCenteralManager.sharedInstance().data.temperatureT2)!)) : String(format: "%.1f", Double(MainCenteralManager.sharedInstance().data.temperatureT2)!)
//            T2Value = val
//
//        }else if isKelvin {
//
//            tempType = "K"
//            T1Value = String(format:"%.1f",Float(Float(MainCenteralManager.sharedInstance().data.temperatureT1)! + 273.15))
//            T2Value = String(format:"%.1f",Float((5.0 / 9.0) * (Double(MainCenteralManager.sharedInstance().data.temperatureT2)! + 459.67)))
//        }
//
//    }
    
    if isKelvin {
        
        lblT1.text = "\( T1Value ) \(tempType)"
        
    }else{
        
        lblT1.text = "\( T1Value ) \u{00B0}\(tempType)"
    }
    
    
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
    
    if isKelvin {
        
        lblT2.text = "\( T2Value ) \(tempType)"
        
    }else{
        
        lblT2.text = "\( T2Value ) \u{00B0}\(tempType)"
    }
    
    if let minVal = (rangeData.object(at: 2) as AnyObject).value(forKey: "minValue") as? String{
        var minimumValue = minVal
        
        if minimumValue == ""{
            lblT2Min.text = "MIN 00"
        }
        else{
            
            if isCelsius {
                
                minimumValue = String(format: "%.1f", (Float(minVal)! - 32) / 1.8)
            }else if  isKelvin {
                
                minimumValue = String(format: "%.1f", (Float(minVal)! + 459.67) * (5/9))
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
            
            var val = ""
            
            if isCelsius {
                
                val = ((Float(maxVal)! - 32) / 1.8) >= 600 ? String(format: "%.1f", floor((Float(maxVal)! - 32) / 1.8)) : String(format: "%.1f", (Float(maxVal)! - 32) / 1.8)
                
                maximumValue = val
                //maximumValue = String(format: "%.1f", (Float(maxVal)! - 32) / 1.8)
            }else if  isKelvin {
                
                maximumValue = String(format: "%.1f", (Float(maxVal)! + 459.67) * (5/9))
                val = maximumValue
            }else{
                
                val = Float(maximumValue)! >= 1000 ? String(format: "%.1f", floor(Float(maximumValue)!)) :
                    String(format: "%.1f", Float(maximumValue)!)
            }
            
            lblT2Max.text = "MAX \(val)"
            //lblT2Max.text = "MAX \(String(format: "%.1f", Float(maximumValue)!))"
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
        
        isChangingTemp = true
        
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
        
       
        
        if MainCenteralManager.sharedInstance().data.cOrFOrK == "F" {
            
            viewProgress.isHidden = false
            activityIndicator.startAnimating()
            
            DispatchQueue.main.async(execute: {() -> Void in
              
                MainCenteralManager.sharedInstance().CommandF {
                    
                    MainCenteralManager.sharedInstance().CommandF {
                        
                        MainCenteralManager.sharedInstance().CommandA()
                        self.isChangingTemp = false
                      
                    }
                }
            })

        }else if MainCenteralManager.sharedInstance().data.cOrFOrK == "K" {
            
            viewProgress.isHidden = false
            activityIndicator.startAnimating()
            
            DispatchQueue.main.async(execute: {() -> Void in
                
                MainCenteralManager.sharedInstance().CommandF {
                    
                    MainCenteralManager.sharedInstance().CommandA()
                    self.isChangingTemp = false
                    
                    
                }
            })

        }

        //SetData()
    }
    @IBAction func btnFehrenheit_Tapped(_ sender: Any) {
        
        isChangingTemp = true
        
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
        
        if MainCenteralManager.sharedInstance().data.cOrFOrK == "K" {
            
            
            viewProgress.isHidden = false
            activityIndicator.startAnimating()
           
            DispatchQueue.main.async(execute: {() -> Void in
                
                MainCenteralManager.sharedInstance().CommandF {
                    
                    MainCenteralManager.sharedInstance().CommandF {
                        
                        MainCenteralManager.sharedInstance().CommandA()
                        self.isChangingTemp = false
                        
                    }
                }
            })
    
        }else if MainCenteralManager.sharedInstance().data.cOrFOrK == "C" {
            
            viewProgress.isHidden = false
            activityIndicator.startAnimating()
            
            DispatchQueue.main.async(execute: {() -> Void in
                
                MainCenteralManager.sharedInstance().CommandF {
                    
                    MainCenteralManager.sharedInstance().CommandA()
                    self.isChangingTemp = false
                   
                }
                
            })
           
        }

        //SetData()
        
    }
    @IBAction func btnKelvin_Tapped(_ sender: Any) {
        
        isChangingTemp = true
        
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
        
        if MainCenteralManager.sharedInstance().data.cOrFOrK == "C" {
            
            viewProgress.isHidden = false
            activityIndicator.startAnimating()
            
            DispatchQueue.main.async(execute: {() -> Void in
                
                MainCenteralManager.sharedInstance().CommandF {
                    
                    MainCenteralManager.sharedInstance().CommandF {
                        
                        MainCenteralManager.sharedInstance().CommandA()
                        self.isChangingTemp = false
                       
                    }
                }
                
            })
            
        }else if MainCenteralManager.sharedInstance().data.cOrFOrK == "F" {
            
            viewProgress.isHidden = false
            activityIndicator.startAnimating()
            
            DispatchQueue.main.async(execute: {() -> Void in
                
                MainCenteralManager.sharedInstance().CommandF {
                    
                    MainCenteralManager.sharedInstance().CommandA()
                    self.isChangingTemp = false
                   
                }
                
            })
 
        }

        //SetData()
    }
    
    @IBAction func btnWetBulb_Tapped(_ sender: Any) {
        
        if MainCenteralManager.sharedInstance().data.isWetBulb {
            
        }else if MainCenteralManager.sharedInstance().data.isDewPoint {

            DispatchQueue.main.async(execute: {() -> Void in
                
                MainCenteralManager.sharedInstance().CommandC()
                MainCenteralManager.sharedInstance().CommandC()
                MainCenteralManager.sharedInstance().CommandA()
            })
 
            
        }else{
      
            DispatchQueue.main.async(execute: {() -> Void in
                
                MainCenteralManager.sharedInstance().CommandC()
                MainCenteralManager.sharedInstance().CommandA()
            })
          
        }
        
        let notificationName = Notification.Name("settingDataNotification")
        NotificationCenter.default.post(name: notificationName, object: nil)
    }
    
    @IBAction func btnNormal_Tapped(_ sender: Any) {
        
        if MainCenteralManager.sharedInstance().data.isWetBulb {

            DispatchQueue.main.async(execute: {() -> Void in
                
                MainCenteralManager.sharedInstance().CommandC()
                MainCenteralManager.sharedInstance().CommandC()
                MainCenteralManager.sharedInstance().CommandA()
                
            })
   
            
        }else if MainCenteralManager.sharedInstance().data.isDewPoint {
  
            DispatchQueue.main.async(execute: {() -> Void in
                
                MainCenteralManager.sharedInstance().CommandC()
                MainCenteralManager.sharedInstance().CommandA()
            })
           
            
        }else{

        }
        
        let notificationName = Notification.Name("settingDataNotification")
        NotificationCenter.default.post(name: notificationName, object: nil)
    }
    @IBAction func btnDewBulb_Tapped(_ sender: Any) {
        
        if MainCenteralManager.sharedInstance().data.isWetBulb {

            
            DispatchQueue.main.async(execute: {() -> Void in
                
                MainCenteralManager.sharedInstance().CommandC()
                MainCenteralManager.sharedInstance().CommandA()
            })
            
        }else if MainCenteralManager.sharedInstance().data.isDewPoint {

        }else{
            
            DispatchQueue.main.async(execute: {() -> Void in
                
                MainCenteralManager.sharedInstance().CommandC()
                MainCenteralManager.sharedInstance().CommandC()
                MainCenteralManager.sharedInstance().CommandA()
            })
           
        }
        
        let notificationName = Notification.Name("settingDataNotification")
        NotificationCenter.default.post(name: notificationName, object: nil)
        
    }
    
    
    @IBAction func switched(_ sender:UISwitch){
        
    
       /*if isCelsius {
            
            lblMinMaxTemp.text = "Please enter value between -200 C to 1370 C."
            
        }else if isFahrenheit {
            
            lblMinMaxTemp.text = "Please enter value between -328 F to 2498 F."
            
        }else if isKelvin {
            
            lblMinMaxTemp.text = "Please enter value between 73.15 K to 1643.15 K."
        }
        
       */
        
        if sender.tag == 21{
            if sender.isOn{
                
                txtMaxTemp.placeholder = "Max RH"
                txtMinTemp.placeholder = "Min RH"
                lblAlarmViewTitle.text = "Set Alarm RH"
                lblMinMaxTemp.text = "Please enter value between 0 % to 100 %."
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
                lblRHAlarmStatus.isHidden = false
                
                SetData()
            }
        }
        else if sender.tag == 22{
            if sender.isOn{
                
                let minT1Temp = MainCenteralManager.sharedInstance().getT1MinValue(temperatureType: MainCenteralManager.sharedInstance().data.cOrFOrK)
                let maxT1Temp = MainCenteralManager.sharedInstance().getT1MaxValue(temperatureType: MainCenteralManager.sharedInstance().data.cOrFOrK)
                
                let temp = MainCenteralManager.sharedInstance().data.cOrFOrK
                if temp == "K" {
                    
                    lblMinMaxTemp.text = "Please enter value between " + String(minT1Temp) + " " + temp + " to " + String(maxT1Temp) + " " + temp + "."
                    
                }else{
                    
                    lblMinMaxTemp.text = "Please enter value between " + String(minT1Temp) + " °" + temp + " to " + String(maxT1Temp) + " °" + temp + "."
                }
                
                
                
                txtMaxTemp.placeholder = "Max Temp"
                txtMinTemp.placeholder = "Min Temp"
                lblAlarmViewTitle.text = "Set Alarm Temp T1"
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
                lblT1AlarmStatus.isHidden = false
                
                SetData()
            }
            
        }
        else if sender.tag == 23{
            if sender.isOn{
                
                let minT2Temp = MainCenteralManager.sharedInstance().getMinValue(temperatureType: MainCenteralManager.sharedInstance().data.cOrFOrK, deviceType: MainCenteralManager.sharedInstance().data.DeviceType)
                let maxT2Temp = MainCenteralManager.sharedInstance().getMaxValue(temperatureType: MainCenteralManager.sharedInstance().data.cOrFOrK, deviceType: MainCenteralManager.sharedInstance().data.DeviceType)
                
                let temp = MainCenteralManager.sharedInstance().data.cOrFOrK
                if temp == "K" {
                    
                    lblMinMaxTemp.text = "Please enter value between " + String(minT2Temp) + " " + temp + " to " + String(maxT2Temp) + " " + temp + "."
                    
                }else{
                    
                    lblMinMaxTemp.text = "Please enter value between " + String(minT2Temp) + " °" + temp + " to " + String(maxT2Temp) + " °" + temp + "."
                }
                
                
                txtMaxTemp.placeholder = "Max Temp"
                txtMinTemp.placeholder = "Min Temp"
                lblAlarmViewTitle.text = "Set Alarm Temp T2"
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
                lblT2AlarmStatus.isHidden = false
                
                SetData()
            }
            
        }
        
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
        
        let minTemp = txtMinTemp.text ?? ""
        let maxTemp = txtMaxTemp.text ?? ""
        
        if txtMinTemp.text == "" || Float(minTemp) == nil {
            showAlert(Appname, title: "Please fill minimum field")
        }
        else if txtMaxTemp.text == "" || Float(maxTemp) == nil {
            showAlert(Appname, title: "Please fill maximum field")
        }
        else{
            
            var minTemp:String = txtMinTemp.text!
            var maxTemp:String = txtMaxTemp.text!
            
            
            var alertMsg = ""
          
            
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
                    alertMsg = "Minimum value should be less than Maximun value."
                    showAlert(Appname, title: alertMsg)
                    return
                }
                else
                {
                    
                    //RHCount = 10
                    isRHAlarmActive = true
                    //RHTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateRHCount), userInfo: nil, repeats: true)
                    
                    USERDEFAULT.set(true, forKey: "isRH")
                    USERDEFAULT.synchronize()
                    
                    lblRHMax.isHidden = false
                    lblRHMin.isHidden = false
                    //lblRHAlarmStatus.isHidden = true
                    
                    lblRHMin.text = "MIN \(txtMinTemp.text!)"
                    lblRHMax.text = "MAX \(txtMaxTemp.text!)"
                    
                    switchRH.isOn = true
                    
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
                    
                    SetData()
                    viewAlarmTemp.removeFromSuperview()
                }
            }
            else{
                
                var maxRangeTemp : Float = 0
                var minRangeTemp : Float = 0
                
                if indexID == 22 {
                    
                    minRangeTemp = MainCenteralManager.sharedInstance().getT1MinValue(temperatureType: MainCenteralManager.sharedInstance().data.cOrFOrK)
                    maxRangeTemp = MainCenteralManager.sharedInstance().getT1MaxValue(temperatureType: MainCenteralManager.sharedInstance().data.cOrFOrK)
                    
                }else if indexID == 23 {
                    
                    minRangeTemp = MainCenteralManager.sharedInstance().getMinValue(temperatureType: MainCenteralManager.sharedInstance().data.cOrFOrK, deviceType: MainCenteralManager.sharedInstance().data.DeviceType)
                    maxRangeTemp = MainCenteralManager.sharedInstance().getMaxValue(temperatureType: MainCenteralManager.sharedInstance().data.cOrFOrK, deviceType: MainCenteralManager.sharedInstance().data.DeviceType)
                }
                
                let temp = MainCenteralManager.sharedInstance().data.cOrFOrK
                if temp == "K" {
                    
                    alertMsg = "Please enter value between " + String(minRangeTemp) + " " + temp + " to " + String(maxRangeTemp) + " " + temp + "."
                    
                }else{
                    
                    alertMsg = "Please enter value between " + String(minRangeTemp) + " °" + temp + " to " + String(maxRangeTemp) + " °" + temp + "."
                }
                
                //Please enter value between -200 C to 1370 C.
                if Float(minTemp)! < minRangeTemp {
                    showAlert(Appname, title: alertMsg)
                    return
                }
                else if Float(maxTemp)! > maxRangeTemp {
                    showAlert(Appname, title: alertMsg)
                    return
                }
                else if Float(minTemp)! > Float(maxTemp)! {
                    showAlert(Appname, title: "Minimum value should be less than Maximun value.")
                    return
                }
                else
                {
                    
                    if indexID == 22{
                        
                        //T1Count = 10
                        isT1AlarmActive = true
                        //T1Timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateT1Count), userInfo: nil, repeats: true)
                        
                        if isFahrenheit {
                            // Fahrenheit to Celsius
                            minTemp = String((Float(minTemp)! - 32) / 1.8)
                            maxTemp = String((Float(maxTemp)! - 32) / 1.8)
                        }else if isKelvin {
                            // Kelvin to Celsius
                            minTemp = String((Float(minTemp)! - 273.15))
                            maxTemp = String((Float(maxTemp)! - 273.15))
                            
                        }
                        
                        USERDEFAULT.set(true, forKey: "isT1")
                        USERDEFAULT.synchronize()
                        
                        lblT1Max.isHidden = false
                        lblT1Min.isHidden = false
                        //lblT1AlarmStatus.isHidden = true
                        
                        lblT1Min.text = "MIN \(txtMinTemp.text!)"
                        lblT1Max.text = "MAX \(txtMaxTemp.text!)"
                        
                        switchT1.isOn = true
                        
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
                        
                        //T2Count = 10
                        isT2AlarmActive = true
                        //T2Timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateT2Count), userInfo: nil, repeats: true)
                        
                        if isCelsius {
                            
                            //Celsius to Fahrenheit
                            minTemp = String((Float(minTemp)! * 1.8) + 32)
                            maxTemp = String((Float(maxTemp)! * 1.8) + 32)
                            
                        }else if isKelvin {
                            //Kelvin to Fahrenheit
                            minTemp = String((Float(minTemp)! * 1.8) - 459.67)
                            maxTemp = String((Float(maxTemp)! * 1.8) - 459.67)
                        }
                        
                        USERDEFAULT.set(true, forKey: "isT2")
                        USERDEFAULT.synchronize()
                        
                        lblT2Max.isHidden = false
                        lblT2Min.isHidden = false
                        //lblT2AlarmStatus.isHidden = true
                        
                        lblT2Min.text = "MIN \(txtMinTemp.text!)"
                        lblT2Max.text = "MAX \(txtMaxTemp.text!)"
                        
                        switchT2.isOn = true
                        
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
                    
                    SetData()
                    
                    viewAlarmTemp.removeFromSuperview()
                }
            }
            
        }
    }
  
    @objc func updateRHCount()  {
        
        if(RHCount > 0)
        {
            isRHAlarmActive = false
            RHCount -= 1
            
        } else {
            
            isRHAlarmActive = true
            RHTimer.invalidate()
        }
    }
    @objc func updateT1Count()  {
        
        if(T1Count > 0)
        {
            isT1AlarmActive = false
            T1Count -= 1
            
        } else {
            
            isT1AlarmActive = true
            T1Timer.invalidate()
        }
    }
    @objc func updateT2Count()  {
        
        if(T2Count > 0)
        {
            isT2AlarmActive = false
            T2Count -= 1
            
        } else {
            
            isT2AlarmActive = true
            T2Timer.invalidate()
        }
    }
    @IBAction func btnAlarmCancelClicked(_ sender:UIButton){
        if indexID == 21{
            USERDEFAULT.set(false, forKey: "isRH")
            USERDEFAULT.synchronize()
            switchRH.isOn = false
            
            lblRHMax.isHidden = true
            lblRHMin.isHidden = true
            lblRHAlarmStatus.isHidden = false
            
        }
        else if indexID == 22{
            USERDEFAULT.set(false, forKey: "isT1")
            USERDEFAULT.synchronize()
            switchT1.isOn = false
            
            lblT1Max.isHidden = true
            lblT1Min.isHidden = true
            lblT1AlarmStatus.isHidden = false
        }
        else if indexID == 23{
            USERDEFAULT.set(false, forKey: "isT2")
            USERDEFAULT.synchronize()
            switchT2.isOn = false
            
            lblT2Max.isHidden = true
            lblT2Min.isHidden = true
            lblT2AlarmStatus.isHidden = false
            
        }
        
        viewAlarmTemp.removeFromSuperview()
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
    
    if isRHAlarmActive {
        
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
                    
                    if RHIntValue! > minIntValue! {
                        isRHMinActive = true
                    }
                    if RHIntValue! < maxIntValue! {
                        isRHMaxActive = true
                    }
                    if RHIntValue! < minIntValue! {
                        
                        if isRHMinActive {
                            
                            if temperatureRHAlertBool == true {
                                
                                /*viewAlertOutRange = viewAlertOutRangeViewController(AlertMsg: "Alert value reached below", AlertTemperature: "RH : \(minVal!)",dataType: "RH")
                                 
                                 if self.view.isDescendant(of: viewAlertOutRange.view) {
                                 
                                 } else {
                                 
                                 self.present(viewAlertOutRange, animated: false, completion: nil)
                                 }*/
                                
                                isRHAlarmPlaying = true
                                self.addAlertOutOfRange(AlertMsg: "Alert value reached below", AlertTemperature: "RH : \(minVal!)",dataType: "RH")
                                temperatureRHAlertBool = false
                                print("Play sound")
                            }
                        }
                        
                    }
                    else if RHIntValue! > maxIntValue! {
                        
                        if isRHMaxActive {
                            
                            if temperatureRHAlertBool == true {
                                
                                /*viewAlertOutRange = viewAlertOutRangeViewController(AlertMsg: "Alert value reached above", AlertTemperature: "RH : \(maxVal!)",dataType: "RH")
                                 
                                 if self.view.isDescendant(of: viewAlertOutRange.view) {
                                 
                                 } else {
                                 
                                 self.present(viewAlertOutRange, animated: false, completion: nil)
                                 }*/
                                isRHAlarmPlaying = true
                                self.addAlertOutOfRange(AlertMsg: "Alert value reached above", AlertTemperature: "RH : \(maxVal!)",dataType: "RH")
                                temperatureRHAlertBool = false
                                print("Play sound")
                            }
                        }
                       
                    }
                    else{
                        
                        if !isRHAlarmPlaying {
                            
                            temperatureRHAlertBool = true
                            print("Stop Playing")
                        }
                        
                    }
                }
            }
        }
    }

    
    if isT1AlarmActive {
    
        
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
                
                let minIntValue = Float(minVal!)
                let maxIntValue = Float(maxVal!)
                let t1IntValue = Float(MainCenteralManager.sharedInstance().data.temperatureT1 as String)
                
                if t1IntValue != nil {
                    
                    if t1IntValue! > minIntValue! {
                        isT1MinActive = true
                    }
                    if t1IntValue! < maxIntValue! {
                        isT1MaxActive = true
                    }
                    
                    if t1IntValue! < minIntValue! {
                        
                        if isT1MinActive {
                         
                            if temperatureT1AlertBool == true {
                                
                                if isFahrenheit {
                                    
                                    minVal = celToFeh(degree: minVal!)
                                }else if isKelvin {
                                    
                                    minVal = celToKel(degree: minVal!)
                                }else{
                                    
                                    minVal = String(format:"%.1f",Float(minVal!)!)
                                }
                                
                                /*viewAlertOutRange = viewAlertOutRangeViewController(AlertMsg: "Alert value reached below", AlertTemperature: "T1 : \(minVal!)",dataType: "")
                                 
                                 if self.view.isDescendant(of: viewAlertOutRange.view) {
                                 
                                 } else {
                                 
                                 self.present(viewAlertOutRange, animated: false, completion: nil)
                                 }*/
                                
                                isT1AlarmPlaying = true
                                self.addAlertOutOfRangeT1(AlertMsg: "Alert value reached below", AlertTemperature: "T1 : \(minVal!)",dataType: "")
                                temperatureT1AlertBool = false
                                print("Play sound")
                            }
                        }
                    }
                    else if t1IntValue! > maxIntValue! {
                        
                        if isT1MaxActive {
                         
                            if temperatureT1AlertBool == true {
                                
                                if isFahrenheit {
                                    
                                    maxVal = celToFeh(degree: maxVal!)
                                }else if isKelvin {
                                    
                                    maxVal = celToKel(degree: maxVal!)
                                }else{
                                    
                                    maxVal = String(format:"%.1f",Float(maxVal!)!)
                                }
                                
                                /*viewAlertOutRange = viewAlertOutRangeViewController(AlertMsg: "Alert value reached above", AlertTemperature: "T1 : \(maxVal!)",dataType: "")
                                 
                                 if self.view.isDescendant(of: viewAlertOutRange.view) {
                                 
                                 } else {
                                 
                                 self.present(viewAlertOutRange, animated: false, completion: nil)
                                 }*/
                                
                                isT1AlarmPlaying = true
                                
                                self.addAlertOutOfRangeT1(AlertMsg: "Alert value reached above", AlertTemperature: "T1 : \(maxVal!)",dataType: "")
                                temperatureT1AlertBool = false
                                print("Play sound")
                            }
                        }
                    }
                    else{
                        if !isT1AlarmPlaying {
                            
                            temperatureT1AlertBool = true
                            print("Stop Playing")
                        }
                        
                    }
                }
            }
        }
    }
    
    if isT2AlarmActive {
     
        
        if let t2 = USERDEFAULT.value(forKey: "isT2") as? Bool{
            if  t2 == true{
                var minVal = (rangeData.object(at: 2) as AnyObject).value(forKey: "minValue") as? String
                var maxVal = (rangeData.object(at: 2) as AnyObject).value(forKey: "maxValue") as? String
                
                /* if isFahrenheit {
                 
                 minVal = String((Float(minVal!)! * 1.8) + 32)
                 maxVal = String((Float(maxVal!)! * 1.8) + 32)
                 }else if isKelvin {
                 
                 minVal = String(Float(minVal!)! + 273.15)
                 maxVal = String(Float(maxVal!)! + 273.15)
                 }else{
                 
                 minVal = String(format: "%.1f",  Float(minVal!)!)
                 maxVal = String(format: "%.1f",  Float(maxVal!)!)
                 
                 }*/
                
                let minIntValue = Float(minVal!)
                let maxIntValue = Float(maxVal!)
                
                let t2IntValue = Float(MainCenteralManager.sharedInstance().data.temperatureT2 as String)
                
                if t2IntValue != nil {
                    
                    if t2IntValue! > minIntValue! {
                        isT2MinActive = true
                    }
                    if t2IntValue! < maxIntValue! {
                        isT2MaxActive = true
                    }
                    
                    if t2IntValue! < minIntValue! {
                        
                        if isT2MinActive {
                          
                            if temperatureT2AlertBool == true {
                                
                                if isCelsius {
                                    
                                    minVal = FehToCel(degree: minVal!)
                                }else if isKelvin {
                                    
                                    minVal = FehToKel(degree: minVal!)
                                }else{
                                    
                                    minVal = String(format:"%.1f",Float(minVal!)!)
                                }
                                
                                /*viewAlertOutRange = viewAlertOutRangeViewController(AlertMsg: "Alert value reached below", AlertTemperature: "T2 : \(minVal!)",dataType: "")
                                 
                                 if self.view.isDescendant(of: viewAlertOutRange.view) {
                                 
                                 } else {
                                 self.present(viewAlertOutRange, animated: false, completion: nil)
                                 
                                 }*/
                                isT2MaxActive = true
                                isT2AlarmPlaying = true
                                
                                self.addAlertOutOfRangeT2(AlertMsg: "Alert value reached below", AlertTemperature: "T2 : \(minVal!)",dataType: "")
                                temperatureT2AlertBool = false
                                print("Play sound")
                            }
                        }
                        
                    }
                    else if t2IntValue! > maxIntValue! {
                        
                        if isT2MaxActive {
                         
                            if temperatureT2AlertBool == true {
                                
                                if isCelsius {
                                    
                                    maxVal = FehToCel(degree: maxVal!)
                                }else if isKelvin {
                                    
                                    maxVal = FehToKel(degree: maxVal!)
                                }else{
                                    
                                    maxVal = String(format:"%.1f",Float(maxVal!)!)
                                }
                                
                                /*viewAlertOutRange = viewAlertOutRangeViewController(AlertMsg: "Alert value reached above", AlertTemperature: "T2 : \(maxVal!)",dataType: "")
                                 
                                 if self.view.isDescendant(of: viewAlertOutRange.view) {
                                 
                                 } else {
                                 self.present(viewAlertOutRange, animated: false, completion: nil)
                                 
                                 }*/
                                
                                isT2AlarmPlaying = true
                                
                                self.addAlertOutOfRangeT2(AlertMsg: "Alert value reached above", AlertTemperature: "T2 : \(maxVal!)",dataType: "")
                                temperatureT2AlertBool = false
                                print("Play sound")
                            }
                        }
                    }
                    else{
                        
                        if !isT2AlarmPlaying {
                            
                            temperatureT2AlertBool = true
                            print("Stop Playing")
                        }
                        
                    }
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
    
    func addAlertOutOfRange(AlertMsg :String , AlertTemperature:String , dataType:String) {
        
        objAlertView = Bundle.main.loadNibNamed("AlertOutOfRangeView", owner: self, options: nil)?[0] as! AlertOutOfRangeView
        objAlertView.delegate = self   //AlertOutOfRangeViewDelegate
        objAlertView.frame = CGRect(x: 0, y: 0, width: ScreenSize.SCREEN_WIDTH, height: ScreenSize.SCREEN_HEIGHT)
        //self.view.addSubview(self.objAlertView)
        //objAlertView.isHidden = true
        objAlertView.lblAlertMsg.text = AlertMsg
        objAlertView.lblTemp.text = AlertTemperature + " %"
        self.view.layoutIfNeeded()
        objAlertView.playSound()
        
        
        arrViews.append(1)
        
        let index0 = arrViews.index(of: 1)
       
       
        if index0 == 0 {
            
            self.view.addSubview(self.objAlertView)
            
        }else if index0 == 1 {
            let value = arrViews[0]
            if value == 2 {
                
                self.view.insertSubview(objAlertView, belowSubview: objAlertViewT1)
            }else if value == 3 {
                self.view.insertSubview(objAlertView, belowSubview: objAlertViewT2)
            }
        }else if index0 == 2 {
            
            let value = arrViews[1]
            if value == 2 {
                
                self.view.insertSubview(objAlertView, belowSubview: objAlertViewT1)
            }else if value == 3 {
                self.view.insertSubview(objAlertView, belowSubview: objAlertViewT2)
            }
            
        }

    }
    
    func addAlertOutOfRangeT1(AlertMsg :String , AlertTemperature:String , dataType:String) {
        
        objAlertViewT1 = Bundle.main.loadNibNamed("AlertOutOfRangeViewT1", owner: self, options: nil)?[0] as! AlertOutOfRangeViewT1
        objAlertViewT1.delegate = self   //AlertOutOfRangeViewDelegate
        objAlertViewT1.frame = CGRect(x: 0, y: 0, width: ScreenSize.SCREEN_WIDTH, height: ScreenSize.SCREEN_HEIGHT)
        //self.view.addSubview(self.objAlertViewT1)
        //objAlertViewT1.isHidden = true
        objAlertViewT1.lblAlertMsg.text = AlertMsg
        objAlertViewT1.lblTemp.text = AlertTemperature  + " " + MainCenteralManager.sharedInstance().data.cOrFOrK
        self.view.layoutIfNeeded()
        objAlertViewT1.playSound()
        
        arrViews.append(2)
       
        let index1 = arrViews.index(of: 2)
        
        if index1 == 0 {
            
            self.view.addSubview(self.objAlertViewT1)
            
        }else if index1 == 1 {
            
            let value = arrViews[0]
            if value == 1 {
                
                self.view.insertSubview(objAlertViewT1, belowSubview: objAlertView)
            }else if value == 3 {
                self.view.insertSubview(objAlertViewT1, belowSubview: objAlertViewT2)
            }
        }else if index1 == 2 {
            
            let value = arrViews[1]
            if value == 1 {
                
                self.view.insertSubview(objAlertViewT1, belowSubview: objAlertView)
            }else if value == 3 {
                self.view.insertSubview(objAlertViewT1, belowSubview: objAlertViewT2)
            }
            
            
        }
    }
    
    func addAlertOutOfRangeT2(AlertMsg :String , AlertTemperature:String , dataType:String) {
        
        objAlertViewT2 = Bundle.main.loadNibNamed("AlertOutOfRangeViewT2", owner: self, options: nil)?[0] as! AlertOutOfRangeViewT2
        objAlertViewT2.delegate = self   //AlertOutOfRangeViewDelegate
        objAlertViewT2.frame = CGRect(x: 0, y: 0, width: ScreenSize.SCREEN_WIDTH, height: ScreenSize.SCREEN_HEIGHT)
        //self.view.addSubview(self.objAlertViewT2)
        //objAlertViewT2.isHidden = true
        objAlertViewT2.lblAlertMsg.text = AlertMsg
        objAlertViewT2.lblTemp.text = AlertTemperature  + " " + MainCenteralManager.sharedInstance().data.cOrFOrK
        self.view.layoutIfNeeded()
        objAlertViewT2.playSound()
        
        
        arrViews.append(3)
        
        let index2 = arrViews.index(of: 3)
        
        if index2 == 0 {
            
            self.view.addSubview(self.objAlertViewT2)
            
        }else if index2 == 1 {
            
            let value = arrViews[0]
            if value == 1 {
                
                self.view.insertSubview(objAlertViewT2, belowSubview: objAlertView)
            }else if value == 2 {
                self.view.insertSubview(objAlertViewT2, belowSubview: objAlertViewT1)
            }
        }else if index2 == 2 {
            
            let value = arrViews[1]
            if value == 1 {
                
                self.view.insertSubview(objAlertViewT2, belowSubview: objAlertView)
            }else if value == 2 {
                self.view.insertSubview(objAlertViewT2, belowSubview: objAlertViewT1)
            }
        }
        
    }
}

extension RealTImeReadingVC : AlertOutOfRangeViewDelegate {
    func btnOK_Tapped() {
    
        isRHAlarmPlaying = false
        arrViews.remove(at: 0)
        objAlertView.stopSound()
        //objAlertView.isHidden = true
        objAlertView.removeFromSuperview()
    }
}
extension RealTImeReadingVC : AlertOutOfRangeViewDelegateT1 {
    func btnOKT1_Tapped() {
        
        isT1AlarmPlaying = false
        arrViews.remove(at: 0)
        objAlertViewT1.stopSound()
        //objAlertViewT1.isHidden = true
        objAlertViewT1.removeFromSuperview()
    }
}
extension RealTImeReadingVC : AlertOutOfRangeViewDelegateT2 {
    func btnOKT2_Tapped() {
        
        isT2AlarmPlaying = false
        arrViews.remove(at: 0)
        objAlertViewT2.stopSound()
        //objAlertViewT2.isHidden = true
        objAlertViewT2.removeFromSuperview()
    }
}
extension RealTImeReadingVC : MainCenteralManagerDelegate{
  func ReceiveCommand(){
    self.CheckingTemperature()
    
    if !isSlidingStart && !isChangingTemp {
        
        self.viewProgress.isHidden = true
        self.activityIndicator.stopAnimating()
        
        self.SetData()
    }
  }
    
    func Disconnect() {
        let alert=UIAlertController(title: Appname, message: "Connection Lost", preferredStyle: UIAlertControllerStyle.alert);
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {(action:UIAlertAction) in
            self.exitApp()
        }));
        present(alert, animated: true, completion: nil);
    }
    
    func exitApp() {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                exit(0)
            }
        }
    }
}
