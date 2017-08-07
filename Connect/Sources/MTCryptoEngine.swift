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
import Base32

struct CryptoEngine {

    static let maximumDigits = 8
    static let generatePeriod:TimeInterval = 30

    func generatePKCS5(pass:String) -> [UInt8]
    {
        let password: [UInt8] = pass.utf8.map {$0}
        let salt: [UInt8] = "salt".utf8.map {$0}
        do {
            return try PKCS5.PBKDF2(password:password, salt: salt, iterations: 4096, keyLength: 16, variant: .sha256).calculate()
        } catch {
            return []
        }
    }

    func loginWithPassword(pass:String) -> Bool
    {
        var result = false
        let password:[UInt8] = generatePKCS5(pass:pass)

        UserProfiles.currentUser.password = password

        if let secret = UserProfiles.currentUser.persistentKey?.arrayOfBytes()
        {
            do {
                let aes = try AES(key: password, iv:nil, blockMode:.CBC, padding:PKCS7())
                let dd = try aes.decrypt(secret)

                result = dd.count == 0

                if(result){ return !result}

                if let a = String(bytes: dd, encoding: String.Encoding.utf8)
                {
                    let last4 = a.substring(from:a.index(a.endIndex, offsetBy: -5))

                    result = (last4 == "CMAK.") ?  true : false

                    if(result)
                    {
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

    func createMac() -> Bool
    {
        let storedMACSecret = UserProfiles.currentUser.MACSecret
        let storedMACDetails = UserProfiles.currentUser.datailsMAC.value

        if storedMACSecret.isEmpty || storedMACDetails.isEmpty
        {
            return false
        }

        if let decoded = MF_Base32Codec.data(fromBase32String: storedMACSecret)
        {
            if (CC.CMAC.available())
            {
                let byteArray:[UInt8] = storedMACDetails.utf8.map {$0}
                let detailsData = Data(byteArray)
                let key = Data(decoded)
                let mac =  CC.CMAC.AESCMAC(detailsData, key: key)
                let hash = mac.arrayOfBytes()

                let offset = Int(hash[hash.count - 1] & 0x7)

                let trimValue = UInt((hash[offset]) & 0x7f) << 24
                    | UInt((hash[offset + 1]) & 0xff) << 16
                    | UInt((hash[offset + 2]) & 0xff) << 8
                    | UInt((hash[offset + 3]) & 0xff)

                let intTrim = Int(trimValue)
                let equationResult = intTrim % 100000000

                UserProfiles.currentUser.encryptedMAC.value = "\(equationResult)"

                return true
            } else {
                return false
            }
        }
        return false
    }
}

