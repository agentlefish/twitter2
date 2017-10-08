//
//  TwitterService.swift
//  Twitter
//
//  Created by Xiang Yu on 9/26/17.
//  Copyright © 2017 Xiang Yu. All rights reserved.
//

import UIKit
import BDBOAuth1Manager
import SwiftyJSON

extension NSNotification.Name {
    static let TwitterUserDidLogout = NSNotification.Name("TwitterUserDidLogout")
}

class TwitterService: BDBOAuth1SessionManager {
    
    var loginSuccess: (() -> ())?
    var loginFailure: ((Error) -> ())?
    
    enum TimelineType {
        case home
        case mentions
        case user
    }
    
    static let sharedInstance = TwitterService(baseURL: URL(string: "https://api.twitter.com"), consumerKey: "RAHfq2C7VjV4S7vVB2XvhJGem", consumerSecret: "BiIZzhTg6baYf7VvukvRPqfAgHoes7eMbX5stYG3hBJUAHbbSc")
    
    func login(success:@escaping () -> (), failure:@escaping (Error) -> ()) {
        loginSuccess = success
        loginFailure = failure
        
        deauthorize()
        fetchRequestToken(withPath: "oauth/request_token", method: "GET", callbackURL: URL(string: "twittercodepath://oauth"), scope: nil, success: { (requestToken: BDBOAuth1Credential!) in
            print("I got a request token")
            
            guard let url = URL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(requestToken.token!)") else {
                print("error: authentication url error. request token: \(requestToken.token!)")
                return
            }
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }, failure: { (error: Error!) in
            print("error during oauth request token: \(error.localizedDescription)")
            self.loginFailure?(error)
        })
    }
    
    func logout() {
        User.currentUser = nil
        deauthorize()
        
        NotificationCenter.default.post(name: NSNotification.Name.TwitterUserDidLogout, object: nil)
    }
    
    func open(url: URL) {
        print(url.description)
        let accessToken = BDBOAuth1Credential(queryString: url.query)
        
        fetchAccessToken(withPath: "oauth/access_token", method: "POST", requestToken: accessToken, success: { (accessToken: BDBOAuth1Credential!) in
            
            self.currentAccount(success: { (user: User) in
                User.currentUser = user
                self.loginSuccess?()
            }, failure: { (error: Error) in
                self.loginFailure?(error)
            })
            
        }, failure: { (error: Error!) in
            
            print("error during oauth access token: \(error.localizedDescription)")
            self.loginFailure?(error)
            
        })
    }
    
    func getTimeline(_ type: TimelineType!, olderthan tweetid: Int?, forScreenName screenname: String?, success: @escaping ([Tweet]) -> (), failure: @escaping (Error) -> ()) {
        
        var parameters: [String : AnyObject] = [:]
        
        if let tweetid = tweetid {
            parameters["max_id"] = (tweetid-1) as AnyObject
        }
        
        if let screenname = screenname {
            parameters["screen_name"] = screenname as AnyObject
        }
        
        var cmd: String!
        
        switch type {
        case .home:
            cmd = "1.1/statuses/home_timeline.json"
            break
        case .mentions:
            cmd = "1.1/statuses/mentions_timeline.json"
            break
        case .user:
            cmd = "1.1/statuses/user_timeline.json"
            break
        default:
            cmd = "1.1/statuses/home_timeline.json"
            break
        }

        get(cmd, parameters: parameters, progress: nil, success: { (task: URLSessionDataTask, response: Any) -> Void in
            
            let rootJSON = JSON(response)
            if let tweets = (rootJSON.array?.map { return Tweet.build($0) }) {
                success(tweets)
            }
            }, failure: { (task: URLSessionDataTask?, error: Error) -> Void in
                print("error in get home timeline: \(error.localizedDescription)")
                failure(error)
                })
    }
    
    func currentAccount(success: @escaping (User) -> (), failure: @escaping (Error) -> ()) {
        
        get("1.1/account/verify_credentials.json", parameters: nil, progress: nil, success: { (task: URLSessionDataTask, response: Any) -> Void in
            
            let rootJSON = JSON(response)
            let user = User.build(rootJSON)
            success(user)
            print("current user name: \(user.name)")
            
        }, failure: { (task: URLSessionDataTask?, error: Error) -> Void in
            print("error in get current user: \(error.localizedDescription)")
            failure(error)
        })
    }
    
    func getUser(byScreenName screenname: String?, orByUserId userId: Int?, success: @escaping (User) -> (), failure: @escaping (Error) -> ()) {
        
        var parameters: [String : AnyObject] = [:]
        
        if let screenname = screenname {
            parameters["screen_name"] = screenname as AnyObject
        }
        
        if let userId = userId {
            parameters["user_id"] = userId as AnyObject
        }
        
        get("1.1/users/show.json", parameters: parameters, progress: nil, success: { (task: URLSessionDataTask, response: Any) -> Void in
            
            let rootJSON = JSON(response)
            let user = User.build(rootJSON)
            success(user)
            print("current user name: \(user.name)")
            
        }, failure: { (task: URLSessionDataTask?, error: Error) -> Void in
            print("error in get current user: \(error.localizedDescription)")
            failure(error)
        })
    }
    
    func tweet(_ status: String!, replyTo tweetid: Int?, success: @escaping (Tweet) -> (), failure: @escaping (Error) -> ()) {

        var parameters: [String : AnyObject] = ["status": status as AnyObject]
        
        if let tweetid = tweetid {
            parameters["in_reply_to_status_id"] = tweetid as AnyObject
        }
        
        post("1.1/statuses/update.json", parameters: parameters, progress: nil, success: { (task: URLSessionDataTask, response: Any) in
            
            let rootJSON = JSON(response)
            let tweet = Tweet.build(rootJSON)
            success(tweet)
            print("tweet OK!!!")
            
        }) { (task: URLSessionDataTask?, error: Error) in
            print("error in sending tweet: \(error.localizedDescription)")
            failure(error)
        }
    }
    
    func retweet(_ tweetid: Int!, success: @escaping (Tweet) -> (), failure: @escaping (Error) -> ()) {
        
        //let parameters: [String : AnyObject] = ["id": tweetid as AnyObject]
        
        post("1.1/statuses/retweet/\(tweetid.description).json", parameters: nil, progress: nil, success: { (task: URLSessionDataTask, response: Any) in
            
            let rootJSON = JSON(response)
            let tweet = Tweet.build(rootJSON)
            // return value may be delayed. but we have to display retweeted in UI first
            tweet.retweeted = true
            success(tweet)
            print("retweet OK!!!")
            
        }) { (task: URLSessionDataTask?, error: Error) in
            print("error in retweet: \(error.localizedDescription)")
            failure(error)
        }
    }
    
    func unretweet(_ tweetid: Int!, success: @escaping (Tweet) -> (), failure: @escaping (Error) -> ()) {
        
        //let parameters: [String : AnyObject] = ["id": tweetid as AnyObject]
        
        post("1.1/statuses/unretweet/\(tweetid.description).json", parameters: nil, progress: nil, success: { (task: URLSessionDataTask, response: Any) in
            
            let rootJSON = JSON(response)
            let tweet = Tweet.build(rootJSON)
            // return value may be delayed. but we have to display retweeted in UI first
            tweet.retweeted = false
            success(tweet)
            print("unretweet OK!!!")
            
        }) { (task: URLSessionDataTask?, error: Error) in
            print("error in unretweet: \(error.localizedDescription)")
            failure(error)
        }
    }
    
    func favorite(_ tweetid: Int!, success: @escaping (Tweet) -> (), failure: @escaping (Error) -> ()) {
        
        let parameters: [String : AnyObject] = ["id": tweetid as AnyObject]
        
        post("1.1/favorites/create.json", parameters: parameters, progress: nil, success: { (task: URLSessionDataTask, response: Any) in
            
            let rootJSON = JSON(response)
            let tweet = Tweet.build(rootJSON)
            // return value may be delayed. but we have to display favorited in UI first
            tweet.favorited = true
            success(tweet)
            print("favorite OK!!!")
            
        }) { (task: URLSessionDataTask?, error: Error) in
            print("error in favorite: \(error.localizedDescription)")
            failure(error)
        }
    }
    
    func unfavorite(_ tweetid: Int!, success: @escaping (Tweet) -> (), failure: @escaping (Error) -> ()) {
        
        let parameters: [String : AnyObject] = ["id": tweetid as AnyObject]
        
        post("1.1/favorites/destroy.json", parameters: parameters, progress: nil, success: { (task: URLSessionDataTask, response: Any) in
            
            let rootJSON = JSON(response)
            let tweet = Tweet.build(rootJSON)
            // return value may be delayed. but we have to display favorited in UI first
            tweet.favorited = false
            success(tweet)
            print("unfavorite OK!!!")
            
        }) { (task: URLSessionDataTask?, error: Error) in
            print("error in unfavorite: \(error.localizedDescription)")
            failure(error)
        }
    }
    
}
