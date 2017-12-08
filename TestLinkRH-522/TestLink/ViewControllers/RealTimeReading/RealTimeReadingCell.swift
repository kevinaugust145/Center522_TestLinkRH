//
//  RealTimeReadingCell.swift
//  TestLink
//
//  Created by Pritesh Pethani on 24/01/17.
//  Copyright © 2017 Pritesh Pethani. All rights reserved.
//

import UIKit

class RealTimeReadingCell: UITableViewCell {

    @IBOutlet var name : UILabel!
    @IBOutlet var value : UILabel!
    
    @IBOutlet var switchReading : UISwitch!

    @IBOutlet var lblMin : UILabel!
    @IBOutlet var lblMax : UILabel!
    @IBOutlet var lblStatus : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
