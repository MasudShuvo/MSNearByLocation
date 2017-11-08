//
//  MSLocationTableViewCell.swift
//  MSNearByLocation
//
//  Created by Masud Shuvo on 11/8/17.
//  Copyright © 2017 Masud Shuvo. All rights reserved.
//

import UIKit

class MSLocationTableViewCell: UITableViewCell {

    @IBOutlet var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet var locationTitle: UILabel!
    @IBOutlet var locationImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
