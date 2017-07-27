//
//  CommonCryptoAes128.swift
//  Connect
//
//  Created by Alexey Galaev on 12/13/16.
//  Copyright © 2016 Canopus. All rights reserved.
//

import Foundation
import Security

func AES128Encryption()
{
    let keyString        = "12345678901234567890123456789012"
    let keyData: Data    = keyString.data(using:.utf8)!
    let keyBytes         = UnsafeMutableRawPointer(mutating: keyData.bytes)
    print("keyLength   = \(keyData.count), keyData   = \(keyData)")
    
    let message       = "Don´t try to read this text. Top Secret Stuff"
    let data: Data! = (message as String).data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue)) as Data!
    let dataLength    = size_t(data.count)
    let dataBytes     = UnsafeMutableRawPointer(mutating: data.bytes)
    print("dataLength  = \(dataLength), data      = \(data)")
    
    let cryptData    = NSMutableData(length: Int(dataLength) + kCCKeySizeAES128)
    let cryptPointer = UnsafeMutableRawPointer(cryptData!.mutableBytes)
    let cryptLength  = size_t(cryptData!.length)
    
    let keyLength              = size_t(kCCKeySizeAES128)
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
        print("cryptLength = \(numBytesEncrypted), cryptData = \(String(describing: cryptData))")
        
        // Not all data is a UTF-8 string so Base64 is used
        let base64cryptString = cryptData!.base64EncodedString(options: NSData.Base64EncodingOptions.lineLength64Characters)
        print("base64cryptString = \(base64cryptString)")
        
    } else {
        print("Error: \(cryptStatus)")
    }
}

func AES128Decryption(data:NSData) //data = cryptData
{
    let keyString        = "12345678901234567890123456789012"
    let keyData: NSData! = (keyString as NSString).data(using: String.Encoding.utf8.rawValue) as NSData!
    let keyBytes         = UnsafeMutableRawPointer(mutating: keyData.bytes)
    print("keyLength   = \(keyData.length), keyData   = \(keyData)")
    
    let message       = "Don´t try to read this text. Top Secret Stuff"
    let data: NSData! = (message as NSString).data(using: String.Encoding.utf8.rawValue) as NSData!
    let dataLength    = size_t(data.length)
    let dataBytes     = UnsafeMutableRawPointer(mutating: data.bytes)
    print("dataLength  = \(dataLength), data      = \(data)")
    
    let cryptData    = NSMutableData(length: Int(dataLength) + kCCBlockSizeAES128)
    let cryptPointer = UnsafeMutableRawPointer(cryptData!.mutableBytes)
    let cryptLength  = size_t(cryptData!.length)
    
    let keyLength              = size_t(kCCKeySizeAES128)
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
        print("DecryptcryptLength = \(numBytesEncrypted), Decrypt = \(String(describing: cryptData))")
        
        // Not all data is a UTF-8 string so Base64 is used
        let base64cryptString = cryptData!.base64EncodedString(options:.lineLength64Characters)
        print("base64DecryptString = \(base64cryptString)")
        print( "utf8 actual string = \(String(describing: NSString(data: cryptData! as Data, encoding: String.Encoding.utf8.rawValue)))");
    } else {
        print("Error: \(cryptStatus)")
    }
}
