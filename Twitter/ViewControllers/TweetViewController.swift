//
//  TweetViewController.swift
//  Twitter
//
//  Created by Xiang Yu on 9/30/17.
//  Copyright © 2017 Xiang Yu. All rights reserved.
//

import UIKit

class TweetViewController: UIViewController {
    
    @IBOutlet weak var profileImgView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var screennameLabel: UILabel!
    @IBOutlet weak var tweetContentLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var retweetCountLabel: UILabel!
    @IBOutlet weak var favoriteCountLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var retweetButton: UIButton!

    weak var tweet: Tweet!
    
    weak var composeViewDelegate: ComposeTweetViewControllerDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let tweet = tweet {
            screennameLabel.text = "@\(tweet.user?.screenname ?? "null")"
            usernameLabel.text = tweet.user?.name
            tweetContentLabel.text = tweet.text
            
            reloadRetweetStatus()
            reloadFavoriteStatus()
            
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
    
    private func reloadRetweetStatus() {
        retweetCountLabel.text = tweet.retweetCount.description
        let retweetImage = tweet.retweeted ? UIImage(named:"retweeted") : UIImage(named:"retweet")
        retweetButton.setImage(retweetImage, for: .normal)
    }
    
    private func reloadFavoriteStatus() {
        favoriteCountLabel.text = tweet.favoritesCount.description
        let favImage = tweet.favorited ? UIImage(named:"favorited") : UIImage(named:"favorite")
        favoriteButton.setImage(favImage, for: .normal)
    }

    @IBAction func onRetweetButton(_ sender: Any) {
        //do unretweet
        if tweet?.retweeted == true {
            TwitterService.sharedInstance?.unretweet(tweet?.id, success: { (tweet: Tweet) in
                self.tweet?.retweeted = false
                self.tweet?.retweetCount -= 1
                
                self.reloadRetweetStatus()
            }, failure: { (error: Error) in
                Utils.popAlertWith(msg: "Unretweet failed: \(error.localizedDescription)", in: self)
            })
        } else {
        
            //do retweet
            TwitterService.sharedInstance?.retweet(tweet?.id, success: { (tweet: Tweet) in
                self.tweet?.retweeted = true
                self.tweet?.retweetCount += 1
                
                self.reloadRetweetStatus()
            }, failure: { (error: Error) in
                Utils.popAlertWith(msg: "Retweet failed: \(error.localizedDescription)", in: self)
            })
        }
    }
    
    @IBAction func onFavoriteButton(_ sender: Any) {
        //do unfavorite
        if tweet?.favorited == true {
            TwitterService.sharedInstance?.unfavorite(tweet?.id, success: { (tweet: Tweet) in
                self.tweet?.favorited = false
                self.tweet?.favoritesCount -= 1
                
                self.reloadFavoriteStatus()
            }, failure: { (error: Error) in
                Utils.popAlertWith(msg: "Unfavorite failed: \(error.localizedDescription)", in: self)
            })
        } else {
        
            //do favorite
            TwitterService.sharedInstance?.favorite(tweet?.id, success: { (tweet: Tweet) in
                self.tweet?.favorited = true
                self.tweet?.favoritesCount += 1
                
                self.reloadFavoriteStatus()
            }, failure: { (error: Error) in
                Utils.popAlertWith(msg: "Favorite failed: \(error.localizedDescription)", in: self)
            })
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // navigate to compose tweet view
        if let navigationController = segue.destination as? UINavigationController {
            
            guard let composeTweetViewController = navigationController.topViewController as? ComposeTweetViewController else {
                return
            }
            
            composeTweetViewController.replyToTweet = tweet
            composeTweetViewController.delegate = composeViewDelegate
        }
    }

}
