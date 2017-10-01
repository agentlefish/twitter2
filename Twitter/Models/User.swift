//
//  User.swift
//  Twitter
//
//  Created by Xiang Yu on 9/28/17.
//  Copyright © 2017 Xiang Yu. All rights reserved.
//

import UIKit
import SwiftyJSON

class User: NSObject {
    
    var name: String?
    var screenname: String?
    var profileImgUrl: URL?
    var tagline: String?
    
    var json:JSON?
    
    init(json: JSON) {
        self.json = json
        
        name = json["name"].string
        screenname = json["screen_name"].string
        tagline = json["description"].string
        
        if let imgUrlStr = json["profile_image_url_https"].string {
            profileImgUrl = URL(string: imgUrlStr)
        }
    }
    
    class func build(_ json:JSON) -> User {
        return User(json: json)
    }
    
    private static var _currentUser: User?
    
    class var currentUser: User? {
        get {
            if _currentUser != nil {
                return _currentUser
            }
            
            let defaults = UserDefaults.standard
            if let jsonStr = defaults.object(forKey: "currentUserJSON") as? String {
                _currentUser = build(JSON(parseJSON: jsonStr))
            }
            return _currentUser
        }
        
        set(user) {
            let defaults = UserDefaults.standard
            
            defaults.set(user?.json?.rawString(), forKey: "currentUserJSON")
            
            defaults.synchronize()
        }
    }
}
