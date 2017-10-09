//
//  MenuViewController.swift
//  Twitter
//
//  Created by Xiang Yu on 10/5/17.
//  Copyright © 2017 Xiang Yu. All rights reserved.
//

import UIKit

@objc protocol MenuViewControllerDelegate {
    @objc optional func menuViewController(_ menuViewController: MenuViewController, didUpdateViewController viewController: UIViewController)
}

class MenuViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var viewControllers: [(title: String, controller: UIViewController)] = []
    
    var lastSelectedViewController: String?
    
    weak var delegate: MenuViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableViewAutomaticDimension
        
        reloadViewControllers()
    }
    
    func reloadViewControllers() {
        viewControllers.removeAll()
        
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let profileNavViewController = mainStoryboard.instantiateViewController(withIdentifier: "ProfileNavigationController") as! UINavigationController
        let profileViewController = profileNavViewController.topViewController as! ProfileViewController
        profileViewController.screenname = User.currentUser?.screenname
        
        let homeNavViewController = mainStoryboard.instantiateViewController(withIdentifier: "TimelineNavigationController") as! UINavigationController
        let homeViewController = homeNavViewController.topViewController as! TimelineViewController
        homeViewController.timelineType = .home
        
        let mentionsNavViewController = mainStoryboard.instantiateViewController(withIdentifier: "TimelineNavigationController") as! UINavigationController
        let mentionsViewController = mentionsNavViewController.topViewController as! TimelineViewController
        mentionsViewController.timelineType = .mentions
        
        viewControllers.append(("Profile", profileNavViewController))
        viewControllers.append(("Home", homeNavViewController))
        viewControllers.append(("Mentions", mentionsNavViewController))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

extension MenuViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewControllers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell", for: indexPath) as! MenuCell
        cell.menuItemLabel.text = viewControllers[indexPath.row].title
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let viewController = self.viewControllers[indexPath.row].controller
        
        delegate?.menuViewController?(self, didUpdateViewController: viewController)
    }
}
