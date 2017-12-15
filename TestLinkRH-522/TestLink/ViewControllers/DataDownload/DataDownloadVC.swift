//
//  DataDownloadVC.swift
//  TestLink
//
//  Created by Pritesh Pethani on 24/01/17.
//  Copyright © 2017 Pritesh Pethani. All rights reserved.
//

import UIKit

//private let commandP = "CommandP"
//private let commandRepeatP = "CommandRepeatP"
//private let commandWrong = "CommandWrong"
//private let commandFinished = "CommandFinished"

class DataDownloadVC: UIViewController{
  
  @IBOutlet var textView :UITextView!
  
  @IBOutlet var tableDD: UITableView!
  @IBOutlet var btnDownload: UIButton!
  @IBOutlet var btnGraph: UIButton!
  @IBOutlet var btnText: UIButton!
  
    @IBOutlet var nslcTopView: NSLayoutConstraint!
    @IBOutlet var topView: UIView!
    var myDownloadedData : NSMutableArray = NSMutableArray()
  var mySavedData:Bool!
  var myFinishCommandCalled:Bool!
  
  
  var myProgressLabel: UILabel!//For diplaying progress on downloaded data on Tableview's Footer
    
  //N
  var userSelectFileName:String?
  
  //For saving csv file subview
  @IBOutlet var viewWriteCSV: UIView!
  @IBOutlet var txtCSVName: UITextField!
  @IBOutlet var txtCSVDescription: UITextView!
  var csvFilename:String!
  var index:Int!
  @IBOutlet var viewName:UIView!
  @IBOutlet var viewDescription:UIView!
  
  var myData:NSMutableArray!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.generalSettings()
    
    
    
    
    self.GetData()
    
    MainCenteralManager.sharedInstance().mainCenteralManagerForCommandPDelegate = self
  }
  
    override func viewDidLayoutSubviews() {
        
        Utility.set_TopLayout_VesionRelated(nslcTopView, topView, self)
    }
  
  func GetData() {
    
    if (!self.myFinishCommandCalled){
      self.addLoadingIndicatiorOnFooterOnTableViewStore()
    }else{
      self.myDownloadedDataMethod()
    }
    
  }
  
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    
  }
  
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  
  
  // MARK: - OTHER METHODS
  
  func generalSettings() {
    
    txtCSVDescription.placeholder = "Write Note"
    csvFilename = ""
    mySavedData = false
    myFinishCommandCalled = false
    
    viewName.layer.masksToBounds = true
    viewName.layer.borderWidth = 1.0
    viewName.layer.borderColor = UIColor.black.cgColor
    
    viewDescription.layer.masksToBounds = true
    viewDescription.layer.borderWidth = 1.0
    viewDescription.layer.borderColor = UIColor.black.cgColor
    
    tableDD.register(UITableViewCell.self, forCellReuseIdentifier: "DDCell")
    btnText.layer.borderWidth = 1.0
    btnText.layer.borderColor = UIColor.lightGray.cgColor
    btnGraph.layer.borderWidth = 1.0
    btnGraph.layer.borderColor = UIColor.lightGray.cgColor
    btnDownload.layer.borderWidth = 1.0
    btnDownload.layer.borderColor = UIColor.lightGray.cgColor
    
    self.addTapGestureInOurView()
  }
  
  func addTapGestureInOurView(){
    let tapRecognizer:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.backgroundTap(_:)))
    tapRecognizer.cancelsTouchesInView = false
    self.view.addGestureRecognizer(tapRecognizer)
  }
  
  @objc func backgroundTap(_ sender:UITapGestureRecognizer){
    let point:CGPoint = sender.location(in: sender.view)
    let viewTouched = view.hitTest(point, with: nil)
    if viewTouched!.isKind(of: UIButton.self) && viewTouched!.isKind(of:UITextView.self){
      
    }
    else{
      self.view.endEditing(true)
    }
  }
  
  func addLoadingIndicatiorOnFooterOnTableViewStore(){
    
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    spinner.startAnimating()
    spinner.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 44)
    
    //tableDD.tableFooterView = spinner
    
    myProgressLabel = UILabel.init(frame: CGRect(x: 0, y: 44, width: UIScreen.main.bounds.size.width, height: 30))
    myProgressLabel.text = "0% Progress Completed"
    myProgressLabel.textAlignment = .center
    
    let myFooterView = UIView.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 74))
    myFooterView.addSubview(myProgressLabel)
    myFooterView.addSubview(spinner)
    
    tableDD.tableFooterView = myFooterView
  }
  
  func removeLoadingIndicatiorOnFooterOnTableViewStore(){
    tableDD.tableFooterView = nil
  }
  
  // MARK: - Button Action Methods
  
  @IBAction func btnBackliked(_ sender: UIButton) {
    
    //self.centralManager?.cancelPeripheralConnection(self.peripheral)
    MainCenteralManager.sharedInstance().SwitchCommandA()
    //NotificationCenter.default.post(name: NSNotification.Name(rawValue: "callingMethodForBetryStatus"), object: nil)
    
    _ = self.navigationController?.popViewController(animated: true)
  }
  
  @IBAction func btnDOWNLOADliked(_ sender: UIButton) {
    
    if csvFilename == ""{
      showAlert(Appname, title: "Please Select CSV File")
      return
    }
    
    txtCSVName.text = csvFilename
    
    txtCSVDescription.text = ""
    
    self.view.addSubview(viewWriteCSV)
  }
  
  @IBAction func btnTextcliked(_ sender: UIButton) {
    
    
    if csvFilename == ""{
      showAlert(Appname, title: "Please Select CSV File")
      return
    }
    
    self.saveDataInArray()
    
    let fileManager = FileManager.default
    if fileManager.fileExists(atPath: self.dataFilePathLibrary()) {
      print("FILE AVAILABLE")
      //showAlert(Appname, title: "This file is already exist.")
      
      let fileManager = FileManager.default
      let tempFolderPath = NSTemporaryDirectory()
      
      do {
        let filePaths = try fileManager.contentsOfDirectory(atPath: tempFolderPath)
        for filePath in filePaths {
          try fileManager.removeItem(atPath: NSTemporaryDirectory() + filePath)
        }
      } catch let error as NSError {
        print("Could not clear temp folder: \(error.debugDescription)")
      }
      
    } else {
      FileManager.default.createFile(atPath: self.dataFilePathLibrary(), contents: nil, attributes: nil)
    }
    
    var stringToWrite = String()
    stringToWrite += "Date,Time,T1,T2, T3,T4, Scale\n"
    
    for i in 0..<myData.count {
      stringToWrite += "\((myData[i] as AnyObject).value(forKey: "date") as! String),"
      stringToWrite += "\((myData[i] as AnyObject).value(forKey: "time") as! String),"
      stringToWrite += "\((myData[i] as AnyObject).value(forKey: "T1") as! String),"
      stringToWrite += "\((myData[i] as AnyObject).value(forKey: "T2") as! String),"
      stringToWrite += "\((myData[i] as AnyObject).value(forKey: "T3") as! String),"
      stringToWrite += "\((myData[i] as AnyObject).value(forKey: "T4") as! String),"
      stringToWrite += "\((myData[i] as AnyObject).value(forKey: "scale") as! String)\n"
    }
    
    //Moved this stuff out of the loop so that you write the complete string once and only once.
    print("writeString :\(stringToWrite)")
    //            var handle: FileHandle?
    //
    //
    //            handle = FileHandle(forWritingAtPath: self.dataFilePath())
    //            print("Path :->\(self.dataFilePath1())")
    //            //say to handle where's the file fo write
    //            handle?.truncateFile(atOffset: (handle?.seekToEndOfFile())!)
    //            //position handle cursor to the end of file
    //
    //            handle?.write(stringToWrite.data(using: String.Encoding.utf8)!)
    
    let text = stringToWrite //just a text
    let path = URL(fileURLWithPath: self.dataFilePathLibrary())
    
    //writing
    do {
      try text.write(to: path, atomically: false, encoding: String.Encoding.utf8)
    }
    catch {
      print("error handling here")
      /* error handling here */}
    
    
    //let nsDocumentDirectory = NSTemporaryDirectory()//FileManager.SearchPathDirectory.libraryDirectory
    //let nsUserDomainMask = FileManager.SearchPathDomainMask.userDomainMask
    //let paths = NSTemporaryDirectory()//NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true)
    //        guard paths.first != nil else {
    //            return
    //        }
    
    
    let filePath = self.dataFilePathLibrary()
    
    let obj = TextViewVC()
    obj.filePath = filePath
    self.navigationController?.pushViewController(obj, animated: true)
    
    
    //        let obj = TextViewVC()
    //        self.navigationController?.pushViewController(obj, animated: true)
  }
  
  @IBAction func btnGraphClicked(_ sender: UIButton) {
    
    if csvFilename == ""{
      showAlert(Appname, title: "Please Select CSV File")
      return
    }
    
    self.saveDataInArray()
    
    let obj = RealTimeGraphVC()
    obj.isFromDataDownload = true
    obj.myRecords = myData
    self.navigationController?.pushViewController(obj, animated: true)
    
    //        let obj = RealTimeGraphVC()
    //        obj.isFromDataDownload = true
    //        self.navigationController?.pushViewController(obj, animated: true)
  }
  
  func saveDataInArray() {
    let myFinalDataArray = MainCenteralManager.sharedInstance().dataP.myFinalDataArray
    
    if myFinalDataArray.count == 0 {
      return
    }
    
    if index != nil
    {
      DispatchQueue.global().sync {
        var dict = NSMutableDictionary()
        self.myData = NSMutableArray()
        if myFinalDataArray.count < self.index {
          return
        }
        
        
        let myRecords : NSMutableArray = myFinalDataArray[self.index] as! NSMutableArray
        
        if myRecords.count < 32 {
          return
        }
        
        print("myRecords[13] = ", myRecords[13])
        
        let byte3 = MainCenteralManager.sharedInstance().converToBinary(x1: UInt8("\((myRecords[13] as AnyObject).value(forKey: "Int") as! String)")!)
        
        var myScale:String = "C"
        if (MainCenteralManager.sharedInstance().data.cOrF == "C")
        {
          myScale = "C"
        }
        else
        {
          myScale = "F"
        }
        
        //Fetching date
        let myDate:String = "\((myRecords[0] as AnyObject).value(forKey: "Hexa") as! String)\((myRecords[1] as AnyObject).value(forKey: "Hexa") as! String)/\((myRecords[2] as AnyObject).value(forKey: "Hexa") as! String)/\((myRecords[3] as AnyObject).value(forKey: "Hexa") as! String)"

        //Fetching time
        var hourInterval:Int = Int("\((myRecords[4] as AnyObject).value(forKey: "Hexa") as! String)")!//13
        var minutesInterval:Int = Int("\((myRecords[5] as AnyObject).value(forKey: "Hexa") as! String)")!
        var secondsInterval:Int = Int("\((myRecords[6] as AnyObject).value(forKey: "Hexa") as! String)")!
 
        //Fetching time invertal
        let h2:String = "\("\((myRecords[7] as AnyObject).value(forKey: "Hexa") as! String)")\("\((myRecords[8] as AnyObject).value(forKey: "Hexa") as! String)")"
        let timeInterval:Int = Int(h2, radix: 16)!
        
        print("timeInterval = ", timeInterval)
        
        print("myRecords[9] = ", myRecords[9])
        
        var myDeviceType = ""
        
        myDeviceType = MainCenteralManager.sharedInstance().getDeviceType(value: UInt8("\((myRecords[9] as AnyObject).value(forKey: "Int") as! String)")!)
        
        print("myDeviceType = ", myDeviceType)
        
        var i:Int = 16
        
        while i < myRecords.count {
          
          if myRecords.count >= i+8{
            
            //self.getCelsius(x1: byteArray[9], x2: byteArray[10])
            
            let byte1:UInt8 = UInt8("\((myRecords[i] as AnyObject).value(forKey: "Int") as! String)")!
            let byte2:UInt8 = UInt8("\((myRecords[i+1] as AnyObject).value(forKey: "Int") as! String)")!
            let byte3:UInt8 = UInt8("\((myRecords[i+2] as AnyObject).value(forKey: "Int") as! String)")!
            let byte4:UInt8 = UInt8("\((myRecords[i+3] as AnyObject).value(forKey: "Int") as! String)")!
            let byte5:UInt8 = UInt8("\((myRecords[i+4] as AnyObject).value(forKey: "Int") as! String)")!
            let byte6:UInt8 = UInt8("\((myRecords[i+5] as AnyObject).value(forKey: "Int") as! String)")!
            let byte7:UInt8 = UInt8("\((myRecords[i+6] as AnyObject).value(forKey: "Int") as! String)")!
            let byte8:UInt8 = UInt8("\((myRecords[i+7] as AnyObject).value(forKey: "Int") as! String)")!
            
            dict = NSMutableDictionary()
            dict["date"] = myDate
            
            // Change logic to calculate perfect time
            let dateString = "\(myDate) 00:00:00"
            
            // setup a DateFormatter
            let dateFormatter = DateFormatter()
            // the format of the given date
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            
            guard let date = dateFormatter.date(from: dateString) else {
                fatalError()
            }
            let currentDate = date
            
            
            var dateComponent = DateComponents()
            
            dateComponent.hour = hourInterval
            dateComponent.minute = minutesInterval
            dateComponent.second = secondsInterval
            
            let futureDate = Calendar.current.date(byAdding: dateComponent, to: currentDate)
            
            let dateFormatter1 = DateFormatter()
            // the format of the given date
            dateFormatter1.dateFormat = "yyyy/MM/dd"
            
            let dateOnly = dateFormatter1.string(from:futureDate!)
            
            dateFormatter1.dateFormat = "HH:mm:ss"
            
            let timeOnly = dateFormatter1.string(from:futureDate!)
            
            dict["time"] = timeOnly
            dict["date"] = dateOnly
            
            let t1 = Float(MainCenteralManager.sharedInstance().getFahrenheit(x1: byte1, x2: byte2))!
            
            if (myScale == "C"){
                if t1 > MainCenteralManager.sharedInstance().getMaxValue(temperatureType: "C", deviceType: myDeviceType) {
                    dict["T1"] = "OL"
                }
                else if t1 < MainCenteralManager.sharedInstance().getMinValue(temperatureType: "C", deviceType: myDeviceType){
                    dict["T1"] = "-OL"
                }
                else {
                    dict["T1"] = MainCenteralManager.sharedInstance().getCelsius(x1: byte1, x2: byte2)
                }
            }
            else {
                if t1 > MainCenteralManager.sharedInstance().getMaxValue(temperatureType: "F", deviceType: myDeviceType) {
                    dict["T1"] = "OL"
                }
                else if t1 < MainCenteralManager.sharedInstance().getMinValue(temperatureType: "F", deviceType: myDeviceType){
                    dict["T1"] = "-OL"
                }
                else {
                    dict["T1"] = MainCenteralManager.sharedInstance().getFahrenheit(x1: byte1, x2: byte2)
                }
            }
            let t2 = Float(MainCenteralManager.sharedInstance().getFahrenheit(x1: byte3, x2: byte4))!
            
            if (myScale == "C"){
                if t2 > MainCenteralManager.sharedInstance().getMaxValue(temperatureType: "C", deviceType: myDeviceType) {
                    dict["T2"] = "OL"
                }
                else if t2 < MainCenteralManager.sharedInstance().getMinValue(temperatureType: "C", deviceType: myDeviceType){
                    dict["T2"] = "-OL"
                }
                else {
                    dict["T2"] = MainCenteralManager.sharedInstance().getCelsius(x1: byte3, x2: byte4)
                }
            }
            else {
                if t2 > MainCenteralManager.sharedInstance().getMaxValue(temperatureType: "F", deviceType: myDeviceType) {
                    dict["T2"] = "OL"
                }
                else if t2 < MainCenteralManager.sharedInstance().getMinValue(temperatureType: "F", deviceType: myDeviceType){
                    dict["T2"] = "-OL"
                }
                else {
                    dict["T2"] = MainCenteralManager.sharedInstance().getFahrenheit(x1: byte3, x2: byte4)
                }
            }
            
            
            let t3 = Float(MainCenteralManager.sharedInstance().getFahrenheit(x1: byte5, x2: byte6))!
            
            if (myScale == "C"){
                if t3 > MainCenteralManager.sharedInstance().getMaxValue(temperatureType: "C", deviceType: myDeviceType) {
                    dict["T3"] = "OL"
                }
                else if t3 < MainCenteralManager.sharedInstance().getMinValue(temperatureType: "C", deviceType: myDeviceType){
                    dict["T3"] = "-OL"
                }
                else {
                    dict["T3"] = MainCenteralManager.sharedInstance().getCelsius(x1: byte5, x2: byte6)
                }
            }
            else {
                if t3 > MainCenteralManager.sharedInstance().getMaxValue(temperatureType: "F", deviceType: myDeviceType) {
                    dict["T3"] = "OL"
                }
                else if t3 < MainCenteralManager.sharedInstance().getMinValue(temperatureType: "F", deviceType: myDeviceType){
                    dict["T3"] = "-OL"
                }
                else {
                    dict["T3"] = MainCenteralManager.sharedInstance().getFahrenheit(x1: byte5, x2: byte6)
                }
            }
            let t4 = Float(MainCenteralManager.sharedInstance().getFahrenheit(x1: byte7, x2: byte8))!
            
            if (myScale == "C"){
                if t4 > MainCenteralManager.sharedInstance().getMaxValue(temperatureType: "C", deviceType: myDeviceType) {
                    dict["T4"] = "OL"
                }
                else if t4 < MainCenteralManager.sharedInstance().getMinValue(temperatureType: "C", deviceType: myDeviceType){
                    dict["T4"] = "-OL"
                }
                else {
                    dict["T4"] =  MainCenteralManager.sharedInstance().getCelsius(x1: byte7, x2: byte8)
                }
            }
            else {
                if t4 > MainCenteralManager.sharedInstance().getMaxValue(temperatureType: "F", deviceType: myDeviceType) {
                    dict["T4"] = "OL"
                }
                else if t4 < MainCenteralManager.sharedInstance().getMinValue(temperatureType: "F", deviceType: myDeviceType){
                    dict["T4"] = "-OL"
                }
                else {
                    dict["T4"] = MainCenteralManager.sharedInstance().getFahrenheit(x1: byte7, x2: byte8)
                }
            }

            dict["scale"] = myScale
            self.myData.add(dict)
            
            secondsInterval = secondsInterval + timeInterval
          }
          i = i + 8
        }
        
        print("myData myData myData ", self.myData)
      }
    }
  }
  
  @IBAction func btnCSVSavedClicked(_ sender: UIButton) {
    
    if txtCSVName.text == ""{
      showAlert(Appname, title: "Please Enter CSV Name")
    }
      //        else if txtCSVDescription.text == ""{
      //            showAlert(Appname, title: "Please Enter Description")
      //        }
    else{
      
      let saveDataDict:NSMutableDictionary!
      let myData1:NSMutableArray!
      
      if let userCSVDescription = USERDEFAULT.value(forKey: "userCSVFileData") as? NSArray
      {
        print("Already added Description",userCSVDescription)
        let temp:NSArray = userCSVDescription.value(forKey: "filename") as! NSArray
        let myIndexValue:Int = temp.index(of: "\(txtCSVName.text!).csv")
        print("My IndexValue",myIndexValue)
        
        if myIndexValue > userCSVDescription.count{
          myData1 = NSMutableArray(array: userCSVDescription)
          saveDataDict = NSMutableDictionary()
          saveDataDict["filename"] = "\(txtCSVName.text!).csv"
          saveDataDict["description"] = txtCSVDescription.text
          myData1.add(saveDataDict)
          
          print("MYDATA",myData1)
          
          USERDEFAULT.set(myData1, forKey: "userCSVFileData")
          USERDEFAULT.synchronize()
          
        }
        else{
          myData1 = NSMutableArray(array: userCSVDescription)
          let temp = NSMutableDictionary()
          temp["filename"] = "\(txtCSVName.text!).csv"
          temp["description"] = txtCSVDescription.text
          myData1.replaceObject(at: myIndexValue, with: temp)
          
          USERDEFAULT.set(myData1, forKey: "userCSVFileData")
          USERDEFAULT.synchronize()
          
          
          print("MYDATA",myData1)
        }
      }
      else{
        myData1 = NSMutableArray()
        saveDataDict = NSMutableDictionary()
        saveDataDict["filename"] = "\(txtCSVName.text!).csv"
        saveDataDict["description"] = txtCSVDescription.text
        myData1.add(saveDataDict)
        
        print("MYDATA",myData1)
        
        USERDEFAULT.set(myData1, forKey: "userCSVFileData")
        USERDEFAULT.synchronize()
      }
      
      self.saveDataInArray()
      
      //            if index != nil
      //            {
      //                DispatchQueue.global().sync {
      //                    var dict = NSMutableDictionary()
      //                    self.myData = NSMutableArray()
      //
      //                    //"\((mySingleFileData[0] as AnyObject).value(forKey: "Hexa") as! String)"
      //
      //                    let myRecords : NSMutableArray = self.myFinalDataArray[self.index] as! NSMutableArray
      //
      //                    var hourInterval:Int = 13
      //                    var minutesInterval:Int = 05
      //                    var secondsInterval:Int = 05
      //
      //                    let byte3 = self.converToBinary(x1: UInt8("\((myRecords[13] as AnyObject).value(forKey: "Int") as! String)")!)
      //                    var myScale:String = "C"
      //                    if (byte3[0] == "1")
      //                    {
      //                        myScale = "C"
      //                    }
      //                    else
      //                    {
      //                        myScale = "F"
      //                    }
      //
      //                    var i:Int = 16
      //
      //                    while i < myRecords.count {
      //
      //                        if myRecords.count >= i+8{
      //
      //                            //self.getCelsius(x1: byteArray[9], x2: byteArray[10])
      //
      //                            let byte1:UInt8 = UInt8("\((myRecords[i] as AnyObject).value(forKey: "Int") as! String)")!
      //                            let byte2:UInt8 = UInt8("\((myRecords[i+1] as AnyObject).value(forKey: "Int") as! String)")!
      //                            let byte3:UInt8 = UInt8("\((myRecords[i+2] as AnyObject).value(forKey: "Int") as! String)")!
      //                            let byte4:UInt8 = UInt8("\((myRecords[i+3] as AnyObject).value(forKey: "Int") as! String)")!
      //                            let byte5:UInt8 = UInt8("\((myRecords[i+4] as AnyObject).value(forKey: "Int") as! String)")!
      //                            let byte6:UInt8 = UInt8("\((myRecords[i+5] as AnyObject).value(forKey: "Int") as! String)")!
      //                            let byte7:UInt8 = UInt8("\((myRecords[i+6] as AnyObject).value(forKey: "Int") as! String)")!
      //                            let byte8:UInt8 = UInt8("\((myRecords[i+7] as AnyObject).value(forKey: "Int") as! String)")!
      //
      //                            dict = NSMutableDictionary()
      //                            dict["date"] = "2017/05/05"//(myRecords[i] as AnyObject).value(forKey: "date")
      //
      //                            secondsInterval = secondsInterval + 5
      //
      //                            if secondsInterval > 60 {
      //
      //                                minutesInterval = minutesInterval + (secondsInterval/60)
      //                                secondsInterval = (secondsInterval%60)
      //                            }
      //
      //                            if minutesInterval > 60 {
      //                                hourInterval = hourInterval + (minutesInterval/60)
      //                                minutesInterval = (minutesInterval%60)
      //                            }
      //
      //                            dict["time"] = "\(String(format: "%02d", hourInterval)):\(String(format: "%02d", minutesInterval)):\(String(format: "%02d", secondsInterval))"
      //
      //                            //dict["time"] = "\(hourInterval):\(minutesInterval):\(secondsInterval)"//(myRecords[i] as AnyObject).value(forKey: "time")
      //
      //                            if Float(self.getFahrenheit(x1: byte1, x2: byte2))! > MaxTempValue {
      //                                dict["t1"] = "--"
      //                            }else{
      //                                dict["t1"] = self.getFahrenheit(x1: byte1, x2: byte2)
      //                            }
      //
      //                            if Float(self.getFahrenheit(x1: byte3, x2: byte4))! > MaxTempValue {
      //                                dict["t2"] = "--"
      //                            }else{
      //                                dict["t2"] = self.getFahrenheit(x1: byte3, x2: byte4)
      //                            }
      //
      //                            if Float(self.getFahrenheit(x1: byte5, x2: byte6))! > MaxTempValue {
      //                                dict["t3"] = "--"
      //                            }else{
      //                                dict["t3"] = self.getFahrenheit(x1: byte5, x2: byte6)
      //                            }
      //
      //                            if Float(self.getFahrenheit(x1: byte7, x2: byte8))! > MaxTempValue {
      //                                dict["t4"] = "--"
      //                            }else{
      //                                dict["t4"] = self.getFahrenheit(x1: byte7, x2: byte8)
      //                            }
      //
      //                            dict["scale"] = myScale
      //                            self.myData.add(dict)
      //                        }
      //                        i = i + 8
      //                    }
      //
      //                    print("myData myData myData ", self.myData)
      //
      //                }
      //            }
      
      let fileManager = FileManager.default
      if fileManager.fileExists(atPath: self.dataFilePath1()) {
        print("FILE AVAILABLE")
        showAlert(Appname, title: "This file is already exist.")
        
        return
      } else {
        FileManager.default.createFile(atPath: self.dataFilePath1(), contents: nil, attributes: nil)
      }
      
      var stringToWrite = String()
      stringToWrite += "Date,Time,T1,T2, T3,T4, Scale\n"
      
      for i in 0..<myData.count {
        stringToWrite += "\((myData[i] as AnyObject).value(forKey: "date") as! String),"
        stringToWrite += "\((myData[i] as AnyObject).value(forKey: "time") as! String),"
        stringToWrite += "\((myData[i] as AnyObject).value(forKey: "T1") as! String),"
        stringToWrite += "\((myData[i] as AnyObject).value(forKey: "T2") as! String),"
        stringToWrite += "\((myData[i] as AnyObject).value(forKey: "T3") as! String),"
        stringToWrite += "\((myData[i] as AnyObject).value(forKey: "T4") as! String),"
        stringToWrite += "\((myData[i] as AnyObject).value(forKey: "scale") as! String)\n"
      }
      
      //Moved this stuff out of the loop so that you write the complete string once and only once.
      print("writeString :\(stringToWrite)")
      //            var handle: FileHandle?
      //
      //
      //            handle = FileHandle(forWritingAtPath: self.dataFilePath())
      //            print("Path :->\(self.dataFilePath1())")
      //            //say to handle where's the file fo write
      //            handle?.truncateFile(atOffset: (handle?.seekToEndOfFile())!)
      //            //position handle cursor to the end of file
      //
      //            handle?.write(stringToWrite.data(using: String.Encoding.utf8)!)
      
      let text = stringToWrite //just a text
      let path = URL(fileURLWithPath: self.dataFilePath1())
      
      //writing
      do {
        try text.write(to: path, atomically: false, encoding: String.Encoding.utf8)
      }
      catch {
        print("error handling here")
        /* error handling here */}
      
      
      viewWriteCSV.removeFromSuperview()
      
      APPDELEGATE.window.makeToast("File is saved")
    }
  }
  
  func dataFilePath1() -> String {
    
    let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
    let url = NSURL(fileURLWithPath: path)
    let trimbeforeAfterString = txtCSVName.text?.trimmingCharacters(in: .whitespaces)
    var trimmedString = trimbeforeAfterString?.replacingOccurrences(of: " ", with: "_")
    trimmedString = trimmedString?.replacingOccurrences(of: "/", with: "-")
    let filePath = url.appendingPathComponent("\(trimmedString!).csv")?.path
    return filePath!
  }
  
  func dataFilePathLibrary() -> String {
    
    let path = NSTemporaryDirectory()//NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)[0] as String
    let url = NSURL(fileURLWithPath: path)
    let trimbeforeAfterString = txtCSVName.text?.trimmingCharacters(in: .whitespaces)
    var trimmedString = trimbeforeAfterString?.replacingOccurrences(of: " ", with: "_")
    trimmedString = trimmedString?.replacingOccurrences(of: "/", with: "-")
    let filePath = url.appendingPathComponent("Temp.csv")?.path
    return filePath!
  }
  
  @IBAction func btnCSVCancelClicked(_ sender: UIButton) {
    viewWriteCSV.removeFromSuperview()
  }
  
  
  // MARK: - CBCentralManager Methods
  
  func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
    if peripheral.state == CBPeripheralState.connected {
      //bbConnect.text = "Connected"
      peripheral.discoverServices(nil)
    }
  }
  
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
  
  //    func centralManagerDidUpdateState(_ central: CBCentralManager) {
  //
  //    }
  
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
  //
  //    }
  
  func getIntValueFromArray(index: Int) -> Int {
    return ((myDownloadedData.object(at: index) as! NSMutableDictionary).value(forKey: "Int")) as! Int
  }
  
  var isGetData : Bool = false
  
  //    func set32Byte(byteArray: Array<UInt8>)
  //    {
  //        DispatchQueue.global().async {
  //
  //            var checkSum: Int = 0
  //
  //            //-----------**********Removing repeating data--------------////
  //            var isSavedData : Bool = true
  //
  //            if self.lastSavedDataArray == [] {
  //                self.lastSavedDataArray = byteArray
  //                isSavedData = true
  //            }
  //            else {
  //                if self.lastSavedDataArray == byteArray {
  //                    isSavedData = false
  //                }
  //                else {
  //                    self.lastSavedDataArray = byteArray
  //                    isSavedData = true
  //                }
  //            }
  //
  //            self.lastSavedDataArray = byteArray
  //
  //            if isSavedData {
  //                print("Data are not same : ")
  //                //-----------**********Removing repeating data--------------////
  //
  //                self.totalBytesReceived += 32;
  //                print("TotalBytesReceived: \(self.totalBytesReceived) Total Bytes: \(self.totalBytes)")
  //
  //                DispatchQueue.main.async {
  //
  //                    if Int(self.totalBytes) != 0 {
  //                        var myProgress:Int = 0
  //                        myProgress = (Int(self.totalBytesReceived) * 100) / Int(self.totalBytes)
  //                        self.myProgressLabel!.text = "\(myProgress)% Progress Completed"
  //                        //var myProgress:Float = 0
  //                        //myProgress = (Float(self.totalBytesReceived) * 100) / Float(self.totalBytes)
  //                        //self.myProgressLabel!.text = "\(String(format:"%02.2f", myProgress))% Progress Completed"
  //                    }
  //                }
  //
  //                for i in 0 ..< 32  {
  //
  //                    // Total Check Sum Value
  //                    checkSum = checkSum + Int(byteArray[i])
  //
  //                    // Add Data to array
  //                    let myData : NSMutableDictionary = NSMutableDictionary()
  //                    myData.setValue(String(format:"%02X", byteArray[i]), forKey: "Hexa")
  //                    myData.setValue("\(byteArray[i])", forKey: "Int")
  //                    //myData.setValue("\(Int(byteArray[i]))", forKey: "Int")
  //                    myData.setValue("\(self.converToBinary(x1: byteArray[i]))", forKey: "Binary")
  //                    myData.setValue("\(Int8(bitPattern: byteArray[i]))", forKey: "Decimal")
  //                    self.myDownloadedData.add(myData)
  //
  //                }
  //            }
  //            else{
  //                for i in 0 ..< 32  {
  //                    // Total Check Sum Value
  //                    checkSum = checkSum + Int(byteArray[i])
  //                }
  //                print("Data are same : ")
  //            }
  //
  //
  //            if (Int((byteArray[34] & 0xFF)) == (checkSum & 0xFF) && byteArray[35] == 5) {
  //                self.btncommandRepeatP()
  //            }
  //            else {
  //                self.btncommandWrongCommand()
  //            }
  //
  //            //self.saveAsFileAction()
  //
  //        }
  //    }
  
  //    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
  //
  //        print("Called00000")
  //
  //        if (characteristic.value != nil){
  //            let resultStr = NSString(data: characteristic.value!, encoding: String.Encoding.utf8.rawValue)
  //
  ////            if resultStr == nil {
  ////                return
  ////            }
  //
  //            print("Called1111")
  //
  //            if let value = characteristic.value {
  //
  //
  //                let byteArray:Array<UInt8> = [UInt8](value)
  //
  //            print("Called22222")
  //
  //                guard value.count == 36 else {
  //                    return
  //                }
  //
  //                print("characteristic uuid:\(characteristic.uuid) \n value:\(resultStr)")
  //                let log = "read: \(value)"
  //                print(log)
  //
  //                print("Called3333")
  //                if (characteristic.uuid.description == "49535343-1E4D-4BD9-BA61-23C647249616"){
  //
  //                    print("byteArray : ", byteArray)
  //
  //                    if myCalledCommand == commandFinished {
  //                        print("Finished Command Response")
  //                        if !self.mySavedData {
  //                            self.saveAsFileAction()
  //                        }
  //
  //                        return;
  //                    }
  //
  //                    if myCalledCommand == commandP {
  //
  //                        totalBytes = (Int((byteArray[10] & 0xFF)) * 65536) + (Int((byteArray[11] & 0xFF)) * 256) + (Int((byteArray[12] & 0xFF)) + 1);
  //
  //                        if (totalBytes > 0x40000 || totalBytes < 256) {
  //                            totalBytes = 0x40000;
  //                        }
  //
  //                        if totalBytes == 0 {
  //                            APPDELEGATE.window.makeToast("Getting zero bytes")
  //                            return
  //                        }
  //
  //                        if (totalBytes % 32 == 0) {
  //                            totalBytes = totalBytes - totalBytes % 32 + 32;
  //                        }
  //
  //                        totalBytesReceived = 0;
  //                        totalBytes -= 32;
  //                        self.set32Byte(byteArray: byteArray)
  //                        //isFirsttime = false;
  //                    }
  //                    else {
  //
  //                        if (totalBytesReceived > totalBytes)
  //                        {
  //                            self.btncommandFinishCommand()
  //                            return;
  //                        }
  //
  //                        if (byteArray.count >= 36) {
  //
  //                            self.set32Byte(byteArray: byteArray)
  //
  //                        } else {
  //                            if (myCalledCommand == commandWrong) {
  //                                self.btncommandRepeatP()
  //                            } else {
  //                                self.btncommandWrongCommand()
  //                            }
  //                        }
  //                    }
  //                }
  //            }
  //
  //            if lastString == resultStr{
  //                return;
  //            }
  //
  //            // 操作的characteristic 保存
  //            self.savedCharacteristic = characteristic
  //        }
  //    }
  
  //    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
  //
  //        if error != nil{
  //            print("写入 characteristics 时 \(peripheral.name) 报错 \(error?.localizedDescription)")
  //            return
  //        }
  //    }
  
  //    func viewController(characteristic: CBCharacteristic, value : Data ) -> () {
  //
  //        print("Called555555")
  //
  //
  //        //只有 characteristic.properties 有write的权限才可以写入
  //        if characteristic.properties.contains(CBCharacteristicProperties.write){
  //            //设置为  写入有反馈
  //            print("Write Command: \(value)")
  //            self.peripheral.writeValue(value, for: characteristic, type: .withResponse)
  //
  //        }else{
  //            print("写入不可用~")
  //        }
  //    }
  
  // MARK: - Button Action Methods
  //    @IBAction func btncommandC(){
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
  
  
  // MARK: - Send P Command to Notifiy Start Downloading.
  //    func btncommandP(){
  //
  //        self.addLoadingIndicatiorOnFooterOnTableViewStore()
  //
  //        //myCalledCommand = commandP
  //        //print("\n\nP Command called -  ", myCalledCommand)
  //        let commandCbyte : [UInt8] = [  0x02 , 0x50 , 0x00 , 0x00 , 0x00 , 0x00 , 0x03 ]
  //        self.sendCommandToDevice(command: commandCbyte)
  //    }
  
  // MARK: - Send Repeat P Command to Continue Downloading next data.
  //    @IBAction func btncommandRepeatP(){
  //        myCalledCommand = commandRepeatP
  //
  //        print("\n\nRepeat P Command called -  ", myCalledCommand)
  //
  //        let commandCbyte : [UInt8] = [  0x02 , 0x70 , 0x00 , 0x00 , 0x00 , 0x00 , 0x03 ]
  
  //        self.sendCommandToDevice(command: commandCbyte)
  //    }
  
  //    func sendCommandToDevice(characteristic: CBCharacteristic,value : Data ) -> () {
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
  
  
  
  // MARK: - Send Wrong Command to Notify previous Command is Failed.
  //    @IBAction func btncommandWrongCommand(){
  //        myCalledCommand = commandWrong
  //        print("\n\nWrong P Command called -  ", myCalledCommand)
  //
  //        let commandWbyte : [UInt8] = [  0x02 , 0x6e , 0x00 , 0x00 , 0x00 , 0x00 , 0x03 ]
  //        self.sendCommandToDevice(command: commandWbyte)
  //    }
  
  // MARK: - Send Finish Command for End Downloading Process.
  //    @IBAction func btncommandFinishCommand() {
  //
  //        if self.myFinishCommandCalled == false {
  //
  //            self.myFinishCommandCalled = true
  //
  //            myCalledCommand = commandFinished
  //            print("\n\nFinished Command called -  ", myCalledCommand)
  //
  //            let commandFbyte : [UInt8] = [  0x02 , 0x71 , 0x00 , 0x00 , 0x00 , 0x00 , 0x03 ]
  //            self.sendCommandToDevice(command: commandFbyte)
  //        }
  //    }
  
  // MARK: - Send Command To Device
  //    func sendCommandToDevice(command: [UInt8]) -> Void {
  //        let data3 = Data(bytes:command)
  //
  //        // If service count is greater then Zero.
  //        if self.btServices.count > 1 {
  //            let charItems = self.btServices[1].characteristics
  //            for characteristic in charItems {
  //                peripheral.readValue(for: characteristic)
  //                peripheral.setNotifyValue(true, for: characteristic)
  //            }
  //
  ////            for characteristic in charItems {
  ////                self.viewController(characteristic: characteristic, value: data3)
  ////            }
  //
  //
  //            for characteristic in charItems {
  //
  //                print("Called66666")
  //                if characteristic.properties.contains(CBCharacteristicProperties.writeWithoutResponse) {
  //                //if characteristic.uuid.description == "49535343-8841-43F4-A8D4-ECBE34729BB3" {
  //                    print("write: \(characteristic.uuid.description)")
  //                    self.peripheral.writeValue(data3, for: characteristic, type: .withResponse)
  //                    //break;
  //                }
  //                else{
  //                    print("写入不可用~")
  //                }
  //            }
  //        }
  //    }
  
  
  
  // MARK: - Create CSV File Methods
  
  func myDownloadedDataMethod() {
    
    var myDownloadedData =  MainCenteralManager.sharedInstance().dataP.myDownloadedData
    var myFinalDataArray = MainCenteralManager.sharedInstance().dataP.myFinalDataArray
    
    print("data is \(myDownloadedData)") 
    
    
    var isSavingData:Bool = false
    
    var mySingFileDataArray:NSMutableArray = NSMutableArray()
    
    if myDownloadedData.count == 0 {
      //self.tableDD.reloadData()
      return
    }
    
    
    for i in 1..<myDownloadedData.count+1 {
      if isSavingData == true {
        
        if "\((myDownloadedData[i-1] as AnyObject).value(forKey: "Hexa") as! String)" == "5A"
        {
          
          if myDownloadedData.count > i
          {
            if "\((myDownloadedData[i] as AnyObject).value(forKey: "Hexa") as! String)" == "A5"
            {
              myFinalDataArray.add(mySingFileDataArray)
              mySingFileDataArray = NSMutableArray()
              //tableDD.reloadData()
              isSavingData = false
              print("Stop data download")
              print("Saved data download")
            }
          }
        }
        else{
          mySingFileDataArray.add(myDownloadedData[i-1] as AnyObject)
        }
      }
      else{
        if "\((myDownloadedData[i-1] as AnyObject).value(forKey: "Hexa") as! String)" == "A5"
        {
          
          if myDownloadedData.count > i
          {
            if "\((myDownloadedData[i] as AnyObject).value(forKey: "Hexa") as! String)" == "5A"
            {
              isSavingData = true
              print("New data download");
            }
          }
          
        }
      }
      
      
      if i == myDownloadedData.count {
        if mySingFileDataArray.count > 0 {
          myFinalDataArray.add(mySingFileDataArray)
          mySingFileDataArray = NSMutableArray()
          print("Saved data download")
        }
      }
    }
    
    //print("myFinalDataArray myFinalDataArray ", myFinalDataArray);
    self.removeLoadingIndicatiorOnFooterOnTableViewStore()
    tableDD.reloadData()
    
  }
  
  func dataFilePath() -> String {
    //var paths: [Any] = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
    //let documentsDirectory: String = paths[0] as! String
    // return URL(fileURLWithPath: documentsDirectory).appendingPathComponent("").absoluteString
    
    let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
    let url = NSURL(fileURLWithPath: path)
    let filePath = url.appendingPathComponent("myfile.csv")?.path
    return filePath!
    
  }
  
  //@IBAction func saveAsFileAction() {
  //
  //        self.mySavedData = true
  //
  //        if myProgressLabel != nil {
  //            myProgressLabel.text = "Loading Files"
  //        }
  //
  //        //self.myDownloadedDataMethod()
  //        //return
  //
  //        var dict = NSMutableDictionary()
  //        var myData = NSMutableArray()
  //
  //        myData = NSMutableArray()
  //
  //
  //
  //        let fileManager = FileManager.default
  //        if fileManager.fileExists(atPath: self.dataFilePath()) {
  //            print("FILE AVAILABLE")
  //        } else {
  //            FileManager.default.createFile(atPath: self.dataFilePath(), contents: nil, attributes: nil)
  //        }
  //
  //
  //        var stringToWrite = String()
  //
  //        stringToWrite += "Hexa\n\n"//"Hexa,Int,Binary,Decimal\n\n"
  //        for i in 1..<myDownloadedData.count+1 {
  //            stringToWrite += "\((myDownloadedData[i-1] as AnyObject).value(forKey: "Hexa") as! String),"
  ////            stringToWrite += "\((myDownloadedData[i] as AnyObject).value(forKey: "Int") as! String),"
  ////            //stringToWrite += "\((myDownloadedData[i] as AnyObject).value(forKey: "Binary") as! String),"
  ////            stringToWrite += "\((myDownloadedData[i] as AnyObject).value(forKey: "Decimal") as! String),\n"
  //
  //            if i % 16 == 0 {
  //                stringToWrite += "\n"
  //            }
  //        }
  //        //Moved this stuff out of the loop so that you write the complete string once and only once.
  //        print("writeString :\(stringToWrite)")
  //        var handle: FileHandle?
  //
  //
  //        handle = FileHandle(forWritingAtPath: self.dataFilePath())
  //
  //        print("Path :->\(self.dataFilePath())")
  //        //say to handle where's the file fo write
  //        handle?.truncateFile(atOffset: (handle?.seekToEndOfFile())!)
  //        //position handle cursor to the end of file
  //        handle?.write(stringToWrite.data(using: String.Encoding.utf8)!)
  //
  //}
  
  //    @IBAction func shareButtonPressed(_ sender: UIButton) {
  //        //NSString *str = [[NSBundle mainBundle] pathForResource:@"BLS Report_2016-10-11_11-33-40" ofType:@"pdf"];
  //        //    NSString *str = [[NSBundle mainBundle] pathForResource:@"myfile" ofType:@"csv"];
  //        //    NSArray *activityItems = @[[NSURL fileURLWithPath:str]];
  //        let activityItems: [Any] = [URL(fileURLWithPath: self.dataFilePath())]
  //        let shareScreen = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
  //        self.present(shareScreen, animated: true, completion: { _ in })
  //    }
  
}


extension DataDownloadVC: UITableViewDataSource, UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return MainCenteralManager.sharedInstance().dataP.myFinalDataArray.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "DDCell")
    
    //"\((myDownloadedData[i] as AnyObject).value(forKey: "Hexa") as! String)"
    let mySingleFileData:NSMutableArray = MainCenteralManager.sharedInstance().dataP.myFinalDataArray[indexPath.row] as! NSMutableArray
    
    if mySingleFileData.count > 7 {
      print("My file data------------------------------")
      print("\((mySingleFileData[0] as AnyObject).value(forKey: "Hexa") as! String)")
      print("\((mySingleFileData[1] as AnyObject).value(forKey: "Hexa") as! String)")
      print("\((mySingleFileData[2] as AnyObject).value(forKey: "Hexa") as! String)")
      print("\((mySingleFileData[3] as AnyObject).value(forKey: "Hexa") as! String)")
      print("\((mySingleFileData[4] as AnyObject).value(forKey: "Hexa") as! String)")
      print("\((mySingleFileData[5] as AnyObject).value(forKey: "Hexa") as! String)")
      print("\((mySingleFileData[6] as AnyObject).value(forKey: "Hexa") as! String)")
      print("------------------------------------------")
      
      cell?.textLabel?.text = "\((mySingleFileData[0] as AnyObject).value(forKey: "Hexa") as! String)\((mySingleFileData[1] as AnyObject).value(forKey: "Hexa") as! String)/\((mySingleFileData[2] as AnyObject).value(forKey: "Hexa") as! String)/\((mySingleFileData[3] as AnyObject).value(forKey: "Hexa") as! String) \((mySingleFileData[4] as AnyObject).value(forKey: "Hexa") as! String):\((mySingleFileData[5] as AnyObject).value(forKey: "Hexa") as! String):\((mySingleFileData[6] as AnyObject).value(forKey: "Hexa") as! String).csv"
        
        
        //N
        print(cell?.textLabel?.text)
        
        if userSelectFileName == cell?.textLabel?.text{
            cell?.accessoryType = UITableViewCellAccessoryType.checkmark
        }else{
            cell?.accessoryType = UITableViewCellAccessoryType.none
        }

      
      
    }
    else {
      cell?.textLabel?.text = "File Number \(indexPath.row + 1)"
    }
    
    let bgColorView = UIView()
    if #available(iOS 10.0, *) {
        bgColorView.backgroundColor = UIColor(displayP3Red: 204/255, green: 226/255, blue: 241/255, alpha: 1.0)
    } else {
        bgColorView.backgroundColor = UIColor(red: 204/255, green: 226/255, blue: 241/255, alpha:  1.0)
    }
    
    cell?.selectedBackgroundView = bgColorView
    
    //cell?.textLabel?.text = "File Number \(indexPath.row + 1)"
    return cell!
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    let mySingleFileData:NSMutableArray = MainCenteralManager.sharedInstance().dataP.myFinalDataArray[indexPath.row] as! NSMutableArray
    
    if mySingleFileData.count > 7 {
      print("My file data------------------------------")
      print("\((mySingleFileData[0] as AnyObject).value(forKey: "Hexa") as! String)")
      print("\((mySingleFileData[1] as AnyObject).value(forKey: "Hexa") as! String)")
      print("\((mySingleFileData[2] as AnyObject).value(forKey: "Hexa") as! String)")
      print("\((mySingleFileData[3] as AnyObject).value(forKey: "Hexa") as! String)")
      print("\((mySingleFileData[4] as AnyObject).value(forKey: "Hexa") as! String)")
      print("\((mySingleFileData[5] as AnyObject).value(forKey: "Hexa") as! String)")
      print("\((mySingleFileData[6] as AnyObject).value(forKey: "Hexa") as! String)")
      print("------------------------------------------")
      
      csvFilename = "\((mySingleFileData[0] as AnyObject).value(forKey: "Hexa") as! String)\((mySingleFileData[1] as AnyObject).value(forKey: "Hexa") as! String)/\((mySingleFileData[2] as AnyObject).value(forKey: "Hexa") as! String)/\((mySingleFileData[3] as AnyObject).value(forKey: "Hexa") as! String) \((mySingleFileData[4] as AnyObject).value(forKey: "Hexa") as! String):\((mySingleFileData[5] as AnyObject).value(forKey: "Hexa") as! String):\((mySingleFileData[6] as AnyObject).value(forKey: "Hexa") as! String)"
    }
    
    index = indexPath.row
    
    tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
    self.userSelectFileName = tableView.cellForRow(at: indexPath)?.textLabel?.text
  }
  
  func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
    tableView.cellForRow(at: indexPath)?.accessoryType = .none
  }
}

extension DataDownloadVC : MainCenteralManagerForCommandPDelegate{
  func ReceiveCommand(){
    //更新進度
    
    if Int(MainCenteralManager.sharedInstance().dataP.totalBytes) != 0 {
      var myProgress:Int = 0
      myProgress = (Int(MainCenteralManager.sharedInstance().dataP.totalBytesReceived) * 100) / Int(MainCenteralManager.sharedInstance().dataP.totalBytes)
      if (myProgress >= 100 ){
        myProgress = 100;
      }
      self.myProgressLabel!.text = "\(myProgress)% Progress Completed"
    }
  }
  func ReceiveFinish(){
    self.myFinishCommandCalled = true
    self.GetData()
  }
}
