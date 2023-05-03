// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Extensions
import FirebaseProtocol
import Foundation
import OptionalSubscripts

#if canImport(AppKit)
import AppKit
#endif

public private(set) var runningApp: AppProtocol!

public protocol AppProtocol: AnyObject, CustomStringConvertible {

    var language: Language { get }

    var events: Session.Events { get }
    var state: Session.State { get }
    var remoteConfiguration: Session.RemoteConfiguration { get }
    var deepLinks: App.DeepLink { get }
    var local: Optional<Any>.Store { get }
    var napis: NAPI.Store { get }

    var clientObservers: Client.Observers { get }
    var sessionObservers: Session.Observers { get }

    #if canImport(SwiftUI)
    var environmentObject: App.EnvironmentObject { get }
    #endif

    var isInTransaction: Bool { get async }

    func register(
        napi root: I_blockchain_namespace_napi,
        domain: L,
        policy: L_blockchain_namespace_napi_napi_policy.JSON?,
        repository: @escaping (Tag.Reference) -> AnyPublisher<AnyJSON, Never>,
        in context: Tag.Context
    ) async throws
}

public class App: AppProtocol {

    public let language: Language

    public let events: Session.Events
    public let state: Session.State
    public let remoteConfiguration: Session.RemoteConfiguration

#if canImport(SwiftUI)
    public lazy var environmentObject = App.EnvironmentObject(self)
#endif

    public let local = Any?.Store()
    public lazy var napis = NAPI.Store(self)

    public lazy var deepLinks = DeepLink(self)

    public let clientObservers: Client.Observers
    public lazy var sessionObservers: Session.Observers = .init(app: self)

    public convenience init(
        language: Language = Language.root.language,
        remote: some RemoteConfiguration_p
    ) {
        self.init(
            language: language,
            remoteConfiguration: Session.RemoteConfiguration(remote: remote)
        )
    }

    @_disfavoredOverload
    public convenience init(
        language: Language = Language.root.language,
        state: Session.State = .init(),
        remoteConfiguration: Session.RemoteConfiguration
    ) {
        self.init(
            language: language,
            state: state,
            remoteConfiguration: remoteConfiguration
        )
    }

    init(
        language: Language = Language.root.language,
        events: Session.Events = .init(),
        state: Session.State = .init(),
        clientObservers: Client.Observers = .init(),
        remoteConfiguration: Session.RemoteConfiguration
    ) {
        defer { start() }
        self.language = language
        self.events = events
        self.state = state
        self.clientObservers = clientObservers
        self.remoteConfiguration = remoteConfiguration
        runningApp = self
    }

    deinit {
        for o in __observers {
            o.stop()
        }
    }

    private func start() {
        state.app = self
        deepLinks.start()
        sessionObservers.subscribe()
        remoteConfiguration.start(app: self)
        do {
            #if DEBUG
            _ = logger
            #endif
        }
        for o in __observers {
            o.start()
        }
    }

    // Observers

    private lazy var logger = events.sink { event in
        guard event.tag.isNot(blockchain.session.event.hidden) else { return }
        if
            let message = event.context[e.message] as? String,
            let file = event.context[e.file] as? String,
            let line = event.context[e.line] as? Int
        {
            if event.tag == blockchain.ux.type.analytics.error[] {
                print("🏷 ‼️", message, "←", file, line)
            } else {
                print("🏷 ‼️", event.reference, message, "←", file, line)
            }
        } else {
            print("🏷", event.reference, "←", event.source.file, event.source.line)
        }
    }

    private lazy var __observers = [
        actions,
        aliases,
        copyItems,
        sets,
        urls
    ]

    private lazy var actions = on(blockchain.ui.type.action) { [weak self] event async throws in
        guard let self else { return }
        do {
            try await handle(action: event)
            let handled = try event.reference.tag.as(blockchain.ui.type.action).was.handled.key(to: event.reference.context)
            post(event: handled, context: event.context, file: event.source.file, line: event.source.line)
        } catch {
            if ProcessInfo.processInfo.environment["BLOCKCHAIN_DEBUG_NAMESPACE_ACTION"] == "TRUE" {
                post(error: error, context: event.context, file: event.source.file, line: event.source.line)
            }
            return
        }
    }

    private lazy var sets = on(blockchain.ui.type.action.then.set.session.state) { [weak self] event throws in
        guard let self else { return }
        guard let action = event.action else { return }
        struct _KeyValuePair: Decodable {
            let key: Tag.Reference, value: AnyJSON
        }
        do {
            let data = try action.data.decode([_KeyValuePair].self)
            state.transaction { state in
                for next in data {
                    state.set(next.key, to: next.value.any)
                }
            }
            for next in data {
                post(event: next.key, context: event.context + [next.key: next.value], file: event.source.file, line: event.source.line)
            }
        } catch {
            post(error: error, context: event.context, file: event.source.file, line: event.source.line)
        }
    }

    private lazy var urls = on(blockchain.ui.type.action.then.launch.url) { [weak self] event throws in
        guard let self else { return }
        do {
            let url: URL
            do {
                url = try event.context.decode(blockchain.ui.type.action.then.launch.url)
            } catch {
                url = try event.action.or(throw: "No action").data.decode()
            }
            guard deepLinks.canProcess(url: url) else {
                DispatchQueue.main.async {
                    #if canImport(UIKit)
                        UIApplication.shared.open(url)
                    #elseif canImport(AppKit)
                        NSWorkspace.shared.open(url)
                    #endif
                }
                return
            }
            post(
                event: blockchain.app.process.deep_link,
                context: event.context + [blockchain.app.process.deep_link.url: url],
                file: event.source.file,
                line: event.source.line
            )
        } catch {
            post(error: error, context: event.context, file: event.source.file, line: event.source.line)
        }
    }

    private lazy var copyItems = on(blockchain.ui.type.action.then.copy) { event throws in
#if canImport(UIKit)
        let string: String = try event.action.or(throw: "No action").data.decode()
        UIPasteboard.general.string = string
#endif
    }

    private lazy var aliases = on(blockchain.session.state.value) { [weak self] event in
        guard let self else { return }
        let tag = try event.tag.as(blockchain.session.state.value).alias
        let path = tag[].key(to: event.reference.context)
        do {
            let key = try await get(path, as: Tag.self).key(to: event.reference.context)
            let value = try state.get(event.reference, as: String.self)
            post(value: value, of: key, file: event.source.file, line: event.source.line)
        } catch {
            return
        }
    }
}

extension AppProtocol {

    public var isInTransaction: Bool {
        get async {
            guard state.data.isInTransaction else { return false }
            return await local.isInTransaction
        }
    }

    public func signIn(userId: String) {
        post(event: blockchain.session.event.will.sign.in)
        state.transaction { state in
            state.set(blockchain.user.id, to: userId)
        }
        post(event: blockchain.session.event.did.sign.in)
        sessionObservers.reset()
    }

    public func signOut() {
        post(event: blockchain.session.event.will.sign.out)

        state.transaction { state in
            state.clear(blockchain.app.configuration.pubkey.service.auth)
        }

        state.transaction { state in
            state.clear(blockchain.user.id)
        }
        Task { try await set(blockchain.user, to: nil) }
        post(event: blockchain.session.event.did.sign.out)
    }
}

extension AppProtocol {

    public func post(
        value: AnyHashable,
        of event: Tag.Event,
        file: String = #fileID,
        line: Int = #line
    ) {
        let reference = event.key().in(self)
        state.set(reference, to: value)
        post(
            event: event,
            reference: reference,
            context: [event: value],
            file: file,
            line: line
        )
    }

    public func post(
        event: Tag.Event,
        context: Tag.Context = [:],
        file: String = #fileID,
        line: Int = #line
    ) {
        post(
            event: event,
            reference: event.key().in(self),
            context: context,
            file: file,
            line: line
        )
    }

    func post(
        event: Tag.Event,
        reference: Tag.Reference,
        context: Tag.Context = [:],
        file: String = #fileID,
        line: Int = #line
    ) {
        events.send(
            Session.Event(
                origin: event,
                reference: reference,
                context: [
                    s.file: file,
                    s.line: line
                ] + context,
                file: file,
                line: line
            )
        )
    }

    public func post(
        _ tag: L_blockchain_ux_type_analytics_error,
        error: some Error,
        context: Tag.Context = [:],
        file: String = #fileID,
        line: Int = #line
    ) {
        post(tag[], error: error, context: context, file: file, line: line)
    }

    public func post(
        error: some Error,
        context: Tag.Context = [:],
        file: String = #fileID,
        line: Int = #line
    ) {
        if let error = error as? Tag.Error {
            post(blockchain.ux.type.analytics.error, error: error, context: context + [error.event: AnyJSON(error)], file: error.file, line: error.line)
        } else {
            post(blockchain.ux.type.analytics.error, error: error, context: context, file: file, line: line)
        }
    }

    private func post(
        _ event: Tag.Event,
        error: some Error,
        context: Tag.Context = [:],
        file: String = #fileID,
        line: Int = #line
    ) {
        post(
            event: event,
            context: context + [
                e.message: "\(error.localizedDescription)",
                e.file: file,
                e.line: line
            ]
        )
    }

    public func on(
        _ first: Tag.Event,
        _ rest: Tag.Event...
    ) -> AnyPublisher<Session.Event, Never> {
        on([first] + rest)
    }

    public func on(
        _ tags: some Sequence<Tag.Event>
    ) -> AnyPublisher<Session.Event, Never> {
        events.filter(tags.map { $0.key().in(self) })
            .eraseToAnyPublisher()
    }

    public func on(
        where filter: @escaping (Tag) -> Bool
    ) -> AnyPublisher<Session.Event, Never> {
        events.filter { filter($0.tag) }.eraseToAnyPublisher()
    }

    public func on(
        _ first: Tag.Event,
        _ rest: Tag.Event...,
        bufferingPolicy: AsyncStream<Session.Event>.Continuation.BufferingPolicy = .bufferingNewest(1)
    ) -> AsyncStream<Session.Event> {
        on([first] + rest, bufferingPolicy: bufferingPolicy)
    }

    public func on(
        _ tags: some Sequence<Tag.Event>,
        bufferingPolicy: AsyncStream<Session.Event>.Continuation.BufferingPolicy = .bufferingNewest(1)
    ) -> AsyncStream<Session.Event> {
        events.filter(tags.map { $0.key().in(self) }).stream(bufferingPolicy: bufferingPolicy)
    }
}

extension AppProtocol {

    public func post(
        action event: Tag.Event,
        value: some Any,
        context: Tag.Context = [:],
        file: String = #fileID,
        line: Int = #line
    ) {
        do {
            let id = try event[].lineage.first(where: { tag in tag.is(blockchain.ui.type.action) })
                .or(throw: "\(event) is not an descendant of \(blockchain.ui.type.action)")
                .as(blockchain.ui.type.action)
            let ref = event.key().in(self)
            post(
                event: event,
                reference: ref,
                context: context + [
                    blockchain.ui.type.action: Action(
                        tag: id,
                        event: ref,
                        data: AnyJSON(value)
                    )
                ],
                file: file,
                line: line
            )
        } catch {
            post(error: error, context: context, file: file, line: line)
        }
    }
}

private let e = (
    message: blockchain.ux.type.analytics.error.message[],
    file: blockchain.ux.type.analytics.error.source.file[],
    line: blockchain.ux.type.analytics.error.source.line[]
)

private let s = (
    file: blockchain.ux.type.analytics.event.source.file[],
    line: blockchain.ux.type.analytics.event.source.line[]
)

extension AppProtocol {

    public func register(
        napi root: I_blockchain_namespace_napi,
        domain: L,
        policy: L_blockchain_namespace_napi_napi_policy.JSON? = nil,
        repository: @escaping (Tag.Reference) async -> AnyJSON,
        in context: Tag.Context = [:]
    ) async throws {
        try await transaction { app in
            try await app.set(root.napi.data.key(to: context + [root.napi.id: domain(\.id)]), to: AnyJSON(repository))
            if let policy {
                try await app.set(root.napi.policy.key(to: context + [root.napi.id: domain(\.id)]), to: policy.any())
            }
        }
    }

    @_disfavoredOverload
    public func register(
        napi root: I_blockchain_namespace_napi,
        domain: L,
        policy: L_blockchain_namespace_napi_napi_policy.JSON? = nil,
        repository: @escaping (Tag.Reference) -> AsyncStream<AnyJSON>,
        in context: Tag.Context = [:]
    ) async throws {
        try await transaction { app in
            try await app.set(root.napi.data.key(to: context + [root.napi.id: domain(\.id)]), to: AnyJSON(repository))
            if let policy {
                try await app.set(root.napi.policy.key(to: context + [root.napi.id: domain(\.id)]), to: policy.any())
            }
        }
    }

    public func register(
        napi root: I_blockchain_namespace_napi,
        domain: L,
        policy: L_blockchain_namespace_napi_napi_policy.JSON? = nil,
        repository: @escaping (Tag.Reference) -> AnyPublisher<AnyJSON, Never>,
        in context: Tag.Context = [:]
    ) async throws {
        try await transaction { app in
            try await app.set(root.napi.data.key(to: context + [root.napi.id: domain(\.id)]), to: AnyJSON(repository))
            if let policy {
                try await app.set(root.napi.policy.key(to: context + [root.napi.id: domain(\.id)]), to: policy.any())
            }
        }
    }
}

extension AppProtocol {

    public func publisher<Language: L>(for event: Tag.Event, as id: Language) -> AnyPublisher<FetchResult.Value<Language.JSON>, Never> {
        publisher(for: event, as: Language.JSON.self)
    }

    public func publisher<T: Equatable>(for event: Tag.Event, as _: T.Type = T.self) -> AnyPublisher<FetchResult.Value<T>, Never> {
        publisher(for: event).decode(T.self)
            .removeDuplicates(
                by: { lhs, rhs in (try? lhs.get() == rhs.get()) ?? false }
            )
            .eraseToAnyPublisher()
    }

    public func publisher<T>(for event: Tag.Event, as _: T.Type = T.self) -> AnyPublisher<FetchResult.Value<T>, Never> {
        publisher(for: event).decode(T.self)
    }

    public func publisher(for event: Tag.Event) -> AnyPublisher<FetchResult, Never> {

        func makePublisher(_ ref: Tag.Reference) -> AnyPublisher<FetchResult, Never> {
            switch ref.tag {
            case blockchain.session.state.value, blockchain.db.collection.id:
                return state.publisher(for: ref)
            case blockchain.session.configuration.value:
                return remoteConfiguration.publisher(for: ref)
            case _ where ref.tag.isNAPI:
                return napis.publisher(for: ref)
            default:
                return local.nonisolated_publisher(for: ref, app: self)
            }
        }

        let ref = event.key().in(self)
        let ids = ref.context.mapKeys(\.tag)

        do {
            let context = Tag.Context(ids)
            let dynamicKeys = try ref.tag.template.indices.set
                .subtracting(ids.keys.map(\.id))
                .map { try Tag(id: $0, in: language) }
                .map { try (key: $0, value: $0.ref(to: context - $0, in: self).validated(), recursive: false) }
            + ids.compactMapValues { $0 as? iTag }
                .map { try (key: $0, value: $1.id.ref(to: context - $0, in: self).validated(), recursive: true) }
            guard dynamicKeys.isNotEmpty else {
                return try makePublisher(ref.validated())
            }
            return dynamicKeys
                .map { _, value, recursive -> AnyPublisher<FetchResult, Never> in
                    recursive ? publisher(for: value) : makePublisher(value)
                }
                .combineLatest()
                .flatMap { output -> AnyPublisher<FetchResult, Never> in
                    do {
                        let values = try output.map { try $0.decode(String.self).get() }
                        let indices = zip(dynamicKeys.map(\.key), values).reduce(into: [:]) { $0[$1.0] = $1.1 }
                        return try makePublisher(ref.ref(to: context + Tag.Context(indices)).validated())
                            .eraseToAnyPublisher()
                    } catch let error as FetchResult.Error {
                        return Just(.error(error, ref.metadata(.app)))
                            .eraseToAnyPublisher()
                    } catch let error as AnyDecoder.Error {
                        return Just(.error(.decoding(error), ref.metadata(.app)))
                            .eraseToAnyPublisher()
                    } catch {
                        return Just(.error(.other(error), ref.metadata(.app)))
                            .eraseToAnyPublisher()
                    }
                }
                .eraseToAnyPublisher()
        } catch let error as FetchResult.Error {
            return Just(.error(error, ref.metadata(.app)))
                .eraseToAnyPublisher()
        } catch let error as AnyDecoder.Error {
            return Just(.error(.decoding(error), ref.metadata(.app)))
                .eraseToAnyPublisher()
        } catch {
            return Just(.error(.other(error), ref.metadata(.app)))
                .eraseToAnyPublisher()
        }
    }

    public func get<T: Decodable>(
        _ event: Tag.Event,
        waitForValue: Bool = false,
        as _: T.Type = T.self,
        file: String = #fileID,
        line: Int = #line
    ) async throws -> T {
        let stream = publisher(for: event, as: T.self).stream() // ← Invert this, foundation API is async/await with actor
        if waitForValue {
            return try await stream.compactMap(\.value).next(file: file, line: line)
        } else {
            return try await stream.next(file: file, line: line).get()
        }
    }

    public func get<T: Decodable>(
        _ event: Tag.Event,
        waitForValue: Bool = false,
        as _: T.Type = T.self,
        or fallback: T,
        file: String = #fileID,
        line: Int = #line
    ) async -> T {
        do {
            return try await get(
                event,
                waitForValue: waitForValue,
                as: T.self,
                file: file,
                line: line
            )
        } catch {
            return fallback
        }
    }

    public func stream(
        _ event: Tag.Event,
        bufferingPolicy: AsyncStream<FetchResult>.Continuation.BufferingPolicy = .bufferingNewest(1)
    ) -> AsyncStream<FetchResult> {
        publisher(for: event).stream(bufferingPolicy: bufferingPolicy)
    }

    @_disfavoredOverload
    public func stream<T: Decodable>(
        _ event: Tag.Event,
        as _: T.Type = T.self,
        bufferingPolicy: AsyncStream<FetchResult.Value<T>>.Continuation.BufferingPolicy = .bufferingNewest(1)
    ) -> AsyncStream<FetchResult.Value<T>> {
        publisher(for: event, as: T.self).stream(bufferingPolicy: bufferingPolicy)
    }
}

extension AppProtocol {

    public typealias BatchUpdates = [(Tag.Event, Any?)]

    @discardableResult
    public func transaction(_ body: (Self) async throws -> Void) async rethrows -> Self {
        try await local.transaction { _ in
            try await body(self)
        }
        return self
    }

    public func batch(updates sets: BatchUpdates, in context: Tag.Context = [:], file: String = #fileID, line: Int = #line) async throws {
        var updates = Any?.Store.BatchUpdates()
        for (event, value) in sets {
            let reference = event.key(to: context)
            try updates.append((reference.route(app: self, file: file, line: line), value))
        }
        await local.batch(updates)
    }

    public func set(_ event: Tag.Event, to value: Any?, file: String = #fileID, line: Int = #line) async throws {
        let reference = event.key().in(self)
        switch event {
        case blockchain.session.state.value, blockchain.db.collection.id:
            return state.set(reference, to: value)
        case blockchain.session.configuration.value:
            #if DEBUG
            remoteConfiguration.override(reference, with: value)
            #endif
        case _ where reference.tag.isNAPI:
            assertionFailure("Cannot set NAPI directly, please define a repository. If this error is unexpected, and you require it's behaviour please ask in #ios-engineers")
        default:
            break
        }
        if
            let collectionId = try? reference.tag.as(blockchain.db.collection).id[],
            !reference.indices.map(\.key).contains(collectionId)
        {
            if value == nil {
                try await local.set(reference.route(toCollection: true, app: self, file: file, line: line), to: nil)
            } else {
                guard let map = value as? [String: Any] else { throw "Not a collection" }
                var updates = Any?.Store.BatchUpdates()
                for (key, value) in map {
                    try updates.append((reference.key(to: [collectionId: key]).route(app: self, file: file, line: line), value))
                }
                await local.batch(updates)
            }
        } else {
            try await local.set(reference.route(app: self, file: file, line: line), to: value)
        }
        #if DEBUG
        if isInTest { await Task.megaYield(count: 20) }
        #endif
    }
}

extension Tag.Reference {

    func route(toCollection: Bool = false, app: AppProtocol? = nil, file: String = #fileID, line: Int = #line) throws -> Optional<Any>.Store.Route {
        let lineage = tag.lineage.reversed()
        return try lineage.indexed()
            .flatMap { index, node throws -> [Optional<Any>.Store.Location] in
                guard node.isCollection, let collectionId = node["id"] else {
                    return [.key(node.name)]
                }
                if let id = indices[collectionId], id != Tag.Context.genericIndex {
                    return [.key(node.name), .key(id)]
                } else if let id = try? context[collectionId].decode(String.self), id != Tag.Context.genericIndex {
                    return [.key(node.name), .key(id)]
                } else if let state = app?.state, let id = state.result(for: collectionId).decode(String.self).value {
                    return [.key(node.name), .key(id)]
                } else if toCollection, index == lineage.index(before: lineage.endIndex) {
                    return [.key(node.name)]
                } else {
                    throw error(message: "Missing indices for ref to \(collectionId)", file: file, line: line)
                }
            }
    }
}

extension App {
    public var description: String { "App \(language.id)" }
}

extension AppProtocol {
    public func setup(_ body: @escaping (Self) async throws -> Void) -> Self {
        Task {
            try await transaction(body)
        }
        return self
    }
}

extension Optional.Store {

    nonisolated func nonisolated_publisher(
        for ref: Tag.Reference,
        bufferingPolicy limit: Optional.Store.BufferingPolicy = .bufferingNewest(1),
        app: AppProtocol? = nil
    ) -> AnyPublisher<FetchResult, Never> {
        Task.Publisher { await publisher(for: ref, bufferingPolicy: limit, app: app) }
            .switchToLatest()
            .eraseToAnyPublisher()
    }

    func publisher(
        for ref: Tag.Reference,
        bufferingPolicy limit: Optional.Store.BufferingPolicy = .bufferingNewest(1),
        app: AppProtocol? = nil
    ) -> AnyPublisher<FetchResult, Never> {
        do {
            let route = try ref.route(toCollection: ref.tag.isCollection && ref.context[ref.tag["id"]!].isNil, app: app)
            return publisher(for: route, bufferingPolicy: limit)
                .task { value in
                    guard value.isNotNil, data.contains(route) else {
                        return FetchResult.error(.keyDoesNotExist(ref), ref.metadata(.app))
                    }
                    return FetchResult(value as Any, metadata: ref.metadata(.app))
                }
                .eraseToAnyPublisher()
        } catch {
            return .just(.error(.other(error), ref.metadata(.app)))
        }
    }
}

extension Optional<Any> {

    func contains(_ location: Location) -> Bool {
        switch (location, self) {
        case (.key(let key), let dictionary as [String: Any]):
            return dictionary.keys.contains(key)
        case (.index(let index), let array as [Any]):
            return index >= 0 && index < array.count
        case _:
            return false
        }
    }

    func contains<Route>(_ route: Route) -> Bool where Route: Collection, Route.Index == Int, Route.Element == Location {
        guard let next = route.first else { return true }
        return contains(next) && self[next].contains(route.dropFirst())
    }
}
