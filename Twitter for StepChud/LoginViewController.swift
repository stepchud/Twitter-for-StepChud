//
//  LoginViewController.swift
//  Twitter for StepChud
//
//  Created by Stephen Chudleigh on 10/26/16.
//  Copyright © 2016 Stephen Chudleigh. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onLoginButton(_ sender: AnyObject) {
        TwitterClient.sharedInstance?.login(
        success: {
            print("I've logged in!")
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: User.userDidLoginNotification), object: nil)
        }) {
            (error: Error?) in
            print(error?.localizedDescription)
        }
    }
}
