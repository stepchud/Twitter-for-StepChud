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
    var user: User?
    var text: String?
    var timestamp: Date?
    var retweeted=false
    var retweetStatus: Tweet?
    var retweetCount: Int=0
    var favorited=false
    var favoritesCount: Int=0
    
    let formatter = DateFormatter()
    
    init(dictionary: NSDictionary) {
        formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
        if let userDict = dictionary["user"] as? NSDictionary {
            user = User(dictionary: userDict)
        }
        
        id = dictionary["id_str"] as? String
        text = dictionary["text"] as? String
        retweeted = dictionary["retweeted"] as! Bool
        retweetCount = (dictionary["retweet_count"] as? Int) ?? 0
        if let rtDictionary = dictionary["retweeted_status"] as? NSDictionary {
            retweetStatus = Tweet(dictionary: rtDictionary)
        }
        favorited = dictionary["favorited"] as! Bool
        favoritesCount = (dictionary["favorite_count"] as? Int) ?? 0
        
        if let created_at = dictionary["created_at"] as? String {
            timestamp = formatter.date(from: created_at)
        }
    }
    
    class func fromArray(dictionaries: [NSDictionary]) -> [Tweet] {
        var tweets = [Tweet]()
        
        for dictionary in dictionaries {
            tweets.append(Tweet(dictionary: dictionary))
        }
        
        return tweets
    }
}
