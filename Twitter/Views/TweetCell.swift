//
//  TweetCell.swift
//  Twitter
//
//  Created by Xiang Yu on 9/28/17.
//  Copyright © 2017 Xiang Yu. All rights reserved.
//

import UIKit

class TweetCell: UITableViewCell {

    @IBOutlet weak var profileImgView: UIImageView!
    
    @IBOutlet weak var screennameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var tweetContentLabel: UILabel!
    
    var tweet: Tweet! {
        didSet {
            screennameLabel.text = "@\(tweet.user?.screenname ?? "null")"
            usernameLabel.text = tweet.user?.name
            tweetContentLabel.text = tweet.text
            
            if let timestamp = tweet.timestamp {
                let formatter = DateFormatter()
                if Calendar.current.isDateInToday(timestamp) { //print time only
                    formatter.timeStyle = .short
                    timestampLabel.text = formatter.string(from: timestamp)
                }
                else { // print date only
                    formatter.dateStyle = .short
                    timestampLabel.text = formatter.string(from: timestamp)
                }
            }
            
            if let imageURL = tweet.user?.profileImgUrl {
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

        // Configure the view for the selected state
    }

}
