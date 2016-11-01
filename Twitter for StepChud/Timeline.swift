//
//  Timeline.swift
//  Twitter for StepChud
//
//  Created by Stephen Chudleigh on 10/30/16.
//  Copyright © 2016 Stephen Chudleigh. All rights reserved.
//

import UIKit

class Timeline: NSObject {

    var tweets: [Tweet]?
    
    var maxID: Int {
        let maxID = tweets!.map { Int($0.id!) }.reduce(0) {
            max, curr in
            return max! > curr! ? max : curr
        }
        return maxID!
    }
    
    var minID: Int {
        let minID = tweets!.map { Int($0.id!) }.reduce(0) {
            min, curr in
            if min == 0 {
                return curr!
            } else {
                return (min > curr!) ? curr! : min
            }
        }
        return minID - 1
    }
    
    init(tweets: [Tweet]) {
        self.tweets = tweets
    }
    
    func prepend(tweets: [Tweet]) {
        if let currentTweets = self.tweets {
            self.tweets = tweets + currentTweets
        } else {
            self.tweets = tweets
        }
    }
    
    func append(tweets: [Tweet]) {
        if let currentTweets = self.tweets {
            self.tweets = currentTweets + tweets
        } else {
            self.tweets = tweets
        }
    }
}
