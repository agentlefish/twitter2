//
//  HamburgerViewController.swift
//  Twitter
//
//  Created by Xiang Yu on 10/5/17.
//  Copyright © 2017 Xiang Yu. All rights reserved.
//

import UIKit

class HamburgerViewController: UIViewController {

    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var greyView: UIView!
    
    @IBOutlet weak var contentLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var menuWidthConstraint: NSLayoutConstraint!
    
    var originalContentLeading: CGFloat!
    
    var menuViewController: MenuViewController!
    var contentViewController: UIViewController! {
        didSet(oldContentViewController) {
            view.layoutIfNeeded()
            
            if oldContentViewController != nil {
                oldContentViewController.willMove(toParentViewController: nil)
                oldContentViewController.removeFromParentViewController()
                oldContentViewController.didMove(toParentViewController: nil)
            }
            
            contentViewController.willMove(toParentViewController: self)
            contentView.addSubview(contentViewController.view)
            contentViewController.didMove(toParentViewController: self)
            
            if let timelineViewController = (contentViewController as? UINavigationController)?.topViewController as? TimelineViewController {
                timelineViewController.hamburgerViewController = self
            }
            
            contentView.bringSubview(toFront: greyView)
            
            UIView.animate(withDuration: 0.5) {
                self.greyView.alpha = 0
                self.contentLeadingConstraint.constant = 0
                self.view.layoutIfNeeded()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        menuViewController = mainStoryboard.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
        
        menuViewController.willMove(toParentViewController: self)
        menuView.addSubview(menuViewController.view)
        menuViewController.willMove(toParentViewController: self)
        
        menuViewController.delegate = self
        
        for vc in menuViewController.viewControllers {
            if vc.title == "Home" {
                self.contentViewController = vc.controller
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onPanGesture(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        let velocity = sender.velocity(in: view)
        
        UIView.animate(withDuration: 0.5) {
            if sender.state == .began {
                self.originalContentLeading = self.contentLeadingConstraint.constant
                
                self.greyView.alpha = self.originalContentLeading < 5 ? 0 : 0.5
                self.contentView.bringSubview(toFront: self.greyView)
            } else if sender.state == .changed {
                let newLeadingMargin = self.originalContentLeading + translation.x
                
                if newLeadingMargin > 0 && newLeadingMargin <= self.menuWidthConstraint.constant {
                    self.contentLeadingConstraint.constant = self.originalContentLeading + translation.x
                    
                    var alpha = translation.x/self.view.frame.width*0.5
                    
                    if(translation.x < 0) {
                        alpha += 0.5
                    }
                    
                    self.greyView.alpha = alpha
                }
                
            } else if sender.state == .ended {
                if velocity.x > 0 {
                    self.contentLeadingConstraint.constant = self.menuWidthConstraint.constant
                    
                    self.greyView.alpha = 0.5
                    self.contentView.bringSubview(toFront: self.greyView)
                    
                    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.didTapOnGreyView(sender:)))
                    self.greyView.addGestureRecognizer(tapGestureRecognizer)
                    
                } else {
                    self.contentLeadingConstraint.constant = 0
                    
                    self.contentView.sendSubview(toBack: self.greyView)
                }
            }
            
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func didTapOnGreyView(sender: UITapGestureRecognizer) {
        UIView.animate(withDuration: 0.3, animations: {
            self.contentLeadingConstraint.constant = 0
            self.greyView.alpha = 0
            
            self.view.layoutIfNeeded()
        }) { (result) in
            self.contentView.sendSubview(toBack: self.greyView)
        }
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension HamburgerViewController: MenuViewControllerDelegate {
    func menuViewController(_ menuViewController: MenuViewController, didUpdateViewController viewController: UIViewController) {
        self.contentViewController = viewController
    }
}

extension HamburgerViewController: TweetCellDelegate {
    func tweetCell(_ tweetCell: TweetCell, didTapOnScreenname screenname: String) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let profileNavViewController = mainStoryboard.instantiateViewController(withIdentifier: "ProfileNavigationController") as! UINavigationController
        let profileViewController = profileNavViewController.topViewController as! ProfileViewController
        profileViewController.screenname = screenname
        
        self.contentViewController = profileNavViewController
    }
}
