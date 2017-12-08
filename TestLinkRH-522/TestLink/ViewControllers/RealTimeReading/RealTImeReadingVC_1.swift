////
////  RealTImeReadingVC.swift
////  TestLink
////
////  Created by Pritesh Pethani on 24/01/17.
////  Copyright © 2017 Pritesh Pethani. All rights reserved.
////
//
//import UIKit
//import AVFoundation
//
//
//class RealTImeReadingVC_1: UIViewController, UITableViewDataSource, UITableViewDelegate, AVAudioPlayerDelegate, UITextFieldDelegate {
//  
//  var centralManager: CBCentralManager? = nil
//  var peripheral: CBPeripheral!
//  var btServices :[BTServiceInfo] = []
//  var lastString :NSString = ""
//  var savedCharacteristic : CBCharacteristic?
//  
//  @IBOutlet var textView :UITextView!
//  var currentBTServiceInfo :BTServiceInfo!
//  
//  //-------------------------
//  var temperature1:NSString = "--"
//  var temperature2:NSString = "--"
//  var temperature3:NSString = "--"
//  var temperature4:NSString = "--"
//  var tempType:NSString = "C"
//  
//  var isCommandACalled : Bool = true
//  var isCommandCCalled : Bool = true
//  
//  @IBOutlet var tableReading: UITableView!
//  @IBOutlet var viewAlarmTemp: UIView!
//  
//  @IBOutlet var viewAlertOutRange: UIView!
//  @IBOutlet var viewAlertMsg: UILabel!
//  @IBOutlet var viewAlertTemperature: UILabel!
//  
//  var temperature1AlertBool:Bool = true
//  var temperature2AlertBool:Bool = true
//  var temperature3AlertBool:Bool = true
//  var temperature4AlertBool:Bool = true
//  
//  //Switch
//  @IBOutlet var switchFah :UISwitch!
//  
//  var rangeData = NSMutableArray()
//  var rangeDict = NSMutableDictionary()
//  var indexID:Int!
//  
//  @IBOutlet var lblMinMaxTemp :UILabel!
//  @IBOutlet var lblType :UILabel!
//  @IBOutlet var txtMinTemp :UITextField!
//  @IBOutlet var txtMaxTemp :UITextField!
//  
//  @IBOutlet var fTemp :UILabel!
//  @IBOutlet var cTemp :UILabel!
//  
//  @IBOutlet var temperatureButton:UIButton!
//  
//  var player: AVAudioPlayer?
//  
//  var myQueue:DispatchQueue!
//  var myGroup:DispatchGroup!
//  
//  @IBOutlet var indicatorView : UIActivityIndicatorView!
//  var isChangeTemperaturing = false
//  override func viewDidLoad() {
//    super.viewDidLoad()
//    
//    myQueue = DispatchQueue(label: "com.allaboutswift.dispatchgroup", attributes: .concurrent, target: .main)
//    myGroup = DispatchGroup()
//    
//    
//    
//    fTemp.text = "\u{00B0}F"
//    cTemp.text = "\u{00B0}C"
//    //self.playSound()
//    
//    if peripheral != nil {
//      self.title = peripheral.name
//      peripheral.delegate = self
//      centralManager?.delegate = self
//      centralManager?.connect(peripheral, options: nil)
//      
//      if peripheral.state == CBPeripheralState.connected {
//        
//      }
//      
//      Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(self.btncommandA), userInfo: nil, repeats: false)
//    }
//    
//    if USERDEFAULT.value(forKey: "temperatureData") != nil
//    {
//      if let tempData = USERDEFAULT.value(forKey: "temperatureData") as? NSArray
//      {
//        rangeData = NSMutableArray(array: tempData)
//        tableReading.reloadData()
//      }
//      else{
//        rangeData = NSMutableArray()
//        
//        rangeDict.setValue("", forKey: "minValue")
//        rangeDict.setValue("", forKey: "maxValue")
//        rangeData.add(rangeDict)
//        
//        rangeDict.setValue("", forKey: "minValue")
//        rangeDict.setValue("", forKey: "maxValue")
//        rangeData.add(rangeDict)
//        
//        rangeDict.setValue("", forKey: "minValue")
//        rangeDict.setValue("", forKey: "maxValue")
//        rangeData.add(rangeDict)
//        
//        rangeDict.setValue("", forKey: "minValue")
//        rangeDict.setValue("", forKey: "maxValue")
//        rangeData.add(rangeDict)
//        
//        print("Range Data ", rangeData)
//      }
//    }
//    else{
//      rangeData = NSMutableArray()
//      
//      rangeDict.setValue("", forKey: "minValue")
//      rangeDict.setValue("", forKey: "maxValue")
//      rangeData.add(rangeDict)
//      
//      rangeDict.setValue("", forKey: "minValue")
//      rangeDict.setValue("", forKey: "maxValue")
//      rangeData.add(rangeDict)
//      
//      rangeDict.setValue("", forKey: "minValue")
//      rangeDict.setValue("", forKey: "maxValue")
//      rangeData.add(rangeDict)
//      
//      rangeDict.setValue("", forKey: "minValue")
//      rangeDict.setValue("", forKey: "maxValue")
//      rangeData.add(rangeDict)
//      
//      print("Range Data ", rangeData)
//      
//      USERDEFAULT.set(self.rangeData, forKey: "temperatureData")
//      USERDEFAULT.synchronize()
//    }
//    self.setFehData()
//    self.addTapGestureInOurView()
//    //self.playSound()
//  }
//  
//  
//  override func viewWillAppear(_ animated: Bool) {
//    
//    //設計值
//    self.ReadCharacteristicsValue()
//  }
//  
//  override func didReceiveMemoryWarning() {
//    super.didReceiveMemoryWarning()
//    // Dispose of any resources that can be recreated.
//  }
//  
//  override func viewDidDisappear(_ animated: Bool) {
//    super.viewDidDisappear(animated)
//    self.centralManager = nil
//    self.peripheral = nil
//  }
//  
//  // MARK: - UITableView Methods
//  
//  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
//    return 4
//  }
//  
//  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
//    
//    let identifier = "RTRCell"
//    
//    var cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? RealTimeReadingCell
//    
//    if cell == nil {
//      let nib  = Bundle.main.loadNibNamed("RealTimeReadingCell", owner: self, options: nil)
//      cell = nib?[0] as? RealTimeReadingCell
//    }
//    
//    var isFahrenheitSwitch:Bool = false
//    
//    if switchFah.isOn{
//      isFahrenheitSwitch = true
//      
//    }
//    else{
//      isFahrenheitSwitch = false
//    }
//    
//    if indexPath.row == 0 {
//      
//      cell?.name.text = "T1"
//      cell?.value.text = "\(self.temperature1 as String) \u{00B0} \(tempType)"
//      
//      if let minVal = (rangeData.object(at: 0) as AnyObject).value(forKey: "minValue") as? String{
//        var minimumValue = "\(minVal)"
//        
//        if minimumValue == ""{
//          cell?.lblMin.text = "MIN 00"
//        }
//        else{
//          if isFahrenheitSwitch {
//            minimumValue = String((Float(minimumValue)! * 1.8) + 32)
//          }
//          
//          cell?.lblMin.text = "MIN \(minimumValue)"
//        }
//      }
//      
//      if let maxVal = (rangeData.object(at: 0) as AnyObject).value(forKey: "maxValue") as? String{
//        var maximumValue = "\(maxVal)"
//        
//        if maximumValue == ""{
//          cell?.lblMax.text = "MAX 00"
//        }
//        else{
//          if isFahrenheitSwitch {
//            maximumValue = String((Float(maximumValue)! * 1.8) + 32)
//          }
//          cell?.lblMax.text = "MAX \(maximumValue)"
//        }
//      }
//      
//      if let t1 = USERDEFAULT.value(forKey: "isT1") as? Bool{
//        if  t1 == true{
//          USERDEFAULT.set(true, forKey: "isT1")
//          USERDEFAULT.synchronize()
//          cell?.switchReading.isOn = true
//          
//          cell?.lblMax.isHidden = false
//          cell?.lblMin.isHidden = false
//          cell?.lblStatus.text = "ALARM SET"
//        }
//        else{
//          USERDEFAULT.set(false, forKey: "isT1")
//          USERDEFAULT.synchronize()
//          cell?.switchReading.isOn = false
//          
//          cell?.lblMax.isHidden = true
//          cell?.lblMin.isHidden = true
//          cell?.lblStatus.text = "ALARM UNSET"
//        }
//        
//      }
//      else{
//        USERDEFAULT.set(false, forKey: "isT1")
//        USERDEFAULT.synchronize()
//        cell?.switchReading.isOn = false
//        
//        cell?.lblMax.isHidden = true
//        cell?.lblMin.isHidden = true
//        cell?.lblStatus.text = "ALARM UNSET"
//      }
//    }
//    else if indexPath.row == 1 {
//      cell?.name.text = "T2"
//      cell?.value.text = "\(self.temperature2 as String) \u{00B0} \(tempType)"
//      
//      if let minVal = (rangeData.object(at: 1) as AnyObject).value(forKey: "minValue") as? String{
//        var minimumValue = "\(minVal)"
//        
//        if minimumValue == ""{
//          cell?.lblMin.text = "MIN 00"
//        }
//        else{
//          if isFahrenheitSwitch {
//            minimumValue = String((Float(minimumValue)! * 1.8) + 32)
//          }
//          
//          cell?.lblMin.text = "MIN \(minimumValue)"
//        }
//      }
//      
//      if let maxVal = (rangeData.object(at: 1) as AnyObject).value(forKey: "maxValue") as? String{
//        var maximumValue = "\(maxVal)"
//        
//        if maximumValue == ""{
//          cell?.lblMax.text = "MAX 00"
//        }
//        else{
//          if isFahrenheitSwitch {
//            maximumValue = String((Float(maximumValue)! * 1.8) + 32)
//          }
//          cell?.lblMax.text = "MAX \(maximumValue)"
//        }
//      }
//      
//      if let t2 = USERDEFAULT.value(forKey: "isT2") as? Bool{
//        if  t2 == true{
//          USERDEFAULT.set(true, forKey: "isT2")
//          USERDEFAULT.synchronize()
//          cell?.switchReading.isOn = true
//          
//          cell?.lblMax.isHidden = false
//          cell?.lblMin.isHidden = false
//          cell?.lblStatus.text = "ALARM SET"
//          
//          
//        }
//        else{
//          USERDEFAULT.set(false, forKey: "isT2")
//          USERDEFAULT.synchronize()
//          cell?.switchReading.isOn = false
//          
//          cell?.lblMax.isHidden = true
//          cell?.lblMin.isHidden = true
//          cell?.lblStatus.text = "ALARM UNSET"
//        }
//        
//      }
//      else{
//        USERDEFAULT.set(false, forKey: "isT2")
//        USERDEFAULT.synchronize()
//        cell?.switchReading.isOn = false
//        
//        cell?.lblMax.isHidden = true
//        cell?.lblMin.isHidden = true
//        cell?.lblStatus.text = "ALARM UNSET"
//      }
//      
//      
//      
//    }
//    else if indexPath.row == 2 {
//      cell?.name.text = "T3"
//      cell?.value.text = "\(self.temperature3 as String) \u{00B0} \(tempType)"
//      
//      if let minVal = (rangeData.object(at: 2) as AnyObject).value(forKey: "minValue") as? String{
//        var minimumValue = "\(minVal)"
//        
//        if minimumValue == ""{
//          cell?.lblMin.text = "MIN 00"
//        }
//        else{
//          if isFahrenheitSwitch {
//            minimumValue = String((Float(minimumValue)! * 1.8) + 32)
//          }
//          cell?.lblMin.text = "MIN \(minimumValue)"
//        }
//      }
//      
//      if let maxVal = (rangeData.object(at: 2) as AnyObject).value(forKey: "maxValue") as? String{
//        var maximumValue = "\(maxVal)"
//        
//        if maximumValue == ""{
//          cell?.lblMax.text = "MAX 00"
//        }
//        else{
//          if isFahrenheitSwitch {
//            maximumValue = String((Float(maximumValue)! * 1.8) + 32)
//          }
//          cell?.lblMax.text = "MAX \(maximumValue)"
//        }
//      }
//      
//      
//      if let t3 = USERDEFAULT.value(forKey: "isT3") as? Bool{
//        if  t3 == true{
//          USERDEFAULT.set(true, forKey: "isT3")
//          USERDEFAULT.synchronize()
//          cell?.switchReading.isOn = true
//          
//          cell?.lblMax.isHidden = false
//          cell?.lblMin.isHidden = false
//          cell?.lblStatus.text = "ALARM SET"
//          
//          
//        }
//        else{
//          USERDEFAULT.set(false, forKey: "isT3")
//          USERDEFAULT.synchronize()
//          cell?.switchReading.isOn = false
//          cell?.lblMax.isHidden = true
//          cell?.lblMin.isHidden = true
//          cell?.lblStatus.text = "ALARM UNSET"
//          
//        }
//        
//      }
//      else{
//        USERDEFAULT.set(false, forKey: "isT3")
//        USERDEFAULT.synchronize()
//        cell?.switchReading.isOn = false
//        cell?.lblMax.isHidden = true
//        cell?.lblMin.isHidden = true
//        cell?.lblStatus.text = "ALARM UNSET"
//      }
//    }
//    else if indexPath.row == 3 {
//      cell?.name.text = "T4"
//      cell?.value.text = "\(self.temperature4 as String) \u{00B0} \(tempType)"
//      
//      if let minVal = (rangeData.object(at: 3) as AnyObject).value(forKey: "minValue") as? String{
//        var minimumValue = "\(minVal)"
//        
//        if minimumValue == ""{
//          cell?.lblMin.text = "MIN 00"
//        }
//        else{
//          if isFahrenheitSwitch {
//            minimumValue = String((Float(minimumValue)! * 1.8) + 32)
//          }
//          
//          cell?.lblMin.text = "MIN \(minimumValue)"
//        }
//      }
//      
//      if let maxVal = (rangeData.object(at: 3) as AnyObject).value(forKey: "maxValue") as? String{
//        var maximumValue = "\(maxVal)"
//        
//        if maximumValue == ""{
//          cell?.lblMax.text = "MAX 00"
//        }
//        else{
//          if isFahrenheitSwitch {
//            maximumValue = String((Float(maximumValue)! * 1.8) + 32)
//          }
//          cell?.lblMax.text = "MAX \(maximumValue)"
//        }
//      }
//      
//      if let t4 = USERDEFAULT.value(forKey: "isT4") as? Bool{
//        if  t4 == true{
//          USERDEFAULT.set(true, forKey: "isT4")
//          USERDEFAULT.synchronize()
//          cell?.switchReading.isOn = true
//          
//          cell?.lblMax.isHidden = false
//          cell?.lblMin.isHidden = false
//          cell?.lblStatus.text = "ALARM SET"
//        }
//        else{
//          USERDEFAULT.set(false, forKey: "isT4")
//          USERDEFAULT.synchronize()
//          cell?.switchReading.isOn = false
//          
//          cell?.lblMax.isHidden = true
//          cell?.lblMin.isHidden = true
//          cell?.lblStatus.text = "ALARM UNSET"
//        }
//        
//      }
//      else{
//        USERDEFAULT.set(false, forKey: "isT4")
//        USERDEFAULT.synchronize()
//        cell?.switchReading.isOn = false
//        
//        cell?.lblMax.isHidden = true
//        cell?.lblMin.isHidden = true
//        cell?.lblStatus.text = "ALARM UNSET"
//      }
//    }
//    
//    cell?.switchReading.tag = indexPath.row
//    cell?.switchReading.addTarget(self, action: #selector(self.switchedReadingChange(_:)), for: .valueChanged)
//    
//    return cell!
//  }
//  
//  // MARK: - UITextField Methods
//  
//  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//    return true
//  }
//  
//  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//    
//    if(string == "." ){
//      let countdots = (textField.text?.components(separatedBy: ".").count)! - 1
//      
//      if countdots > 0 && string == "."
//      {
//        return false
//      }
//    }
//    return true
//  }
//  
//  
//  // MARK: - Button Action Methods
//  
//  @IBAction func btnBackliked(_ sender: UIButton) {
//    _ = self.navigationController?.popViewController(animated: true)
//  }
//  
//  @IBAction func btnClockliked(_ sender: UIButton) {
//    self.view.addSubview(viewAlarmTemp)
//  }
//  
//  // MARK: - Other Methods
//  
//  func addTapGestureInOurView(){
//    let tapRecognizer:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.backgroundTap(_:)))
//    tapRecognizer.cancelsTouchesInView = false
//    self.view.addGestureRecognizer(tapRecognizer)
//  }
//  @IBAction func backgroundTap(_ sender:UITapGestureRecognizer){
//    
//    let point:CGPoint = sender.location(in: sender.view)
//    let viewTouched = view.hitTest(point, with: nil)
//    
//    if viewTouched!.isKind(of: UIButton.self){
//      
//    }
//    else{
//      self.view.endEditing(true)
//    }
//  }
//  
//  //    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//  //        viewAlarmTemp.removeFromSuperview()
//  //    }
//  
//  func setFehData() {
//    
//    if let isFah = USERDEFAULT.value(forKey: "isFahrenheit") as? Bool{
//      if  isFah == true{
//        USERDEFAULT.set(true, forKey: "isFahrenheit")
//        USERDEFAULT.synchronize()
//        switchFah.isOn = true
//        temperatureButton.setImage(UIImage.init(named: "on.png"), for: .normal)
//      }
//      else{
//        USERDEFAULT.set(false, forKey: "isFahrenheit")
//        USERDEFAULT.synchronize()
//        switchFah.isOn = false
//        temperatureButton.setImage(UIImage.init(named: "off.png"), for: .normal)
//      }
//    }
//    else{
//      USERDEFAULT.set(false, forKey: "isFahrenheit")
//      USERDEFAULT.synchronize()
//      switchFah.isOn = false
//      temperatureButton.setImage(UIImage.init(named: "off.png"), for: .normal)
//    }
//  }
//  
//  func playSound() {
//    
//    //merchant.m4a
//    let url = Bundle.main.url(forResource: "alarmsound", withExtension: "mp3")!
//    
//    do {
//      player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3)
//      //guard let player = player else { return }
//      
//      try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
//      try AVAudioSession.sharedInstance().setActive(true)
//      
//      player?.prepareToPlay()
//      player?.play()
//    } catch let error {
//      print(error.localizedDescription)
//    }
//    
//    
//    //let url = Bundle.main.url(forResource: "merchant", withExtension: "m4a")!
//    //
//    //        let url = Bundle.main.url(forResource: "alarmsound", withExtension: "mp3")!
//    //
//    //        do {
//    //            player = try AVAudioPlayer.init(contentsOf: url)
//    //            //player = try AVAudioPlayer(contentsOf: url)
//    //            //guard let player = player else { return }
//    //
//    //            player?.prepareToPlay()
//    //            player?.play()
//    //            player?.delegate = self
//    //            player?.numberOfLoops = 1
//    //            player?.rate = 2.0
//    //
//    //
//    //        } catch let error {
//    //            print(error.localizedDescription)
//    //        }
//    
//    
//  }
//  
//  func stopSound() {
//    
//    player?.stop()
//  }
//  
//  public func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?){
//    print("audioPlayerDecodeErrorDidOccur")
//  }
//  
//  public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool){
//    print("audioPlayerDidFinishPlaying")
//  }
//  
//  
//  func commandCallingMethod() {
//    
//  }
//  
//  
//  // MARK: - Button Action Methods
//  @IBAction func btncommandC(){
//    
//    //檢查裝置是否連線中
//    if !self.checkingStates() {
//      return
//    }
//    
//    isCommandCCalled = false
//    
//    //[  0x02 , 0x43 , 0x00 , 0x00 , 0x00 , 0x00 , 0x03 ]   C Command
//    //[  0x02 , 0x50 , 0x00 , 0x00 , 0x00 , 0x00 , 0x03 ]   P Command
//    let commandCbyte : [UInt8] = [  0x02 , 0x43 , 0x00 , 0x00 , 0x00 , 0x00 , 0x03 ]
//    let data2 = Data(bytes:commandCbyte)
//    
//    if self.btServices.count > 1 {
//      let charItems = self.btServices[1].characteristics
//      //            for characteristic in charItems {
//      //                peripheral.readValue(for: characteristic)
//      //
//      //                //设置 characteristic 的 notifying 属性 为 true ， 表示接受广播
//      //                peripheral.setNotifyValue(true, for: characteristic)
//      //            }
//      
//      
//      //for characteristic in self.currentBTServiceInfo.characteristics {
//      for characteristic in charItems {
//        if characteristic.properties.contains(CBCharacteristicProperties.writeWithoutResponse){
//          //设置为  写入有反馈
//          self.peripheral.writeValue(data2, for: characteristic, type: .withResponse)
//          //print("写入withoutResponse~")
//        }else{
//          print("写入不可用~")
//        }
//      }
//      
//      if(self.isChangeTemperaturing){
//         self.btncommandA()
//      }
//    }
//    
//    
//  }
//  
//  @IBAction func btncommandP(){
//    
//    //[  0x02 , 0x43 , 0x00 , 0x00 , 0x00 , 0x00 , 0x03 ]   C Command
//    //[  0x02 , 0x50 , 0x00 , 0x00 , 0x00 , 0x00 , 0x03 ]   P Command
//    let commandCbyte : [UInt8] = [  0x02 , 0x50 , 0x00 , 0x00 , 0x00 , 0x00 , 0x03 ]
//    let data2 = Data(bytes:commandCbyte)
//    
//    if self.btServices.count > 1 {
//      let charItems = self.btServices[1].characteristics
//      //            for characteristic in charItems {
//      //                peripheral.readValue(for: characteristic)
//      //
//      //                //设置 characteristic 的 notifying 属性 为 true ， 表示接受广播
//      //                peripheral.setNotifyValue(true, for: characteristic)
//      //            }
//      
//      //for characteristic in self.currentBTServiceInfo.characteristics {
//      for characteristic in charItems {
//        if characteristic.properties.contains(CBCharacteristicProperties.writeWithoutResponse){
//          //设置为  写入有反馈
//          self.peripheral.writeValue(data2, for: characteristic, type: .withResponse)
//          //print("写入withoutResponse~")
//        }else{
//          print("写入不可用~")
//        }
//      }
//    }
//  }
//  
//  @IBAction func btncommandRepeatP(){
//    
//    //[  0x02 , 0x43 , 0x00 , 0x00 , 0x00 , 0x00 , 0x03 ]   C Command
//    //[  0x02 , 0x50 , 0x00 , 0x00 , 0x00 , 0x00 , 0x03 ]   P Command
//    let commandCbyte : [UInt8] = [  0x02 , 0x70 , 0x00 , 0x00 , 0x00 , 0x00 , 0x03 ]
//    let data2 = Data(bytes:commandCbyte)
//    
//    if self.btServices.count > 1 {
//      let charItems = self.btServices[1].characteristics
//      //            for characteristic in charItems {
//      //                peripheral.readValue(for: characteristic)
//      //
//      //                //设置 characteristic 的 notifying 属性 为 true ， 表示接受广播
//      //                peripheral.setNotifyValue(true, for: characteristic)
//      //            }
//      
//      //for characteristic in self.currentBTServiceInfo.characteristics {
//      for characteristic in charItems {
//        if characteristic.properties.contains(CBCharacteristicProperties.writeWithoutResponse){
//          //设置为  写入有反馈
//          self.peripheral.writeValue(data2, for: characteristic, type: .withResponse)
//          //print("写入withoutResponse~")
//        }else{
//          print("写入不可用~")
//        }
//      }
//    }
//  }
//  
//  @IBAction func btncommandA(){
//    
//    if !isCommandCCalled {
//      print("isCommandCCalled")
//      return
//    }
//    
//    if !isCommandACalled {
//      print("isCommandACalled")
//      return
//    }
//    
//    if !self.checkingStates() {
//      print("checkingStates")
//      return
//    }
//    
//    isCommandACalled = false
//    
//    let commandAbyte : [UInt8] = [  0x02 , 0x41 , 0x00 , 0x00 , 0x00 , 0x00 , 0x03 ]
//    let data1 = Data(bytes:commandAbyte)
//    
//    if self.btServices.count > 1 {
//      let charItems = self.btServices[1].characteristics
//      //            for characteristic in charItems {
//      //                peripheral.readValue(for: characteristic)
//      //
//      //                //设置 characteristic 的 notifying 属性 为 true ， 表示接受广播
//      //                peripheral.setNotifyValue(true, for: characteristic)
//      //
//      //
//      //            }
//      
//      for characteristic in charItems {
//        self.viewController(characteristic: characteristic, value: data1)
//      }
//    }
//  }
//  
//  @IBAction func btncommandWrongCommand(){
//    let commandAbyte : [UInt8] = [  0x02 , 0x6e , 0x00 , 0x00 , 0x00 , 0x00 , 0x03 ]
//    let data1 = Data(bytes:commandAbyte)
//    
//    if self.btServices.count > 1 {
//      let charItems = self.btServices[1].characteristics
//      //            for characteristic in charItems {
//      //                peripheral.readValue(for: characteristic)
//      //
//      //                //设置 characteristic 的 notifying 属性 为 true ， 表示接受广播
//      //                peripheral.setNotifyValue(true, for: characteristic)
//      //
//      //            }
//      
//      for characteristic in charItems {
//        self.viewController(characteristic: characteristic, value: data1)
//      }
//    }
//  }
//  
//  @IBAction func buttonFahereinHeitChange(_ sender:UIButton){
//    
//    //myGroup.wait()
//    print("buttonFahereinHeitChange called.. myGroup.wait")
//    
//    
//    if sender.tag == 20{
//      if !self.switchFah.isOn{
//        USERDEFAULT.set(true, forKey: "isFahrenheit")
//        USERDEFAULT.synchronize()
//        //self.switchFah.isOn = true
//        //temperatureButton.setImage(UIImage.init(named: "on.png"), for: .normal)
//      }
//      else{
//        USERDEFAULT.set(false, forKey: "isFahrenheit")
//        USERDEFAULT.synchronize()
//        //self.switchFah.isOn = false
//        //temperatureButton.setImage(UIImage.init(named: "off.png"), for: .normal)
//      }
//    }
//    
//   
//      self.btncommandC()
//      self.indicatorView.startAnimating()
//      //清除資料
//      self.clearnData()
//      self.isChangeTemperaturing = true;
//    
//    
//
//    let notificationName = Notification.Name("settingDataNotification")
//    NotificationCenter.default.post(name: notificationName, object: nil)
//  }
//  
//  @IBAction func switchedFahereinHeitChange(_ sender:UISwitch){
//    
//    //polo
//    if sender.tag == 20{
//      if sender.isOn{
//        USERDEFAULT.set(true, forKey: "isFahrenheit")
//        USERDEFAULT.synchronize()
//        //temperatureButton.setImage(UIImage.init(named: "on.png"), for: .normal)
//      }
//      else{
//        USERDEFAULT.set(false, forKey: "isFahrenheit")
//        USERDEFAULT.synchronize()
//        //temperatureButton.setImage(UIImage.init(named: "off.png"), for: .normal)
//      }
//    }
//    
//
//      self.btncommandC()
//       self.indicatorView.startAnimating()
//      //清除資料
//      self.clearnData()
//      self.isChangeTemperaturing = true;
//      
//    
//   
//    
//    
//    let notificationName = Notification.Name("settingDataNotification")
//    NotificationCenter.default.post(name: notificationName, object: nil)
//  }
//  
//  @IBAction func switchedReadingChange(_ sender:UISwitch){
//    indexID = sender.tag
//    
//    let indexPath = IndexPath(row: sender.tag, section: 0)
//    let cell = tableReading.cellForRow(at: indexPath) as! RealTimeReadingCell
//    
//    if switchFah.isOn{
//      lblMinMaxTemp.text = "Please enter value between -328 F to 2498 F."
//    }
//    else{
//      lblMinMaxTemp.text = "Please enter value between -200 C to 1370 C."
//    }
//    
//    if sender.tag == 0{
//      if sender.isOn{
//        //                USERDEFAULT.set(true, forKey: "isT1")
//        //                USERDEFAULT.synchronize()
//        
//        cell.lblMax.isHidden = false
//        cell.lblMin.isHidden = false
//        cell.lblStatus.text = "ALARM SET"
//        
//        txtMinTemp.text = ""
//        txtMaxTemp.text = ""
//        
//        //                if let minVal = (rangeData.object(at: sender.tag) as AnyObject).value(forKey: "minValue") as? String{
//        //                    txtMinTemp.text = "\(minVal)"
//        //                }
//        //
//        //                if let maxVal = (rangeData.object(at: sender.tag) as AnyObject).value(forKey: "maxValue") as? String{
//        //                    txtMaxTemp.text = "\(maxVal)"
//        //                }
//        
//        self.view.addSubview(viewAlarmTemp)
//        
//      }
//      else{
//        USERDEFAULT.set(false, forKey: "isT1")
//        USERDEFAULT.synchronize()
//        
//        cell.lblMax.isHidden = true
//        cell.lblMin.isHidden = true
//        cell.lblStatus.text = "ALARM UNSET"
//      }
//      
//    }
//    else if sender.tag == 1{
//      if sender.isOn{
//        //                USERDEFAULT.set(true, forKey: "isT2")
//        //                USERDEFAULT.synchronize()
//        
//        cell.lblMax.isHidden = false
//        cell.lblMin.isHidden = false
//        cell.lblStatus.text = "ALARM SET"
//        
//        //                if let minVal = (rangeData.object(at: sender.tag) as AnyObject).value(forKey: "minValue") as? String{
//        //                    txtMinTemp.text = "\(minVal)"
//        //                }
//        //
//        //                if let maxVal = (rangeData.object(at: sender.tag) as AnyObject).value(forKey: "maxValue") as? String{
//        //                    txtMaxTemp.text = "\(maxVal)"
//        //                }
//        txtMinTemp.text = ""
//        txtMaxTemp.text = ""
//        self.view.addSubview(viewAlarmTemp)
//      }
//      else{
//        USERDEFAULT.set(false, forKey: "isT2")
//        USERDEFAULT.synchronize()
//        
//        cell.lblMax.isHidden = true
//        cell.lblMin.isHidden = true
//        cell.lblStatus.text = "ALARM UNSET"
//        
//      }
//    }
//    else if sender.tag == 2{
//      if sender.isOn{
//        //                USERDEFAULT.set(true, forKey: "isT3")
//        //                USERDEFAULT.synchronize()
//        
//        cell.lblMax.isHidden = false
//        cell.lblMin.isHidden = false
//        cell.lblStatus.text = "ALARM SET"
//        
//        //                if let minVal = (rangeData.object(at: sender.tag) as AnyObject).value(forKey: "minValue") as? String{
//        //                    txtMinTemp.text = "\(minVal)"
//        //                }
//        //
//        //                if let maxVal = (rangeData.object(at: sender.tag) as AnyObject).value(forKey: "maxValue") as? String{
//        //                    txtMaxTemp.text = "\(maxVal)"
//        //                }
//        txtMinTemp.text = ""
//        txtMaxTemp.text = ""
//        
//        self.view.addSubview(viewAlarmTemp)
//      }
//      else{
//        USERDEFAULT.set(false, forKey: "isT3")
//        USERDEFAULT.synchronize()
//        
//        cell.lblMax.isHidden = true
//        cell.lblMin.isHidden = true
//        cell.lblStatus.text = "ALARM UNSET"
//        
//      }
//      
//    }
//    else if sender.tag == 3{
//      if sender.isOn{
//        //                USERDEFAULT.set(true, forKey: "isT4")
//        //                USERDEFAULT.synchronize()
//        
//        cell.lblMax.isHidden = false
//        cell.lblMin.isHidden = false
//        cell.lblStatus.text = "ALARM SET"
//        
//        //                if let minVal = (rangeData.object(at: sender.tag) as AnyObject).value(forKey: "minValue") as? String{
//        //                    txtMinTemp.text = "\(minVal)"
//        //                }
//        //
//        //                if let maxVal = (rangeData.object(at: sender.tag) as AnyObject).value(forKey: "maxValue") as? String{
//        //                    txtMaxTemp.text = "\(maxVal)"
//        //                }
//        txtMinTemp.text = ""
//        txtMaxTemp.text = ""
//        self.view.addSubview(viewAlarmTemp)
//      }
//      else{
//        USERDEFAULT.set(false, forKey: "isT4")
//        USERDEFAULT.synchronize()
//        
//        cell.lblMax.isHidden = true
//        cell.lblMin.isHidden = true
//        cell.lblStatus.text = "ALARM UNSET"
//        
//      }
//    }
//    
//    let notificationName = Notification.Name("settingDataNotification")
//    NotificationCenter.default.post(name: notificationName, object: nil)
//  }
//  
//  @IBAction func btnAlarmSetClicked(_ sender:UIButton){
//    
//    if USERDEFAULT.value(forKey: "temperatureData") != nil{
//      if let tempData = USERDEFAULT.value(forKey: "temperatureData") as? NSArray
//      {
//        rangeData = NSMutableArray(array: tempData)
//      }
//    }
//    
//    if txtMinTemp.text == "" {
//      showAlert(Appname, title: "Please fill minimum field")
//    }
//    else if txtMaxTemp.text == ""{
//      showAlert(Appname, title: "Please fill maximum field")
//    }
//    else{
//      
//      let indexPath = IndexPath(row: indexID, section: 0)
//      let cell = tableReading.cellForRow(at: indexPath) as! RealTimeReadingCell
//      
//      cell.lblMax.isHidden = false
//      cell.lblMin.isHidden = false
//      cell.lblStatus.text = "ALARM SET"
//      cell.switchReading.isOn = true
//      
//      if indexID == 0{
//        USERDEFAULT.set(true, forKey: "isT1")
//        USERDEFAULT.synchronize()
//      }
//      else if indexID == 1{
//        USERDEFAULT.set(true, forKey: "isT2")
//        USERDEFAULT.synchronize()
//      }
//      else if indexID == 2{
//        USERDEFAULT.set(true, forKey: "isT3")
//        USERDEFAULT.synchronize()
//        
//      }
//      else if indexID == 3{
//        USERDEFAULT.set(true, forKey: "isT4")
//        USERDEFAULT.synchronize()
//        
//      }
//      
//      //let notificationName = Notification.Name("settingDataNotification")
//      //NotificationCenter.default.post(name: notificationName, object: nil)
//      
//      var minTemp:String = txtMinTemp.text!
//      var maxTemp:String = txtMaxTemp.text!
//      
//      var isFahrenheitSwitch:Bool = false
//      
//      if switchFah.isOn{
//        isFahrenheitSwitch = true
//      }
//      else{
//        isFahrenheitSwitch = false
//      }
//      
//      //Please enter value between -200 C to 1370 C.
//      if Float(minTemp)! < -200 {
//        showAlert(Appname, title: "Please enter value between -200 C to 1370 C.")
//      }
//      else if Float(maxTemp)! > 1370 {
//        showAlert(Appname, title: "Please enter value between -200 C to 1370 C.")
//      }
//      else if Float(minTemp)! > Float(maxTemp)! {
//        showAlert(Appname, title: "Minimum value is not more then maximum value.")
//      }
//      else{
//        if isFahrenheitSwitch {
//          minTemp = String((Float(minTemp)! - 32) / 1.8)
//          maxTemp = String((Float(maxTemp)! - 32) / 1.8)
//        }
//        
//        let temp = (self.rangeData[self.indexID] as! NSDictionary).mutableCopy() as! NSMutableDictionary
//        print("Before Upadate Value : ",temp)
//        temp.setValue(minTemp, forKey: "minValue")
//        temp.setValue(maxTemp, forKey: "maxValue")
//        print("After update Value : ",temp)
//        if (self.rangeData.count > self.indexID) {
//          self.rangeData.replaceObject(at: self.indexID, with: temp)
//          let indexPath = NSIndexPath(row: self.indexID, section: 0) as NSIndexPath
//          self.tableReading.reloadRows(at: [indexPath as IndexPath], with: .none)
//        }
//        viewAlarmTemp.removeFromSuperview()
//      }
//      
//      USERDEFAULT.set(self.rangeData, forKey: "temperatureData")
//      USERDEFAULT.synchronize()
//      
//      let notificationName = Notification.Name("settingDataNotification")
//      NotificationCenter.default.post(name: notificationName, object: nil)
//    }
//  }
//  
//  @IBAction func btnAlarmCancelClicked(_ sender:UIButton){
//    let indexPath = IndexPath(row: indexID, section: 0)
//    let cell = tableReading.cellForRow(at: indexPath) as! RealTimeReadingCell
//    
//    cell.lblMax.isHidden = true
//    cell.lblMin.isHidden = true
//    cell.lblStatus.text = "ALARM UNSET"
//    cell.switchReading.isOn = false
//    
//    if indexID == 0{
//      USERDEFAULT.set(false, forKey: "isT1")
//      USERDEFAULT.synchronize()
//    }
//    else if indexID == 1{
//      USERDEFAULT.set(false, forKey: "isT2")
//      USERDEFAULT.synchronize()
//      
//    }
//    else if indexID == 2{
//      USERDEFAULT.set(false, forKey: "isT3")
//      USERDEFAULT.synchronize()
//      
//    }
//    else if indexID == 3{
//      USERDEFAULT.set(false, forKey: "isT4")
//      USERDEFAULT.synchronize()
//    }
//    
//    viewAlarmTemp.removeFromSuperview()
//    
//    let notificationName = Notification.Name("settingDataNotification")
//    NotificationCenter.default.post(name: notificationName, object: nil)
//    
//    
//  }
//  
//  @IBAction func btnCloseTemperatureAlert(_ sender:UIButton){
//    viewAlertOutRange.removeFromSuperview()
//    self.stopSound()
//  }
//  
//  // MARK: - Other Methods
//  
//  func getFahrenheit(x1:UInt8 , x2:UInt8) -> String {
//    let x1_16 =  String(format:"%02X", x1)
//    let x2_16 =  String(format:"%02X", x2)
//    let x3 = x1_16 + x2_16
//    return String(Float(UInt(x3, radix: 16)!) / 10)
//  }
//  
//  func converToBinary(x1:UInt8) -> [String] {
//    var str = String(x1, radix: 2)
//    while str.characters.count % 8 != 0 {
//      str = "0" + str
//    }
//    return str.characters.map { String($0) }
//  }
//  
//  func getCelsius(x1:UInt8 , x2:UInt8) -> String {
//    let fahrenheit = self.getFahrenheit(x1: x1, x2: x2)
//    return String(format:"%.1f",Float(5.0 / 9.0 * (Double(fahrenheit)! - 32.0)))
//  }
//  
//  
//  func clearnData() {
//    
//    temperature1 = "--"
//    
//    
//    
//    temperature2 = "--"
//    
//    
//    
//    temperature3 = "--"
//    
//    
//    
//    temperature4 = "--"
//    
//    
//    tableReading.reloadData()
//    
//  }
//  
//  
//  func setTextForTemperatures (t1:String , t2:String, t3:String , t4:String, temperatureType:UInt8) {
//    temperature1 = t1 as NSString
//    temperature2 = t2 as NSString
//    temperature3 = t3 as NSString
//    temperature4 = t4 as NSString
//    
//    
//    if Float(temperature1 as String)! > MaxTempValue {
//      temperature1 = "--"
//    }
//    
//    if Float(temperature2 as String)! > MaxTempValue {
//      temperature2 = "--"
//    }
//    
//    if Float(temperature3 as String)! > MaxTempValue {
//      temperature3 = "--"
//    }
//    
//    if Float(temperature4 as String)! > MaxTempValue {
//      temperature4 = "--"
//    }
//    
//    tableReading.reloadData()
//    
//    
//    
//    let myString : [String] = self.converToBinary(x1: temperatureType)
//    print("myString", myString)
//    print("myString[0]", myString[0])
//    
//    
//    if myString.count > 0 {
//      
//      if myString[0] == "0" {
//        print("Feranhit")
//        switchFah.setOn(true, animated: true)
//        temperatureButton.setImage(UIImage.init(named: "on.png"), for: .normal)
//        USERDEFAULT.set(true, forKey: "isFahrenheit")
//        USERDEFAULT.synchronize()
//      }
//      else if myString[0] == "1" {
//        print("celcius")
//        temperatureButton.setImage(UIImage.init(named: "off.png"), for: .normal)
//        switchFah.setOn(false, animated: true)
//        USERDEFAULT.set(false, forKey: "isFahrenheit")
//        USERDEFAULT.synchronize()
//      }
//      else {
//        print("else")
//      }
//    }
//    
//    //        if sender.isOn{
//    //            USERDEFAULT.set(true, forKey: "isFahrenheit")
//    //            USERDEFAULT.synchronize()
//    //
//    //        }
//    //        else{
//    //            USERDEFAULT.set(false, forKey: "isFahrenheit")
//    //            USERDEFAULT.synchronize()
//    //        }
//    
//    self.checkingTemperatureValueBetweenMaxAndMin()
//    
//    isCommandACalled = true
//    
//    //self.btncommandA()
//    
//    Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(self.btncommandA), userInfo: nil, repeats: false)
//    
//    myGroup.enter()
//    myQueue.async (group: myGroup) {
//      print("doing stuff again")
//      self.btncommandA()
//      //self.myGroup.leave()
//    }
//    
//    //        DispatchQueue.main.async {
//    //            self.btncommandA()
//    //
//    ////            while (self.isCommandCCalled == true) {
//    ////                sleep(5)
//    ////            }
//    //        }
//  }
//  
//  func checkingStates () -> Bool {
//    
//    if peripheral == nil {
//      return false
//    }
//    
//    if peripheral.state == CBPeripheralState.connected {
//      print("connected")
//    }
//    else if peripheral.state == CBPeripheralState.connecting {
//      print("connecting")
//      return false
//    }
//    else if peripheral.state == CBPeripheralState.disconnected {
//      
//      //APPDELEGATE.window.makeToast("BT Device is disconnected")
//      print("disconnected")
//      
//      return false
//    }
//    
//    return true
//  }
//  
//  func checkingTemperatureValueBetweenMaxAndMin () {
//    
//    var isFahrenheitSwitch:Bool = false
//    
//    if switchFah.isOn{
//      isFahrenheitSwitch = true
//    }
//    else{
//      isFahrenheitSwitch = false
//      
//    }
//    
//    if let t1 = USERDEFAULT.value(forKey: "isT1") as? Bool{
//      
//      
//      
//      if  t1 == true{
//        var minVal = (rangeData.object(at: 0) as AnyObject).value(forKey: "minValue") as? String
//        var maxVal = (rangeData.object(at: 0) as AnyObject).value(forKey: "maxValue") as? String
//        
//        if isFahrenheitSwitch {
//          minVal = String((Float(minVal!)! * 1.8) + 32)
//          maxVal = String((Float(maxVal!)! * 1.8) + 32)
//        }
//        
//        let minIntValue = Float(minVal!)
//        let maxIntValue = Float(maxVal!)
//        print(temperature1)
//        let t1IntValue = Float(temperature1 as String)
//        
//        if t1IntValue != nil {
//          
//          if t1IntValue! < minIntValue! {
//            if temperature1AlertBool == true {
//              viewAlertMsg.text = "Alert value reached below"
//              viewAlertTemperature.text = "T1 : \(minVal!)"
//              if self.view.isDescendant(of: viewAlertOutRange) {
//                
//              } else {
//                self.view.addSubview(viewAlertOutRange)
//                self.playSound()
//              }
//              temperature1AlertBool = false
//              print("Play sound")
//            }
//          }
//          else if t1IntValue! > maxIntValue! {
//            if temperature1AlertBool == true {
//              viewAlertMsg.text = "Alert value reached above"
//              viewAlertTemperature.text = "T1 : \(maxVal!)"
//              if self.view.isDescendant(of: viewAlertOutRange) {
//                
//              } else {
//                self.view.addSubview(viewAlertOutRange)
//                self.playSound()
//              }
//              temperature1AlertBool = false
//              print("Play sound")
//            }
//          }
//          else{
//            temperature1AlertBool = true
//            print("Stop Playing")
//          }
//        }
//      }
//    }
//    
//    if let t1 = USERDEFAULT.value(forKey: "isT2") as? Bool{
//      if  t1 == true{
//        var minVal = (rangeData.object(at: 1) as AnyObject).value(forKey: "minValue") as? String
//        var maxVal = (rangeData.object(at: 1) as AnyObject).value(forKey: "maxValue") as? String
//        
//        if isFahrenheitSwitch {
//          minVal = String((Float(minVal!)! * 1.8) + 32)
//          maxVal = String((Float(maxVal!)! * 1.8) + 32)
//        }
//        
//        let minIntValue = Float(minVal!)
//        let maxIntValue = Float(maxVal!)
//        print(temperature1)
//        let t1IntValue = Float(temperature2 as String)
//        
//        if t1IntValue != nil {
//          if t1IntValue! < minIntValue! {
//            if temperature2AlertBool == true {
//              viewAlertMsg.text = "Alert value reached below"
//              viewAlertTemperature.text = "T2 : \(minVal!)"
//              if self.view.isDescendant(of: viewAlertOutRange) {
//                
//              } else {
//                self.view.addSubview(viewAlertOutRange)
//                self.playSound()
//              }
//              temperature2AlertBool = false
//              print("Play sound")
//            }
//          }
//          else if t1IntValue! > maxIntValue! {
//            if temperature2AlertBool == true {
//              viewAlertMsg.text = "Alert value reached above"
//              viewAlertTemperature.text = "T2 : \(maxVal!)"
//              if self.view.isDescendant(of: viewAlertOutRange) {
//                
//              } else {
//                self.view.addSubview(viewAlertOutRange)
//                self.playSound()
//              }
//              temperature2AlertBool = false
//              print("Play sound")
//            }
//          }
//          else{
//            temperature2AlertBool = true
//            print("Stop Playing")
//          }
//        }
//      }
//    }
//    
//    if let t1 = USERDEFAULT.value(forKey: "isT3") as? Bool{
//      if  t1 == true{
//        var minVal = (rangeData.object(at: 2) as AnyObject).value(forKey: "minValue") as? String
//        var maxVal = (rangeData.object(at: 2) as AnyObject).value(forKey: "maxValue") as? String
//        
//        if isFahrenheitSwitch {
//          minVal = String((Float(minVal!)! * 1.8) + 32)
//          maxVal = String((Float(maxVal!)! * 1.8) + 32)
//        }
//        
//        let minIntValue = Float(minVal!)
//        let maxIntValue = Float(maxVal!)
//        print(temperature1)
//        let t1IntValue = Float(temperature3 as String)
//        
//        if t1IntValue != nil {
//          if t1IntValue! < minIntValue! {
//            if temperature3AlertBool == true {
//              viewAlertMsg.text = "Alert value reached below"
//              viewAlertTemperature.text = "T3 : \(minVal!)"
//              if self.view.isDescendant(of: viewAlertOutRange) {
//                
//              } else {
//                self.view.addSubview(viewAlertOutRange)
//                self.playSound()
//              }
//              temperature3AlertBool = false
//              print("Play sound")
//            }
//          }
//          else if t1IntValue! > maxIntValue! {
//            if temperature3AlertBool == true {
//              viewAlertMsg.text = "Alert value reached above"
//              viewAlertTemperature.text = "T3 : \(maxVal!)"
//              if self.view.isDescendant(of: viewAlertOutRange) {
//                
//              } else {
//                self.view.addSubview(viewAlertOutRange)
//                self.playSound()
//              }
//              temperature3AlertBool = false
//            }
//            
//            print("Play sound")
//          }
//          else{
//            temperature3AlertBool = true
//            print("Stop Playing")
//          }
//        }
//      }
//    }
//    
//    if let t1 = USERDEFAULT.value(forKey: "isT4") as? Bool{
//      if  t1 == true{
//        var minVal = (rangeData.object(at: 3) as AnyObject).value(forKey: "minValue") as? String
//        var maxVal = (rangeData.object(at: 3) as AnyObject).value(forKey: "maxValue") as? String
//        
//        if isFahrenheitSwitch {
//          minVal = String((Float(minVal!)! * 1.8) + 32)
//          maxVal = String((Float(maxVal!)! * 1.8) + 32)
//        }
//        
//        let minIntValue = Float(minVal!)
//        let maxIntValue = Float(maxVal!)
//        print(temperature1)
//        let t1IntValue = Float(temperature4 as String)
//        
//        if t1IntValue != nil {
//          if t1IntValue! < minIntValue! {
//            if temperature4AlertBool == true {
//              viewAlertMsg.text = "Alert value reached below"
//              viewAlertTemperature.text = "T4 : \(minVal!)"
//              if self.view.isDescendant(of: viewAlertOutRange) {
//                
//              } else {
//                self.view.addSubview(viewAlertOutRange)
//                self.playSound()
//              }
//              
//              temperature4AlertBool = false
//              print("Play sound")
//            }
//          }
//          else if t1IntValue! > maxIntValue! {
//            if temperature4AlertBool == true {
//              viewAlertMsg.text = "Alert value reached above"
//              viewAlertTemperature.text = "T4 : \(maxVal!)"
//              if self.view.isDescendant(of: viewAlertOutRange) {
//                
//              } else {
//                self.view.addSubview(viewAlertOutRange)
//                self.playSound()
//              }
//              
//              temperature4AlertBool = false
//              print("Play sound")
//            }
//          }
//          else{
//            temperature4AlertBool = true
//            print("Stop Playing")
//          }
//        }
//      }
//    }
//  }
//  
//  
//  
//  private func ReadCharacteristicsValue(){
//    if self.btServices.count > 1 {
//      let charItems = self.btServices[1].characteristics
//      for characteristic in charItems {
//        peripheral.readValue(for: characteristic)
//        
//        //设置 characteristic 的 notifying 属性 为 true ， 表示接受广播
//        peripheral.setNotifyValue(true, for: characteristic)
//      }
//    }
//  }
//  
//  
//  private func SetType(){
//    
//  }
//  
//  
//}
//
//
//
//extension RealTImeReadingVC : CBCentralManagerDelegate{
//  
//  
//  func centralManagerDidUpdateState(_ central: CBCentralManager) {
//    
//  }
//  
//  
//  // MARK: - CBCentralManager Methods
//  
//  func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
//    if peripheral.state == CBPeripheralState.connected {
//      //bbConnect.text = "Connected"
//      peripheral.discoverServices(nil)
//    }
//  }
//  
//  
//  
//  //    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
//  //
//  //        print("NAME:" + peripheral.name! )
//  //        print("RSSI:" + RSSI.description )
//  //
//  //        if (peripheral.state == CBPeripheralState.connected){
//  //            print("isConnected: connected")
//  //        }else{
//  //            print("isConnected: disconnected")
//  //        }
//  //
//  //        print("advertisementData:" + advertisementData.description)
//  //
//  //
//  ////        if (peripheral.services != nil ){
//  ////
//  ////        }
//  //
//  //    }
//  
//  func viewController(characteristic: CBCharacteristic,value : Data ) -> () {
//    
//    //只有 characteristic.properties 有write的权限才可以写入
//    if characteristic.properties.contains(CBCharacteristicProperties.write){
//      //设置为  写入有反馈
//      self.peripheral.writeValue(value, for: characteristic, type: .withResponse)
//      
//    }else{
//      print("写入不可用~")
//    }
//  }
//  
//  
//  
//}
//
//extension RealTImeReadingVC : CBPeripheralDelegate{
//  
//  func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
//    for serviceObj in peripheral.services! {
//      let service:CBService = serviceObj
//      let isServiceIncluded = self.btServices.filter({ (item: BTServiceInfo) -> Bool in
//        return item.service.uuid == service.uuid
//      }).count
//      if isServiceIncluded == 0 {
//        btServices.append(BTServiceInfo(service: service, characteristics: []))
//      }
//      peripheral.discoverCharacteristics(nil, for: service)
//    }
//  }
//  
//  
//  
//  func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
//    let serviceCharacteristics = service.characteristics
//    for item in btServices {
//      if item.service.uuid == service.uuid {
//        item.characteristics = serviceCharacteristics!
//        let charitem = serviceCharacteristics?.first
//        self.peripheral.setNotifyValue(true, for: charitem!)
//        break
//      }
//    }
//    //self.tableView.reloadData()
//  }
//  
//  
//  
//  func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
//    
//    
//    if error != nil{
//      print("写入 characteristics 时 \(peripheral.name) 报错 \(error?.localizedDescription)")
//      return
//    }
//    
//  }
//  
//  func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
//    
//    if (characteristic.value != nil){
//      let resultStr = NSString(data: characteristic.value!, encoding: String.Encoding.utf8.rawValue)
//      
//      print("characteristic uuid:\(characteristic.uuid)   value:\(resultStr)")
//      
//      if let value = characteristic.value{
//        let log = "read: \(value)"
//        print(log)
//        
//        guard value.count == 64 else {
//          
//          if value.count == 32 {
//            isCommandCCalled = true
//            self.myGroup.resume()
//            print("buttonFahereinHeitChange called.. myGroup.resume")
//            
//            if (self.isChangeTemperaturing){
//              Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.btncommandA), userInfo: nil, repeats: false)
//            }
//          }
//          
//          return
//        }
//        
//        let byteArray = [UInt8](value)
//        print(byteArray)
//        
//        if (characteristic.uuid.description == "49535343-1E4D-4BD9-BA61-23C647249616"){
//          //var text = ""
//          let byte3 = self.converToBinary(x1: byteArray[2])
//          
//          if (self.isChangeTemperaturing){
//            //改變溫度中
//            if ((self.tempType == "F" && byte3[0] == "1") || (self.tempType == "C" && byte3[0] != "1")){
//              //改變成功
//              self.indicatorView.stopAnimating()
//              
//            }else{
//              self.btncommandA()
//              return
//            }
//          }
//          if (byte3[0] == "1"){
//            
//            self.tempType = "C"
//            self.setTextForTemperatures(t1: self.getCelsius(x1: byteArray[9], x2: byteArray[10]), t2: self.getCelsius(x1: byteArray[11], x2: byteArray[12]), t3: self.getCelsius(x1: byteArray[13], x2: byteArray[14]), t4: self.getCelsius(x1: byteArray[15], x2: byteArray[16]), temperatureType: byteArray[2])
//          }else{
//            self.tempType = "F"
//            self.setTextForTemperatures(t1: self.getFahrenheit(x1: byteArray[9], x2: byteArray[10]), t2: self.getFahrenheit(x1: byteArray[11], x2: byteArray[12]), t3: self.getFahrenheit(x1: byteArray[13], x2: byteArray[14]), t4: self.getFahrenheit(x1: byteArray[15], x2: byteArray[16]), temperatureType: byteArray[2])
//            
//          }
//          
//          
//          //let byte5 = self.converToBinary(x1: byteArray[5])
//          
//          
//          
//        }
//      }
//      
//      if lastString == resultStr{
//        return;
//      }
//      
//      // 操作的characteristic 保存
//      self.savedCharacteristic = characteristic
//      
//    }
//  }
//  
//  
//}
