//
//  AppDelegate.swift
//  TestLink
//
//  Created by Pritesh Pethani on 24/01/17.
//  Copyright © 2017 Pritesh Pethani. All rights reserved.
//

import UIKit

class AppDelegate: UIResponder,UIApplicationDelegate {

    var window: UIWindow?
    var navigationC: UINavigationController?
    var manager: CBCentralManager?
    var peripheral: CBPeripheral?
    var firstVC:HomeVC!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        firstVC = HomeVC(nibName: "HomeVC", bundle: nil)
        self.navigationC  = UINavigationController(rootViewController: firstVC!)
        self.window?.rootViewController = navigationC
        self.navigationC!.setNavigationBarHidden(true, animated: true)
        self.window?.backgroundColor = UIColor.white
        self.window?.makeKeyAndVisible()

        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        
    }
    func applicationDidEnterBackground(_ application: UIApplication) {
        
    }
    func applicationWillEnterForeground(_ application: UIApplication) {
        
    }
    func applicationDidBecomeActive(_ application: UIApplication) {
        
    }
    func applicationWillTerminate(_ application: UIApplication) {
        
    }
    
}
