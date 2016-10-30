//
//  Tweet.swift
//  Twitter for StepChud
//
//  Created by Stephen Chudleigh on 10/27/16.
//  Copyright © 2016 Stephen Chudleigh. All rights reserved.
//

import UIKit

class Tweet: NSObject {
    
    var id: String?
    var fullName: String?
    var userName: String?
    var text: String?
    var timestamp: Date?
    var retweetCount: Int=0
    var favoritesCount: Int=0
    var profileImageURL: URL?
    
    let formatter = DateFormatter()
    
    init(dictionary: NSDictionary) {
        formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
        if let userDict = dictionary["user"] as? NSDictionary {
            fullName = userDict["name"] as? String
            userName = userDict["screen_name"] as? String
            
            if let urlString = userDict["profile_image_url_https"] as? String {
                profileImageURL = URL(string: urlString)
            }
        }
        
        id = dictionary["id_str"] as? String
        text = dictionary["text"] as? String
        retweetCount = (dictionary["retweet_count"] as? Int) ?? 0
        favoritesCount = (dictionary["favorite_count"] as? Int) ?? 0
        
        if let created_at = dictionary["created_at"] as? String {
            timestamp = formatter.date(from: created_at)
        }
    }
    
    init(user: User, text: String) {
        self.text = text
    }
    
    class func fromArray(dictionaries: [NSDictionary]) -> [Tweet] {
        var tweets = [Tweet]()
        
        for dictionary in dictionaries {
            tweets.append(Tweet(dictionary: dictionary))
        }
        
        return tweets
    }
}
