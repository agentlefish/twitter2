//
//  AccountCell.swift
//  Twitter
//
//  Created by Xiang Yu on 10/8/17.
//  Copyright © 2017 Xiang Yu. All rights reserved.
//

import UIKit

class AccountCell: UITableViewCell {

    @IBOutlet weak var profileImgView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var screennameLabel: UILabel!
    
    var user: User! {
        didSet {
            screennameLabel.text = "@\(user.screenname ?? "null")"
            usernameLabel.text = user.name
            
            if let imageURL = user.profileImgUrl {
                profileImgView.setImageWith(imageURL)
            } else {
                profileImgView.image = nil
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        self.selectionStyle = .none
    }

}
