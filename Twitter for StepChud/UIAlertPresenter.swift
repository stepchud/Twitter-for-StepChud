//
//  UIAlertPresenter.swift
//  Twitter for StepChud
//
//  Created by Stephen Chudleigh on 10/31/16.
//  Copyright © 2016 Stephen Chudleigh. All rights reserved.
//

import UIKit

class UIAlertPresenter {
    static func presentAlert(errorText: String, from controller: UIViewController) {
        let alertController = UIAlertController(title: "Error", message: errorText, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in }
        alertController.addAction(cancelAction)
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in }
        alertController.addAction(okAction)
        controller.present(alertController, animated: true, completion: nil)
    }
}
