//
//  ComposeTweetViewController.swift
//  Twitter
//
//  Created by Xiang Yu on 9/29/17.
//  Copyright © 2017 Xiang Yu. All rights reserved.
//

import UIKit

@objc protocol ComposeTweetViewControllerDelegate {
    @objc optional func composeTweetViewController(_ composeTweetViewController: ComposeTweetViewController, didTweet status: Tweet)
}

class ComposeTweetViewController: UIViewController {

    @IBOutlet weak var screennameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var profileImgView: UIImageView!
    @IBOutlet weak var tweetTextView: UITextView!
    
    @IBOutlet weak var tweetButton: UIBarButtonItem!
    @IBOutlet var keyboardToolBar: UIToolbar!
    @IBOutlet weak var countDownLabel: UILabel!
    
    weak var delegate: ComposeTweetViewControllerDelegate!
    
    let TweetCharLimit = 140
    
    var replyToTweet: Tweet?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // something wrong with current user. better logout and login again
        guard let currentUser = User.currentUser else {
            TwitterService.sharedInstance?.logout()
            return
        }
        
        screennameLabel.text = "@\(currentUser.screenname ?? "null")"
        usernameLabel.text = currentUser.name
        
        if let imageURL = currentUser.profileImgUrl {
            profileImgView.setImageWith(imageURL)
        } else {
            profileImgView.image = nil
        }

        tweetTextView.delegate = self
        tweetTextView.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Action
    
    @IBAction func onCancelButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
	
    @IBAction func onTweetButton(_ sender: Any) {
        if tweetTextView.text.lengthOfBytes(using: String.Encoding.utf8) == 0 {
            Utils.popAlertWith(msg: "Please type something to tweet about", in: self)
        }
        TwitterService.sharedInstance?.tweet(tweetTextView.text, replyTo: replyToTweet?.id, success: { (tweet: Tweet) in
            print("successfully tweeted: \(tweet.text)")
            self.delegate?.composeTweetViewController?(self, didTweet: tweet)
            self.dismiss(animated: true, completion: nil)
        }, failure: { (error: Error) in
            Utils.popAlertWith(msg: "Tweet failed: \(error.localizedDescription)", in: self)
        })
    }

    // MARK: - Navigation

    //override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
    //}

}

extension ComposeTweetViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        guard let tweet = tweetTextView.text else {
            return
        }
        
        let countDown = TweetCharLimit - tweet.lengthOfBytes(using: String.Encoding.utf8)
        countDownLabel.text = countDown.description
        
        if(countDown < 0){
            tweetButton.isEnabled = false
            countDownLabel.textColor = UIColor.red
        } else {
            tweetButton.isEnabled = true
            countDownLabel.textColor = UIColor.gray
        }
    }
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        //add tool bar above keyboard
        countDownLabel.text = "140"
        countDownLabel.textColor = UIColor.gray
        tweetTextView.inputAccessoryView = self.keyboardToolBar
        
        if let replyToUser = replyToTweet?.user?.screenname {
            tweetTextView.text = "@\(replyToUser) "
        }
        
        return true
    }
}
