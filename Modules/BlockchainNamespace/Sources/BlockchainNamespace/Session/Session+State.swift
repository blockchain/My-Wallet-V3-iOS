// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import KeychainKit
import SwiftExtensions

extension Session {

    public final class State {

        unowned var app: AppProtocol!
        var data: Data

        public init(
            _ data: Tag.Context = [:],
            preferences: Preferences = UserDefaults.standard
        ) {
            self.data = Data(preferences: preferences)
            self.data.store = data.dictionary
        }
    }
}

extension Session.State {

    public class Data {

        public internal(set) var store: [Tag.Reference: Any] = [:]
        internal var subjects: [Tag.Reference: Subject] = [:]
        private var dirty: (data: [Tag.Reference: Any], level: UInt) = ([:], 0)

        private let lock = NSRecursiveLock()

        var preferences: Preferences

        var keychain: (
            user: KeychainAccessAPI,
            shared: KeychainAccessAPI
        )

        let keychainAccount = (
            user: SessionStateKeychainQueryProvider(service: nil),
            shared: SessionStateKeychainQueryProvider(service: "com.blockchain.session.state[shared]")
        )

        private let shared = Tag.Context.genericIndex
        private var user: String? {
            sync { store[blockchain.user.id.key()] } as? String
        }

        init(preferences: Preferences) {
            self.preferences = preferences
            self.keychain = (
                user: KeychainAccess(queryProvider: keychainAccount.user),
                shared: KeychainAccess(queryProvider: keychainAccount.shared)
            )
        }
    }

    private func key(_ event: Tag.Event) -> Tag.Reference {
        event.key().in(app)
    }
}

extension Session.State {

    public struct Function: Hashable {

        public let id: UUID = UUID()
        public let call: () throws -> Any?

        public init(_ call: @escaping () -> some Any) {
            self.call = call as () throws -> Any?
        }

        public init(_ call: @escaping () throws -> some Any) {
            self.call = call as () throws -> Any?
        }

        @discardableResult
        public func callAsFunction() throws -> Any? {
            try call()
        }

        public static func == (x: Function, y: Function) -> Bool {
            x.id == y.id
        }

        public func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }
}

extension Session.State.Data {

    private struct Tombstone: Hashable {}

    public struct Computed {
        public let key: Tag.Reference
        public let yield: () throws -> Any
    }
}

extension Session.State {

    public func transaction(_ yield: (Session.State) throws -> some Any) {
        data.beginTransaction()
        do {
            _ = try yield(self)
            data.endTransaction()
        } catch {
            data.rollbackTransaction()
        }
    }

    public func transaction(_ yield: (Session.State) async throws -> some Any) async {
        data.beginTransaction()
        do {
            _ = try await yield(self)
            data.endTransaction()
        } catch {
            data.rollbackTransaction()
        }
    }

    public func doesNotContain(_ event: Tag.Event) -> Bool {
        !data.store.keys.contains(key(event))
    }

    public func contains(_ event: Tag.Event) -> Bool {
        data.store.keys.contains(key(event))
    }

    public func clear(_ event: Tag.Event) {
        let key = key(event)
        if key.tag.is(blockchain.user.id) {
            transaction { state in
                let user = key
                for key in data.store.keys where key.tag.isNot(blockchain.session.state.shared.value) {
                    guard key.tag.isNot(blockchain.session.state.preference.value) else { continue }
                    guard key.tag.isNot(blockchain.session.state.stored.value) else { continue }
                    guard key != user else { continue }
                    state.clear(key)
                }
            }
            data.keychainAccount.user.signOut()
        }
        data.clear(key)
    }

    public func set(_ event: Tag.Event, to value: Any?) {
        data.set(key(event), to: value as Any)
    }

    public func set(_ event: Tag.Event, to value: @escaping () throws -> Any) {
        let key = key(event)
        set(key, to: Data.Computed(key: key, yield: value))
    }

    public func set(_ reference: Tag.Reference, to value: Any?) {
        data.set(reference, to: value as Any)
    }

    public func get(_ event: Tag.Event) throws -> Any {
        try data.get(key(event))
    }

    public func get<T: Decodable>(
        _ event: Tag.Event,
        as type: T.Type = T.self,
        using decoder: AnyDecoderProtocol = BlockchainNamespaceDecoder()
    ) throws -> T {
        try decoder.decode(T.self, from: get(event) as Any)
    }

    public func get<T: Decodable>(
        _ event: Tag.Event,
        as type: T.Type = T.self,
        or fallback: T,
        using decoder: AnyDecoderProtocol = BlockchainNamespaceDecoder()
    ) -> T {
        do {
            return try get(
                event,
                as: T.self,
                using: decoder
            )
        } catch {
            return fallback
        }
    }

    @_disfavoredOverload
    public func get<T>(
        _ event: Tag.Event,
        as type: T.Type = T.self
    ) throws -> T {
        try (get(event) as? T).or(
            throw: AnyJSON.Error("Error casting \(event) to \(T.self)")
        )
    }

    public func result(for event: Tag.Event) -> FetchResult {
        let key = key(event)
        do {
            return try .value(get(key), key.metadata(.state))
        } catch {
            return .error(error, key.metadata(.state))
        }
    }

    public func publisher(for event: Tag.Event) -> AnyPublisher<FetchResult, Never> {
        let key = key(event)
        return Just(result(for: key))
            .merge(with: data.subject(for: key))
            .eraseToAnyPublisher()
    }
}

extension FetchResult {
    @inlinable public var isYes: Bool { decode(Bool.self, using: ComputeDecoder()).value == true }
    @inlinable public var isNo: Bool { decode(Bool.self, using: ComputeDecoder()).value == false }
}

extension Session.State {

    @inlinable public func yes(
        if ifs: L & I_blockchain_db_type_boolean...,
        unless buts: L & I_blockchain_db_type_boolean...
    ) -> Bool {
        yes(if: ifs, unless: buts)
    }

    @inlinable public func yes(
        if ifs: [L & I_blockchain_db_type_boolean],
        unless buts: [L & I_blockchain_db_type_boolean]
    ) -> Bool {
        ifs.allSatisfy { result(for: $0).isYes } && buts.none { result(for: $0).isYes }
    }

    @inlinable public func no(
        if ifs: L & I_blockchain_db_type_boolean...,
        unless buts: L & I_blockchain_db_type_boolean...
    ) -> Bool {
        no(if: ifs, unless: buts)
    }

    @inlinable public func no(
        if ifs: [L & I_blockchain_db_type_boolean],
        unless buts: [L & I_blockchain_db_type_boolean]
    ) -> Bool {
        yes(if: ifs, unless: buts) ? false : true
    }
}

extension Session.State.Data {

    public var isInTransaction: Bool { sync { dirty.level > 0 } }
    public var isNotInTransaction: Bool { !isInTransaction }

    public func contains(_ key: Tag.Reference) -> Bool {
        sync { store.keys.contains(key) }
    }

    func get(_ key: Tag.Reference) throws -> Any {
        if let value = sync(execute: { store[key] }) {
            return try (value as? Computed)?.yield() ?? value
        }

        let tag = key.tag
        switch tag {
        case blockchain.session.state.preference.value:
            guard let value = tag.is(blockchain.session.state.shared.value)
                ? preference(key, in: shared)
                : user.flatMap({ user in preference(key, in: user) })
            else {
                throw FetchResult.Error.keyDoesNotExist(key)
            }
            set(key, to: value)
            return value
        case blockchain.session.state.stored.value:
            guard let value = stored(key) else {
                throw FetchResult.Error.keyDoesNotExist(key)
            }
            set(key, to: value)
            return value
        default:
            throw FetchResult.Error.keyDoesNotExist(key)
        }
    }

    func set(_ key: Tag.Reference, to value: Any) {
        if isInTransaction {
            sync { dirty.data[key] = value }
        } else {
            update([key: value])
        }
        if key.tag == blockchain.user.id[], let id = value as? String {
            beginTransaction()
            keychainAccount.user.signIn(id)
            let user = key
            let keys = sync { subjects.keys }
            for key in keys {
                guard key != user else { continue }
                guard key.tag.isNot(blockchain.session.state.shared.value) else { continue }
                if key.tag.is(blockchain.session.state.preference.value), let value = preference(key, in: id) {
                    set(key, to: value)
                }
                if key.tag.is(blockchain.session.state.stored.value), let value = stored(key) {
                    set(key, to: value)
                }
            }
            endTransaction()
        }
    }

    private func preference(_ key: Tag.Reference, in scope: String) -> Any? {
        preferences.object(forKey: blockchain.session.state(\.id))[scope, key.string]
    }

    private func secure(_ key: Tag.Reference) throws -> KeychainAccessAPI {
        switch key.tag {
        case blockchain.session.state.shared.value:
            return keychain.shared
        case blockchain.session.state.stored.value:
            return keychain.user
        default:
            throw "No keychain for \(key)"
        }
    }

    private func stored(_ key: Tag.Reference) -> Any? {
        try? secure(key).read(for: key.string).get().json()
    }

    func clear(_ key: Tag.Reference) {
        if isInTransaction {
            sync { dirty.data[key] = Tombstone.self }
        } else {
            update([key: Tombstone.self])
        }
    }

    func beginTransaction() {
        sync {
            dirty.level += 1
        }
    }

    func endTransaction() {
        let data: [Tag.Reference: Any]? = sync {
            let data = dirty.data
            switch dirty.level {
            case 1:
                dirty.data.removeAll(keepingCapacity: true)
                dirty.level = 0
                return data
            case 1...UInt.max:
                dirty.level -= 1
                return nil
            default:
                assertionFailure(
                    "Misaligned begin -> end transaction calls. You must be in a transaction to end a transaction."
                )
                return nil
            }
        }
        if let data {
            update(data)
        }
    }

    func rollbackTransaction() {
        sync {
            precondition(isInTransaction)
            dirty.level = 0
            dirty.data.removeAll(keepingCapacity: true)
        }
    }

    func subject(for key: Tag.Reference) -> Session.State.Subject {
        sync {
            let subject = subjects[key, default: .init()]
            subjects[key] = subject
            return subject
        }
    }

    private func update(_ data: [Tag.Reference: Any]) {
        for (key, value) in data {
            switch value {
            case is Tombstone.Type:
                sync { store.removeValue(forKey: key) }
            default:
                sync { store[key] = value }
            }
        }
        for (key, value) in data where key.tag.is(blockchain.session.state.stored.value) {
            do {
                let keychain = try secure(key)
                switch value {
                case is Tombstone.Type:
                    try? keychain.remove(for: key.string).get()
                    if key.tag.reference != key {
                        try? keychain.remove(for: key.tag.id).get()
                    }
                default:
                    let (value, _) = try encode(value)
                    func dataToWrite() throws -> Data {
                        if let data: Data = value as? Data {
                            return data
                        } else if JSONSerialization.isValidJSONObject([value]) {
                            return try JSONSerialization.data(
                                withJSONObject: value,
                                options: .fragmentsAllowed
                            )
                        }
                        throw "\(value) is not a valid JSON value"
                    }
                    try keychain.write(
                        value: dataToWrite(),
                        for: key.string
                    )
                    .get()
                }
            } catch {
                print(
                    """
                    ⚠️ Failed to write stored value \(key)
                    \(error)
                    """
                )
            }
        }
        preferences.transaction(blockchain.session.state(\.id)) { object in
            do {
                try update(
                    object: &object,
                    from: data,
                    scope: shared,
                    filter: { $0.is(blockchain.session.state.shared.value) }
                )
                if let user {
                    try update(
                        object: &object,
                        from: data,
                        scope: user,
                        filter: { $0.isNot(blockchain.session.state.shared.value) }
                    )
                } else {
                    #if DEBUG
                    let preferences = data.keys.filter { key in
                        key.tag.is(blockchain.session.state.preference.value)
                        && key.tag.isNot(blockchain.session.state.shared.value)
                    }
                    if preferences.isNotEmpty {
                        print(
                            """
                            ⚠️ Attempted to write user preference without being signed in.

                            If you meant this to be written against the user, please ensure you are signed in
                            before attempting to write - you can observe `blockchain.session.event.did.sign.in`.

                            Most commonly, you will see this if you have mistakenly not marked a shared state value
                            as `blockchain.session.state.shared.value`.

                            \(preferences.map(\.string).array)
                            """
                        )
                    }
                    #endif
                }
            } catch {
                print("⚠️ failed to write value \(error)")
            }
        }
        for (key, value) in data {
            let subject = sync { subjects[key] }
            switch value {
            case is Tombstone.Type:
                subject?.send(.error(FetchResult.Error.keyDoesNotExist(key), key.metadata(.state)))
            default:
                subject?.send(.value(value, key.metadata(.state)))
            }
        }
    }

    private func update(object: inout Any?, from data: [Tag.Reference: Any], scope: String, filter: (Tag) -> Bool) throws {
        var dictionary = object[scope] as? [String: Any] ?? [:]
        for (key, value) in data.filter({ key, _ in
            key.tag.is(blockchain.session.state.preference.value) && filter(key.tag)
        }) {
            if value is Tombstone.Type {
                dictionary.removeValue(forKey: key.id())
            } else {
                let (value, boxed) = try encode(value)
                if boxed {
                    dictionary[key.id()] = try JSONSerialization.data(withJSONObject: value, options: .fragmentsAllowed)
                } else {
                    dictionary[key.id()] = value
                }
            }
        }
        object[scope] = dictionary
    }

    func encode(_ any: Any) throws -> (value: Any, boxed: Bool) {
        if let data: Data = any as? Data {
            return (data, false)
        } else if JSONSerialization.isValidJSONObject([any]) {
            return (any, false)
        } else if let value = any as? Encodable {
            struct Box: Encodable {
                let value: Encodable
                func encode(to encoder: Encoder) throws { try value.encode(to: encoder) }
            }
            let encoded = try AnyEncoder().encode(Box(value: value)) as Any
            if JSONSerialization.isValidJSONObject([encoded]) {
                return (encoded, true)
            }
        }
        throw "\(any) is not a valid JSON value"
    }

    @discardableResult
    func sync<T>(execute work: () throws -> T) rethrows -> T {
        lock.lock()
        defer { lock.unlock() }
        return try work()
    }
}

extension Session.State {
    public typealias Subject = PassthroughSubject<FetchResult, Never>
}

class SessionStateKeychainQueryProvider: KeychainQueryProvider {

    var permission: KeychainKit.KeychainPermission { .whenUnlocked }

    var generic: GenericPasswordQuery?

    init(service: String?) {
        if let service {
            self.generic = GenericPasswordQuery(service: service)
        }
    }

    func signIn(_ user: String) {
        generic = GenericPasswordQuery(service: "com.blockchain.session.state[\(user)]")
    }

    func signOut() {
        generic = nil
    }

    func commonQuery(key: String?, data: Data?) -> [String: Any] {
        generic?.commonQuery(key: key, data: data) ?? [:]
    }

    func writeQuery(key: String, data: Data) -> [String: Any] {
        generic?.writeQuery(key: key, data: data) ?? [:]
    }

    func readOneQuery(key: String) -> [String: Any] {
        generic?.readOneQuery(key: key) ?? [:]
    }
}
