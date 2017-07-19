//
//  MTAppearance.swift
//  Connect
//
//  Created by Alexey Galaev on 12/10/16.
//  Copyright © 2016 Canopus. All rights reserved.
//

import Foundation
import UIKit
import PopupDialog

func setupAppearance() {
    
    let navigationBarAppearace = UINavigationBar.appearance()
    
    navigationBarAppearace.tintColor = uicolorFromHex(rgbValue: 0x303030)
    navigationBarAppearace.barTintColor = uicolorFromHex(rgbValue: 0xfcb022)
    navigationBarAppearace.titleTextAttributes = [
        NSFontAttributeName: UIFont(name: "Roboto-Medium", size: 20)!
    ]
    // Customize dialog appearance
    let pv = PopupDialogDefaultView.appearance()
    pv.backgroundColor      = uicolorFromHex(rgbValue: 0x303030)
    pv.titleFont            = UIFont(name: "Roboto-Medium", size: 20)!
    pv.titleColor           = UIColor.white
    pv.messageFont          = UIFont(name: "Roboto-Regular", size: 16)!
    pv.messageColor         = uicolorFromHex(rgbValue: 0xA0A0A0)
    pv.messageTextAlignment = .left
    
    // Customize default button appearance
    let db = DefaultButton.appearance()
    db.titleFont      = UIFont(name: "Roboto-Medium", size: 14)!
    db.titleColor     = uicolorFromHex(rgbValue: 0xFCB022)
    db.buttonColor    = uicolorFromHex(rgbValue: 0x303030)
    db.separatorColor = UIColor(red:0.20, green:0.20, blue:0.25, alpha:1.00)
    
    // Customize cancel button appearance
    let cb = CancelButton.appearance()
    cb.titleFont      = UIFont(name: "Roboto-Medium", size: 14)!
    cb.titleColor     = UIColor(white: 0.6, alpha: 1)
    cb.buttonColor    = UIColor(red:0.25, green:0.25, blue:0.29, alpha:1.00)
    cb.separatorColor = UIColor(red:0.20, green:0.20, blue:0.25, alpha:1.00)
}
