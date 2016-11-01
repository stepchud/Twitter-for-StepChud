//
//  ComposeTweetViewController.swift
//  Twitter for StepChud
//
//  Created by Stephen Chudleigh on 10/29/16.
//  Copyright © 2016 Stephen Chudleigh. All rights reserved.
//

import UIKit

@objc protocol ComposeTweetDelegate {
    @objc optional func composeTweetViewController(newTweet: Tweet)
}

class ComposeTweetViewController: UIViewController, UITextViewDelegate {
    
    static let storyboardIdentifier = "ComposeNavigationController"
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var remainingCharsLabel: UILabel!
    
    @IBOutlet weak var composeTextView: UITextView!
    
    weak var delegate: ComposeTweetDelegate?
    weak var replyTweet: Tweet?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadUserDetails()
        composeTextView.delegate = self
        composeTextView.becomeFirstResponder()
    }

    func loadUserDetails() {
        if let url = User.currentUser?.profileURL {
            profileImageView.af_setImage(withURL: url)
        }
        fullNameLabel.text = User.currentUser?.name
        userNameLabel.text = User.currentUser?.username
        if let replyTo = replyTweet?.userName {
            composeTextView.text = "@\(replyTo) "
        } else {
            composeTextView.text = ""
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let remaining = 140 - textView.text.characters.count
        remainingCharsLabel.text = "\(remaining)"
        if remaining < 0 {
            remainingCharsLabel.textColor = .red
        } else if remaining < 10 {
            remainingCharsLabel.textColor = .orange
        } else {
            remainingCharsLabel.textColor = .black
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onCancelButton(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func onTweetButton(_ sender: UIBarButtonItem) {
        if let text = composeTextView.text {
            if text.isEmpty {
                UIAlertPresenter.presentAlert(errorText: "Please enter a Tweet", from: self)
            } else if text.characters.count > 140 {
                UIAlertPresenter.presentAlert(errorText: "Tweet text can not be over 140 characters", from: self)
            } else {
                TwitterClient.sharedInstance?.sendTweet(text, replyTweet: replyTweet, success: { (tweet: Tweet) in
                    self.delegate?.composeTweetViewController?(newTweet: tweet)
                    self.dismiss(animated: true, completion: nil)
                }, failure: { (error: Error) in
                    UIAlertPresenter.presentAlert(errorText: error.localizedDescription, from: self)
                })
            }
        } else {
            UIAlertPresenter.presentAlert(errorText: "Couldn't find tweet text input", from: self)
        }
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
