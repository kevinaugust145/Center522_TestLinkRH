//
//  SettingVC.swift
//  TestLink
//
//  Created by Pritesh Pethani on 24/01/17.
//  Copyright © 2017 Pritesh Pethani. All rights reserved.
//

import UIKit

class SettingVC: UIViewController {

    @IBOutlet var viewAlarmTemp: UIView!
    
    @IBOutlet var nslcTopView: NSLayoutConstraint!
    @IBOutlet var topView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    override func viewDidLayoutSubviews() {
        
        Utility.set_TopLayout_VesionRelated(nslcTopView, topView, self)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnClockliked(_ sender: UIButton) {
        self.view.addSubview(viewAlarmTemp)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        viewAlarmTemp.removeFromSuperview()
    }
    @IBAction func btnBackliked(_ sender: UIButton) {
       _ = self.navigationController?.popViewController(animated: true)
    }
}
