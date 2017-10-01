//
//  HomeViewController.swift
//  Twitter
//
//  Created by Xiang Yu on 9/26/17.
//  Copyright © 2017 Xiang Yu. All rights reserved.
//

import UIKit
import MBProgressHUD

class HomeViewController: UIViewController {
    
    var tweets: [Tweet] = []
    var isMoreDataLoading = false

    @IBOutlet weak var tweetsTableView: UITableView!
    @IBOutlet weak var loadingMoreView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Initialize a UIRefreshControl
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: UIControlEvents.valueChanged)
        // add refresh control to table view
        tweetsTableView.insertSubview(refreshControl, at: 0)
        
        refreshControlAction()
        
        tweetsTableView.delegate = self
        tweetsTableView.dataSource = self
        tweetsTableView.estimatedRowHeight = 100
        tweetsTableView.rowHeight = UITableViewAutomaticDimension
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onLogoutButton(_ sender: Any) {
        TwitterService.sharedInstance?.logout()
    }
    
    @objc private func refreshControlAction(_ refreshControl: UIRefreshControl?=nil) {
        // Display HUD right before the request is made
        let initialLoad = (refreshControl == nil)
        if initialLoad {
            MBProgressHUD.showAdded(to: self.view, animated: true)
        }
        TwitterService.sharedInstance?.homeTimeline(olderthan: nil, success: { (tweets: [Tweet]) in
            
            // Hide HUD once the network request comes back (must be done on main UI thread)
            MBProgressHUD.hide(for: self.view, animated: true)
            
            self.tweets = tweets
            self.tweetsTableView.reloadData()
            
            refreshControl?.endRefreshing()
            
        }, failure: { (error: Error) in
            // Hide HUD once the network request comes back (must be done on main UI thread)
            MBProgressHUD.hide(for: self.view, animated: true)
            
            refreshControl?.endRefreshing()
            
            Utils.popAlertWith(msg: "error in get home time line: \(error.localizedDescription)", in: self)
        })
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? TweetViewController {
            let indexPath = tweetsTableView.indexPath(for: sender as! UITableViewCell)!
            
            destinationViewController.tweet = tweets[indexPath.row]
            destinationViewController.composeViewDelegate = self
        }
        else if let destinationViewController = segue.destination as? UINavigationController {
            guard let composeTweetViewController = destinationViewController.topViewController as? ComposeTweetViewController else {
                return
            }
            
            composeTweetViewController.delegate = self
        }
    }

}

// MARK: - Table View Delegate

extension HomeViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tweetsTableView.dequeueReusableCell(withIdentifier: "TweetCell", for: indexPath) as! TweetCell
        cell.tweet = tweets[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tweetsTableView.deselectRow(at: indexPath, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = tweetsTableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tweetsTableView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tweetsTableView.isDragging) {
                isMoreDataLoading = true
                let progressHUD = MBProgressHUD.showAdded(to: loadingMoreView, animated: true)
                progressHUD.bezelView.backgroundColor = .clear
                
                //artificially delay for 3 sec to avoid 429 error
                let when = DispatchTime.now() + 3
                DispatchQueue.main.asyncAfter(deadline: when) {
                    TwitterService.sharedInstance?.homeTimeline(olderthan: self.tweets.last?.id, success: { (tweets: [Tweet]) in
                        
                        // Hide HUD once the network request comes back (must be done on main UI thread)
                        MBProgressHUD.hide(for: self.loadingMoreView, animated: true)
                        self.isMoreDataLoading = false
                        
                        self.tweets.append(contentsOf: tweets)
                        self.tweetsTableView.reloadData()
                        
                    }, failure: { (error: Error) in
                        // Hide HUD once the network request comes back (must be done on main UI thread)
                        MBProgressHUD.hide(for: self.loadingMoreView, animated: true)
                        self.isMoreDataLoading = false

                        Utils.popAlertWith(msg: "error in get more time line: \(error.localizedDescription)", in: self)
                    })
                }
            }
        }
    }
}

// MARK: - Compose Tweet View Delegate

extension HomeViewController: ComposeTweetViewControllerDelegate {
    func composeTweetViewController(_ composeTweetViewController: ComposeTweetViewController, didTweet status: Tweet) {
        self.tweets.insert(status, at: 0)
        self.tweetsTableView.reloadData()
    }
}
