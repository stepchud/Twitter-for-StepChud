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
    static let storyboardIdentifier = "ProfileViewController"
    
    @IBOutlet weak var tableView: UITableView!
    
    var isDataLoading = false
    var loadingMoreView:InfiniteScrollActivityView?
    
    var user: User!
    var timeline: Timeline?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
        
        if user == nil {
            user = User.currentUser
        }
        
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.barTintColor = TwitterBlue
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        setupInfiniteScroll()
        loadUserTimeline()
    }


    func loadUserTimeline() {
        TwitterClient.sharedInstance?.userTimeline(for: user.username!, since: nil, before: nil, success: { (tweets: [Tweet]) in
            self.timeline = Timeline(tweets: tweets)
            
            self.tableView.reloadData()
            
            }, failure: { (error: Error) in
                print(error.localizedDescription)
        })
    }
    
    
    func loadOlderTweets() {
        TwitterClient.sharedInstance?.userTimeline(for: user.username!, since: nil, before: timeline?.minID, success: { (olderTweets: [Tweet]) in
            self.timeline?.append(tweets: olderTweets)
            self.tableView.reloadData()
            self.isDataLoading = false
            self.loadingMoreView!.stopAnimating()
            }, failure: { (error: Error) in
                // handle error loading tweets
        })
    }
    
    // Set up Infinite Scroll loading indicator
    func setupInfiniteScroll() {
        let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.isHidden = true
        tableView.addSubview(loadingMoreView!)
        
        var insets = tableView.contentInset;
        insets.bottom += InfiniteScrollActivityView.defaultHeight;
        tableView.contentInset = insets
    }
    
    // first row has the profile info & images
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let tweets = timeline?.tweets {
            return tweets.count + 1
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row==0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "UserProfileCell", for: indexPath) as! UserProfileCell
            cell.user = user
            cell.selectionStyle = .none
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TweetCell", for: indexPath) as! TweetCell
            if let tweet = timeline?.tweets?[indexPath.row-1] {
                cell.tweet = tweet
                cell.delegate = self
            }
            cell.selectionStyle = .none
            
            return cell
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        if segue.destination is TweetDetailViewController {
            let vc = segue.destination as! TweetDetailViewController
            if let indexPath = tableView.indexPath(for: sender as! UITableViewCell) {
                vc.tweet = self.timeline?.tweets?[indexPath.row-1]
            }
        }
    }

}

extension ProfileViewController: ComposeTweetDelegate {
    func composeTweetViewController(newTweet: Tweet) {
        if user.username == newTweet.user?.username {
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

extension ProfileViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !isDataLoading {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.isDragging) {
                isDataLoading = true
                
                // Update position of loadingMoreView, and start loading indicator
                let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
                loadingMoreView?.frame = frame
                loadingMoreView!.startAnimating()
                
                loadOlderTweets()
            }
        }
    }
}
