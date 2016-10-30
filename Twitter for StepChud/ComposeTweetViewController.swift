//
//  ComposeTweetViewController.swift
//  Twitter for StepChud
//
//  Created by Stephen Chudleigh on 10/29/16.
//  Copyright © 2016 Stephen Chudleigh. All rights reserved.
//

import UIKit

class ComposeTweetViewController: UIViewController {
    
    static let storyboardIdentifier = "ComposeNavigationController"
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var composeTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadUserDetails()
    }

    func loadUserDetails() {
        if let url = User.currentUser?.profileURL {
            profileImageView.af_setImage(withURL: url)
        }
        fullNameLabel.text = User.currentUser?.name
        userNameLabel.text = User.currentUser?.username
        composeTextView.text = ""
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onCancelButton(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func onTweetButton(_ sender: UIBarButtonItem) {
        TwitterClient.sharedInstance?.sendTweet(composeTextView.text)
        self.dismiss(animated: true, completion: nil)
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
