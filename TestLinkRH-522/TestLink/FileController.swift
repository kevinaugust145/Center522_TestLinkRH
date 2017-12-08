//
//  File.swift
//  TestLink
//
//  Created by Meet Doshi on 1/18/17.
//  Copyright © 2017 Pritesh Pethani. All rights reserved.
//

import Foundation

import UIKit


@objc class FileController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Swift"
        print("ViewController")
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func getNewPhotoAction(sender: AnyObject) {
        print("getNewPhotoAction")
//        let nextViewController = FirstViewController(nibName: "FirstViewController", bundle: nil)
//        self.navigationController!.pushViewController(nextViewController, animated: true)
    }
    
}
