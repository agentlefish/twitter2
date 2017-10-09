//
//  AccountsViewController.swift
//  Twitter
//
//  Created by Xiang Yu on 10/8/17.
//  Copyright © 2017 Xiang Yu. All rights reserved.
//

import UIKit

class AccountsViewController: UIViewController {

    @IBOutlet weak var accountsTableView: UITableView!

    @IBOutlet var panGesture: UIPanGestureRecognizer!
    
    var accounts: [User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        accountsTableView.delegate = self
        accountsTableView.dataSource = self
        
        panGesture.delegate = self
        
        accounts = User.authorizedUsers
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onPan(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: self.view)
        let velocity = sender.velocity(in: self.view)
        print("transy:\(translation.y)  vy:\(velocity.y)")
        if  (translation.y > 200) && (velocity.y > 150) {
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func onCreateAccountButton(_ sender: Any) {
        TwitterService.sharedInstance?.login(as: nil, success: { () -> () in
            print("I've logged in")
            
            self.performSegue(withIdentifier: "SwitchAccountSegue", sender: nil)
        }, failure: { (error: Error) -> () in
            Utils.popAlertWith(msg: "error in login: \(error.localizedDescription)", in: self)
        })
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let sender = sender as? UITableViewCell {
            let indexPath = accountsTableView.indexPath(for: sender)!
            User.currentUser = accounts[indexPath.row]
        }
    }

}

extension AccountsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return accounts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = accountsTableView.dequeueReusableCell(withIdentifier: "AccountCell", for: indexPath) as! AccountCell
        cell.user = accounts[indexPath.row]
        
        return cell
    }
}

extension AccountsViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
