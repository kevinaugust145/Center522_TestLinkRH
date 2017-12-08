//
//  FAQTableVC.swift
//  Foomerang
//
//  Created by Pritesh Pethani on 24/10/16.
//  Copyright © 2016 Pritesh Pethani. All rights reserved.
//

import UIKit

class FileOpenTableVC: UITableViewCell {

    @IBOutlet var lblQuestion:UILabel!
    @IBOutlet var lblDescription:UILabel!

    @IBOutlet var myImageView:UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
