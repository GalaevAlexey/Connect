//
//  ConnectTests.swift
//  ConnectTests
//
//  Created by Alexey Galaev on 12/8/16.
//  Copyright © 2016 Canopus. All rights reserved.
//

import XCTest
import SwCrypt
import CryptoSwift
import KeychainSwift

class ConnectTests: XCTestCase {
    
    func testKeichain() {
        let keichaine = KeychainSwift()

        let string = "test"
        if let data = string.data(using:.utf8){
            keichaine.set(data, forKey: "data", withAccess: .accessibleAfterFirstUnlock)
            let testdata = keichaine.getData("data")
            
            XCTAssert(testdata == data)
        }
        keichaine.set(string, forKey: "string",withAccess: .accessibleAfterFirstUnlock)
        
        let teststring = keichaine.get("string")
        
        XCTAssert(teststring == string)
        
    }
    
    func testCMAC()
    {
        XCTAssert(CC.CMAC.available())
        let input = "Date: Nov 25 2016 4:22AM, Operation: sell, Amount to sell: 10.00 USD, Amount to buy: 8.88 EUR, USD/EUR: 0.888325".data(using: String.Encoding.utf8)!

        let key:[UInt8] = [0, 17, 34, 51, 68, 85, 102, 119, 136, 153, 17, 34, 51, 68, 85, 102]
        let expectedOutput = "39dad38bec20f6432c08b978fb1de338".dataFromHexadecimalString()!
        let cmac = CC.CMAC.AESCMAC(input, key: Data(key))
        
        let hash = cmac.arrayOfBytes()
        
        let offset = Int(hash[hash.count - 1] & 0x7)
        
        let trimValue = UInt((hash[offset]) & 0x7f) << 24 | UInt((hash[offset + 1]) & 0xff) << 16 | UInt((hash[offset + 2]) & 0xff) << 8 | UInt((hash[offset + 3]) & 0xff)
        
        let intTrim = Int(trimValue)
        let encodedMAC = "\(intTrim % 100000000)"
        XCTAssert(cmac == expectedOutput)
    }
    
    
    func testLogin() {
        let password = "Aqwert12@%".utf8.map {$0}
        let secretstring = "AAISEM2EKVTHPCEZCERDGRCVMY+GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQCMAK."
        let expectedSecret = "AAISEM2EKVTHPCEZCERDGRCVMY+GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQCMAK.".utf8.map{$0}
        let secretstring2 = "+CMAK."
        let secretstring3 = "AAISEM2EKVTHPCEZCERDGRCVMY+CMAK."
        let secretstring4 = "+GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQCMAK."
        print(expectedSecret.count)
      
        do {
            let generatedpass = try PKCS5.PBKDF2(password: password, salt: [], iterations: 4096, keyLength: 16, variant: .sha256).calculate()
            let aes = try AES(key: generatedpass, iv:nil, blockMode:.CBC, padding:PKCS7())
            let encryptedKey = try aes.encrypt(expectedSecret)
            let encryptedKey1 = try aes.encrypt(secretstring2.utf8.map{$0})
            let encryptedKey2 = try aes.encrypt(secretstring3.utf8.map{$0})
            let encryptedKey3 = try aes.encrypt(secretstring4.utf8.map{$0})
       
            let decryptedKey = try aes.decrypt(encryptedKey)
            let dencryptedKey1 = try aes.decrypt(encryptedKey1)
            let dencryptedKey2 = try aes.decrypt(encryptedKey2)
            let dencryptedKey3 = try aes.decrypt(encryptedKey3)
           
            if let string1 = String(bytes:decryptedKey, encoding:.utf8){
                print(string1)
                XCTAssert(string1 == secretstring)
            }
            if let string2 = String(bytes:dencryptedKey1, encoding:.utf8){
                print(string2)
                XCTAssert(string2 == secretstring2)
            }
            if let string3 = String(bytes:dencryptedKey2, encoding:.utf8){
                print(string3)
                XCTAssert(string3 == secretstring3)
            }
            if let string4 = String(bytes:dencryptedKey3, encoding:.utf8){
                print(string4)
                XCTAssert(string4 == secretstring4)
            }
           
        } catch {
            print("error generate pbkdf")
        }
    }
    
    func testAES128Encryption()
    {
        let keyString        = "Aqwert12@%".utf8.map {$0}
        do {
            let generatedPass:[UInt8]  = try PKCS5.PBKDF1(password: keyString, salt:[], variant: .sha1, iterations: 4096).calculate()
            let keyData = Data(generatedPass)
            let keyBytes         = UnsafeMutableRawPointer(mutating: keyData.bytes)
            print("keyLength   = \(keyData.count), keyData   = \(keyData)")
            
            let message       = "+CMAK."
            let data: Data! = (message as String).data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue)) as Data!
            let dataLength    = size_t(data.count)
            let dataBytes     = UnsafeMutableRawPointer(mutating: data.bytes)
            print("dataLength  = \(dataLength), data      = \(data)")
            
            let cryptData    = NSMutableData(length: Int(dataLength) + kCCKeySizeAES128)
            let cryptPointer = UnsafeMutableRawPointer(cryptData!.mutableBytes)
            let cryptLength  = size_t(cryptData!.length)
            
            let keyLength              = size_t(kCCKeySizeAES256)
            let operation: CCOperation = UInt32(kCCEncrypt)
            let algoritm:  CCAlgorithm = UInt32(kCCAlgorithmAES128)
            let options:   CCOptions   = UInt32(kCCOptionPKCS7Padding + kCCOptionECBMode)
            
            var numBytesEncrypted :size_t = 0
            
            let cryptStatus = CCCrypt(operation,
                                      algoritm,
                                      options,
                                      keyBytes, keyLength,
                                      nil,
                                      dataBytes, dataLength,
                                      cryptPointer, cryptLength,
                                      &numBytesEncrypted)
            
            if UInt32(cryptStatus) == UInt32(kCCSuccess) {
                //  let x: UInt = numBytesEncrypted
                cryptData!.length = Int(numBytesEncrypted)
                print("cryptLength = \(numBytesEncrypted), cryptData = \(cryptData)")
                
                // Not all data is a UTF-8 string so Base64 is used
                let base64cryptString = cryptData!.base64EncodedString(options: NSData.Base64EncodingOptions.lineLength64Characters)
                print("base64cryptString = \(base64cryptString)")
                
            } else {
                print("Error: \(cryptStatus)")
            }
            
        } catch {
            print("Error generation pass")
        }
    }
    
    func testAES128Decryption() //data = cryptData
    {
        let keyString        = "Aqwert12@%".utf8.map {$0}
        do {
            let generatedPass:[UInt8]  = try PKCS5.PBKDF1(password: keyString, salt:[], variant: .sha1, iterations: 4096).calculate()
            let keyData = Data(generatedPass)
            let keyBytes         = UnsafeMutableRawPointer(mutating: keyData.bytes)
            print("keyLength   = \(keyData.count), keyData   = \(keyData)")
            
            let message       = "+CMAK."
            let data: NSData! = (message as NSString).data(using: String.Encoding.utf8.rawValue) as NSData!
            let dataLength    = size_t(data.length)
            let dataBytes     = UnsafeMutableRawPointer(mutating: data.bytes)
            print("dataLength  = \(dataLength), data      = \(data)")
            
            let cryptData    = NSMutableData(length: Int(dataLength) + kCCBlockSizeAES128)
            let cryptPointer = UnsafeMutableRawPointer(cryptData!.mutableBytes)
            let cryptLength  = size_t(cryptData!.length)
            
            let keyLength              = size_t(kCCKeySizeAES256)
            let operation: CCOperation = UInt32(kCCDecrypt)
            let algoritm:  CCAlgorithm = UInt32(kCCAlgorithmAES128)
            let options:   CCOptions   = UInt32(kCCOptionPKCS7Padding + kCCOptionECBMode)
            
            var numBytesEncrypted :size_t = 0
            
            let cryptStatus = CCCrypt(operation,
                                      algoritm,
                                      options,
                                      keyBytes, keyLength,
                                      nil,
                                      dataBytes, dataLength,
                                      cryptPointer, cryptLength,
                                      &numBytesEncrypted)
            
            if UInt32(cryptStatus) == UInt32(kCCSuccess) {
                //  let x: UInt = numBytesEncrypted
                cryptData!.length = Int(numBytesEncrypted)
                print("DecryptcryptLength = \(numBytesEncrypted), Decrypt = \(cryptData)")
                
                // Not all data is a UTF-8 string so Base64 is used
                let base64cryptString = cryptData!.base64EncodedString(options:.lineLength64Characters)
                print("base64DecryptString = \(base64cryptString)")
                print( "utf8 actual string = \(NSString(data: cryptData! as Data, encoding: String.Encoding.utf8.rawValue))");
            } else {
                print("Error: \(cryptStatus)")
            }
        } catch {
            print("decryption failed")
        }
    }
    
    
    func testManualInput() {
        let byteSecret1:[UInt8] = [0,0,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9,1,1,2,2,3,3,4,4,5,5,6,6]
        let data = Data(bytes: byteSecret1)
        let string = data.arrayOfBytes()
        print(string)
    }
}
