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
    var headerImgUrl: URL?
    var tagline: String?
    
    var tweetsCount: Int?
    var followingCount: Int?
    var followersCount: Int?
    
    var json:JSON?
    
    init(json: JSON) {
        self.json = json
        
        name = json["name"].string
        screenname = json["screen_name"].string
        tagline = json["description"].string
        
        tweetsCount = json["statuses_count"].int
        followingCount = json["friends_count"].int
        followersCount = json["followers_count"].int
        
        if let imgUrlStr = json["profile_image_url_https"].string {
            profileImgUrl = URL(string: imgUrlStr)
        }
        
        if let imgUrlStr = json["profile_banner_url"].string {
            headerImgUrl = URL(string: imgUrlStr)
        }
    }
    
    class func build(_ json:JSON) -> User {
        return User(json: json)
    }
    
    //screen names
    static var authorizedUsers: [User] = []
    
    private static var _currentUser: User!
    
    class var currentUser: User? {
        get {
            if _currentUser != nil {
                return _currentUser
            }
            
            let defaults = UserDefaults.standard
            if let jsonStr = defaults.object(forKey: "currentUserJSON") as? String {
                _currentUser = build(JSON(parseJSON: jsonStr))
                
                if authorizedUsers.index(of: _currentUser) == nil {
                    authorizedUsers.append(_currentUser)
                }
            }
            return _currentUser
        }
        
        set(user) {
            if let user = user {
                if authorizedUsers.index(of: user) == nil {
                    authorizedUsers.append(user)
                }
            }
            
            let defaults = UserDefaults.standard
            
            defaults.set(user?.json?.rawString(), forKey: "currentUserJSON")
            
            defaults.synchronize()
        }
    }
}
