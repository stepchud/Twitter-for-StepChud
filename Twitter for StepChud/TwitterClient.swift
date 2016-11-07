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
                        user.token = accessToken
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
    
    func homeTimeline(since: Int?, before: Int?, success: @escaping ([Tweet]) -> (), failure: @escaping (Error) -> ()) {
        var parameters = [String: Int]()
        if let since = since {
            parameters["since_id"] = since
        }
        if let before = before {
            parameters["max_id"] = before
        }
        print("homeTimeline(\(parameters)")
        get("1.1/statuses/home_timeline.json", parameters: parameters, progress: nil,
            success: { (task: URLSessionDataTask?, response: Any?) in
                let dictionaries = response as! [NSDictionary]
                let tweets = Tweet.fromArray(dictionaries: dictionaries)
                success(tweets)
            },
            failure: { (task: URLSessionDataTask?, error: Error) in
                failure(error)
        })
    }
    
    func userTimeline(for userName: String, since: Int?, before: Int?, success: @escaping ([Tweet]) -> (), failure: @escaping (Error) -> ()) {
        var parameters: [String: Any] = ["screen_name": userName]
        if let since = since {
            parameters["since_id"] = since
        }
        if let before = before {
            parameters["max_id"] = before
        }
        print("userTimeline(\(parameters)")
        get("1.1/statuses/user_timeline.json", parameters: parameters, progress: nil,
            success: { (task: URLSessionDataTask?, response: Any?) in
                let dictionaries = response as! [NSDictionary]
                let tweets = Tweet.fromArray(dictionaries: dictionaries)
                success(tweets)
            },
            failure: { (task: URLSessionDataTask?, error: Error) in
                failure(error)
        })
    }
    
    func sendTweet(_ text: String, replyTweet: Tweet?, success: @escaping (Tweet) -> (), failure: @escaping (Error) ->()) {
        print("sending tweet to: \(replyTweet?.id!)")
        var parameters = ["status": text]
        if let replyID = replyTweet?.id {
            parameters["in_reply_to_status_id"] = replyID
        }
        post("1.1/statuses/update.json", parameters: parameters, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            if let dictionary = response as? NSDictionary {
                success(Tweet(dictionary: dictionary))
            }
        }) { (task: URLSessionDataTask?, error: Error) in
            failure(error)
        }
    }
    
    func toggleRetweet(tweet: Tweet, success: @escaping () -> (), failure: @escaping (Error) ->()) {
        if let tweetID = tweet.id {
            if tweet.retweeted { // undo RT
                var originalTweet = tweetID
                if let retweetStatus = tweet.retweetStatus {
                    originalTweet = retweetStatus.id!
                }
                get("1.1/statuses/show/\(originalTweet).json", parameters: ["include_my_retweet": true],
                    progress: nil, success: {(task: URLSessionDataTask, response: Any?) in
                        if let dictionary = response as? NSDictionary {
                            if let user_retweet = dictionary["current_user_retweet"] as? NSDictionary {
                                self.post("1.1/statuses/unretweet/\(user_retweet["id_str"] as! String).json", parameters: nil, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
                                    success()
                                }) { (task: URLSessionDataTask?, error: Error) in
                                    failure(error)
                                }
                            }
                        }
                }) { (task: URLSessionDataTask?, error: Error) in
                    failure(error)
                }
            } else { // RT
                post("1.1/statuses/retweet/\(tweetID).json", parameters: nil, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
                    success()
                }) { (task: URLSessionDataTask?, error: Error) in
                    failure(error)
                }
            }
        }
    }
    
    func toggleFavorite(tweet: Tweet, success: @escaping () -> (), failure: @escaping (Error) ->()) {
        if let tweetID = tweet.id {
            let postURL = tweet.favorited ? "1.1/favorites/destroy.json" : "1.1/favorites/create.json"
            post(postURL, parameters: ["id": tweetID], progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
                success()
            }) { (task: URLSessionDataTask?, error: Error) in
                failure(error)
            }
        }
    }
}
