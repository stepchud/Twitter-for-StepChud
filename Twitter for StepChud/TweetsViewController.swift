//
//  TweetsViewController.swift
//  Twitter for StepChud
//
//  Created by Stephen Chudleigh on 10/27/16.
//  Copyright © 2016 Stephen Chudleigh. All rights reserved.
//

import UIKit

class TweetsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var timeline: Timeline?
    
    @IBOutlet weak var tableView: UITableView!
    
    // infinite scrooooll
    var isDataLoading = false
    var loadingMoreView:InfiniteScrollActivityView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupNavigation()
        setupInfiniteScroll()
        getTimelineTweets()
        // Do any additional setup after loading the view.
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
    }
    
    func setupNavigation() {
        navigationController?.navigationBar.barTintColor = TwitterBlue
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshTweets), for: .valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
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
        cell.selectionStyle = .none
        
        return cell
    }

    func getTimelineTweets() {
        TwitterClient.sharedInstance?.homeTimeline(since: nil, before: nil, success: { (tweets: [Tweet]) in
            self.timeline = Timeline(tweets: tweets)
            
            self.tableView.reloadData()
            
            }, failure: { (error: Error) in
                print(error.localizedDescription)
        })
    }
    
    func refreshTweets(refreshControl: UIRefreshControl) {
        TwitterClient.sharedInstance?.homeTimeline(since: timeline?.maxID, before: nil, success: { (newTweets: [Tweet]) in
            self.timeline?.prepend(tweets: newTweets)
            self.tableView.reloadData()
            refreshControl.endRefreshing()
            }, failure: { (error: Error) in
                print(error.localizedDescription)
        })
    }
    
    func loadOlderTweets() {
        TwitterClient.sharedInstance?.homeTimeline(since: nil, before: timeline?.minID, success: { (olderTweets: [Tweet]) in
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onLogOut(_ sender: AnyObject) {
        User.currentUser = nil
        TwitterClient.sharedInstance?.logout()
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: User.userDidLogoutNotification), object: nil)
    }

    @IBAction func onNewTweet(_ sender: AnyObject) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: ComposeTweetViewController.storyboardIdentifier) as! UINavigationController
        if let composeVC = vc.viewControllers.first as? ComposeTweetViewController {
            composeVC.delegate = self
        }
        self.present(vc, animated: true, completion: nil)
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

extension TweetsViewController: ComposeTweetDelegate {
    func composeTweetViewController(newTweet: Tweet) {
        timeline?.prepend(tweets: [newTweet])
        tableView.reloadData()
    }
}

extension TweetsViewController: TweetCellDelegate {
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

extension TweetsViewController: UIScrollViewDelegate {
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
