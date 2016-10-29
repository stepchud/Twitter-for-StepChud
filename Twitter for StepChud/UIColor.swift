//
//  UIColor.swift
//  Twitter for StepChud
//
//  Created by Stephen Chudleigh on 10/28/16.
//  Copyright © 2016 Stephen Chudleigh. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        let newRed = CGFloat(red)/255
        let newGreen = CGFloat(green)/255
        let newBlue = CGFloat(blue)/255
        
        self.init(red: newRed, green: newGreen, blue: newBlue, alpha: 1.0)
    }
}
