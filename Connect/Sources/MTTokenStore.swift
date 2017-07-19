

import Foundation
import OneTimePassword

class MTTokenStore {
    
    internal let keychain: Keychain
    internal let userDefaults: UserDefaults
    internal var persistentTokens: [PersistentToken]
    // internal var persistentUserProfiles: [PersistentUserProfile]

    // Throws an error if the initial state could not be loaded from the keychain.
    init(keychain: Keychain, userDefaults: UserDefaults) throws {
        self.keychain = keychain
        self.userDefaults = userDefaults

        // Try to load persistent tokens.
        let persistentTokenSet = try keychain.allPersistentTokens()
        let sortedIdentifiers = userDefaults.persistentIdentifiers()
        // let persistentUserProfiles = keychain.
    
        persistentTokens = persistentTokenSet.sorted(by: { (A, B) in
            let indexOfA = sortedIdentifiers.index(of: A.identifier as NSData)
            let indexOfB = sortedIdentifiers.index(of: B.identifier as NSData)

            switch (indexOfA, indexOfB) {
            case (.some(let iA), .some(let iB)) where iA < iB:
                return true
            default:
                return false
            }
        })

        if persistentTokens.count > sortedIdentifiers.count {
            // If lost tokens were found and appended, save the full list of tokens
            saveTokenOrder()
        }
    }

    internal func saveTokenOrder() {
        let persistentIdentifiers = persistentTokens.map { $0.identifier }
        userDefaults.savePersistentIdentifiers(identifiers: persistentIdentifiers as [NSData])
    }
    
    func addToken(token: Token) throws {
        let newPersistentToken = try keychain.addToken(token)
        persistentTokens.append(newPersistentToken)
        saveTokenOrder()
    }
}

extension MTTokenStore {
    // MARK: Actions

    func saveToken(token: Token, toPersistentToken persistentToken: PersistentToken) throws {
        let updatedPersistentToken = try keychain.updatePersistentToken(persistentToken,
                                                                        withToken: token)
        // Update the in-memory token, which is still the origin of the table view's data
        persistentTokens = persistentTokens.map {
            if $0.identifier == updatedPersistentToken.identifier {
                return updatedPersistentToken
            }
            return $0
        }
    }

    func updatePersistentToken(persistentToken: PersistentToken) throws {
        let newToken = persistentToken.token.updatedToken()
        try saveToken(token: newToken, toPersistentToken: persistentToken)
    }

    func moveTokenFromIndex(origin: Int, toIndex destination: Int) {
        let persistentToken = persistentTokens[origin]
        persistentTokens.remove(at: origin)
        persistentTokens.insert(persistentToken, at: destination)
        saveTokenOrder()
    }

    func deletePersistentToken(persistentToken: PersistentToken) throws {
        try keychain.deletePersistentToken(persistentToken)
        if let index = persistentTokens.index(of: persistentToken) {
            persistentTokens.remove(at: index)
        }
        saveTokenOrder()
    }
}

// MARK: - Token Order Persistence

private let kOTPKeychainEntriesArray = "OTPKeychainEntries"

private extension UserDefaults {
    func persistentIdentifiers() -> [NSData] {
        return array(forKey: kOTPKeychainEntriesArray) as? [NSData] ?? []
    }

    func savePersistentIdentifiers(identifiers: [NSData]) {
        set(identifiers, forKey: kOTPKeychainEntriesArray)
    }
}

//extension Keychain {
//    public func allPersistentUserProfiles() throws -> Set<PersistentUserProfile> {
//        
//    }
//}

