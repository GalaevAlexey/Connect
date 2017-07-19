//
//  Constants.swift
//  Connect
//
//  Created by Alexey Galaev on 11/17/16.
//  Copyright © 2016 Canopus. All rights reserved.
//

import Foundation

struct Messsage {
    static let warning = "Validation Error".localized
    static let title = "Password rules".localized
    static let errorCreateMac = "Mac invalid".localized
    static let passwordNote = "Пароль должен состоять из\nминимум 10 символов.\n\n В пароле должны\nприсутствовать:\n\n-латинские и/или\nкириллические символы\nверхнего и нижнего\nрегистра\n\n-десятичные цифры (от 0 до 9)\n\n -неалфавитные символы\n(например &,#,%)".localized
    
    static let loginError = "Invalid password".localized
    static let tokenError = "Invalid token".localized
}

struct Keys {
    static let firstRunKey = "canopus.ios.firstrunkey"
    static let persistentKey = "canopus.ios.persistentkey"
    static let persistentOTPSecret = "canopus.ios.persistentOTPsecret"
    static let persistentMACSecret = "canopus.ios.persistentMACsecret"
}

struct VCs {
    static let manInput = "MANUAL INPUT".localized
    static let scanQR = "SCAN QR".localized
}

