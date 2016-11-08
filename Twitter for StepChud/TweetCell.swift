//
//  TweetCell.swift
//  Twitter for StepChud
//
//  Created by Stephen Chudleigh on 10/28/16.
//  Copyright © 2016 Stephen Chudleigh. All rights reserved.
//

import UIKit
import AlamofireImage

@objc protocol TweetCellDelegate {
    @objc optional func tweetCell(tweetCell: TweetCell, didReply: Bool)
    @objc optional func tweetCell(tweetCell: TweetCell, didClickOnProfileImage: Bool)
}

class TweetCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!

    @IBOutlet weak var replyButton: UIButton!
    @IBOutlet weak var retweetButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    
    weak var delegate: TweetCellDelegate?
    
    var tweet: Tweet! {
        didSet {
            fullNameLabel.text = tweet.user?.name
            userNameLabel.text = "@\(tweet.user?.username ?? "")"
            timestampLabel.text = tweet.timestamp?.relativeTime ?? "N/A"
            tweetTextLabel.text = tweet.text
            if let profileImage = tweet.user?.profileURL {
                profileImageView.af_setImage(withURL: profileImage)
            }
        }
    }
    
    func updateButtons() {
        if let tweet = tweet {
            retweetButton.setImage(tweet.retweeted ? #imageLiteral(resourceName: "retweet-active") : #imageLiteral(resourceName: "retweet"), for: .normal)
            favoriteButton.setImage(tweet.favorited ? #imageLiteral(resourceName: "favorite-active") : #imageLiteral(resourceName: "favorite"), for: .normal)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let tap = UITapGestureRecognizer(target: self, action: #selector(onProfileImageClicked))
        profileImageView.addGestureRecognizer(tap)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func onProfileImageClicked(_ sender: UIImageView) {
        delegate?.tweetCell?(tweetCell: self, didClickOnProfileImage: true)
    }

    @IBAction func onReplyButton(_ sender: UIButton) {
        delegate?.tweetCell?(tweetCell: self, didReply: true)
    }
    
    @IBAction func onRetweetButton(_ sender: UIButton) {
        if let tweet = tweet {
            TwitterClient.sharedInstance?.toggleRetweet(tweet: tweet, success: { () in
                self.tweet.retweeted = !self.tweet.retweeted
                self.updateButtons()
                }, failure: { (error: Error) in
                    // ignore it for now
            })
        } else {
            // ignore it
        }
    }
    @IBAction func onFavoriteButton(_ sender: AnyObject) {
        if let tweet = tweet {
            TwitterClient.sharedInstance?.toggleFavorite(tweet: tweet, success: {
                self.tweet.favorited = !self.tweet.favorited
                self.updateButtons()
                }, failure: { (error: Error) in
                    // ignore it for now
            })
        } else {
            // ignore it for now
        }
    }
}
