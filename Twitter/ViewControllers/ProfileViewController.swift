//
//  ProfileViewController.swift
//  Twitter
//
//  Created by Xiang Yu on 10/6/17.
//  Copyright © 2017 Xiang Yu. All rights reserved.
//

import UIKit
//import FLEX

class ProfileViewController: UIViewController {

    @IBOutlet weak var headerImgView: UIImageView!
    @IBOutlet weak var profileImgView: UIImageView!
    @IBOutlet weak var headerBlurView: UIVisualEffectView!
    
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
    
    @IBOutlet weak var profileImgTopConstraint: NSLayoutConstraint!
    
    @IBOutlet var panGestureRecognizer: UIPanGestureRecognizer!
    @IBOutlet weak var headerImgHeightConstraint: NSLayoutConstraint!
    
    var screenname: String!
    
    private var originalProfileImgTopMargin: CGFloat!
    private var originalHeaderImgHeight: CGFloat!
    
    private enum AdjustType {
        case none
        case toFront
        case toBack
    }
    private var adjustBlurView: AdjustType = .none
    
    private enum UIState {
        case stretchingHeaderImg
        case initial
        case shrinkingHeaderImg
        case movingUnderHeaderImg
    }
    private var uiState: UIState = .initial
    
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
        
        //FLEXManager.shared().showExplorer()
        
        //pageControl.transform = CGAffineTransform(scaleX: 1, y: 1)
        
        tweetTableView.delegate = self
        tweetTableView.dataSource = self
        
        infoScrollView.delegate = self
        panGestureRecognizer.delegate = self

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
        
        originalProfileImgTopMargin = profileImgTopConstraint.constant
        headerImgHeightConstraint.constant = view.frame.width/3
        originalHeaderImgHeight = headerImgView.frame.height
    }
    
    override func viewDidLayoutSubviews() {
        //print(infoScrollView.frame.width)
        usernamePageWidthConstraint.constant = infoScrollView.bounds.width
        descriptionPageWidthConstraint.constant = infoScrollView.bounds.width
        headerBlurView.frame = headerImgView.bounds
        
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
    
    @IBAction func onPanGesture(_ sender: UIPanGestureRecognizer) {
        UIView.animate(withDuration: 0.3, animations: {
            //let velocity = sender.velocity(in: self.view)
            let translation = sender.translation(in: self.view)
            if sender.state == .began {
                
            } else if sender.state == .changed {
                
                switch self.uiState {
                    
                case .stretchingHeaderImg:
                    self.stretchHeaderImg(translation.y)
                    break
                case .initial:
                    if translation.y > 0 {
                        self.uiState = .stretchingHeaderImg
                        self.stretchHeaderImg(translation.y)
                    } else {
                        self.uiState = .shrinkingHeaderImg
                        self.shrinkHeaderImg(translation.y)
                    }
                    break
                case .shrinkingHeaderImg:
                    self.shrinkHeaderImg(translation.y)
                    break
                case .movingUnderHeaderImg:
                    // this is negative
                    let marginFromHeaderImgToTableview = self.headerImgView.frame.maxY - self.tweetTableView.frame.minY
                    
                    var newTopMargin = self.profileImgTopConstraint.constant + translation.y
                    
                    if newTopMargin > self.originalProfileImgTopMargin {
                        newTopMargin = self.originalProfileImgTopMargin
                        self.uiState = .shrinkingHeaderImg
                        
                        self.adjustBlurView = .toBack
                    } else if translation.y < marginFromHeaderImgToTableview {
                        newTopMargin = self.profileImgTopConstraint.constant + marginFromHeaderImgToTableview
                    }
                    
                    self.profileImgTopConstraint.constant = newTopMargin
                    break
                }
                
                sender.setTranslation(CGPoint.zero, in: self.view)
                
            } else if sender.state == .ended {

                if self.uiState == .stretchingHeaderImg {
                    UIView.animate(withDuration: 0.3) {
                        self.uiState = .initial
                        self.headerImgHeightConstraint.constant = self.originalHeaderImgHeight
                    }
                }
                
            }
            
            self.view.layoutIfNeeded()
        }) { (completed) in
            self.adjustBlurViewIfNeeded()
        }
    }
    
    private func adjustBlurViewIfNeeded() {
        if self.adjustBlurView == .toFront {
            self.view.bringSubview(toFront: self.headerBlurView)
        } else if self.adjustBlurView == .toBack {
            self.view.sendSubview(toBack: self.headerBlurView)
        }
        
        self.adjustBlurView = .none
    }
    
    private func stretchHeaderImg(_ translationy: CGFloat) {
        //maximux stretchable
        let maxHeight = self.originalHeaderImgHeight + 40
        
        var newHeight = self.headerImgView.frame.height + translationy
        
        if newHeight <= self.originalHeaderImgHeight {
            newHeight = self.originalHeaderImgHeight
            self.uiState = .initial
        } else if newHeight > maxHeight {
            newHeight = maxHeight
        }
        
        self.headerImgHeightConstraint.constant = newHeight
    }
    
    private func shrinkHeaderImg(_ translationy: CGFloat) {
        //maximux stretchable
        let minHeight = self.navigationController?.navigationBar.frame.maxY ?? 40
        
        var newHeight = self.headerImgView.frame.height + translationy
        
        if newHeight >= self.originalHeaderImgHeight {
            newHeight = self.originalHeaderImgHeight
            self.uiState = .initial
        } else if newHeight < minHeight {
            newHeight = minHeight
            self.uiState = .movingUnderHeaderImg
            adjustBlurView = .toFront
        }
        
        self.headerImgHeightConstraint.constant = newHeight
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? TweetViewController {
            let indexPath = tweetTableView.indexPath(for: sender as! UITableViewCell)!
            
            destinationViewController.tweet = tweets[indexPath.row]
            //destinationViewController.composeViewDelegate = self
        }
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

extension ProfileViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if otherGestureRecognizer.view?.restorationIdentifier == "userInfoScrollView"
            && otherGestureRecognizer is UIPanGestureRecognizer {
            return false
        } else if let panGes = gestureRecognizer as? UIPanGestureRecognizer {
            let translation = panGes.translation(in: self.view)
            if abs(translation.x) < abs(translation.y) {
                if !(otherGestureRecognizer.view is UITableView) {
                    return false
                }
            }
        }
        return true;
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let panGes = gestureRecognizer as? UIPanGestureRecognizer {
            let translation = panGes.translation(in: self.view)
            if abs(translation.x) > abs(translation.y) {
                return false
            }
        }
        
        return true
    }

}
