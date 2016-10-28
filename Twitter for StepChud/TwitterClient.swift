//
//  TwitterClient.swift
//  Twitter for StepChud
//
//  Created by Stephen Chudleigh on 10/27/16.
//  Copyright © 2016 Stephen Chudleigh. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

class TwitterClient: BDBOAuth1SessionManager {
    
    static let sharedInstance = TwitterClient(baseURL: URL(string: "https://api.twitter.com"), consumerKey: "FQOglB67JmOeuVrhz5k1xNZFQ", consumerSecret: "JIyF5LsS5BGkRpNgV1h6sZumdG920Lg63PAhyY8yiia1ms3EGV")
    
    var loginSuccess: (() -> ())?
    var loginFailure: ((Error?) -> ())?
    
    func login(success: @escaping () -> (), failure: @escaping (Error?) -> ()) {
        loginSuccess = success
        loginFailure = failure
        
        TwitterClient.sharedInstance?.deauthorize()
        TwitterClient.sharedInstance?.fetchRequestToken(
            withPath: "oauth/request_token",
            method: "GET",
            callbackURL: URL(string: "twitterclone://oauth"),
            scope: nil,
            success: { (requestToken:BDBOAuth1Credential?) in
                print("token fetch success \(requestToken?.token)")
                if let token = requestToken?.token {
                    let url = URL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(token)")!
                    UIApplication.shared.open(url)
                }
                
            },
            failure: { (error: Error?) in
                print("error: \(error?.localizedDescription)")
        })
    }
    
    func logout() {
        deauthorize()
    }
    
    func handleOpenUrl(url: URL) {
        let requestToken = BDBOAuth1Credential(queryString: url.query)
        
        fetchAccessToken( withPath: "oauth/access_token", method: "POST", requestToken: requestToken,
            success: { (accessToken: BDBOAuth1Credential?) in

                TwitterClient.sharedInstance?.currentAccount(
                    success: { (user: User) in
                        User.currentUser = user
                        self.loginSuccess?()
                    }, failure: { (error: Error) in
                        self.loginFailure?(error)
                })
                
            }, failure: { (error: Error?) in
                print(error?.localizedDescription)
                self.loginFailure?(error)
        })
    }
    
    func currentAccount(success: @escaping (User) -> (), failure: @escaping (Error) -> ()) {
        get("1.1/account/verify_credentials.json",
             parameters: nil,
             progress: nil,
             success: { (task: URLSessionDataTask?, response: Any?) in
                let dictionary = response as! NSDictionary
                let user = User(dictionary: dictionary)
                success(user)
            },
             failure: { (task: URLSessionDataTask?, error: Error) in
                failure(error)
        })
    }
    
    func homeTimeline(success: @escaping ([Tweet]) -> (), failure: @escaping (Error) -> ()) {
        get("1.1/statuses/home_timeline.json", parameters: nil, progress: nil,
            success: { (task: URLSessionDataTask?, response: Any?) in
                let dictionaries = response as! [NSDictionary]
                let tweets = Tweet.fromArray(dictionaries: dictionaries)
                success(tweets)
            },
            failure: { (task: URLSessionDataTask?, error: Error) in
                failure(error)
        })
    }
}