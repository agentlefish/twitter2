//
//  Tweet.swift
//  Twitter
//
//  Created by Xiang Yu on 9/26/17.
//  Copyright © 2017 Xiang Yu. All rights reserved.
//

import UIKit
import SwiftyJSON

class Tweet: NSObject {
    
    var id: Int?
    var text: String?
    var timestamp: Date?
    var retweetCount: Int = 0
    var retweeted: Bool = false
    var favoritesCount: Int = 0
    var favorited: Bool = false
    
    var user: User?
    
    class func build(_ json:JSON) -> Tweet {
        let tweet = Tweet()
        tweet.id = json["id"].int
        tweet.text = json["text"].string
        tweet.retweetCount = json["retweet_count"].int ?? 0
        tweet.retweeted = json["retweeted"].bool ?? false
        tweet.favoritesCount = json["favorite_count"].int ?? 0
        tweet.favorited = json["favorited"].bool ?? false
        
        tweet.user = User.build(json["user"])
        
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
        if let timestampstr = json["created_at"].string {
            tweet.timestamp = formatter.date(from: timestampstr)
        }
        
        return tweet
    }
}
