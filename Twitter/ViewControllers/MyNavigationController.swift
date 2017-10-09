//
//  MyNavigationController.swift
//  Twitter
//
//  Created by Xiang Yu on 10/8/17.
//  Copyright © 2017 Xiang Yu. All rights reserved.
//

import UIKit

class MyNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressToBringUpAccountsView))
        self.view.addGestureRecognizer(longPress)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func longPressToBringUpAccountsView() {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let accountsViewController = mainStoryboard.instantiateViewController(withIdentifier: "AccountsViewController") as! AccountsViewController
        
        //accountsViewController.modalTransitionStyle = UIModalTransitionStyle
        accountsViewController.modalPresentationStyle = UIModalPresentationStyle.popover
        self.present(accountsViewController, animated: true, completion: nil)
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
