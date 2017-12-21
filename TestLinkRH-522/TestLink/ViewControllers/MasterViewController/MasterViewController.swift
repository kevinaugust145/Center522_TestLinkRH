//
//  ViewController.swift
//  BtSample
//
//  Created by Yu chengJhuo on 1/11/17.
//  Copyright © 2017 Yu-cheng Jhuo. All rights reserved.
//

import UIKit
import CoreBluetooth


@objc class MasterViewController: UIViewController , CBCentralManagerDelegate , UITableViewDataSource, UITableViewDelegate{

    var myCenteralManager: CBCentralManager? = nil
    var BTPeripheral:[CBPeripheral] = [] //  儲存掃瞄到的 peripheral 物件
    var BTIsConnectable: [Int] = [] //  儲存各個藍芽裝置是否可連線
    var BTRSSI:[NSNumber] = [] // 儲存各個藍芽裝置的訊號強度
    
    //@IBOutlet var bbScan:UIButton!
    
    @IBOutlet var tableView:UITableView!
    
    @IBOutlet var nslcTopView: NSLayoutConstraint!
    @IBOutlet var topView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
      
    }
    
    override func viewDidLayoutSubviews() {
        
        Utility.set_TopLayout_VesionRelated(nslcTopView, topView, self)
    }
    override func viewWillAppear(_ animated: Bool) {
        
      myCenteralManager = CBCentralManager(delegate: self, queue: nil)
      Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(MasterViewController.actionScan), userInfo: nil, repeats: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            print("BT ON")
        case .poweredOff:
            print("BT OFF")
        case .resetting:
            print("BT RESSTING")
        case .unknown:
            print("BT UNKNOW")
        case .unauthorized:
            print("BT UNAUTHORIZED")
        case .unsupported:
            print("BT UNSUPPORTED")
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        let temp = BTPeripheral.filter { (pl) -> Bool in
            return pl.name == peripheral.name
        }
        
        if temp.count == 0 {
            
            if peripheral.name?.range(of: "BT") != nil{
            //if (peripheral.name?.contains("BT"))!{
                BTPeripheral.append(peripheral)
                BTRSSI.append(RSSI)
                BTIsConnectable.append(Int((advertisementData[CBAdvertisementDataIsConnectable]! as AnyObject).description)!)
                
                print(advertisementData)
            }
        }
        tableView.reloadData()
    }
        
    // MARK: - Button Action Methods
    
    @IBAction func actionScan() {
//        bbScan.isEnabled = false
//        bbScan.setTitle("Scanning", for: .normal)
        BTPeripheral.removeAll(keepingCapacity: false)
        BTRSSI.removeAll(keepingCapacity: false)
        BTIsConnectable.removeAll(keepingCapacity: false)
        myCenteralManager!.scanForPeripherals(withServices: nil, options: nil)
        Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(MasterViewController.stopScan), userInfo: nil, repeats: false)
    }
    
    @IBAction func backButtonAction() {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @objc func stopScan() {
        tableView.reloadData()
        myCenteralManager!.stopScan()
//        bbScan.setTitle("Scan", for: .normal)
//        bbScan.isEnabled = true
    }
    
    
    
    // MARK: - Tableview Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        print("self.BTPeripheral.count", self.BTPeripheral.count)
        return self.BTPeripheral.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = BTPeripheral[indexPath.row].name

        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //self.performSegue(withIdentifier: "DetailIdentifier", sender: indexPath.row)
        
        let item = self.BTPeripheral[indexPath.row]
        
        let obj = BlueToothOptionVC()
        //let obj = DetailViewController()
      MainCenteralManager.sharedInstance().SetObject(centralManager: self.myCenteralManager!, peripheral: item)
//        obj.peripheral = item
//        obj.centralManager = self.myCenteralManager
        self.navigationController?.pushViewController(obj, animated: true)
    }


}
