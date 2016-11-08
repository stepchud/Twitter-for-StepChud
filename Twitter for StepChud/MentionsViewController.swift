//
//  MentionsViewController.swift
//  Twitter for StepChud
//
//  Created by Stephen Chudleigh on 11/7/16.
//  Copyright © 2016 Stephen Chudleigh. All rights reserved.
//

import UIKit

class MentionsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!

    var timeline: Timeline?
    var isDataLoading = false
    var loadingMoreView:InfiniteScrollActivityView?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
        setupNavigation()
        setupInfiniteScroll()
        getTimelineTweets()
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
    }
    
    func setupNavigation() {
        navigationController?.navigationBar.tintColor = .white
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
        }
        cell.selectionStyle = .none
        
        return cell
    }
    
    func getTimelineTweets() {
        TwitterClient.sharedInstance?.mentionsTimeline(since: nil, before: nil, success: { (tweets: [Tweet]) in
            self.timeline = Timeline(tweets: tweets)
            self.tableView.reloadData()
            
            }, failure: { (error: Error) in
                print(error.localizedDescription)
        })
    }
    
    func refreshTweets(refreshControl: UIRefreshControl) {
        TwitterClient.sharedInstance?.mentionsTimeline(since: timeline?.maxID, before: nil, success: { (newTweets: [Tweet]) in
            self.timeline?.prepend(tweets: newTweets)
            self.tableView.reloadData()
            refreshControl.endRefreshing()
            }, failure: { (error: Error) in
                print(error.localizedDescription)
        })
    }
    
    func loadOlderTweets() {
        TwitterClient.sharedInstance?.mentionsTimeline(since: nil, before: timeline?.minID, success: { (olderTweets: [Tweet]) in
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

extension MentionsViewController: UIScrollViewDelegate {
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
