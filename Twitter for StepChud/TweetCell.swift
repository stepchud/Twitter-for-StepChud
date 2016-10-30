//
//  TweetCell.swift
//  Twitter for StepChud
//
//  Created by Stephen Chudleigh on 10/28/16.
//  Copyright © 2016 Stephen Chudleigh. All rights reserved.
//

import UIKit
import AlamofireImage

class TweetCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!

    var tweet: Tweet! {
        didSet {
            fullNameLabel.text = tweet.fullName
            userNameLabel.text = "@\(tweet.userName ?? "")"
            timestampLabel.text = tweet.timestamp?.relativeTime ?? "N/A"
            tweetTextLabel.text = tweet.text
            if let profileImage = tweet.profileImageURL {
                profileImageView.af_setImage(withURL: profileImage)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func onReplyButton(_ sender: UIButton) {
    }
    @IBAction func onRetweetButton(_ sender: UIButton) {
    }
    @IBAction func onFavoriteButton(_ sender: AnyObject) {
    }
}
