//
//  Color.swift
//  Connect
//
//  Created by Alexey Galaev on 11/14/16.
//  Copyright © 2016 Canopus. All rights reserved.
//

import UIKit

func uicolorFromHex(rgbValue:UInt32) -> UIColor {
    
    let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
    let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
    let blue = CGFloat(rgbValue & 0xFF)/256.0
    return UIColor(red:red, green:green, blue:blue, alpha:1.0)
    
}

struct Design {
    static let orange = uicolorFromHex(rgbValue: 0xfcb022)
    static let disabled = uicolorFromHex(rgbValue: 0x5b5b5b)
    static let enabledtext = uicolorFromHex(rgbValue: 0xE4E4E4)
    static let disabledtext = uicolorFromHex(rgbValue: 0x666666)
}
