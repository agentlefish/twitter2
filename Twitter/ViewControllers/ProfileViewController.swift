//
//  ProfileViewController.swift
//  Twitter
//
//  Created by Xiang Yu on 10/6/17.
//  Copyright © 2017 Xiang Yu. All rights reserved.
//

import UIKit
import FLEX

class ProfileViewController: UIViewController {

    @IBOutlet weak var headerImgView: UIImageView!
    @IBOutlet weak var profileImgView: UIImageView!
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var screennameLabel: UILabel!
    
    @IBOutlet weak var tweetsCountLabel: UILabel!
    @IBOutlet weak var followingCountLabel: UILabel!
    @IBOutlet weak var followersCountLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var infoScrollView: UIScrollView!
    @IBOutlet weak var tweetTableView: UITableView!
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var usernamePageWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var descriptionPageWidthConstraint: NSLayoutConstraint!
    
    
    var screenname: String!
    
    var user: User! {
        didSet {
            screennameLabel.text = "@\(user.screenname ?? "null")"
            usernameLabel.text = user.name
            self.navigationItem.title = user.name
            descriptionLabel.text = user.tagline
            
            tweetsCountLabel.text = String(user.tweetsCount ?? 0)
            followingCountLabel.text = String(user.followingCount ?? 0)
            followersCountLabel.text = String(user.followersCount ?? 0)
            
            if let imageURL = user.profileImgUrl {
                profileImgView.setImageWith(imageURL)
            } else {
                profileImgView.image = nil
            }
            
            if let imageURL = user.headerImgUrl {
                headerImgView.setImageWith(imageURL)
            } else {
                headerImgView.backgroundColor = Utils.blue
            }
        }
    }
    
    var tweets: [Tweet] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        FLEXManager.shared().showExplorer()
        
        //pageControl.transform = CGAffineTransform(scaleX: 1, y: 1)
        
        tweetTableView.delegate = self
        tweetTableView.dataSource = self
        
        infoScrollView.delegate = self

        let twitterService = TwitterService.sharedInstance
        twitterService?.getUser(byScreenName: screenname, orByUserId: nil, success: { (user: User) in
            self.user = user
            
            twitterService?.getTimeline(.user, olderthan: nil, forScreenName: user.screenname, success: { (tweets: [Tweet]) in
                self.tweets = tweets
                self.tweetTableView.reloadData()
            }, failure: { (error: Error) in
                Utils.popAlertWith(msg: "error in getting user timeline: \(error.localizedDescription)", in: self)
            })
        }, failure: { (error: Error) in
            Utils.popAlertWith(msg: "error in getting user info: \(error.localizedDescription)", in: self)
        })
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = UIColor.clear
    }
    
    override func viewDidLayoutSubviews() {
        //print(infoScrollView.frame.width)
        usernamePageWidthConstraint.constant = infoScrollView.bounds.width
        descriptionPageWidthConstraint.constant = infoScrollView.bounds.width
        
        infoScrollView.layoutIfNeeded()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onPageChanged(_ sender: Any) {
        let xOffset = infoScrollView.bounds.width * CGFloat(pageControl.currentPage)
        infoScrollView.setContentOffset(CGPoint(x: xOffset, y:0) , animated: true)
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? TweetViewController {
            let indexPath = tweetTableView.indexPath(for: sender as! UITableViewCell)!
            
            destinationViewController.tweet = tweets[indexPath.row]
            //destinationViewController.composeViewDelegate = self
        }
//        else if let destinationViewController = segue.destination as? UINavigationController {
//            guard let composeTweetViewController = destinationViewController.topViewController as? ComposeTweetViewController else {
//                return
//            }
//
//            composeTweetViewController.delegate = self
//        }
    }

}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tweetTableView.dequeueReusableCell(withIdentifier: "TweetCell", for: indexPath) as! TweetCell
        cell.tweet = tweets[indexPath.row]
        
        return cell
    }
}

extension ProfileViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        pageControl.currentPage = Int(scrollView.contentOffset.x / scrollView.bounds.width)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let alpha = 1 - (scrollView.contentOffset.x / scrollView.bounds.width) * 0.5
        
        headerImgView.alpha = alpha
    }
}
