//
//  MTUserProfile.swift
//  Connect
//
//  Created by Alexey Galaev on 11/25/16.
//  Copyright © 2016 Canopus. All rights reserved.
//

import Foundation
import KeychainSwift
import SwCrypt
import RxSwift
import CryptoSwift

public struct PersistentUserProfile : Equatable {
    
    public let password:Array<Int8>
    
    public let identifier: NSData
}

public func == (lhs: PersistentUserProfile, rhs: PersistentUserProfile) -> Bool {
    return lhs.identifier.isEqual(to: rhs.identifier as Data) && lhs.password == rhs.password
}

struct UserProfile {
    
    var password:[UInt8] = []
    
    var OTPSecret:String = ""
    
    var MACSecret:String = ""
    
    var encryptedOTP = Variable<String>("")
    
    var encryptedMAC = Variable<String>("")
    
    var datailsMAC = Variable<String>("")
    
    var encryptedKey:[UInt8] {
        get {
            let keyToPersistent = MACSecret+"+"+OTPSecret+"CMAK."
            var encrypted:[UInt8] = []
            do {
                print(password)
                let aes = try AES(key: password, iv:nil, blockMode:.CBC, padding:PKCS7())
                let encryptedKey = try aes.encrypt(keyToPersistent.utf8.map({$0}))
                encrypted = encryptedKey
                print(encrypted)
            } catch {
                print("error create encrypted key")
            }
            return encrypted
        }
    }
    
    var persistentKey: Data? {
        get{
            var data = Data()
            if let keyData = keychain.getData(Keys.persistentKey){
                data = keyData
            }
            print(data.count)
        return data
        }
    }
}

struct UserProfiles {
   static var currentUser = UserProfile()
}

let keychain = KeychainSwift()
