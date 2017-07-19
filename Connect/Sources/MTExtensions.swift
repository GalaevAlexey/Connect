//
//  Extensions.swift
//  Connect
//
//  Created by Alexey Galaev on 11/11/16.
//  Copyright © 2016 Canopus. All rights reserved.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift
import OneTimePassword

extension UIViewController {
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

extension Keychain {
    func addSecret(secret:String){
    
    }
}

struct Counter {
    let timeIntervalSince1970: TimeInterval
    let timeIntervalSinceNow: TimeInterval
    init(date: NSDate) {
        timeIntervalSince1970 = date.timeIntervalSince1970
        timeIntervalSinceNow  = date.timeIntervalSinceNow
    }
}

extension String {
    var hexaToInt      : Int    { return Int(strtoul(self, nil, 16))      }
    var hexaToDouble   : Double { return Double(strtoul(self, nil, 16))   }
    var hexaToBinary   : String { return String(hexaToInt, radix: 2)      }
    var decimalToHexa  : String { return String(Int(self) ?? 0, radix: 16)}
    var decimalToBinary: String { return String(Int(self) ?? 0, radix: 2) }
    var binaryToInt    : Int    { return Int(strtoul(self, nil, 2))       }
    var binaryToDouble : Double { return Double(strtoul(self, nil, 2))   }
    var binaryToHexa   : String { return String(binaryToInt, radix: 16)  }
}

extension String {
    var localized:String {
        return NSLocalizedString(self, comment:"")
    }
    
    /// Data never nil
    internal var dataUsingUTF8StringEncoding: Data {
        return utf8CString.withUnsafeBufferPointer {
            return Data(bytes: $0.dropLast().map { UInt8.init($0) })
        }
    }
    
    /// Array<UInt8>
    internal var arrayUsingUTF8StringEncoding: [UInt8] {
        return utf8CString.withUnsafeBufferPointer {
            return $0.dropLast().map { UInt8.init($0) }
        }
    }
}

extension Int {
    var binaryString: String { return String(self, radix: 2)  }
    var hexaString  : String { return String(self, radix: 16) }
    var doubleValue : Double { return Double(self) }
}

extension Data {
    func hexEncodedString() -> String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
}

extension Data {
    
    init?(fromHexEncodedString string: String) {
        
        // Convert 0 ... 9, a ... f, A ...F to their decimal value,
        // return nil for all other input characters
        func decodeNibble(u: UInt16) -> UInt8? {
            switch(u) {
            case 0x30 ... 0x39:
                return UInt8(u - 0x30)
            case 0x41 ... 0x46:
                return UInt8(u - 0x41 + 10)
            case 0x61 ... 0x66:
                return UInt8(u - 0x61 + 10)
            default:
                return nil
            }
        }
        
        self.init(capacity: string.utf16.count/2)
        var even = true
        var byte: UInt8 = 0
        for c in string.utf16 {
            guard let val = decodeNibble(u: c) else { return nil }
            if even {
                byte = val << 4
            } else {
                byte += val
                self.append(byte)
            }
            even = !even
        }
        guard even else { return nil }
    }
}


