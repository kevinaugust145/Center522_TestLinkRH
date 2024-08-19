//
//  HomeVC.swift
//  TestLink
//
//  Created by Pritesh Pethani on 24/01/17.
//  Copyright © 2017 Pritesh Pethani. All rights reserved.
//

import UIKit

class HomeVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        _ = ISControlManager.sharedInstance()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    //  The converted code is limited by 2 KB.
    //  Upgrade your plan to remove this limitation.
    @IBAction func btnSkipCliked(_ sender: UIButton) {
        let obj = BlueToothOptionVC()
        self.navigationController?.pushViewController(obj, animated: true)
    }
    @IBAction func btnScanCliked(_ sender: UIButton) {
        //    [self isLECapableHardware];
        if self.isLECapableHardware() {
            let obj = MasterViewController()
            self.navigationController?.pushViewController(obj, animated: true)
            //        MFi_DeviceListController *list = [[MFi_DeviceListController alloc] initWithStyle:UITableViewStyleGrouped];
            //        [self.navigationController setNavigationBarHidden:NO];
            //        [self.navigationController pushViewController:list animated:YES];
        }
        else {
            //[self openSettings];
        }
        //    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:list];
        //    [self presentViewController:nav animated:YES completion:nil];
    }
    func isLECapableHardware() -> Bool {
        var state: String? = nil
       // switch APPDELEGATE.manager?.state {
           // case .unsupported:
         //       state = "The platform/hardware doesn't support Bluetooth Low Energy."
          //  case .unauthorized:
          //      state = "The app is not authorized to use Bluetooth Low Energy."
          //  case .poweredOff:
          //      state = "Bluetooth is currently powered off."
          //  case .poweredOn:
          //      print("Bluetooth power on")
         //       return true
         //   default:
         //       return false
      //  }
        print("Central manager state: \(state)")
            //Commented by Meet
        let alertView = UIAlertView(title: Appname, message: state!, delegate: nil, cancelButtonTitle: "Okay", otherButtonTitles: "")
        alertView.show()
        
        return false
    }
    func openSettings() {
        let url = URL(string: UIApplicationOpenSettingsURLString)
        if UIApplication.shared.canOpenURL(url!) {
            UIApplication.shared.openURL(url!)
        }
        //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }

}
