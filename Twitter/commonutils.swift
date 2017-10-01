//
//  commonutils.swift
//  Twitter
//
//  Created by Xiang Yu on 9/29/17.
//  Copyright © 2017 Xiang Yu. All rights reserved.
//

import UIKit

class Utils {
    class func popAlertWith(msg: String, in view: UIViewController) {
        let alertController = UIAlertController(title: "Error", message: msg, preferredStyle: .alert)
        
        // create an OK action
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in
            // handle response here.
        }
        // add the OK action to the alert controller
        alertController.addAction(OKAction)
        view.present(alertController, animated: true) {
            // optional code for what happens after the alert controller has finished presenting
        }
    }
}

