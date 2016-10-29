//
//  TweetDetailViewController.swift
//  Twitter for StepChud
//
//  Created by Stephen Chudleigh on 10/28/16.
//  Copyright © 2016 Stephen Chudleigh. All rights reserved.
//

import UIKit

class TweetDetailViewController: UIViewController {

    var tweet: Tweet?
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var retweetsCountLabel: UILabel!
    @IBOutlet weak var favoritesCountLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadTweet()
    }
    
    func loadTweet() {
        if let tweet = tweet {
            if let url = tweet.profileImageURL {
                profileImageView.af_setImage(withURL: url)
            }
            fullNameLabel.text = tweet.fullName
            userNameLabel.text = tweet.userName
            tweetTextLabel.text = tweet.text
            retweetsCountLabel.text = "\(tweet.retweetCount)"
            favoritesCountLabel.text = "\(tweet.favoritesCount)"
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
