//
//  ProfileViewController.swift
//  Twitter for StepChud
//
//  Created by Stephen Chudleigh on 11/7/16.
//  Copyright © 2016 Stephen Chudleigh. All rights reserved.
//

import UIKit
import AlamofireImage

class ProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var profileBackgroundImage: UIImageView!
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var profileBlurbLabel: UILabel!
    @IBOutlet weak var followingCountLabel: UILabel!
    @IBOutlet weak var followerCountLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    var timeline: Timeline?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
        
        setupHeaderDetails()
        loadUserTimeline()
    }

    func setupHeaderDetails() {
        fullNameLabel.text = User.currentUser?.name
        userNameLabel.text = "@\(User.currentUser?.username ?? "")"
        profileBlurbLabel.text = User.currentUser?.tagLine
        if let profileImageURL = User.currentUser?.profileURL {
            profileImage.af_setImage(withURL: profileImageURL)
        }
        if let profileBackgroundURL = User.currentUser?.profileBackgroundURL {
            profileBackgroundImage.af_setImage(withURL: profileBackgroundURL)
        }
        followingCountLabel.text = "\(User.currentUser?.followingCount ?? 0)"
        followerCountLabel.text = "\(User.currentUser?.followerCount ?? 0)"
    }

    func loadUserTimeline() {
        TwitterClient.sharedInstance?.userTimeline(for: User.currentUser!.username!, since: nil, before: nil, success: { (tweets: [Tweet]) in
            self.timeline = Timeline(tweets: tweets)
            
            self.tableView.reloadData()
            
            }, failure: { (error: Error) in
                print(error.localizedDescription)
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timeline?.tweets?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TweetCell", for: indexPath) as! TweetCell
        if let tweet = timeline?.tweets?[indexPath.row] {
            cell.tweet = tweet
            cell.delegate = self
        }
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        if segue.destination is TweetDetailViewController {
            let vc = segue.destination as! TweetDetailViewController
            if let indexPath = tableView.indexPath(for: sender as! UITableViewCell) {
                vc.tweet = self.timeline?.tweets?[indexPath.row]
            }
        }
    }

}

extension ProfileViewController: ComposeTweetDelegate {
    func composeTweetViewController(newTweet: Tweet) {
        if User.currentUser == newTweet.user {
            timeline?.prepend(tweets: [newTweet])
            tableView.reloadData()
        }
    }
}

extension ProfileViewController: TweetCellDelegate {
    func tweetCell(tweetCell: TweetCell, didReply: Bool) {
        if let tweet = tweetCell.tweet {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: ComposeTweetViewController.storyboardIdentifier) as! UINavigationController
            if let composeVC = vc.viewControllers.first as? ComposeTweetViewController {
                composeVC.replyTweet = tweet
                composeVC.delegate = self
            }
            self.present(vc, animated: true, completion: nil)
        }
    }
}
