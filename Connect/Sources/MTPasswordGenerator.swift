//
//  PasswordGenerator.swift
//  Connect
//
//  Created by Alexey Galaev on 11/22/16.
//  Copyright © 2016 Canopus. All rights reserved.
//

import Foundation

extension Array {
    func randomItem() -> Element? {
        let idx = Int(arc4random()) % count
        return self[idx]
    }
    
    func randomItems(total: Int) -> [Element] {
        var result: [Element] = []
        for _ in (0..<total) {
            if let item = randomItem() {
                result += [item]
            }
        }
        return result
    }
    
    func shuffleItems() -> [Element] {
        var newArray = self
        for i in (0..<newArray.count) {
            let j = Int(arc4random()) % newArray.count
            newArray.insert(newArray.remove(at: j), at: i)
        }
        return newArray
    }
}

extension String {
    func split(bySeparator: String) -> Array<String> {
        if bySeparator.characters.count < 1 {
            var items: [String] = []
            for c in self.characters {
                items.append(String(c))
            }
            return items
        }
        return self.components(separatedBy: bySeparator)
    }
}

class PasswordGenerator {
    let lowercaseSet = "abcdefghijklmnopqrstuvwxyz".split(bySeparator: "")
    let uppercaseSet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".split(bySeparator: "")
    let symbolSet    = "!@#$%^&*?".split(bySeparator: "")
    let numberSet    = "0123456789".split(bySeparator: "")
    
    var numbers   = 1
    var lowercase = 4
    var uppercase = 4
    var symbols   = 1
    
    func generate() -> String {
        var password: [String] = []
        password += lowercaseSet.randomItems(total: lowercase)
        password += uppercaseSet.randomItems(total: uppercase)
        password += numberSet.randomItems(total: numbers)
        password += symbolSet.randomItems(total: symbols)
        return password.shuffleItems().reduce("") { (a, b) -> String in a+b }
    }
}


