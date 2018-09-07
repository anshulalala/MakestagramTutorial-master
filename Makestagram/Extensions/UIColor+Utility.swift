//
//  UIColor+Utility.swift
//  Makestagram
//
//  Created by Brian Sakhuja on 7/1/17.
//  Copyright © 2017 Brian Sakhuja. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    /*
     * Converts hex integer into UIColor
     *
     * Usage: UIColor(hex: 0xFFFFFF)
     *
     */
    
    private convenience init(hex: Int) {
        let components = (
            R: CGFloat((hex >> 16) & 0xff) / 255,
            G: CGFloat((hex >> 08) & 0xff) / 255,
            B: CGFloat((hex >> 00) & 0xff) / 255
        )
        
        self.init(red: components.R, green: components.G, blue: components.B, alpha: 1)
    }
    
    
    static var mgBlue: UIColor {
        return UIColor(hex: 0x3796F0)
    }
    
    static var mgLightGray: UIColor {
        return UIColor(hex: 0xDDDCDC)
    }
    
    static var mgRed: UIColor {
        return UIColor(hex: 0xE7554B)
    }
}

// usage
// let brandBlue = UIColor.mgBlue
