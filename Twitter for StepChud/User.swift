//
//  User.swift
//  Twitter for StepChud
//
//  Created by Stephen Chudleigh on 10/27/16.
//  Copyright © 2016 Stephen Chudleigh. All rights reserved.
//

import Foundation
import BDBOAuth1Manager

class User: NSObject {
    
    static let userDidLoginNotification = "UserDidLogin"
    static let userDidLogoutNotification = "UserDidLogout"
    static let userStartedTweetNotification = "UserStartedTweet"
    static let userSentTweetNotification = "UserSentTweet"
    static let userCanceledTweetNotification = "UserCanceledTweet"
    static let currentUserKey = "currentUserData"
    
    var token: BDBOAuth1Credential?
    var name: String?
    var username: String?
    var profileURL: URL?
    var profileBackgroundURL: URL?
    var tagLine: String?
    var followerCount: Int?
    var followingCount: Int?
    
    var dictionary: NSDictionary?
    
    init(dictionary: NSDictionary) {
        self.dictionary = dictionary
        
        name = dictionary["name"] as? String
        username = dictionary["screen_name"] as? String
        tagLine = dictionary["description"] as? String
        followerCount = dictionary["followers_count"] as? Int
        followingCount = dictionary["friends_count"] as? Int
        if let url = dictionary["profile_image_url_https"] as? String {
            profileURL = URL(string: url)
        }
        if let bgUrl = dictionary["profile_banner_url"] as? String {
            profileBackgroundURL = URL(string: bgUrl)
        }
    }
    
    
    static var _currentUser: User?
    
    class var currentUser: User? {
        get {
            if (_currentUser == nil) {
                let defaults = UserDefaults.standard
                
                if let userData = defaults.object(forKey: User.currentUserKey) as? Data {
                    let dictionary = try! JSONSerialization.jsonObject(with: userData, options: []) as! NSDictionary
                    let user = User(dictionary: dictionary)
                    _currentUser = user
                }
            }
            return _currentUser
        }
        
        set(user) {
            _currentUser = user
            
            let defaults = UserDefaults.standard
            if let user = user {
                let data = try! JSONSerialization.data(withJSONObject: user.dictionary!, options: [])
                
                defaults.set(data, forKey: User.currentUserKey)
            } else {
                defaults.removeObject(forKey: User.currentUserKey)
            }
            defaults.synchronize()
        }
    }
}
