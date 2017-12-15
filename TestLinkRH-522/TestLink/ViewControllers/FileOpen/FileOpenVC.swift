//
//  FileOpenVC.swift
//  TestLink
//
//  Created by Pritesh Pethani on 24/01/17.
//  Copyright © 2017 Pritesh Pethani. All rights reserved.
//

import UIKit

class FileOpenVC: UIViewController,UITableViewDelegate,UITableViewDataSource {
  
  
  @IBOutlet var tableFO: UITableView!
  @IBOutlet var btnGraph: UIButton!
  @IBOutlet var btnText: UIButton!
  @IBOutlet var btnDelete: UIButton!
  
  var fileData = NSMutableArray()
  var descriptionData = NSMutableArray()
  
  
  var csvFilename:String!
  var index:Int!
  
  @IBOutlet var lblNoData: UILabel!
    @IBOutlet var topView: UIView!
    
    @IBOutlet var nslcTopView: NSLayoutConstraint!
    
  override func viewDidLoad() {
    super.viewDidLoad()
    csvFilename = ""
    
    tableFO.register(UITableViewCell.self, forCellReuseIdentifier: "FOCell")
    btnText.layer.borderWidth = 1.0
    btnText.layer.borderColor = UIColor.lightGray.cgColor
    btnGraph.layer.borderWidth = 1.0
    btnGraph.layer.borderColor = UIColor.lightGray.cgColor
    
    btnDelete.layer.borderWidth = 1.0
    btnDelete.layer.borderColor = UIColor.lightGray.cgColor
    
    self.getCSVFilesFromDocumentDirectory()
    
    
    
    // Do any additional setup after loading the view.
  }
  
    override func viewDidLayoutSubviews() {
        
        Utility.set_TopLayout_VesionRelated(nslcTopView, topView, self)
    }
    
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func miniMizeThisRows(ar:NSArray){
    
    for dInner in ar {
      
      let indexToRemove:Int = self.fileData.indexOfObjectIdentical(to: dInner)
      let arInner:NSArray = (dInner as! NSDictionary).value(forKey: "children") as! NSArray
      
      if  (arInner.count>0) {
        self.miniMizeThisRows(ar: arInner)
      }
      
      if self.fileData.indexOfObjectIdentical(to: dInner) != NSNotFound {
        self.fileData.removeObject(identicalTo: dInner)
        
        // self.tableView.deleteRows(at: NSIndexPath.init(row: indexToRemove, section: 0), with: .none)
        
        let aa:NSIndexPath = NSIndexPath.init(row: indexToRemove, section: 0)
        self.tableFO.deleteRows(at: [aa as IndexPath], with: .none)
      }
    }
  }
  
  
  // MARK: - UITableView Datasource
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if self.fileData.count == 0{
      return 0
    }
    
    //print("self.fileData.count %@", self.fileData.count)
    
    return self.fileData.count
  }
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    //let cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "FOCell")
    //cell?.textLabel?.text = "\(fileData.object(at: indexPath.row) as! String).csv"
    
    let identifier = "fileDataCell"
    
    var cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? FileOpenTableVC
    
    if cell == nil {
      let nib  = Bundle.main.loadNibNamed("FileOpenTableVC", owner: self, options: nil)
      cell = nib?[0] as? FileOpenTableVC
    }
    
    //print("indexPath.row %@", indexPath.row)
    
    //  cell!.selectionStyle = .none;
    cell?.lblQuestion.text = "\(fileData.object(at: indexPath.row) as! String).csv"
    
    //        if let userCSVDescription = USERDEFAULT.value(forKey: "userCSVFileData") as? NSArray
    //        {
    //            let description = userCSVDescription as NSArray
    
    if descriptionData.count > indexPath.row {
        if let description = (descriptionData.object(at: indexPath.row) as AnyObject).value(forKey: "description") {
            cell?.lblDescription.text = description as? String
        }
        else {
            cell?.lblDescription.text = ""
        }
    }
    else {
        cell?.lblDescription.text = ""
    }
    
    //        //        cell?.lblQuestion.text = (faqData.object(at: indexPath.row) as AnyObject).value(forKey: "que") as? String
    //
    //        cell?.lblQuestion.text = (self.fileData[indexPath.row] as AnyObject).value(forKey: "name") as? String
    //
    //        cell?.lblQuestion = Utility.setlableFrame(cell?.lblQuestion, fontSize: 15.0)
    //
    //        if (CGFloat((cell?.lblQuestion.frame.size.height)!) < 20.0) {
    //            cell?.lblQuestion.frame = CGRect(x: 15, y: 7, width: 261, height: 35)
    //        }
    //
    //
    //        //cell.MenucellImages.image = UIImage.init(named: (self.arForTable[indexPath.row] as AnyObject).value(forKey: "imageIcon") as! String)
    //
    //        if cell?.lblQuestion.text == "Log out"{
    //            cell?.lblQuestion.textColor = UIColor.init(red: 223.0/255.0, green: 117.0/255.0, blue: 54.0/255.0, alpha: 1.0)
    //        }
    //        else{
    //            cell?.lblQuestion.textColor = UIColor.black
    //        }
    //
    //        //For settings plus and minus image
    //        let aa = "\((self.fileData[indexPath.row] as AnyObject).value(forKey: "children") )"
    //
    //        if aa != ""{
    //            let ar:NSArray = (self.fileData[indexPath.row] as AnyObject).value(forKey: "children") as! NSArray
    //
    //            if ar.count>0 {
    //                var isAlreadyInserted:Bool = false
    //
    //                for dInner in ar{
    //                    let index:NSInteger = self.fileData.indexOfObjectIdentical(to: dInner)
    //                    isAlreadyInserted = (index>0 && index != Int.max)
    //                    if isAlreadyInserted {
    //                        break
    //                    }
    //
    //                }
    //
    //                if isAlreadyInserted == true {
    //                    //                    self.miniMizeThisRows(ar: ar)
    //                    cell?.myImageView.image = UIImage.init(named: "down.png")
    //
    //                }
    //                else{
    //                    cell?.myImageView.image = UIImage.init(named: "left.png")
    //                }
    //
    //
    //            }
    //            else{
    //                cell?.myImageView.image = UIImage.init(named: "")
    //            }
    //
    //        }
    //        else{
    //            cell?.myImageView.image = UIImage.init(named: "")
    //        }
    //
    //
    //        if (self.fileData[indexPath.row] as AnyObject).value(forKey: "level") as! String == "2"{
    //            cell?.backgroundColor = UIColor.white
    //            //cell.menucellname.font = UIFont.systemFont(ofSize: 14.0)
    //        }
    //
    //        else{
    //            cell?.backgroundColor = UIColor.lightGray
    //            //cell.menucellname.font = UIFont.systemFont(ofSize: 18.0)
    //        }
    //
    
    let bgColorView = UIView()
    
    if #available(iOS 10.0, *) {
        bgColorView.backgroundColor = UIColor(displayP3Red: 204/255, green: 226/255, blue: 241/255, alpha: 1.0)
    } else {
        bgColorView.backgroundColor = UIColor(red: 204/255, green: 226/255, blue: 241/255, alpha:  1.0)
    }
    cell?.selectedBackgroundView = bgColorView
    
    //cell?.accessoryType = .checkmark
    
    return cell!
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    
    csvFilename = "\(fileData.object(at: indexPath.row) as! String).csv"
    index = indexPath.row
    
    tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
    
    //        tableView.deselectRow(at: indexPath, animated: true)
    //        let d:NSDictionary = self.fileData[indexPath.row] as! NSDictionary
    //
    //        if (d.value(forKey: "children") != nil)  {
    //
    //            let ar:NSArray = d.value(forKey: "children") as! NSArray
    //            var  isAlreadyInserted: Bool = false
    //
    //
    //            for dInner in ar{
    //                let index:NSInteger = self.fileData.indexOfObjectIdentical(to: dInner)
    //                isAlreadyInserted = (index>0 && index != Int.max )
    //                if isAlreadyInserted {
    //                    break
    //                }
    //            }
    //
    //            if isAlreadyInserted == true {
    //                self.miniMizeThisRows(ar: ar)
    //            }
    //            else{
    //                var count:Int = indexPath.row + 1
    //                let arCells = NSMutableArray()
    //                for dInner in ar{
    //                    arCells.add(NSIndexPath.init(row: count, section: 0))
    //                    self.fileData.insert(dInner, at: count)
    //
    //                    let aa:NSIndexPath = NSIndexPath.init(row: count, section: 0)
    //                    tableView.insertRows(at: [aa as IndexPath], with: .none)
    //
    //                    count = count + 1
    //                }
    //
    //                //                tableView.insertRows(at: (arCells as NSArray) as! [IndexPath], with: .none)
    //
    //            }
    //            tableView.reloadRows(at: [indexPath], with: .none)
    //        }
  }
  
  //    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
  //
  //        var myCellHeight:CGFloat =  50.0
  //
  //        var myLabel = UILabel.init()
  //        myLabel.frame = CGRect(x: 15, y: 7, width: 261, height: 35)
  //        myLabel.numberOfLines = 0
  //
  //        myLabel.text = (self.fileData[indexPath.row] as AnyObject).value(forKey: "name") as? String
  //
  //        myLabel = Utility.setlableFrame(myLabel, fontSize: 15.0)
  //
  //        if (myLabel.frame.size.height < 20.0) {
  //            myLabel.frame = CGRect(x: 15, y: 7, width: 261, height: 35)
  //        }
  //
  //        if ((self.fileData[indexPath.row] as AnyObject).value(forKey: "name") as? String) != ""{
  //            myCellHeight = myLabel.frame.size.height
  //
  //        }
  //        else{
  //            myCellHeight = 50.0
  //        }
  //
  //        myCellHeight = myCellHeight + 14.0
  //
  //        return myCellHeight
  //
  //    }
  
  func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
    tableView.cellForRow(at: indexPath)?.accessoryType = .none
  }
  
  
  
  // MARK: - Button Action Methods
  
  @IBAction func btnBackliked(_ sender: UIButton) {
    //NotificationCenter.default.post(name: NSNotification.Name(rawValue: "callingMethodForBetryStatus"), object: nil)
    _ = self.navigationController?.popViewController(animated: true)
  }
  @IBAction func btnTextcliked(_ sender: UIButton) {
    
    if csvFilename == ""{
      showAlert(Appname, title: "Please Select CSV File")
    }
    else{
      self.readCSVData(fileName: csvFilename, goingToGraph: false)
      
    }
    
    
  }
  @IBAction func btnGraphClicked(_ sender: UIButton) {
    if csvFilename == ""{
      showAlert(Appname, title: "Please Select CSV File")
    }
    else{
      self.readCSVData(fileName: csvFilename, goingToGraph: true)
    }
  }
  
  @IBAction func btnDeleteClicked(_ sender: UIButton) {
    //self.removeCSV(filename: csvFilename)
    if csvFilename == ""{
      showAlert(Appname, title: "Please Select CSV File")
    }
    else{
      self.removeCSV(fileName: csvFilename)
    }
  }
  
  // MARK: - Other Methods
  
  func getCSVFilesFromDocumentDirectory(){
    
    // Get the document directory url
    let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    do {
      // Get the directory contents urls (including subfolders urls)
      let directoryContents = try FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil, options: [])
      print("directoryContent :-> ",directoryContents)
      
      // if you want to filter the directory contents you can do like this:
      let csvFiles = directoryContents.filter{ $0.pathExtension == "csv" }
      print("CSV urls:",csvFiles)
      let csvFileNames = csvFiles.map{ $0.deletingPathExtension().lastPathComponent
      }
      print("CSV list:", csvFileNames)
      
      //let arr = NSArray(array: csvFileNames)
      //let temp = arr.reverseObjectEnumerator().allObjects
      
      self.fileData = NSMutableArray(array: csvFileNames)
      
      
      if let userCSVDescription = USERDEFAULT.value(forKey: "userCSVFileData") as? NSArray
      {
        let description = userCSVDescription as NSArray
        // let temp = description.reverseObjectEnumerator().allObjects
        
        let descriptor: NSSortDescriptor = NSSortDescriptor(key: "filename", ascending: true, selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))
        let sortedResults = description.sortedArray(using: [descriptor])
        
        let finalData = NSArray(array: sortedResults)
        print("Final Data ",finalData)
        
        descriptionData = NSMutableArray(array: finalData)
        print("Description Data :->",descriptionData)
      }
      
      
      
      if self.fileData.count == 0 {
        lblNoData.isHidden = false
        tableFO.isHidden = true
      }
      else{
        lblNoData.isHidden = true
        tableFO.isHidden = false
      }
      
      tableFO.reloadData()
      
    } catch let error as NSError {
      print(error.localizedDescription)
    }
    
  }
  
  //    func removeCSV(filename: String) {
  //        let fileManager = FileManager.default
  //        let documentsPath: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
  //        let filePath: String = URL(fileURLWithPath: documentsPath).appendingPathComponent(filename).absoluteString
  //
  //        do{
  //            try fileManager.removeItem(atPath: filePath)
  //        }catch{
  //
  //        }
  //        self.getCSVFilesFromDocumentDirectory()
  //    }
  //
  func removeCSV(fileName:String) {
    let fileManager = FileManager.default
    let nsDocumentDirectory = FileManager.SearchPathDirectory.documentDirectory
    let nsUserDomainMask = FileManager.SearchPathDomainMask.userDomainMask
    let paths = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true)
    guard let dirPath = paths.first else {
      return
    }
    let filePath = "\(dirPath)/\(fileName)"
    do {
      try fileManager.removeItem(atPath: filePath)
    } catch let error as NSError {
      print(error.debugDescription)
    }
    
    //        if let userCSVDescription = USERDEFAULT.value(forKey: "userCSVFileData") as? NSArray
    //        {
    //            let description = NSMutableArray(array: userCSVDescription)
    descriptionData.removeObject(at: index)
    
    USERDEFAULT.set(descriptionData, forKey: "userCSVFileData")
    USERDEFAULT.synchronize()
    
    
    // }
    
    self.getCSVFilesFromDocumentDirectory()
    
    
    
  }
  
  func readCSVData(fileName:String, goingToGraph:Bool) {
    let nsDocumentDirectory = FileManager.SearchPathDirectory.documentDirectory
    let nsUserDomainMask = FileManager.SearchPathDomainMask.userDomainMask
    let paths = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true)
    guard let dirPath = paths.first else {
      return
    }
    
    let filePath = "\(dirPath)/\(fileName)"
    
    if !goingToGraph {
      let obj = TextViewVC()
      obj.filePath = filePath
      self.navigationController?.pushViewController(obj, animated: true)
      
      return
    }
    
    let file = try? String(contentsOfFile: filePath, encoding: String.Encoding.utf8)
    let allLines: [Any]? = file?.components(separatedBy: CharacterSet.newlines)
    print("All Lines :->\(allLines!)")
    
    
    let url = URL(fileURLWithPath: filePath)
    var aa:String!
    do {
      aa = try String(contentsOf: url)
    } catch{
      
    }
    
    let entries = NSMutableArray()
    for line: String in aa.components(separatedBy: "\n")
    {
      let rows: [Any] = line.components(separatedBy: ",")
      // ';' can be any separator, e.g. \t or just a comma
      //entries.append(rows)
      entries.add(rows)
    }
    print("abcdddd",entries)
    
    let myRecords : NSMutableArray = NSMutableArray()
    
    if entries.count > 0 {
      
      entries.removeObject(at: 0)
      
      if entries.count > 0 {
        
        entries.removeObject(at: entries.count - 1)
        
        for i in 0..<entries.count {
          
          print(entries[i])
          
          let myIndexObject : NSArray = entries[i] as! NSArray
          
          print(myIndexObject)
          
          let myData : NSMutableDictionary = NSMutableDictionary()
          myData.setValue(myIndexObject[0], forKey: "date")
          myData.setValue(myIndexObject[1], forKey: "time")
          
          let RH = myIndexObject[2] as! String
          let t1 = myIndexObject[3] as! String
          let t2 = myIndexObject[4] as! String
          let scale = myIndexObject[5] as! String
          
         /* if ( scale == "C" && MainCenteralManager.sharedInstance().data.cOrF == "F"){
            // c to f
            t1 =  String(format: "%.1f", (Float(t1)! * 1.8) + 32)
            t2 =  String(format: "%.1f", (Float(t2)! * 1.8) + 32)
            t3 =  String(format: "%.1f", (Float(t3)! * 1.8) + 32)
            t4 =  String(format: "%.1f", (Float(t4)! * 1.8) + 32)
            scale =  "F"
          }else if (scale == "F" && MainCenteralManager.sharedInstance().data.cOrF == "C"){
            //f to c
            t1 =  String(format: "%.1f",(Float(t1)! - 32) / 1.8)
            t2 =  String(format: "%.1f",(Float(t2)! - 32) / 1.8)
            t3 =  String(format: "%.1f",(Float(t3)! - 32) / 1.8)
            t4 =  String(format: "%.1f",(Float(t4)! - 32) / 1.8)
            scale =  "C"
          }
          */
          myData.setValue(RH, forKey: "RH")
          myData.setValue(t1, forKey: "T1")
          myData.setValue(t2, forKey: "T2")
          myData.setValue(scale, forKey: "scale")
        
          print(myData)
          myRecords.add(myData)
        }
      }
      
      print("myRecords", myRecords)
    }
    
    if goingToGraph {
      let obj = RealTimeGraphVC()
      obj.isFromDataDownload = true
      obj.myRecords = myRecords
      self.navigationController?.pushViewController(obj, animated: true)
    }
  }
  
  @IBAction func shareButtonPressed(_ sender: UIButton) {
    if csvFilename == ""{
      showAlert(Appname, title: "Please Select CSV File")
    }
    else{
      let activityItems: [Any] = [URL(fileURLWithPath: self.dataFilePath(fileName: csvFilename))]
      let shareScreen = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
      self.present(shareScreen, animated: true, completion: nil)
    }
  }
  
  func dataFilePath(fileName:String) -> String {
    //var paths: [Any] = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
    //let documentsDirectory: String = paths[0] as! String
    // return URL(fileURLWithPath: documentsDirectory).appendingPathComponent("").absoluteString
    
    let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
    let url = NSURL(fileURLWithPath: path)
    let filePath = url.appendingPathComponent(fileName)?.path
    return filePath!
  }
}
