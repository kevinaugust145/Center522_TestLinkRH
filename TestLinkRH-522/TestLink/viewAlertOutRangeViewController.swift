//
//  viewAlertOutRangeViewController.swift
//  TestLink
//
//  Created by Yu chengJhuo on 6/25/17.
//  Copyright © 2017 Pritesh Pethani. All rights reserved.
//

import UIKit
import AVFoundation

class viewAlertOutRangeViewController: UIViewController {
  
  @IBOutlet var viewAlertOutRange: UIView!
  @IBOutlet var viewAlertMsg: UILabel!
  @IBOutlet var viewAlertTemperature: UILabel!
    @IBOutlet var btnCancel: UIButton!
  
  var alertMsg : String = ""
  var alertTemperature : String = ""
  var player: AVAudioPlayer?
  
   var transitioner : CAVTransitioner
  
  init() {
    self.transitioner = CAVTransitioner()
    
    super.init(nibName: nil, bundle: nil)
    
    
    self.modalPresentationStyle = .custom
    self.transitioningDelegate = self.transitioner
  }
  
  init(AlertMsg :String , AlertTemperature:String) {
    self.transitioner = CAVTransitioner()
    self.alertMsg = AlertMsg
    self.alertTemperature = AlertTemperature
    
    super.init(nibName: nil, bundle: nil)
    
    self.modalPresentationStyle = .custom
    self.transitioningDelegate = self.transitioner
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    self.viewAlertMsg.text = self.alertMsg
    
    if let _ = Float(self.alertTemperature) {
      self.alertTemperature = String(format: "%.1f",  Float(self.alertTemperature)!)
    }

    
    self.viewAlertTemperature.text = self.alertTemperature + MainCenteralManager.sharedInstance().data.cOrF
    
  }
  
  override func viewDidAppear(_ animated: Bool) {
    self.playSound()
  }

  func playSound() {
    
    //merchant.m4a
    let url = Bundle.main.url(forResource: "alarmsound", withExtension: "mp3")!
    
    do {
      player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
      //guard let player = player else { return }
      
      try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
      try AVAudioSession.sharedInstance().setActive(true)
      
      player?.prepareToPlay()
      player?.play()
    } catch let error {
      print(error.localizedDescription)
    }
  }
  
  func stopSound() {
    
    player?.stop()
  }
  
  @IBAction func btnCloseTemperatureAlert(_ sender:UIButton){
//    viewAlertOutRange.stopSound()
//    viewAlertOutRange.view.removeFromSuperview()
    
    self.stopSound()
    self.dismiss(animated: false, completion: nil)
  }
  
  
}
