//
//  UserProfileCell.swift
//  Twitter for StepChud
//
//  Created by Stephen Chudleigh on 11/7/16.
//  Copyright © 2016 Stephen Chudleigh. All rights reserved.
//

import UIKit
import AlamofireImage

class UserProfileCell: UITableViewCell {

    @IBOutlet weak var profileBackgroundImage: UIImageView!
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var profileBlurbLabel: UILabel!
    @IBOutlet weak var followingCountLabel: UILabel!
    @IBOutlet weak var followerCountLabel: UILabel!
    
    var user: User! {
        didSet {
            fullNameLabel.text = user.name
            userNameLabel.text = "@\(user.username ?? "")"
            profileBlurbLabel.text = user.tagLine
            followingCountLabel.text = "\(user.followingCount ?? 0)"
            followerCountLabel.text = "\(user.followerCount ?? 0)"
            
            if let profileURL = user.profileURL {
                profileImage.af_setImage(withURL: profileURL)
            }
            if let profileBackgroundURL = user.profileBackgroundURL {
                profileBackgroundImage.af_setImage(withURL: profileBackgroundURL)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
