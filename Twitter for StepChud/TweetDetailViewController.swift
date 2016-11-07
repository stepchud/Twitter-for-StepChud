//
//  TweetDetailViewController.swift
//  Twitter for StepChud
//
//  Created by Stephen Chudleigh on 10/28/16.
//  Copyright © 2016 Stephen Chudleigh. All rights reserved.
//

import UIKit

class TweetDetailViewController: UIViewController {

    var tweet: Tweet!
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var retweetsCountLabel: UILabel!
    @IBOutlet weak var favoritesCountLabel: UILabel!
    
    @IBOutlet weak var retweetButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadTweet()
    }
    
    func loadTweet() {
        if let tweet = tweet {
            if let url = tweet.user?.profileURL {
                profileImageView.af_setImage(withURL: url)
            }
            fullNameLabel.text = tweet.user?.name
            userNameLabel.text = "@\(tweet.user?.username ?? "")"
            tweetTextLabel.text = tweet.text
            retweetsCountLabel.text = "\(tweet.retweetCount)"
            favoritesCountLabel.text = "\(tweet.favoritesCount)"
            updateButtons()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onReplyButton(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: ComposeTweetViewController.storyboardIdentifier) as! UINavigationController
        if let composeVC = vc.viewControllers.first as? ComposeTweetViewController {
            composeVC.replyTweet = tweet
        }
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func onRetweetButton(_ sender: UIButton) {
        if let tweet = tweet {
            TwitterClient.sharedInstance?.toggleRetweet(tweet: tweet, success: { () in
                self.tweet.retweeted = !self.tweet.retweeted
                if self.tweet.retweeted {
                    self.tweet.retweetCount += 1
                } else {
                    self.tweet.retweetCount -= 1
                }
                self.retweetsCountLabel.text = "\(self.tweet.retweetCount)"
                self.updateButtons()
                }, failure: { (error: Error) in
                    UIAlertPresenter.presentAlert(errorText: error.localizedDescription, from: self)
            })
        } else {
            UIAlertPresenter.presentAlert(errorText: "Tweet ID missing", from: self)
        }
    }
    @IBAction func onFavoriteButton(_ sender: UIButton) {
        if let tweet = tweet {
            TwitterClient.sharedInstance?.toggleFavorite(tweet: tweet, success: {
                self.tweet.favorited = !self.tweet.favorited
                if self.tweet.favorited {
                    self.tweet.favoritesCount += 1
                } else {
                    self.tweet.favoritesCount -= 1
                }
                self.favoritesCountLabel.text = "\(self.tweet.favoritesCount)"
                self.updateButtons()
                }, failure: { (error: Error) in
                    UIAlertPresenter.presentAlert(errorText: error.localizedDescription, from: self)
            })
        } else {
            UIAlertPresenter.presentAlert(errorText: "Tweet ID missing", from: self)
        }
    }
    
    func updateButtons() {
        if let tweet = tweet {
            retweetButton.setImage(tweet.retweeted ? #imageLiteral(resourceName: "retweet-active") : #imageLiteral(resourceName: "retweet"), for: .normal)
            favoriteButton.setImage(tweet.favorited ? #imageLiteral(resourceName: "favorite-active") : #imageLiteral(resourceName: "favorite"), for: .normal)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

