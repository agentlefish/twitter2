//
//  LoginViewController.swift
//  Twitter
//
//  Created by Xiang Yu on 9/26/17.
//  Copyright © 2017 Xiang Yu. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onLoginButton(_ sender: Any) {
        TwitterService.sharedInstance?.login(as: nil,success: { () -> () in
            print("I've logged in")
            
            self.performSegue(withIdentifier: "LoginSegue", sender: nil)
        }, failure: { (error: Error) -> () in
            Utils.popAlertWith(msg: "error in login: \(error.localizedDescription)", in: self)
        })
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
