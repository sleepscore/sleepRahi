//
//  LocalAccountStore.swift
//  sleepX
//
//  Persists username + PIN hash locally (UserDefaults). For lab/demo use only.
//

import Foundation
import CryptoKit

final class LocalAccountStore {
    static let shared = LocalAccountStore()

    private let defaults = UserDefaults.standard
    private let storageKey = "sleepX.localAccounts.v1"

    private init() {}

    private var accountHashes: [String: String] {
        get { defaults.dictionary(forKey: storageKey) as? [String: String] ?? [:] }
        set { defaults.set(newValue, forKey: storageKey) }
    }

    enum RegistrationError: Error {
        case usernameTaken
    }

    func register(username: String, pin: String) throws {
        let key = normalize(username)
        var map = accountHashes
        guard map[key] == nil else { throw RegistrationError.usernameTaken }
        map[key] = hashPIN(pin)
        accountHashes = map
    }

    func verify(username: String, pin: String) -> Bool {
        let key = normalize(username)
        guard let stored = accountHashes[key] else { return false }
        return stored == hashPIN(pin)
    }

    private func normalize(_ username: String) -> String {
        username.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    private func hashPIN(_ pin: String) -> String {
        let digest = SHA256.hash(data: Data(pin.utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}
