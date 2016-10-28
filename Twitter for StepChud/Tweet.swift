//
//  Tweet.swift
//  Twitter for StepChud
//
//  Created by Stephen Chudleigh on 10/27/16.
//  Copyright © 2016 Stephen Chudleigh. All rights reserved.
//

import UIKit

class Tweet: NSObject {
    
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
        text = dictionary["text"] as? String
        retweetCount = (dictionary["retweet_count"] as? Int) ?? 0
        favoritesCount = (dictionary["favorites_count"] as? Int) ?? 0
        
        if let created_at = dictionary["created_at"] as? String {
            timestamp = formatter.date(from: created_at)
        }
        
        if let urlString = dictionary["profile_image_url_https"] as? String {
            self.profileImageURL = URL(string: urlString)
        }
    }
    
    class func fromArray(dictionaries: [NSDictionary]) -> [Tweet] {
        var tweets = [Tweet]()
        
        for dictionary in dictionaries {
            let tweet = Tweet(dictionary: dictionary)
            tweets.append(tweet)
        }
        
        return tweets
    }
}
