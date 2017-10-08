//
//  TweetCell.swift
//  Twitter
//
//  Created by Xiang Yu on 9/28/17.
//  Copyright © 2017 Xiang Yu. All rights reserved.
//

import UIKit

@objc protocol TweetCellDelegate {
    @objc optional func tweetCell(_ tweetCell: TweetCell, didTapOnScreenname screenname: String)
}

class TweetCell: UITableViewCell {

    @IBOutlet weak var profileImgView: UIImageView!
    
    @IBOutlet weak var screennameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var tweetContentLabel: UILabel!
    
    var delegate: TweetCellDelegate?
    
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
        
        profileImgView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(TweetCell.onTapOnProfileImg(_:)))
        profileImgView.addGestureRecognizer(tap)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        self.selectionStyle = .none
    }
    
    @IBAction func onTapOnProfileImg(_ sender: UITapGestureRecognizer) {
        let cell = sender.view?.superview?.superview as? TweetCell
        if let screenname = cell?.tweet.user?.screenname {
            delegate?.tweetCell?(self, didTapOnScreenname: screenname)
        }
    }

}
