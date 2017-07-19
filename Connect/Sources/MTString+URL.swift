//
//  String+URL.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 12/28/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

extension String {
    
    var URLEscaped: String {
       return self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
    }
    
    var TokenSecret:String {
        var s = ""
        for chr in self.characters {
            let str = String(chr)
            if str.lowercased() != str {
                s += str
            } else {
                if let digit = Int("\(chr)")  {
                     s += "\(digit)"
                }
            }
        }
        return s
    }
    
    var byteArray:[UInt8]{
        let a = self.characters.map{String($0)}
        var n:[UInt8] = []
        for c in a {
            if let i = UInt8(c) {
                n.append(i)
            }
        }
        return n
    }
    
    var SMACSOTP:String {
        let l = self.characters.map { String($0) }
        let t = l.prefix(upTo:l.count - 5)
        let s = t.joined(separator: "")
        return s
    }
}
