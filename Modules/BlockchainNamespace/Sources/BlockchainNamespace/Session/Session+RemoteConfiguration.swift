// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnyCoding
import Combine
import Extensions
import FirebaseProtocol
import Foundation

extension Session {

    public class RemoteConfiguration {

        private let lock = NSRecursiveLock()

        public var isSynchronized: Bool { _isSynchronized.value }
        private let _isSynchronized: CurrentValueSubject<Bool, Never> = .init(false)

        public var allKeys: [String] { Array(resolved.keys) }

        private var resolved: [String: Any?] { _decoded.value + _override.value }

        private var _subscription: AnyCancellable?
        private var _fetched: [String: Any?] = [:] {
            didSet {
                _subscription = experiments.decode(_fetched)
                    .combineLatest(_override)
                    .map(+)
                    .sink { [unowned self] output in
                        _decoded.send(output)
                        if !isSynchronized { _isSynchronized.send(true) }
                    }
            }
        }

        private var _decoded: CurrentValueSubject<[String: Any?], Never> = .init([:])
        private var _override: CurrentValueSubject<[String: Any?], Never> = .init([:])

        private var fetch: ((AppProtocol, Bool) -> Void)?
        private var bag: Set<AnyCancellable> = []

        var session: URLSessionProtocol
        var scheduler: AnySchedulerOf<DispatchQueue>
        var preferences: Preferences

        private var experiments: Experiments!
        private unowned var app: AppProtocol!

        public init(
            remote: some RemoteConfiguration_p,
            session: URLSessionProtocol = URLSession.shared,
            preferences: Preferences = UserDefaults.standard,
            scheduler: AnySchedulerOf<DispatchQueue> = .main,
            default defaultValue: Default = [:]
        ) {
            self.preferences = preferences
            self.scheduler = scheduler
            self.session = session
            let backoff = ExponentialBackoff()
            self.fetch = { [unowned self] app, isStale in

                let cached = preferences.object(
                    forKey: blockchain.session.configuration(\.id)
                ) as? [String: Any] ?? [:]

                _override.send(cached.mapKeys { important + $0 })

                var configuration: [String: Any?] = defaultValue.dictionary.mapKeys { key in
                    key.idToFirebaseConfigurationKeyDefault()
                }

                let expiration: TimeInterval
                if isStale {
                    expiration = 0 // Instant
                } else if isDebug {
                    expiration = 30 // 30 seconds
                } else {
                    expiration = 3600 // 1 hour
                }

                func errored() {
                    Task.detached { @MainActor in
                        try await backoff.next()
                        self.fetch?(app, isStale)
                    }
                }

                remote.fetch(withExpirationDuration: expiration) { [self] _, error in
                    guard error.peek(as: .error, if: \.isNotNil).isNil else { return errored() }
                    remote.activate { [self] _, error in
                        guard error.peek(as: .error, if: \.isNotNil).isNil else { return errored() }
                        let keys = remote.allKeys(from: .remote)
                        for key in keys {
                            do {
                                configuration[key] = try JSONSerialization.jsonObject(
                                    with: remote[key].dataValue,
                                    options: .fragmentsAllowed
                                )
                            } catch {
                                configuration[key] = String(decoding: remote[key].dataValue, as: UTF8.self)
                            }
                        }
                        self._fetched = configuration
                        app.state.set(blockchain.app.configuration.remote.is.stale, to: false)
                    }
                }
            }
        }

        func start(app: AppProtocol) {

            self.app = app
            experiments = Experiments(app: app, session: session)

            app.publisher(for: blockchain.app.configuration.remote.is.stale, as: Bool.self)
                .replaceError(with: false)
                .scan((stale: false, count: 0)) { ($1, $0.count + 1) }
                .sink { [unowned self] stale, count in
                    if stale || count == 1 {
                        fetch?(app, stale)
                    }
                }
                .store(in: &bag)

            _override
                .debounce(for: .seconds(1), scheduler: scheduler)
                .sink { [preferences] configuration in
                    let overrides = configuration.filter { key, _ in key.starts(with: important) }
                        .mapKeys { key in
                            String(key.dropFirst())
                        }
                    preferences.transaction(blockchain.session.configuration(\.id)) { object in
                        for (key, value) in overrides {
                            object[key] = value
                        }
                    }
                }
                .store(in: &bag)
        }

        private func key(_ event: Tag.Event) -> Tag.Reference {
            event.key().in(app)
        }

        public func contains(_ event: Tag.Event) -> Bool {
            resolved[firstOf: key(event).firebaseConfigurationKeys] != nil
        }

        public func override(_ event: Tag.Event, with value: Any?) {
            _override.send(lock.withLock {
                var override = _override.value
                override[key(event).idToFirebaseConfigurationKeyImportant()] = value
                return override
            })
        }

        public func override(_ event: Tag.Reference, with value: Any?) {
            _override.send(lock.withLock {
                var override = _override.value
                override[event.idToFirebaseConfigurationKeyImportant()] = value
                return override
            })
        }

        public func clear() {
            _override.send([:])
        }

        public func clear(_ event: Tag.Event) {
            _override.send(lock.withLock {
                var override = _override.value
                override.removeValue(forKey: key(event).idToFirebaseConfigurationKeyImportant())
                return override
            })
        }

        @available(*, deprecated, message: "Please use the async API available on App directly. app.get(_:), app.stream(_:) or app.publisher(for:)")
        public func get(_ event: Tag.Event) throws -> Any? {
            try result(for: event).get()
        }

        @available(*, deprecated, message: "Please use the async API available on App directly. app.get(_:), app.stream(_:) or app.publisher(for:)")
        public func get<T: Decodable>(
            _ event: Tag.Event,
            as _: T.Type = T.self,
            using decoder: AnyDecoderProtocol = BlockchainNamespaceDecoder()
        ) throws -> T {
            try decoder.decode(T.self, from: get(event) as Any)
        }

        @available(*, deprecated, message: "Please use the async API available on App directly. app.get(_:), app.stream(_:) or app.publisher(for:)")
        public func get<T: Decodable>(
            _ event: Tag.Event,
            as _: T.Type = T.self,
            or fallback: T,
            using decoder: AnyDecoderProtocol = BlockchainNamespaceDecoder()
        ) -> T {
            do {
                return try get(event, as: T.self, using: decoder)
            } catch {
                return fallback
            }
        }

        @available(*, deprecated, message: "Please use the async API available on App directly. try await app.get(_:)")
        public func result(for event: Tag.Event) -> FetchResult {
            let key = key(event)
            guard isSynchronized else {
                return .error(Error.notSynchronized, key.metadata(.remoteConfiguration))
            }
            guard let value = resolved[firstOf: key.firebaseConfigurationKeys] else {
                return .error(FetchResult.Error.keyDoesNotExist(key), key.metadata(.remoteConfiguration))
            }
            return .value(value as Any, key.metadata(.remoteConfiguration))
        }

        public func publisher(for event: Tag.Event) -> AnyPublisher<FetchResult, Never> {
            let publisher = _decoded.combineLatest(_override).map { [key] configuration, user -> FetchResult in
                let key = key(event)
                switch (configuration + user)[firstOf: key.firebaseConfigurationKeys] {
                case let value?:
                    return .value(value as Any, key.metadata(.remoteConfiguration))
                case nil:
                    return .error(FetchResult.Error.keyDoesNotExist(key), key.metadata(.remoteConfiguration))
                }
            }
            if isSynchronized {
                return publisher.eraseToAnyPublisher()
            } else {
                return _isSynchronized.filter(\.self)
                    .map { _ in publisher }
                    .switchToLatest()
                    .eraseToAnyPublisher()
            }
        }

        public func override(_ key: String, with value: Any) {
            let o = lock.withLock { var o = _override.value; o[key] = value; return o }
            _override.send(o)
        }

        public func get(_ key: String) throws -> Any? {
            guard isSynchronized else { throw Error.notSynchronized }
            return resolved[key] as Any?
        }

        public func publisher(for string: String) -> AnyPublisher<Any?, Never> {
            let publisher = _decoded.map { $0[string]?.wrapped }
            if isSynchronized {
                return publisher.eraseToAnyPublisher()
            } else {
                return _isSynchronized.filter(\.self)
                    .map { _ in publisher }
                    .switchToLatest()
                    .eraseToAnyPublisher()
            }
        }

        /// Determines if the app has the `DEBUG` build flag.
        private var isDebug: Bool {
            #if DEBUG
            return true
            #else
            return false
            #endif
        }
    }
}

extension Session.RemoteConfiguration {

    @available(*, deprecated, message: "Please use the async API available on App directly. app.get(_:), app.stream(_:) or app.publisher(for:)")
    @inlinable public func yes(
        if ifs: L & I_blockchain_db_type_boolean...
    ) -> Bool {
        yes(if: ifs, unless: [])
    }

    @available(*, deprecated, message: "Please use the async API available on App directly. app.get(_:), app.stream(_:) or app.publisher(for:)")
    @inlinable public func yes(
        if ifs: L & I_blockchain_db_type_boolean...,
        unless buts: L & I_blockchain_db_type_boolean...
    ) -> Bool {
        yes(if: ifs, unless: buts)
    }

    @available(*, deprecated, message: "Please use the async API available on App directly. app.get(_:), app.stream(_:) or app.publisher(for:)")
    @inlinable public func yes(
        if ifs: [L & I_blockchain_db_type_boolean],
        unless buts: [L & I_blockchain_db_type_boolean] = []
    ) -> Bool {
        ifs.allSatisfy { result(for: $0).isYes } && buts.none { result(for: $0).isYes }
    }

    @available(*, deprecated, message: "Please use the async API available on App directly. app.get(_:), app.stream(_:) or app.publisher(for:)")
    @inlinable public func no(
        if ifs: L & I_blockchain_db_type_boolean...
    ) -> Bool {
        no(if: ifs, unless: [])
    }

    @available(*, deprecated, message: "Please use the async API available on App directly. app.get(_:), app.stream(_:) or app.publisher(for:)")
    @inlinable public func no(
        if ifs: L & I_blockchain_db_type_boolean...,
        unless buts: L & I_blockchain_db_type_boolean...
    ) -> Bool {
        no(if: ifs, unless: buts)
    }

    @available(*, deprecated, message: "Please use the async API available on App directly. app.get(_:), app.stream(_:) or app.publisher(for:)")
    @inlinable public func no(
        if ifs: [L & I_blockchain_db_type_boolean],
        unless buts: [L & I_blockchain_db_type_boolean] = []
    ) -> Bool {
        yes(if: ifs, unless: buts) ? false : true
    }
}

private let important: String = "!"

extension Session.RemoteConfiguration {

    public enum Error: Swift.Error {
        case notSynchronized
        case keyDoesNotExist(Tag.Reference)
    }
}

extension Tag.Reference {

    fileprivate var components: [String] {
        tag.lineage.reversed().flatMap { tag -> [String] in
            guard
                let collectionId = try? tag.as(blockchain.db.collection).id[],
                let id = indices[collectionId]
            else {
                return [tag.name]
            }
            return [tag.name, id.description.replacingOccurrences(of: ".", with: "_")]
        }
    }

    fileprivate var firebaseConfigurationKeys: [String] {
        [
            idToFirebaseConfigurationKeyImportant(),
            idToFirebaseConfigurationKey(),
            idToFirebaseConfigurationKeyFallback(),
            idToFirebaseConfigurationKeyIsEnabledFallback(),
            idToFirebaseConfigurationKeyIsEnabledFallbackAlternative(),
            idToFirebaseConfigurationKeyDefault()
        ]
    }

    fileprivate func idToFirebaseConfigurationKeyImportant() -> String { important + string }
    fileprivate func idToFirebaseConfigurationKeyDefault() -> String { string }

    /// blockchain_app_configuration_path_to_leaf_is_enabled
    fileprivate func idToFirebaseConfigurationKey() -> String {
        components.joined(separator: "_")
    }

    /// blockchain_app_configuration_path_to_leaf_is_enabled -> ios_ff_path_to_leaf_is_enabled
    fileprivate func idToFirebaseConfigurationKeyFallback() -> String {
        idToFirebaseConfigurationKey()
            .replacingOccurrences(
                of: "blockchain_app_configuration",
                with: "ios_ff"
            )
    }

    /// blockchain_app_configuration_path_to_leaf_is_enabled -> ios_ff_path_to_leaf
    fileprivate func idToFirebaseConfigurationKeyIsEnabledFallback() -> String {
        idToFirebaseConfigurationKey()
            .replacingOccurrences(
                of: "blockchain_app_configuration",
                with: "ios_ff"
            )
            .replacingOccurrences(
                of: "_is_enabled",
                with: ""
            )
    }

    /// blockchain_app_configuration_path_to_leaf_is_enabled -> ios_path_to_leaf
    fileprivate func idToFirebaseConfigurationKeyIsEnabledFallbackAlternative() -> String {
        idToFirebaseConfigurationKey()
            .replacingOccurrences(
                of: "blockchain_app_configuration",
                with: "ios"
            )
            .replacingOccurrences(
                of: "_is_enabled",
                with: ""
            )
    }
}

extension Dictionary {

    fileprivate subscript(firstOf first: Key, _ rest: Key...) -> Value? {
        self[firstOf: [first] + rest]
    }

    fileprivate subscript(firstOf keys: [Key]) -> Value? {
        for key in keys {
            guard let value = self[key] else { continue }
            return value
        }
        return nil
    }
}

extension Session.RemoteConfiguration {

    public struct Default: ExpressibleByDictionaryLiteral {
        let dictionary: [Tag.Reference: Any?]
        public init(_ dictionary: [Tag.Reference: Any?]) {
            self.dictionary = dictionary
        }

        public init(dictionaryLiteral elements: (Tag.Event, Any?)...) {
            self.dictionary = Dictionary(uniqueKeysWithValues: elements.map { ($0.0.key(), $0.1) })
        }

        public init(_ json: Any) throws {
            self.dictionary = try BlockchainNamespaceDecoder()
                .decode([String: AnyJSON?].self, from: json)
                .mapKeysAndValues(
                    key: { try Tag.Reference(id: $0, in: Language.root.language) },
                    value: \.?.wrapped
                )
        }

        public static func + (lhs: Self, rhs: Self) -> Self {
            Self(lhs.dictionary + rhs.dictionary)
        }
    }
}

private actor ExponentialBackoff {

    var n = 0
    var rng = SystemRandomNumberGenerator()
    let unit: TimeInterval

    init(unit: TimeInterval = 0.5) {
        self.unit = unit
    }

    func next() async throws {
        n += 1
        try await Task.sleep(
            nanoseconds: UInt64(TimeInterval.random(
                in: unit...unit * pow(2, TimeInterval(n - 1)),
                using: &rng
            ) * 1_000_000)
        )
    }
}

extension Session.RemoteConfiguration {

    typealias Experiment = [String: [Int: AnyJSON]]

    public static func experiments(in app: AppProtocol) -> AnyPublisher<[String: Int], Never> {
        app.publisher(for: blockchain.ux.user.nabu.experiments, as: [String].self)
            .compactMap(\.value)
            .flatMap { [app] ids -> AnyPublisher<[String: Int], Never> in
                guard ids.isNotEmpty else { return .just([:]) }
                return ids.map { id in
                    app.publisher(for: blockchain.ux.user.nabu.experiment[id].group, as: Int.self)
                        .compactMap { result in result.value.map { (id, $0) } }
                }
                .combineLatest()
                .map(Dictionary.init(uniqueKeysWithValues:))
                .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    class Experiments {

        unowned let app: AppProtocol
        let session: URLSessionProtocol

        private var subscription: AnyCancellable?
        private var http: URLSessionDataTaskProtocol?
        private let baseURL = URL(string: "https://\(Bundle.main.plist?.RETAIL_CORE_URL ?? "api.blockchain.info/nabu-gateway")")!

        init(app: AppProtocol, session: URLSessionProtocol) {

            self.app = app
            self.session = session

            self.subscription = app.on(
                blockchain.session.event.did.sign.in,
                blockchain.session.event.did.sign.out
            ) { [unowned self] event in
                switch event.tag {
                case blockchain.session.event.did.sign.in:
                    try await request(token: app.stream(blockchain.user.token.nabu).compactMap(\.value).next())
                case blockchain.session.event.did.sign.out:
                    request(token: nil)
                default:
                    break
                }
            }
            .subscribe()

            request(token: nil)
        }

        deinit {
            subscription?.cancel()
            http?.cancel()
        }

        func request(token: String?) {
            var request = URLRequest(url: baseURL.appendingPathComponent("experiments"))
            do {
                request.allHTTPHeaderFields = try [
                    "Authorization": "Bearer " + token.or(throw: "No Authorization Token"),
                    "Accept-Language": "application/json"
                ]
            } catch {
                request.allHTTPHeaderFields = ["Accept-Language": "application/json"]
            }
            http = session.dataTask(with: request.peek("🌎", \.cURLCommand)) { [app] data, _, err in
                do {
                    let json = try JSONSerialization.jsonObject(
                        with: data.or(throw: err ?? "No data"),
                        options: []
                    ) as? [String: Int] ??^ "Expected [String: Int]"

                    app.state.transaction { state in
                        for (id, group) in json {
                            state.set(blockchain.ux.user.nabu.experiment[id].group, to: group)
                        }
                        state.set(blockchain.ux.user.nabu.experiments, to: Array(json.keys))
                    }
                } catch {
                    if app.state.doesNotContain(blockchain.ux.user.nabu.experiments) {
                        app.state.set(blockchain.ux.user.nabu.experiments, to: [String]())
                    }
                    app.post(error: error)
                }
            }
            http?.resume()
        }

        func decode(_ fetched: [String: Any?]) -> AnyPublisher<[String: Any?], Never> {
            Session.RemoteConfiguration.experiments(in: app)
                .map { [app] experiments in
                    fetched.deepMap { k, v in
                        do {
                            if
                                let v = v as? [String: Any],
                                let returns = v[Compute.key.returns] as? [String: Any],
                                returns["experiment"].isNotNil
                            {
                                do {
                                    let experiment = try returns["experiment"].decode(Experiment.self)
                                    guard let (id, nabu) = experiment.firstAndOnly else {
                                        throw "Expected 1 experiment, got \(experiment.keys.count)"
                                    }
                                    let any = try nabu[experiments[id] ??^ "No experiment for '\(id)'"] ??^ "No experiment config for '\(id)'"
                                    return (k, any.wrapped)
                                } catch {
                                    if let defaultValue = v[Compute.key.default] {
                                        return (k, defaultValue)
                                    } else {
                                        throw error
                                    }
                                }
                            } else {
                                return (k, v)
                            }
                        } catch {
                            app.post(error: error)
                            return (k, v)
                        }
                    }
                }
                .eraseToAnyPublisher()
        }
    }
}
