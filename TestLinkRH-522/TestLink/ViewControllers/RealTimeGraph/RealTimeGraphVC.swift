//
//  RealTimeGraphVC.swift
//  TestLink
//
//  Created by Pritesh Pethani on 24/01/17.
//  Copyright © 2017 Pritesh Pethani. All rights reserved.
//

import UIKit

// Added By Martin
class XAxisValueFormatter: NSObject, IAxisValueFormatter {
    
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return self.getXAxisDisplayValue(seconds: Int(value))
    }
    
    func getXAxisDisplayValue(seconds : Int) -> String {
        //print("seconds123 ", seconds)
        
        if APPDELEGATE.xAxisValuesFinal == nil {
            return ""
        }
        
        if seconds < 0 {
            return ""
        }
        
        
        if APPDELEGATE.xAxisValuesFinal.count > seconds {
            
            //print("APPDELEGATE.xAxisValuesFinal", APPDELEGATE.xAxisValuesFinal)
            
            //print("String(APPDELEGATE.xAxisValuesFinal[seconds]) ", APPDELEGATE.xAxisValuesFinal[seconds] as! String)
            
            return APPDELEGATE.xAxisValuesFinal[seconds] as! String
        }
        
        return ""
//        let hours: Int = seconds / 3600
//        let remainder: Int = seconds % 3600
//        let minutes: Int = remainder / 60
//        let seconds: Int = remainder % 60
//        if hours > 0 {
//            return "\(hours)h \(minutes)m \(seconds)s"
//        }
//        else {
//            return "\(minutes)m \(seconds)s"
//        }
    }
}

// Added By Martin
class YAxisValueFormatter: NSObject, IAxisValueFormatter {
    
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return self.getYAxisDisplayValue(seconds: Int(value))
    }
    
    func getYAxisDisplayValue(seconds : Int) -> String {
        //print("seconds123 ", seconds)
        
        return "105"
        
        if APPDELEGATE.xAxisValuesFinal == nil {
            return ""
        }
        
        
        
        if seconds < 0 {
            return ""
        }
        
        
        if APPDELEGATE.xAxisValuesFinal.count > seconds {
            
            //print("APPDELEGATE.xAxisValuesFinal", APPDELEGATE.xAxisValuesFinal)
            
            //print("String(APPDELEGATE.xAxisValuesFinal[seconds]) ", APPDELEGATE.xAxisValuesFinal[seconds] as! String)
            
            return APPDELEGATE.xAxisValuesFinal[seconds] as! String
        }
        
        return ""
    }
}


class RealTimeGraphVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, CBPeripheralDelegate, CBCentralManagerDelegate, ChartViewDelegate {
    
    var centralManager: CBCentralManager? = nil
    var peripheral: CBPeripheral!
    var btServices :[BTServiceInfo] = []
    var lastString :NSString = ""
    var savedCharacteristic : CBCharacteristic?
    
    @IBOutlet var textView :UITextView!
    var currentBTServiceInfo :BTServiceInfo!
    
    //---------------------------
    
    @IBOutlet var viewAlarmTemp: UIView!
    var isFromDataDownload: Bool = false
    @IBOutlet var viewBottomPart: UIView!
    @IBOutlet var viewStepper: UIView!
    
    var path: IndexPath!

    @IBOutlet var lblTitle: UILabel!
    
    @IBOutlet var lblRecord: UILabel!
    @IBOutlet var btnRecord: UIButton!
    @IBOutlet var imageViewRecord: UIImageView!
    @IBOutlet var viewWriteCSV: UIView!

    @IBOutlet var txtCSVName: UITextField!
    @IBOutlet var txtCSVDescription: UITextView!

    var isRecord:Bool!//For checking recording is started or stopped
    
    @IBOutlet var viewPicker:UIView!
    @IBOutlet var pickerView:UIPickerView!
    var pickerSelIndx:Int!
    var pickOption:NSMutableArray!

    @IBOutlet var lblPickerValue:UILabel!

    @IBOutlet var btnT1:UIButton!
    @IBOutlet var btnT2:UIButton!
    @IBOutlet var btnT3:UIButton!
    @IBOutlet var btnT4:UIButton!
    
    @IBOutlet var lblT1Text:UILabel!
    @IBOutlet var lblT2Text:UILabel!
    @IBOutlet var lblT3Text:UILabel!
    @IBOutlet var lblT4Text:UILabel!

    @IBOutlet var lblNoRecord: UILabel!
    
    @IBOutlet var viewName:UIView!
    @IBOutlet var viewDescription:UIView!
    
    @IBOutlet var lineChartView:LineChartView!
    
    @IBOutlet var saveDataBtn: UIButton!
    //0774C6 , R7 G116 B198
    
    var dataSets:NSMutableArray!
    
    var set1 : LineChartDataSet? = nil
    var set2 : LineChartDataSet? = nil
    var set3 : LineChartDataSet? = nil
    var set4 : LineChartDataSet? = nil
    
    var myLineGraphdata: LineChartData!
    
    var yVals1 : NSMutableArray = NSMutableArray()
    var yVals2 : NSMutableArray = NSMutableArray()
    var yVals3 : NSMutableArray = NSMutableArray()
    var yVals4 : NSMutableArray = NSMutableArray()
    
    var xAxisCount:Int = 0
    
    var myCommandATimer : Timer!
    var mySavedDataTimer : Timer!
    var myMapDataTimer : Timer!
    
    var myRecords : NSMutableArray!
    var myDataArray : [UInt8]!
    
    var isT1Connected:Bool = true
    var isT2Connected:Bool = true
    var isT3Connected:Bool = true
    var isT4Connected:Bool = true
    
    var myDeviceType:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        yVals1 = NSMutableArray()
        yVals2 = NSMutableArray()
        yVals3 = NSMutableArray()
        yVals4 = NSMutableArray()
        
        APPDELEGATE.xAxisValuesFinal = NSMutableArray()
        APPDELEGATE.xAxisDatesValuesFinal = NSMutableArray()
        APPDELEGATE.xAxisScaleValuesFinal = NSMutableArray()
        
        if peripheral != nil {
            self.title = peripheral.name
            peripheral.delegate = self
            centralManager?.delegate = self
            centralManager?.connect(peripheral, options: nil)
            
            if peripheral.state == CBPeripheralState.connected {
                
            }
            //Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(self.btncommandA), userInfo: nil, repeats: false)
        }

        txtCSVDescription.placeholder = "Write Note"
        btnT1.layer.cornerRadius = btnT1.frame.size.width / 2
        btnT2.layer.cornerRadius = btnT1.frame.size.width / 2
        btnT3.layer.cornerRadius = btnT1.frame.size.width / 2
        btnT4.layer.cornerRadius = btnT1.frame.size.width / 2
        
        viewName.layer.masksToBounds = true
        viewName.layer.borderWidth = 1.0
        viewName.layer.borderColor = UIColor.black.cgColor
        
        viewDescription.layer.masksToBounds = true
        viewDescription.layer.borderWidth = 1.0
        viewDescription.layer.borderColor = UIColor.black.cgColor


        pickerSelIndx=0
        pickOption = NSMutableArray()

        for i in 1...60{
            pickOption.add("\(i)")
        }
        
        isRecord = false
        
        self.dynamicPropertySet()
        if isFromDataDownload {
            viewBottomPart.isHidden = true
        }
        else {
            viewBottomPart.isHidden = false
        }

        viewPicker.frame = CGRect(x: self.viewPicker.frame.origin.x, y: self.view.frame.size.height + self.view.frame.origin.y, width: viewPicker.frame.size.width, height: viewPicker.frame.size.height)

        self.addTapGestureInOurView()
        
        self.settingGraph()
        
        if isFromDataDownload {
            self.lblT1Text.text = ""
            self.lblT2Text.text = ""
            self.lblT3Text.text = ""
            self.lblT4Text.text = ""
            self.view.backgroundColor = UIColor.white
            lblTitle.text = "Graph View"
        }
        else{
            myCommandATimer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(self.btncommandA), userInfo: nil, repeats: true)
            
            let myInterval : TimeInterval = TimeInterval(Float(self.pickerSelIndx + 1))
            print("myInterval", myInterval)
            
            self.myMapDataTimer = Timer.scheduledTimer(timeInterval: myInterval, target: self, selector: #selector(self.setDataOnMap), userInfo: nil, repeats: true)
        }
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
      
      
//        self.centralManager = nil
//        self.peripheral = nil
        if (self.centralManager != nil && self.peripheral != nil){
            MainCenteralManager.sharedInstance().SetObject(centralManager: self.centralManager!, peripheral: self.peripheral)
        }
        if myCommandATimer != nil {
            myCommandATimer.invalidate()
        }
        
        if mySavedDataTimer != nil {
            mySavedDataTimer.invalidate()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Today's work on Graph
    // MARK: - CHARTVIEW METHODS
    
    func settingGraph (){
        self.lineChartView.delegate = self;
        
        self.lineChartView.chartDescription?.enabled = false;
        self.lineChartView.dragEnabled = true;
        self.lineChartView.setScaleEnabled(true)
        self.lineChartView.drawGridBackgroundEnabled = false;
        self.lineChartView.pinchZoomEnabled = true;
        
        self.lineChartView.backgroundColor = UIColor.white//[UIColor colorWithWhite:204/255.f alpha:1.f];
        
        //self.lineChartView.setVisibleXRange(minXRange: 0, maxXRange: 10)
        
        let l:Legend = self.lineChartView.legend
        l.form = .none
        l.textColor = UIColor.white
        l.horizontalAlignment = .left
        l.verticalAlignment = .top
        //l.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:11.f];
        l.orientation = .horizontal
        l.drawInside = true
        
        // Modify By Martin
        let xAxis : XAxis = self.lineChartView.xAxis
        xAxis.labelTextColor = UIColor.black
        xAxis.drawGridLinesEnabled = false
        xAxis.drawAxisLineEnabled = false
        xAxis.granularityEnabled = true
        xAxis.labelPosition = .bottom
        xAxis.valueFormatter = XAxisValueFormatter()
        xAxis.labelRotationAngle = -45
        
        // Modify My Martin
        let leftAxis : YAxis = self.lineChartView.leftAxis
        leftAxis.labelTextColor = UIColor.black
        leftAxis.axisLineColor = UIColor.clear
        leftAxis.drawGridLinesEnabled = false
        leftAxis.drawZeroLineEnabled = false
        leftAxis.granularityEnabled = false
        leftAxis.labelPosition = .outsideChart
        //leftAxis.valueFormatter = YAxisValueFormatter()
        
        // Added By Martin
        self.lineChartView.rightAxis.labelTextColor = UIColor.clear
        self.lineChartView.rightAxis.axisLineColor = UIColor.clear
        
        self.lineChartView.animate(xAxisDuration: 2.5)
        
        //If we are coming from FILE OPEN SCREEN
        if isFromDataDownload {
            
            if myRecords != nil {
                
                for i in 0..<myRecords.count {
                    
                    if ((myRecords[i] as AnyObject).value(forKey: "T1") as! String) != "--" &&
                        ((myRecords[i] as AnyObject).value(forKey: "T1") as! String) != "OL" &&
                        ((myRecords[i] as AnyObject).value(forKey: "T1") as! String) != "-OL"
                    {
                        yVals1.add(ChartDataEntry.init(x: Double(i), y: Double((myRecords[i] as AnyObject).value(forKey: "T1") as! String)!))
                    }
                    
                    if ((myRecords[i] as AnyObject).value(forKey: "T2") as! String) != "--" &&
                        ((myRecords[i] as AnyObject).value(forKey: "T2") as! String) != "OL" &&
                        ((myRecords[i] as AnyObject).value(forKey: "T2") as! String) != "-OL"
                    {
                        yVals2.add(ChartDataEntry.init(x: Double(i), y: Double((myRecords[i] as AnyObject).value(forKey: "T2") as! String)!))
                    }
                    
                    if ((myRecords[i] as AnyObject).value(forKey: "T3") as! String) != "--" &&
                        ((myRecords[i] as AnyObject).value(forKey: "T3") as! String) != "OL" &&
                        ((myRecords[i] as AnyObject).value(forKey: "T3") as! String) != "-OL"
                    {
                        yVals3.add(ChartDataEntry.init(x: Double(i), y: Double((myRecords[i] as AnyObject).value(forKey: "T3") as! String)!))
                    }
                    
                    if ((myRecords[i] as AnyObject).value(forKey: "T4") as! String) != "--" &&
                        ((myRecords[i] as AnyObject).value(forKey: "T4") as! String) != "OL" &&
                        ((myRecords[i] as AnyObject).value(forKey: "T4") as! String) != "-OL"
                    {
                        yVals4.add(ChartDataEntry.init(x: Double(i), y: Double((myRecords[i] as AnyObject).value(forKey: "T4") as! String)!))
                    }
                    
                    
                    APPDELEGATE.xAxisValuesFinal.add((myRecords[i] as AnyObject).value(forKey: "time") as! String)
                    
                    APPDELEGATE.xAxisDatesValuesFinal.add((myRecords[i] as AnyObject).value(forKey: "date") as! String)
                    
                    APPDELEGATE.xAxisScaleValuesFinal.add((myRecords[i] as AnyObject).value(forKey: "scale") as! String)
                }
                
                //print("APPDELEGATE.xAxisValuesFinal", APPDELEGATE.xAxisValuesFinal)
                //print("APPDELEGATE.xAxisDatesValuesFinal", APPDELEGATE.xAxisDatesValuesFinal)
                
                
                if myRecords.count == 0 {
                    return
                }
                
                xAxisCount = myRecords.count
                
                print("xAxisCount : ", xAxisCount)
                
                self.graphSetup()
            }
        }
    }
    
    
    func setDataCount(t1: String, t2:String, t3:String, t4:String, scale:String, seventhByte:UInt8) {
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        //let result = formatter.string(from: date)
        
        let calendar = NSCalendar.current
        let currentDate = calendar.component(.day, from: date as Date)
        let currentMonth = calendar.component(.month, from: date as Date)
        let currentYear = calendar.component(.year, from: date as Date)
        
        
        let hour = calendar.component(.hour, from: date as Date)
        let minutes = calendar.component(.minute, from: date as Date)
        let seconds = calendar.component(.second, from: date as Date)
        
        //        myData.setValue(result, forKey: "date")
        //        myData.setValue(String(format:"%02d:%02d:%02d", hour, minutes, seconds), forKey: "time")
        
        //return String(format:"%02d:%02d:%02d", hour, minutes, seconds)
        
        APPDELEGATE.xAxisValuesFinal.add(String(format:"%02d:%02d:%02d", hour, minutes, seconds))
        
        APPDELEGATE.xAxisDatesValuesFinal.add(String(format:"%04d/%02d/%02d", currentYear, currentMonth, currentDate))
        
        APPDELEGATE.xAxisScaleValuesFinal.add(scale)
        
        //print("APPDELEGATE.xAxisValuesFinal", APPDELEGATE.xAxisValuesFinal)
        //print("APPDELEGATE.xAxisDatesValuesFinal", APPDELEGATE.xAxisDatesValuesFinal)
        
        var isData1 = false
        
        let byte7 = self.converToBinary(x1: seventhByte)
        
        if (byte7[3] == "1"){
            isData1 = false
            self.lblT1Text.text = "Unplug"
        }
        else if Float(t1 as String)! > MainCenteralManager.sharedInstance().getMaxValue(temperatureType: scale, deviceType: myDeviceType) {
            isData1 = false
            self.lblT1Text.text = "OL"
        }
        else if Float(t1 as String)! < MainCenteralManager.sharedInstance().getMinValue(temperatureType: scale, deviceType: myDeviceType){
            isData1 = false
            self.lblT1Text.text = "-OL"
        }
        else {
            // Added By Martin
            isData1 = true
            self.lblT1Text.text = t1
            yVals1.add(ChartDataEntry.init(x: Double(xAxisCount), y: Double(t1)!))
        }
        
//        if Float(t1 as String)! > MaxTempValue || Float(t1 as String)! < MinTempValue {
//            self.lblT1Text.text = "Unplug"
//        }
//        else {
//            // Added By Martin
//            self.lblT1Text.text = t1
//            yVals1.add(ChartDataEntry.init(x: Double(xAxisCount), y: Double(t1)!))
//        }
        
        var isData2 = false
        
        if (byte7[2] == "1"){
            isData2 = false
            self.lblT2Text.text = "Unplug"
        }
        else if Float(t2 as String)! > MainCenteralManager.sharedInstance().getMaxValue(temperatureType: scale, deviceType: myDeviceType) {
            isData2 = false
            self.lblT2Text.text = "OL"
        }
        else if Float(t2 as String)! < MainCenteralManager.sharedInstance().getMinValue(temperatureType: scale, deviceType: myDeviceType){
            isData2 = false
            self.lblT2Text.text = "-OL"
        }
        else {
            // Added By Martin
            isData2 = true
            self.lblT2Text.text = t2
            yVals2.add(ChartDataEntry.init(x: Double(xAxisCount), y: Double(t2)!))
        }
        
        
        
//        if Float(t2 as String)! > MaxTempValue || Float(t2 as String)! < MinTempValue {
//            self.lblT2Text.text = "Unplug"
//        }
//        else {
//            // Added By Martin
//            self.lblT2Text.text = t2
//            yVals2.add(ChartDataEntry.init(x: Double(xAxisCount), y: Double(t2)!))
//        }
        
        var isData3 = false
        
        if (byte7[1] == "1"){
            isData3 = false
            self.lblT3Text.text = "Unplug"
        }
        else if Float(t3 as String)! > MainCenteralManager.sharedInstance().getMaxValue(temperatureType: scale, deviceType: myDeviceType) {
            isData3 = false
            self.lblT3Text.text = "OL"
        }
        else if Float(t3 as String)! < MainCenteralManager.sharedInstance().getMinValue(temperatureType: scale, deviceType: myDeviceType){
            isData3 = false
            self.lblT3Text.text = "-OL"
        }
        else {
            // Added By Martin
            isData3 = true
            self.lblT3Text.text = t3
            yVals3.add(ChartDataEntry.init(x: Double(xAxisCount), y: Double(t3)!))
        }
        
//        if Float(t3 as String)! > MaxTempValue || Float(t3 as String)! < MinTempValue {
//            self.lblT3Text.text = "Unplug"
//        }
//        else {
//            // Added By Martin
//            self.lblT3Text.text = t3
//            yVals3.add(ChartDataEntry.init(x: Double(xAxisCount), y: Double(t3)!))
//        }
        
        var isData4 = false
        
        if (byte7[0] == "1"){
            isData4 = false
            self.lblT4Text.text = "Unplug"
        }
        else if Float(t4 as String)! > MainCenteralManager.sharedInstance().getMaxValue(temperatureType: scale, deviceType: myDeviceType) {
            isData4 = false
            self.lblT4Text.text = "OL"
        }
        else if Float(t4 as String)! < MainCenteralManager.sharedInstance().getMinValue(temperatureType: scale, deviceType: myDeviceType){
            isData4 = false
            self.lblT4Text.text = "-OL"
        }
        else {
            // Added By Martin
            isData4 = true
            self.lblT4Text.text = t4
            yVals4.add(ChartDataEntry.init(x: Double(xAxisCount), y: Double(t4)!))
        }
        
//        if Float(t4 as String)! > MaxTempValue || Float(t4 as String)! < MinTempValue {
//            self.lblT4Text.text = "Unplug"
//        }
//        else {
//            // Added By Martin
//            self.lblT4Text.text = t4
//            yVals4.add(ChartDataEntry.init(x: Double(xAxisCount), y: Double(t4)!))
//        }
        
        // Comment By Martin: Currently Sample Rate is 1 that's why it's working fine but then we change the sample rate then we have to change increment logic according to sample rate to disply proper seconds value on graph.
        
        if !isData1 && !isData2 && !isData3 && !isData4 {
            print("Unplug")
        }
        else {
            xAxisCount = xAxisCount + 1
            self.graphSetup()
        }
    }
    
    func graphSetup() {
        
        if self.lineChartView.data?.dataSetCount != nil {
            self.setLinesOnGraph()
        }
        else{
            let line1Color = UUColor.init(red: 244.0/255.0, green: 165.0/255.0, blue: 34.0/255.0, alpha: 1.0)
            set1 = LineChartDataSet.init(values: NSArray(array: yVals1) as? [ChartDataEntry], label: "A")
            set1?.axisDependency = .left;
            set1?.setColor(line1Color)
            set1?.setCircleColor(line1Color)
            set1?.lineWidth = 1.0
            set1?.circleRadius = 2.0
            set1?.fillAlpha = 65/255.0
            set1?.fillColor = line1Color
            set1?.highlightColor = line1Color
            set1?.drawCircleHoleEnabled = false
            
            let line2Color = UUColor.init(red: 15.0/255.0, green: 70.0/255.0, blue: 144.0/255.0, alpha: 1.0)
            set2 = LineChartDataSet.init(values: NSArray(array: yVals2) as? [ChartDataEntry], label: "B")
            set2?.axisDependency = .left;  // Modify By Martin
            set2?.setColor(line2Color)
            set2?.setCircleColor(line2Color)
            set2?.lineWidth = 1.0
            set2?.circleRadius = 2.0
            set2?.fillAlpha = 65/255.0
            set2?.fillColor = line2Color
            set2?.highlightColor = line2Color
            set2?.drawCircleHoleEnabled = false
            
            let line3Color = UUColor.init(red: 0.0/255.0, green: 213.0/255.0, blue: 126.0/255.0, alpha: 1.0)
            set3 = LineChartDataSet.init(values: NSArray(array: yVals3) as? [ChartDataEntry], label: "C")
            set3?.axisDependency = .left;   // Modify By Martin
            set3?.setColor(line3Color)
            set3?.setCircleColor(line3Color)
            set3?.lineWidth = 1.0
            set3?.circleRadius = 2.0
            set3?.fillAlpha = 65/255.0
            set3?.fillColor = line3Color
            set3?.highlightColor = line3Color
            set3?.drawCircleHoleEnabled = false
            
            let line4Color =  UUColor.init(red: 255.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1.0)
            set4 = LineChartDataSet.init(values: NSArray(array: yVals4) as? [ChartDataEntry], label: "D")
            set4?.axisDependency = .left;  // Modify By Martin
            set4?.setColor(line4Color)
            set4?.setCircleColor(line4Color)
            set4?.lineWidth = 1.0
            set4?.circleRadius = 2.0
            set4?.fillAlpha = 65/255.0
            set4?.fillColor = line4Color
            set4?.highlightColor = line4Color
            set4?.drawCircleHoleEnabled = false
            
            dataSets = NSMutableArray.init()
            //Commented by Meet
            dataSets.add(set1!)
            dataSets.add(set2!)
            dataSets.add(set3!)
            dataSets.add(set4!)
            
            // Modifyed By Martin.
            myLineGraphdata = LineChartData.init(dataSets: NSArray(array: dataSets) as? [IChartDataSet])
            
            myLineGraphdata.setDrawValues(false)
            myLineGraphdata.setValueTextColor(UIColor.white)
            self.lineChartView.data = myLineGraphdata
            
            self.lineChartView.xAxis.axisMaximum = Double(xAxisCount)
            self.lineChartView.setVisibleXRangeMaximum(18)
            self.lineChartView.setVisibleYRangeMaximum(10, axis: .left)
            
            //self.lineChartView.setVisibleYRangeMinimum(0, axis: .left)
            
            if xAxisCount > 0 {
                self.lineChartView.moveViewToX(Double(xAxisCount - 1))
            }
        }
    }
    
    func setLinesOnGraph() {
        set1?.values = NSArray(array: yVals1) as! [ChartDataEntry]
        set2?.values = NSArray(array: yVals2) as! [ChartDataEntry]
        set3?.values = NSArray(array: yVals3) as! [ChartDataEntry]
        set4?.values = NSArray(array: yVals4) as! [ChartDataEntry]
        
        if self.lblNoRecord.isHidden == false {
            var myCount:Int = 0
            
            if dataSets.contains(set1!) && yVals1.count == 0 {
                myCount += 1
            }
            if dataSets.contains(set2!) && yVals2.count == 0 {
                myCount += 1
            }
            if dataSets.contains(set3!) && yVals3.count == 0 {
                myCount += 1
            }
            if dataSets.contains(set4!) && yVals4.count == 0 {
                myCount += 1
            }
            
            if dataSets.count > 0 && dataSets.count != myCount {
                
                self.lblNoRecord.isHidden = true
                self.lineChartView.isHidden = false
                
                myLineGraphdata = LineChartData.init(dataSets: NSArray(array: dataSets!) as? [IChartDataSet])
                myLineGraphdata.setValueTextColor(UIColor.white)
                self.lineChartView.data = myLineGraphdata
            }

        }
        
        self.lineChartView.data?.notifyDataChanged()
        self.lineChartView.notifyDataSetChanged()
        
        //print("setLinesOnGraph called")
        
        //print("xAxisCount called - ",xAxisCount)
        
        self.lineChartView.xAxis.axisMaximum = Double(xAxisCount)
        self.lineChartView.setVisibleXRangeMaximum(18)
        self.lineChartView.setVisibleYRangeMaximum(10, axis: .left)
        //self.lineChartView.setVisibleYRangeMinimum(0, axis: .left)
        
        if xAxisCount > 0 {
            self.lineChartView.moveViewToX(Double(xAxisCount - 1))
        }
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        
        print("chartValueSelected : x = \(highlight.x) y = \(highlight.y)")
        
        var myAlertMsg:String = ""
        
//        var set2 = LineChartDataSet()
//        set2 = (chartView.data?.dataSets[1] as? LineChartDataSet)!
//        let values2 = set2.values
//        //print("values : ", values)
//        let index2 = values2.index(where: {$0.x == highlight.x})  // search index
//        print("index2 : ", index2 ?? "ABC")
//        
//        if index2 != nil {
//            let myChartDataEntry2:ChartDataEntry = values2[index2!]
//            print("values2[index2] - 2nd set : ", myChartDataEntry2)
//            print("myChartDataEntry2.y - 2nd set : ", myChartDataEntry2.y)
//            
//            if myAlertMsg == "" {
//                myAlertMsg = "T2 : \(myChartDataEntry2.y)"
//            }
//            else {
//                myAlertMsg = myAlertMsg+"\nT2 : \(myChartDataEntry2.y)"
//            }
//        }
        
        
        if dataSets.contains(set1!) {
            //var set1 = LineChartDataSet()
            //set1 = (chartView.data?.dataSets[0] as? LineChartDataSet)!
            let values1 = self.set1?.values
            //print("values : ", values)
            let index1 = values1?.index(where: {$0.x == highlight.x})  // search index
            print("index1 : ", index1 ?? "ABC")
            if index1 != nil {
                let myChartDataEntry1:ChartDataEntry = values1![index1!]
                print("values1[index1] - 1st set : ", myChartDataEntry1)
                print("myChartDataEntry.y - 1st set : ", myChartDataEntry1.y)
                
                if myAlertMsg == "" {
                    myAlertMsg = "\(APPDELEGATE.xAxisDatesValuesFinal[index1!] as! String) \(APPDELEGATE.xAxisValuesFinal[index1!] as! String)"
                    myAlertMsg = myAlertMsg+"\nT1 = \(myChartDataEntry1.y)\u{00B0} \(APPDELEGATE.xAxisScaleValuesFinal[index1!] as! String)"
                }
                else {
                    myAlertMsg = myAlertMsg+"\nT1 = \(myChartDataEntry1.y)\u{00B0} \(APPDELEGATE.xAxisScaleValuesFinal[index1!] as! String)"
                }
            }
        }
        
        if dataSets.contains(set2!) {
//            var set2 = LineChartDataSet()
//            set2 = (chartView.data?.dataSets[1] as? LineChartDataSet)!
            let values2 = self.set2?.values
            //print("values : ", values)
            let index2 = values2?.index(where: {$0.x == highlight.x})  // search index
            print("index2 : ", index2 ?? "ABC")
            
            if index2 != nil {
                let myChartDataEntry2:ChartDataEntry = values2![index2!]
                print("values2[index2] - 2nd set : ", myChartDataEntry2)
                print("myChartDataEntry2.y - 2nd set : ", myChartDataEntry2.y)
                
                if myAlertMsg == "" {
                    myAlertMsg = "\(APPDELEGATE.xAxisDatesValuesFinal[index2!] as! String) \(APPDELEGATE.xAxisValuesFinal[index2!] as! String)"
                    myAlertMsg = myAlertMsg+"\nT2 = \(myChartDataEntry2.y)\u{00B0} \(APPDELEGATE.xAxisScaleValuesFinal[index2!] as! String)"
                }
                else {
                    myAlertMsg = myAlertMsg+"\nT2 = \(myChartDataEntry2.y)\u{00B0} \(APPDELEGATE.xAxisScaleValuesFinal[index2!] as! String)"
                }
            }
        }
        
        if dataSets.contains(set3!) {
//            var set3 = LineChartDataSet()
//            set3 = (chartView.data?.dataSets[2] as? LineChartDataSet)!
            let values3 = self.set3?.values
            //print("values : ", values)
            let index3 = values3?.index(where: {$0.x == highlight.x})  // search index
            print("index3 : ", index3 ?? "ABC")
            if index3 != nil {
                let myChartDataEntry3:ChartDataEntry = values3![index3!]
                print("values3[index3] - 3rd set : ", myChartDataEntry3)
                print("myChartDataEntry3.y - 3rd set : ", myChartDataEntry3.y)
                
                if myAlertMsg == "" {
                    myAlertMsg = "\(APPDELEGATE.xAxisDatesValuesFinal[index3!] as! String) \(APPDELEGATE.xAxisValuesFinal[index3!] as! String)"
                    myAlertMsg = myAlertMsg+"\nT3 = \(myChartDataEntry3.y)\u{00B0} \(APPDELEGATE.xAxisScaleValuesFinal[index3!] as! String)"
                }
                else {
                    myAlertMsg = myAlertMsg+"\nT3 = \(myChartDataEntry3.y)\u{00B0} \(APPDELEGATE.xAxisScaleValuesFinal[index3!] as! String)"
                }
            }
        }
        
        
        if dataSets.contains(set4!) {
//            var set4 = LineChartDataSet()
//            set4 = (chartView.data?.dataSets[3] as? LineChartDataSet)!
            let values4 = self.set4?.values
            //print("values : ", values)
            let index4 = values4?.index(where: {$0.x == highlight.x})  // search index
            print("index4 : ", index4 ?? "ABC")
            if index4 != nil {
                let myChartDataEntry4:ChartDataEntry = values4![index4!]
                print("values4[index4] - 4th set : ", myChartDataEntry4)
                print("myChartDataEntry4.y - 4th set : ", myChartDataEntry4.y)
                
                if myAlertMsg == "" {
                    myAlertMsg = "\(APPDELEGATE.xAxisDatesValuesFinal[index4!] as! String) \(APPDELEGATE.xAxisValuesFinal[index4!] as! String)"
                    myAlertMsg = myAlertMsg+"\nT4 = \(myChartDataEntry4.y)\u{00B0} \(APPDELEGATE.xAxisScaleValuesFinal[index4!] as! String)"
                }
                else {
                    myAlertMsg = myAlertMsg+"\nT4 = \(myChartDataEntry4.y)\u{00B0} \(APPDELEGATE.xAxisScaleValuesFinal[index4!] as! String)"
                }
            }
        }
        
        //APPDELEGATE.window.makeToast(myAlertMsg)
        self.view.makeToast(myAlertMsg)
        
        self.lineChartView.centerViewToAnimated(xValue: entry.x, yValue: entry.y, axis: (self.lineChartView.data?.getDataSetByIndex(highlight.dataSetIndex).axisDependency)!, duration: 1.0)
    }
    
    
    func addTapGestureInOurView(){
        let tapRecognizer:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.backgroundTap(_:)))
        tapRecognizer.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapRecognizer)
    }
    
    @IBAction func backgroundTap(_ sender:UITapGestureRecognizer){
        
        let point:CGPoint = sender.location(in: sender.view)
        let viewTouched = view.hitTest(point, with: nil)
        
        
        if viewTouched!.isKind(of: UIButton.self) && viewTouched!.isKind(of:UITextView.self){
            
        }
        else{
            self.view.endEditing(true)
            //            scrMain.setContentOffset(CGPoint(x: 0.0, y: 0.0), animated: true)
            
            
            if (viewTouched!.superview!.superview == viewPicker) {
            }else if(viewTouched!.superview == viewPicker){
            }else if(viewTouched == viewPicker){
            }else{
                UIView.animate(withDuration: 0.3) {
                    
                    self.viewPicker.frame=CGRect(x: self.view.frame.size.width - self.viewPicker.frame.size.width, y: self.view.frame.size.height + self.view.frame.origin.y, width: self.viewPicker.frame.size.width, height: self.viewPicker.frame.size.height)
                }
            }
        }
    }

    // MARK: - BUTTON ACTION METHODS
    //  The converted code is limited by 2 KB.
    //  Upgrade your plan to remove this limitation.
    @IBAction func btnBackliked(_ sender: UIButton) {
        //NotificationCenter.default.post(name: NSNotification.Name(rawValue: "callingMethodForBetryStatus"), object: nil)
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func dynamicPropertySet() {
        viewStepper.layer.borderWidth = 1
        viewStepper.layer.borderColor = UIColor(red: CGFloat(72.0 / 255.0), green: CGFloat(72.0 / 255.0), blue: CGFloat(72.0 / 255.0), alpha: CGFloat(1.0)).cgColor
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        viewAlarmTemp.removeFromSuperview()
    }
    
    // MARK: - PICKERVIEW DELEGATE
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.pickOption.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.pickOption[row]  as? String
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 50.0
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        let label = UILabel()
        label.textAlignment = NSTextAlignment.center
        
        label.font = UIFont.systemFont(ofSize: 20.0)
        label.text = self.pickOption[row]  as? String
        
        return label
    }
    
    
    // MARK: - @Action Methods
    @IBAction func btnAddStaticData(_ sender: UIButton) {
        self.setDataCount(t1: "10", t2: "40", t3: "50", t4: "30", scale: "C", seventhByte: 0)
    }
    
    @IBAction func btnShowHideGraphLines(_ sender: UIButton) {
        
        if dataSets == nil {
            return
        }
        
        if sender.tag == 10 {
            
            //if set1 != nil {
                if dataSets.contains(set1!) {
                    dataSets.remove(set1!)
                    sender.backgroundColor = UIColor.gray
                }
                else{
                    dataSets.add(set1!)
                    if #available(iOS 10.0, *) {
                        sender.backgroundColor = UIColor(displayP3Red: 244/255, green: 165/255, blue: 34/255, alpha: 1.0)
                    } else {
                        sender.backgroundColor = UIColor(red: 244/255, green: 165/255, blue: 34/255, alpha:  1.0)
                    }
                }
            //}
        }
        else if sender.tag == 11 {
            if dataSets.contains(set2!) {
                dataSets.remove(set2!)
                sender.backgroundColor = UIColor.gray
            }
            else{
                dataSets.add(set2!)
                if #available(iOS 10.0, *) {
                    sender.backgroundColor = UIColor(displayP3Red: 15/255, green: 70/255, blue: 144/255, alpha: 1.0)
                } else {
                    sender.backgroundColor = UIColor(red: 15/255, green: 70/255, blue: 144/255, alpha:  1.0)
                }
            }
        }
        else if sender.tag == 12 {
            if dataSets.contains(set3!) {
                dataSets.remove(set3!)
                sender.backgroundColor = UIColor.gray
            }
            else{
                dataSets.add(set3!)
                if #available(iOS 10.0, *) {
                    sender.backgroundColor = UIColor(displayP3Red: 0/255, green: 213/255, blue: 126/255, alpha: 1.0)
                } else {
                    sender.backgroundColor = UIColor(red: 0/255, green: 213/255, blue: 126/255, alpha:  1.0)
                }
                
            }
        }
        else if sender.tag == 13 {
            if dataSets.contains(set4!) {
                dataSets.remove(set4!)
                sender.backgroundColor = UIColor.gray
            }
            else{
                dataSets.add(set4!)
                if #available(iOS 10.0, *) {
                    sender.backgroundColor = UIColor(displayP3Red: 255/255, green: 0/255, blue: 0/255, alpha: 1.0)
                } else {
                    sender.backgroundColor = UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha:  1.0)
                }
            }
        }
        
        print("btnShowHideGraphLines called")
        
        var myCount:Int = 0
        
        if dataSets.contains(set1!) && yVals1.count == 0 {
            myCount += 1
        }
        if dataSets.contains(set2!) && yVals2.count == 0 {
            myCount += 1
        }
        if dataSets.contains(set3!) && yVals3.count == 0 {
            myCount += 1
        }
        if dataSets.contains(set4!) && yVals4.count == 0 {
            myCount += 1
        }
        
        if dataSets.count == 0 || dataSets.count == myCount {
            print("dataSets are blank.")
            self.lblNoRecord.isHidden = false
            self.lineChartView.isHidden = true
            //"No chart data available."
        }
        else{
            self.lblNoRecord.isHidden = true
            self.lineChartView.isHidden = false
            
            myLineGraphdata = LineChartData.init(dataSets: NSArray(array: dataSets!) as? [IChartDataSet])
            myLineGraphdata.setValueTextColor(UIColor.white)
            self.lineChartView.data = myLineGraphdata
            self.lineChartView.data?.notifyDataChanged()
            self.lineChartView.notifyDataSetChanged()
        }
    }
    
    @IBAction func btnClockliked(_ sender: UIButton) {
        self.view.addSubview(viewAlarmTemp)
    }
    
    @IBAction func btnResetcliked(_ sender: UIButton) {
        
        //Without any data, we can not able to reset the data
        if myDataArray == nil {
            return
        }
        
        if myDataArray.count == 0 {
            return
        }
        
//        if isRecord == true{
//            APPDELEGATE.window.makeToast("Please stop the recording first.")
//            return
//        }
        
        yVals1 = NSMutableArray()
        yVals2 = NSMutableArray()
        yVals3 = NSMutableArray()
        yVals4 = NSMutableArray()
        self.graphSetup()
    }
    
    @IBAction func btnStartRecordClicked(_ sender: UIButton) {
        
        if isRecord == true{
            
            txtCSVName.text = ""
            txtCSVDescription.text = ""
            
            self.view.addSubview(viewWriteCSV)
            
            isRecord = false
            lblRecord.text = "RECORD"
            imageViewRecord.image = UIImage.init(named: "record.png")
            
            if myRecords != nil {
                print(myRecords)
            }
            
            if mySavedDataTimer != nil {
                mySavedDataTimer.invalidate()
            }
            
            //N
            
            self.saveDataBtn.isEnabled = false
            self.saveDataBtn.backgroundColor = UIColor.darkGray

        }
        else{
            
            //Without any data, we can not able to start the recording
            if myDataArray == nil {
                return
            }
            
            if myDataArray.count == 0 {
                return
            }
            
            myRecords = NSMutableArray()
            
            self.setSavedDataTrue()
            let myInterval : TimeInterval = TimeInterval(Float(self.pickerSelIndx + 1))
            print("myInterval", myInterval)
            
            self.mySavedDataTimer = Timer.scheduledTimer(timeInterval: myInterval, target: self, selector: #selector(self.setSavedDataTrue), userInfo: nil, repeats: true)
            
            isRecord = true
            lblRecord.text = "STOP"
            imageViewRecord.image = UIImage.init(named: "stop.png")
            
            //N
            self.saveDataBtn.isEnabled = true
            self.saveDataBtn.backgroundColor = UIColor(red: 0.027, green: 0.455, blue: 0.776, alpha: 1)
        }
    }
    
    @objc func setDataOnMap(){
        //Without any data, we can not able to start the recording
        if myDataArray == nil {
            return
        }
        
        if myDataArray.count == 0 {
            return
        }
        
        if myRecords == nil {
            myRecords = NSMutableArray()
        }
        
        let byte3 = self.converToBinary(x1: myDataArray[2])
        
        let byte7 = self.converToBinary(x1: myDataArray[6])
        
        if (byte7[3] == "1"){
            self.isT1Connected = false
        }
        else{
            self.isT1Connected = true
        }
        
        if (byte7[2] == "1"){
            self.isT2Connected = false
        }
        else{
            self.isT2Connected = true
        }
        
        if (byte7[1] == "1"){
            self.isT3Connected = false
        }
        else{
            self.isT3Connected = true
        }
        
        if (byte7[0] == "1"){
            self.isT4Connected = false
        }
        else{
            self.isT4Connected = true
        }
        
        myDeviceType = MainCenteralManager.sharedInstance().getDeviceType(value: myDataArray[5])
        //self.getDeviceType(value: byteArray[5])
        
        if (byte3[0] == "1")
        {
            //self.tempType = "C"
            self.setDataCount(t1: self.getCelsius(x1: myDataArray[9], x2: myDataArray[10]), t2: self.getCelsius(x1: myDataArray[11], x2: myDataArray[12]), t3: self.getCelsius(x1: myDataArray[13], x2: myDataArray[14]), t4: self.getCelsius(x1: myDataArray[15], x2: myDataArray[16]), scale: "C", seventhByte: myDataArray[6])
        }
        else
        {
            //self.tempType = "F"
            self.setDataCount(t1: self.getFahrenheit(x1: myDataArray[9], x2: myDataArray[10]), t2: self.getFahrenheit(x1: myDataArray[11], x2: myDataArray[12]), t3: self.getFahrenheit(x1: myDataArray[13], x2: myDataArray[14]), t4: self.getFahrenheit(x1: myDataArray[15], x2: myDataArray[16]), scale: "F", seventhByte: myDataArray[6])
        }
    }
    
    
    @objc func setSavedDataTrue() {

        let myData : NSMutableDictionary = NSMutableDictionary()
        
        let byte3 = self.converToBinary(x1: myDataArray[2])
        
        let byte7 = self.converToBinary(x1: myDataArray[6])
        
        if (byte3[0] == "1")
        {
            //self.tempType = "C"
            myData.setValue("C", forKey: "scale")
            
            if (byte7[3] == "1"){
                myData.setValue("--", forKey: "T1")
            }
            else if Float(self.getCelsius(x1: myDataArray[9], x2: myDataArray[10]) as String)! > MainCenteralManager.sharedInstance().getMaxValue(temperatureType: "C", deviceType: myDeviceType) {
                myData.setValue("OL", forKey: "T1")
            }
            else if Float(self.getCelsius(x1: myDataArray[9], x2: myDataArray[10]) as String)! < MainCenteralManager.sharedInstance().getMinValue(temperatureType: "C", deviceType: myDeviceType){
                myData.setValue("-OL", forKey: "T1")
            }
            else {
                myData.setValue(self.getCelsius(x1: myDataArray[9], x2: myDataArray[10]), forKey: "T1")
            }
            
//            if Float(self.getCelsius(x1: myDataArray[9], x2: myDataArray[10]) as String)! > MaxTempValue || Float(self.getCelsius(x1: myDataArray[9], x2: myDataArray[10]) as String)! > MinTempValue {
//                myData.setValue("--", forKey: "T1")
//            }
//            else{
//                myData.setValue(self.getCelsius(x1: myDataArray[9], x2: myDataArray[10]), forKey: "T1")
//            }
            
            if (byte7[2] == "1"){
                myData.setValue("--", forKey: "T2")
            }
            else if Float(self.getCelsius(x1: myDataArray[11], x2: myDataArray[12]) as String)! > MainCenteralManager.sharedInstance().getMaxValue(temperatureType: "C", deviceType: myDeviceType) {
                myData.setValue("OL", forKey: "T2")
            }
            else if Float(self.getCelsius(x1: myDataArray[11], x2: myDataArray[12]) as String)! < MainCenteralManager.sharedInstance().getMinValue(temperatureType: "C", deviceType: myDeviceType){
                myData.setValue("-OL", forKey: "T2")
            }
            else {
                myData.setValue(self.getCelsius(x1: myDataArray[11], x2: myDataArray[12]), forKey: "T2")
            }
            
//            if Float(self.getCelsius(x1: myDataArray[11], x2: myDataArray[12]) as String)! > MaxTempValue || Float(self.getCelsius(x1: myDataArray[11], x2: myDataArray[12]) as String)! > MinTempValue {
//                myData.setValue("--", forKey: "T2")
//            }
//            else{
//                myData.setValue(self.getCelsius(x1: myDataArray[11], x2: myDataArray[12]), forKey: "T2")
//            }
            
            if (byte7[1] == "1"){
                myData.setValue("--", forKey: "T3")
            }
            else if Float(self.getCelsius(x1: myDataArray[13], x2: myDataArray[14]) as String)! > MainCenteralManager.sharedInstance().getMaxValue(temperatureType: "C", deviceType: myDeviceType) {
                myData.setValue("OL", forKey: "T3")
            }
            else if Float(self.getCelsius(x1: myDataArray[13], x2: myDataArray[14]) as String)! < MainCenteralManager.sharedInstance().getMinValue(temperatureType: "C", deviceType: myDeviceType){
                myData.setValue("-OL", forKey: "T3")
            }
            else {
                myData.setValue(self.getCelsius(x1: myDataArray[13], x2: myDataArray[14]), forKey: "T3")
            }
            
//            if Float(self.getCelsius(x1: myDataArray[13], x2: myDataArray[14]) as String)! > MaxTempValue || Float(self.getCelsius(x1: myDataArray[13], x2: myDataArray[14]) as String)! > MinTempValue {
//                myData.setValue("--", forKey: "T3")
//            }
//            else{
//                myData.setValue(self.getCelsius(x1: myDataArray[13], x2: myDataArray[14]), forKey: "T3")
//            }
            
            if (byte7[0] == "1"){
                myData.setValue("--", forKey: "T4")
            }
            else if Float(self.getCelsius(x1: myDataArray[15], x2: myDataArray[16]) as String)! > MainCenteralManager.sharedInstance().getMaxValue(temperatureType: "C", deviceType: myDeviceType) {
                myData.setValue("OL", forKey: "T4")
            }
            else if Float(self.getCelsius(x1: myDataArray[15], x2: myDataArray[16]) as String)! < MainCenteralManager.sharedInstance().getMinValue(temperatureType: "C", deviceType: myDeviceType){
                myData.setValue("-OL", forKey: "T4")
            }
            else {
                myData.setValue(self.getCelsius(x1: myDataArray[15], x2: myDataArray[16]), forKey: "T4")
            }
            
//            if Float(self.getCelsius(x1: myDataArray[15], x2: myDataArray[16]) as String)! > MaxTempValue || Float(self.getCelsius(x1: myDataArray[15], x2: myDataArray[16]) as String)! > MinTempValue {
//                myData.setValue("--", forKey: "T4")
//            }
//            else{
//                myData.setValue(self.getCelsius(x1: myDataArray[15], x2: myDataArray[16]), forKey: "T4")
//            }
        }
        else
        {
            myData.setValue("F", forKey: "scale")
            //self.tempType = "F"
            
            if (byte7[3] == "1"){
                myData.setValue("--", forKey: "T1")
            }
            else if Float(self.getFahrenheit(x1: myDataArray[9], x2: myDataArray[10]) as String)! > MainCenteralManager.sharedInstance().getMaxValue(temperatureType: "F", deviceType: myDeviceType) {
                myData.setValue("OL", forKey: "T1")
            }
            else if Float(self.getFahrenheit(x1: myDataArray[9], x2: myDataArray[10]) as String)! < MainCenteralManager.sharedInstance().getMinValue(temperatureType: "F", deviceType: myDeviceType){
                myData.setValue("-OL", forKey: "T1")
            }
            else {
                myData.setValue(self.getFahrenheit(x1: myDataArray[9], x2: myDataArray[10]), forKey: "T1")
            }
            
            
//            if Float(self.getFahrenheit(x1: myDataArray[9], x2: myDataArray[10]) as String)! > MaxTempValue || Float(self.getFahrenheit(x1: myDataArray[9], x2: myDataArray[10]) as String)! > MinTempValue {
//                myData.setValue("--", forKey: "T1")
//            }
//            else{
//                myData.setValue(self.getFahrenheit(x1: myDataArray[9], x2: myDataArray[10]), forKey: "T1")
//            }
            
            if (byte7[2] == "1"){
                myData.setValue("--", forKey: "T2")
            }
            else if Float(self.getFahrenheit(x1: myDataArray[11], x2: myDataArray[12]) as String)! > MainCenteralManager.sharedInstance().getMaxValue(temperatureType: "F", deviceType: myDeviceType) {
                myData.setValue("OL", forKey: "T2")
            }
            else if Float(self.getFahrenheit(x1: myDataArray[11], x2: myDataArray[12]) as String)! < MainCenteralManager.sharedInstance().getMinValue(temperatureType: "F", deviceType: myDeviceType){
                myData.setValue("-OL", forKey: "T2")
            }
            else {
                myData.setValue(self.getFahrenheit(x1: myDataArray[11], x2: myDataArray[12]), forKey: "T2")
            }
            
//            if Float(self.getFahrenheit(x1: myDataArray[11], x2: myDataArray[12]) as String)! > MaxTempValue || Float(self.getFahrenheit(x1: myDataArray[11], x2: myDataArray[12]) as String)! > MinTempValue {
//                myData.setValue("--", forKey: "T2")
//            }
//            else{
//                myData.setValue(self.getFahrenheit(x1: myDataArray[11], x2: myDataArray[12]), forKey: "T2")
//            }
            
            if (byte7[1] == "1"){
                myData.setValue("--", forKey: "T3")
            }
            else if Float(self.getFahrenheit(x1: myDataArray[13], x2: myDataArray[14]) as String)! > MainCenteralManager.sharedInstance().getMaxValue(temperatureType: "F", deviceType: myDeviceType) {
                myData.setValue("OL", forKey: "T3")
            }
            else if Float(self.getFahrenheit(x1: myDataArray[13], x2: myDataArray[14]) as String)! < MainCenteralManager.sharedInstance().getMinValue(temperatureType: "F", deviceType: myDeviceType){
                myData.setValue("-OL", forKey: "T3")
            }
            else {
                myData.setValue(self.getFahrenheit(x1: myDataArray[13], x2: myDataArray[14]), forKey: "T3")
            }
            
//            if Float(self.getFahrenheit(x1: myDataArray[13], x2: myDataArray[14]) as String)! > MaxTempValue || Float(self.getFahrenheit(x1: myDataArray[13], x2: myDataArray[14]) as String)! > MinTempValue {
//                myData.setValue("--", forKey: "T3")
//            }
//            else{
//                myData.setValue(self.getFahrenheit(x1: myDataArray[13], x2: myDataArray[14]), forKey: "T3")
//            }
            
            if (byte7[0] == "1"){
                myData.setValue("--", forKey: "T4")
            }
            else if Float(self.getFahrenheit(x1: myDataArray[15], x2: myDataArray[16]) as String)! > MainCenteralManager.sharedInstance().getMaxValue(temperatureType: "F", deviceType: myDeviceType) {
                myData.setValue("OL", forKey: "T4")
            }
            else if Float(self.getFahrenheit(x1: myDataArray[15], x2: myDataArray[16]) as String)! < MainCenteralManager.sharedInstance().getMinValue(temperatureType: "F", deviceType: myDeviceType){
                myData.setValue("-OL", forKey: "T4")
            }
            else {
                myData.setValue(self.getFahrenheit(x1: myDataArray[15], x2: myDataArray[16]), forKey: "T4")
            }
            
//            if Float(self.getFahrenheit(x1: myDataArray[15], x2: myDataArray[16]) as String)! > MaxTempValue || Float(self.getFahrenheit(x1: myDataArray[15], x2: myDataArray[16]) as String)! > MinTempValue {
//                myData.setValue("--", forKey: "T4")
//            }
//            else{
//                myData.setValue(self.getFahrenheit(x1: myDataArray[15], x2: myDataArray[16]), forKey: "T4")
//            }
        }

        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        //let result = formatter.string(from: date)
        //myData.setValue(result, forKey: "date")
    
        let calendar = NSCalendar.current
        let hour = calendar.component(.hour, from: date as Date)
        let minutes = calendar.component(.minute, from: date as Date)
        let seconds = calendar.component(.second, from: date as Date)
    
        let currentDate = calendar.component(.day, from: date as Date)
        let currentMonth = calendar.component(.month, from: date as Date)
        let currentYear = calendar.component(.year, from: date as Date)
        myData.setValue(String(format:"%04d/%02d/%02d", currentYear, currentMonth, currentDate), forKey: "date")
        
        myData.setValue(String(format:"%02d:%02d:%02d", hour, minutes, seconds), forKey: "time")

        if self.myRecords == nil {
            self.myRecords = NSMutableArray()
        }
        
        print("Data saved")
        
        self.myRecords.add(myData)
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
            
            var dict = NSMutableDictionary()
            var myData = NSMutableArray()
            
            myData = NSMutableArray()
            
            if myRecords != nil{
                for i in 0..<myRecords.count {
                    print(i)
                    
                    dict = NSMutableDictionary()
                    dict["date"] = (myRecords[i] as AnyObject).value(forKey: "date")
                    dict["time"] = (myRecords[i] as AnyObject).value(forKey: "time")
                    dict["t1"] = (myRecords[i] as AnyObject).value(forKey: "T1")
                    dict["t2"] = (myRecords[i] as AnyObject).value(forKey: "T2")
                    dict["t3"] = (myRecords[i] as AnyObject).value(forKey: "T3")
                    dict["t4"] = (myRecords[i] as AnyObject).value(forKey: "T4")
                    //dict["scale"] = "C"
                    dict["scale"] = (myRecords[i] as AnyObject).value(forKey: "scale")
                    myData.add(dict)
                }
            }
            
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: self.dataFilePath()) {
                print("FILE AVAILABLE")
                showAlert(Appname, title: "This file is already exist.")
                return
            } else {
                FileManager.default.createFile(atPath: self.dataFilePath(), contents: nil, attributes: nil)
            }
            
            var stringToWrite = String()
            stringToWrite += "Date,Time,T1,T2, T3,T4, Scale\n"
            for i in 0..<myData.count {
                stringToWrite += "\((myData[i] as AnyObject).value(forKey: "date") as! String),"
                stringToWrite += "\((myData[i] as AnyObject).value(forKey: "time") as! String),"
                stringToWrite += "\((myData[i] as AnyObject).value(forKey: "t1") as! String),"
                stringToWrite += "\((myData[i] as AnyObject).value(forKey: "t2") as! String),"
                stringToWrite += "\((myData[i] as AnyObject).value(forKey: "t3") as! String),"
                stringToWrite += "\((myData[i] as AnyObject).value(forKey: "t4") as! String),"
                stringToWrite += "\((myData[i] as AnyObject).value(forKey: "scale") as! String)\n"
            }
            //Moved this stuff out of the loop so that you write the complete string once and only once.
            print("writeString :\(stringToWrite)")
            var handle: FileHandle?
            
            handle = FileHandle(forWritingAtPath: self.dataFilePath())
            
            //do {
            //    let url = URL(fileURLWithPath: self.dataFilePath())
            
            //     handle = try FileHandle(forWritingTo: url)
            // } catch {
            //     print(error)
            // }
            
            
            //  handle = FileHandle(forReadingAtPath: self.dataFilePath())
            
            // handle = FileHandle(for: self.dataFilePath())
            print("Path :->\(self.dataFilePath())")
            //say to handle where's the file fo write
            handle?.truncateFile(atOffset: (handle?.seekToEndOfFile())!)
            //position handle cursor to the end of file
            handle?.write(stringToWrite.data(using: String.Encoding.utf8)!)
            
            viewWriteCSV.removeFromSuperview()
            
            APPDELEGATE.window.makeToast("File is saved")
        }
    }

    func dataFilePath() -> String {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        let trimbeforeAfterString = txtCSVName.text?.trimmingCharacters(in: .whitespaces)
        let trimmedString = trimbeforeAfterString?.replacingOccurrences(of: " ", with: "")
        let filePath = url.appendingPathComponent("\(trimmedString!).csv")?.path
        return filePath!
    }
    
    @IBAction func btnCSVCancelClicked(_ sender: UIButton) {
        viewWriteCSV.removeFromSuperview()
    }

    @IBAction func btnPickerSelectedClicked(_ sender:UIButton){
        
        self.view.endEditing(true)
        
        UIView.animate(withDuration: 0.3, animations: {
                    
                    self.viewPicker.frame=CGRect(x: self.viewPicker.frame.origin.x, y: self.view.frame.size.height + self.view.frame.origin.y - self.viewPicker.frame.size.height, width: self.viewPicker.frame.size.width, height: self.viewPicker.frame.size.height)
                    
                    
                })
    }
    
    @IBAction func cancelPicker(sender:AnyObject){
        UIView.animate(withDuration: 0.3) {
            
            self.viewPicker.frame=CGRect(x: self.viewPicker.frame.origin.x, y: self.view.frame.size.height + self.view.frame.origin.y, width: self.viewPicker.frame.size.width, height: self.viewPicker.frame.size.height)
            
        }
    }
    
    @IBAction func donePicker(sender:UIButton){
        
        pickerSelIndx = pickerView.selectedRow(inComponent: 0)
        
        print("Picker Index is  :-> \(pickerSelIndx) and value is \(pickOption[pickerSelIndx])")
    
        lblPickerValue.text = self.pickOption[pickerSelIndx] as? String

    
        UIView.animate(withDuration: 0.3, animations: {
            
            self.viewPicker.frame=CGRect(x: self.viewPicker.frame.origin.x, y: self.view.frame.size.height + self.view.frame.origin.y, width: self.viewPicker.frame.size.width, height: self.viewPicker.frame.size.height)
            
        })
        
        self.myMapDataTimer.invalidate()
        self.myMapDataTimer = nil
        
        let myInterval : TimeInterval = TimeInterval(Float(self.pickerSelIndx + 1))
        print("myInterval", myInterval)
        
        self.myMapDataTimer = Timer.scheduledTimer(timeInterval: myInterval, target: self, selector: #selector(self.setDataOnMap), userInfo: nil, repeats: true)
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
                
                guard value.count == 64 else {
                    return
                }
                
                let byteArray = [UInt8](value)
                print(byteArray)
                
                if (characteristic.uuid.description == "49535343-1E4D-4BD9-BA61-23C647249616")
                {
                    //var text = ""
                    
                    
                    
                    self.myDataArray = byteArray
                    
//                    let byte3 = self.converToBinary(x1: byteArray[2])
//                    if (byte3[0] == "1")
//                    {
//                        //self.tempType = "C"
//                        self.setDataCount(t1: self.getCelsius(x1: byteArray[9], x2: byteArray[10]), t2: self.getCelsius(x1: byteArray[11], x2: byteArray[12]), t3: self.getCelsius(x1: byteArray[13], x2: byteArray[14]), t4: self.getCelsius(x1: byteArray[15], x2: byteArray[16]), scale: "C")
//                    }
//                    else
//                    {
//                        //self.tempType = "F"
//                        self.setDataCount(t1: self.getFahrenheit(x1: byteArray[9], x2: byteArray[10]), t2: self.getFahrenheit(x1: byteArray[11], x2: byteArray[12]), t3: self.getFahrenheit(x1: byteArray[13], x2: byteArray[14]), t4: self.getFahrenheit(x1: byteArray[15], x2: byteArray[16]), scale: "F")
//                    }
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
    
    // MARK: - Button Action Methods
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
        
        if !self.checkingStates() {
            return
        }
        
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
        let u3 = UInt16(x3, radix: 16)!
        let s3 = Int16(bitPattern: u3)
        
        return String(Float(s3) / 10)
        //return String(Float(UInt(x3, radix: 16)!) / 10)
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

    func checkingStates () -> Bool {
        if peripheral == nil {
            return false
        }
        
        if peripheral.state == CBPeripheralState.connected {
            print("connected")
        }
        else if peripheral.state == CBPeripheralState.connecting {
            print("connecting")
        }
        else if peripheral.state == CBPeripheralState.disconnected {
            
            //APPDELEGATE.window.makeToast("BT Device is disconnected")
            print("disconnected")
            
            return false
        }
        
        return true
    }
    
}
