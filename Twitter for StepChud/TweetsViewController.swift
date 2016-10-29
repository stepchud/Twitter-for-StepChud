//
//  TweetsViewController.swift
//  Twitter for StepChud
//
//  Created by Stephen Chudleigh on 10/27/16.
//  Copyright © 2016 Stephen Chudleigh. All rights reserved.
//

import UIKit

class TweetsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var tweets: [Tweet]?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
        navigationController?.navigationBar.barTintColor = TwitterBlue
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]

        getTimelineTweets()
        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TweetCell", for: indexPath) as! TweetCell
        cell.tweet = tweets?[indexPath.row]
        cell.selectionStyle = .none
        
        return cell
    }

    func getTimelineTweets() {
        TwitterClient.sharedInstance?.homeTimeline(success: { (tweets: [Tweet]) in
            self.tweets = tweets
            
            self.tableView.reloadData()
            
            }, failure: { (error: Error) in
                print(error.localizedDescription)
        })
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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        if segue.destination is TweetDetailViewController {
            let vc = segue.destination as! TweetDetailViewController
            if let indexPath = tableView.indexPath(for: sender as! UITableViewCell) {
                vc.tweet = self.tweets?[indexPath.row]
            }
        }
    }

}
