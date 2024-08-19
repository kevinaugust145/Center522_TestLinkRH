//
//  AlertOutOfRangeViewT2.swift
//  TestLink
//
//  Created by Developer on 02/01/18.
//  Copyright © 2018 Pritesh Pethani. All rights reserved.
//

import UIKit
import AVFoundation

protocol AlertOutOfRangeViewDelegateT2 {
    
    func btnOKT2_Tapped()
}



class AlertOutOfRangeViewT2: UIView {

    @IBOutlet var lblAlertMsg: UILabel!
    @IBOutlet var lblTemp: UILabel!
    
    var delegate: AlertOutOfRangeViewDelegateT2?
    var player: AVAudioPlayer?
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
    func playSound() {
        
        //merchant.m4a
        let url = Bundle.main.url(forResource: "alarmsound", withExtension: "mp3")!
        
        do {
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            //guard let player = player else { return }
            
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            player?.numberOfLoops = -1
            player?.prepareToPlay()
            player?.play()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func stopSound() {
        
        player?.stop()
    }
    
    @IBAction func btnOk_Tapped(_ sender: Any) {
        
        self.delegate?.btnOKT2_Tapped()
        
    }
    

}
