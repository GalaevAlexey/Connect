//
//  CryptoEngine.swift
//  Connect
//
//  Created by Alexey Galaev on 11/24/16.
//  Copyright © 2016 Canopus. All rights reserved.
//

import Foundation
import CryptoSwift
import OneTimePassword
import SwCrypt


struct CryptoEngine {
    
    static let maximumDigits = 8
    
    static let generatePeriod:TimeInterval = 30

    func generatePKCS5(pass:String) -> [UInt8] {
        
        let password: [UInt8] = pass.utf8.map {$0}
        let salt: [UInt8] = "salt".utf8.map {$0}
        do {
        return try PKCS5.PBKDF2(password:password, salt: salt, iterations: 4096, keyLength: 16, variant: .sha256).calculate()
        } catch {
            return []
        }
    }
    
    func loginWithPassword(pass:String) -> Bool {
        
        //AES128Encryption()
      
        var result = false
        let password:[UInt8] = generatePKCS5(pass:pass)
        print("generatedpass\n\(password)")
        UserProfiles.currentUser.password = password
        
        //let data = Data(password)
        //AES128Decryption(data:data as NSData)
        
        if let secret = UserProfiles.currentUser.persistentKey?.arrayOfBytes() {
            print("secretfromKeychain\n\(secret)")
            do {
                let aes = try AES(key: password, iv:nil, blockMode:.CBC, padding:PKCS7())
                let dd = try aes.decrypt(secret)
                
                print("decryptedsecret\n\(dd)")
                print("decrypted size\n\(dd.count)")

                result = dd.count == 0
                if(result){ return !result}
                let test = String(data: Data(dd), encoding: String.Encoding.utf8)
                print(test ?? "cannotCreate string")
        
                if let a = String(bytes: dd, encoding: String.Encoding.utf8)
                {
                    print(a)
                    let last4 = a.substring(from:a.index(a.endIndex, offsetBy: -5))
                    result = (last4 == "CMAK.") ?  true : false
                    if(result){
                        let c = a.SMACSOTP.components(separatedBy: "+")
                        UserProfiles.currentUser.MACSecret = c[0]
                        print(c[0])
                        UserProfiles.currentUser.OTPSecret = c[1]
                        print(c[1])
                        return result
                    }
                }
            } catch {
                result = false
                print("error create encrypted key")
            }
        }
        return result
    }
    
    func createOTP(secret:String, timeInterval:TimeInterval) -> String? {
        
        var passwordAtTime = ""
        
        if let decoded = base32DecodeToData(secret) {
            guard let generator = Generator(
                factor: .timer(period:CryptoEngine.generatePeriod),
                secret:decoded,
                algorithm: .sha1,
                digits: CryptoEngine.maximumDigits) else {
                    print("Invalid generator parameters")
                    return passwordAtTime
            }
            
            do {
                let date = Date()
                let password = try generator.password(at: date)
                passwordAtTime = password
            } catch {
                print("Invalid Password at time: \(passwordAtTime)")
            }
        }
       return passwordAtTime
    }
    
    func createMac(mackey:String,msg:String, completion:CompletionMac) {
        var encodedMAC = ""
        var decodedKey:[UInt8]? = []
        if mackey.isEmpty || msg.isEmpty{
            return completion(false, "Error MAC".localized)
        }
            if let decoded = base32Decode(mackey) {
                decodedKey = decoded
            }
        if (CC.CMAC.available()){
        let byteArray:[UInt8] = msg.utf8.map {$0}
        let detailsData = Data(byteArray)
        let key = Data(decodedKey!)
        let mac =  CC.CMAC.AESCMAC(detailsData, key: key)
    
        let hash = mac.arrayOfBytes()
        
        let offset = Int(hash[hash.count - 1] & 0x7)
        
        let trimValue = UInt((hash[offset]) & 0x7f) << 24 | UInt((hash[offset + 1]) & 0xff) << 16 | UInt((hash[offset + 2]) & 0xff) << 8 | UInt((hash[offset + 3]) & 0xff)
        
        let intTrim = Int(trimValue)
        let equationResult = intTrim % 100000000
        encodedMAC = "\(equationResult)"
        return completion(true, "\(encodedMAC)")
        } else {
            return completion(false, "errorToCreate")
        }
    }
}

