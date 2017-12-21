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
    
    viewWriteCSV.frame = CGRect(x: 0, y: 0, width: ScreenSize.SCREEN_WIDTH, height: ScreenSize.SCREEN_HEIGHT)
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
    stringToWrite += "Date,Time,RH%,T1, T2, Scale\n"
    
    for i in 0..<myData.count {
      stringToWrite += "\((myData[i] as AnyObject).value(forKey: "date") as! String),"
      stringToWrite += "\((myData[i] as AnyObject).value(forKey: "time") as! String),"
      stringToWrite += "\((myData[i] as AnyObject).value(forKey: "RH") as! String),"
      stringToWrite += "\((myData[i] as AnyObject).value(forKey: "T1") as! String),"
      stringToWrite += "\((myData[i] as AnyObject).value(forKey: "T2") as! String),"
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
        /*if (MainCenteralManager.sharedInstance().data.cOrFOrK == "C")
        {
            myScale = "C"
            
        }else if (MainCenteralManager.sharedInstance().data.cOrFOrK == "F"){
            
            myScale = "F"
        }
        else
        {
          myScale = "K"
        }*/
        
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
        
        //00-F,01-C,10-K
        
        
        let byte9 : UInt8 = UInt8("\((myRecords[9] as AnyObject).value(forKey: "Decimal") as! String)")!
        let b9 = converToBinary(x1: byte9)
        
       /* let byte9 : String = (myRecords[9] as AnyObject).value(forKey: "Binary") as! String
        let b9 = byte9.components(separatedBy: ",") as [String]
        print("Byte 11 2 value = ",b9[2] )
        print("Byte 11 3 value = ",b9[3])*/
        
        if b9[2] == "0" && b9[3] == "0" {
            print("======================= Temp is Faherenheit =======================")
             myScale = "F"
        }else if b9[2] == "0" && b9[3] == "1" {
            
             print("======================= Temp is Celsius ==========================")
             myScale = "C"
        }else if b9[2] == "1" && b9[3] == "0" {
             print("======================= Temp is Kelvin ===========================")
             myScale = "K"
        }
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
            
            let RH = Float(MainCenteralManager.sharedInstance().getFahrenheit(x1: byte1, x2: byte2))!
            
           
            if RH > 100 {
                dict["RH"] = "OL"
            }
            else if RH < 0 {
                dict["RH"] = "-OL"
            }
            else {
                dict["RH"] = MainCenteralManager.sharedInstance().getFahrenheit(x1: byte1, x2: byte2)
            }
            
 
            let t1 = MainCenteralManager.sharedInstance().getFahrenheit(x1: byte3, x2: byte4)
            let t2 = MainCenteralManager.sharedInstance().getFahrenheit(x1: byte5, x2: byte6)
            
            var newT1 = t1
            var newT2 = t2
            
            if myScale == "C" {
                
                // T(°C) = (T(°F) - 32) / 1.8
                newT2 = String(format: "%.1f", (Float(t2)! - 32) / 1.8)
         
            }else if myScale == "F" {
                
                // T(°F) = T(°C) × 1.8 + 32
                newT1 = String(format: "%.1f",(Float(newT1)! * 1.8) + 32)
            
            }else if myScale == "K" {
                
                // T(K) = T(°C) + 273.15
                newT1 = String(format: "%.1f",(Float(newT1)! + 273.15))
                newT2 = String(format:"%.1f",(Float(newT2)! + 459.67) * (5/9))
        
            }

          
            if Float(newT1 as String)! > MainCenteralManager.sharedInstance().getMaxValue(temperatureType: myScale, deviceType: myDeviceType) {
                
                dict["T1"] = "OL"
            }
            else if  Float(newT1 as String)! < MainCenteralManager.sharedInstance().getMinValue(temperatureType: myScale, deviceType: myDeviceType){
                
                dict["T1"] = "-OL"
            }
            else {
                dict["T1"] = newT1
            }

         
            if Float(newT2 as String)! > MainCenteralManager.sharedInstance().getMaxValue(temperatureType: myScale, deviceType: myDeviceType) {
                
                dict["T2"] = "OL"
            }
            else if Float(newT2 as String)! < MainCenteralManager.sharedInstance().getMinValue(temperatureType: myScale, deviceType: myDeviceType){
                    
                dict["T2"] = "-OL"
            }
            else {
                
                dict["T2"] = newT2
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
  
    func converToBinary(x1:UInt8) -> [String] {
        var str = String(x1, radix: 2)
        while str.characters.count % 8 != 0 {
            str = "0" + str
        }
        return str.characters.map { String($0) }
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
    
      
      let fileManager = FileManager.default
      if fileManager.fileExists(atPath: self.dataFilePath1()) {
        print("FILE AVAILABLE")
        showAlert(Appname, title: "This file is already exist.")
        
        return
      } else {
        FileManager.default.createFile(atPath: self.dataFilePath1(), contents: nil, attributes: nil)
      }
      
      var stringToWrite = String()
      stringToWrite += "Date,Time,RH%,T1, T2, Scale\n"
      
      for i in 0..<myData.count {
        stringToWrite += "\((myData[i] as AnyObject).value(forKey: "date") as! String),"
        stringToWrite += "\((myData[i] as AnyObject).value(forKey: "time") as! String),"
        stringToWrite += "\((myData[i] as AnyObject).value(forKey: "RH") as! String),"
        stringToWrite += "\((myData[i] as AnyObject).value(forKey: "T1") as! String),"
        stringToWrite += "\((myData[i] as AnyObject).value(forKey: "T2") as! String),"
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
  
  
  func getIntValueFromArray(index: Int) -> Int {
    return ((myDownloadedData.object(at: index) as! NSMutableDictionary).value(forKey: "Int")) as! Int
  }
  
  var isGetData : Bool = false
  
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
