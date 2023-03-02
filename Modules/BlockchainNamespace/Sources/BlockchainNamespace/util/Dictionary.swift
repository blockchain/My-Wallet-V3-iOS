// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import KeychainKit
import SwiftExtensions

extension Dictionary where Key == Tag {
    public subscript(id: L) -> Value? { self[id[]] }
}

extension Dictionary where Key == Tag.Reference {
    public subscript(id: L) -> Value? { self[id.key()] }
}

extension Mock {

    public class Preferences: SwiftExtensions.Preferences {

        let lock = NSRecursiveLock()
        var store: [String: Any] = [:]

        public init() {}

        public func object(forKey defaultName: String) -> Any? {
            lock.lock()
            defer { lock.unlock() }
            return store[defaultName]
        }

        public func set(_ value: Any?, forKey defaultName: String) {
            lock.lock()
            defer { lock.unlock() }
            store[defaultName] = value
        }
    }

    public final class Keychain: KeychainAccessAPI {

        typealias Service = String
        typealias Key = String

        var store: Any? = [String: Data]()

        let provider: KeychainQueryProvider

        public init(queryProvider: KeychainQueryProvider) { self.provider = queryProvider }
        public init(service: String) { self.provider = GenericPasswordQuery(service: service) }
        public init(service: String, accessGroup: String) { self.provider = GenericPasswordQuery(service: service, accessGroup: accessGroup) }

        public func read(
            for key: String
        ) -> Result<Data, KeychainAccessError> {
            let query = provider.readOneQuery(key: key)
            guard query.isNotEmpty else { return .failure(.readFailure(.itemNotFound(account: key))) }
            if let data = store[query[kSecAttrService as String] as! String, key] as? Data {
                return .success(data)
            } else {
                return .failure(.readFailure(.itemNotFound(account: key)))
            }
        }

        public func write(
            value: Data,
            for key: String
        ) -> Result<Void, KeychainAccessError> {
            let query = provider.writeQuery(key: key, data: value)
            guard query.isNotEmpty else { return .failure(.writeFailure(.writeFailed(account: key, status: 9999))) }
            return .success(store[query[kSecAttrService as String] as! String, key] = value)
        }

        public func remove(
            for key: String
        ) -> Result<Void, KeychainAccessError> {
            let query = provider.commonQuery(key: key, data: nil)
            guard query.isNotEmpty else { return .failure(.writeFailure(.removalFailed(account: key, status: 9999))) }
            return .success(store[query[kSecAttrService as String] as! String, key] = nil)
        }
    }
}
