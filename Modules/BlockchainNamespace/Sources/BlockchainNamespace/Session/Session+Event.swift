// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Extensions

extension Session {

    public typealias Events = PassthroughSubject<Session.Event, Never>

    public struct Event: Identifiable, Hashable {

        public let id: UInt
        public let date: Date
        public let origin: Tag.Event
        public let reference: Tag.Reference
        public let context: Tag.Context

        public let source: (file: String, line: Int)

        public var tag: Tag { reference.tag }

        init(
            date: Date = Date(),
            _ event: Tag.Event,
            context: Tag.Context = [:],
            file: String = #fileID,
            line: Int = #line
        ) {
            self.init(
                date: date,
                origin: event,
                reference: event.key(to: [:]),
                context: context,
                file: file,
                line: line
            )
        }

        init(
            date: Date = Date(),
            origin: Tag.Event,
            reference: Tag.Reference,
            context: Tag.Context = [:],
            file: String = #fileID,
            line: Int = #line
        ) {
            self.id = Self.id
            self.date = date
            self.origin = origin
            self.reference = reference
            self.context = context
            self.source = (file, line)
        }

        public func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }

        public static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.id == rhs.id
        }
    }
}

extension Session.Event: CustomStringConvertible {
    public var description: String { String(describing: origin) }
}

extension Session.Event {
    private static var count: UInt = 0
    private static let lock = NSLock()
    private static var id: UInt {
        lock.lock()
        defer { lock.unlock() }
        count += 1
        return count
    }
}

extension Publisher where Output == Session.Event {

    public func filter(_ type: L) -> Publishers.Filter<Self> {
        filter(type[])
    }

    public func filter(_ type: Tag) -> Publishers.Filter<Self> {
        filter([type])
    }

    public func filter(_ type: Tag.Reference) -> Publishers.Filter<Self> {
        filter([type])
    }

    public func filter(_ types: some Sequence<Tag>) -> Publishers.Filter<Self> {
        filter { $0.tag.is(types) }
    }

    public func filter(_ types: some Sequence<Tag.Reference>) -> Publishers.Filter<Self> {
        filter { event in
            types.contains { type in
                if event.reference == type { return true }
                guard event.tag.is(type.tag) else { return false }
                return type.indices.allSatisfy { event.reference.indices[$0] == $1 }
                    && type.context.allSatisfy { event.reference.context[$0] == $1 }
            }
        }
    }
}

extension AppProtocol {

    @inlinable public func on(
        _ first: Tag.Event,
        _ rest: Tag.Event...,
        file: String = #fileID,
        line: Int = #line,
        action: @escaping (Session.Event) throws -> Void = { _ in }
    ) -> BlockchainEventSubscription {
        on([first] + rest, file: file, line: line, action: action)
    }

    @inlinable public func on(
        _ first: Tag.Event,
        _ rest: Tag.Event...,
        file: String = #fileID,
        line: Int = #line,
        priority: TaskPriority? = nil,
        action: @escaping (Session.Event) async throws -> Void = { _ in }
    ) -> BlockchainEventSubscription {
        on([first] + rest, file: file, line: line, priority: priority, action: action)
    }

    @inlinable public func on<Events>(
        _ events: Events,
        file: String = #fileID,
        line: Int = #line,
        action: @escaping (Session.Event) throws -> Void = { _ in }
    ) -> BlockchainEventSubscription where Events: Sequence, Events.Element: Tag.Event {
        on(events.map { $0 as Tag.Event }, file: file, line: line, action: action)
    }

    @inlinable public func on<Events>(
        _ events: Events,
        file: String = #fileID,
        line: Int = #line,
        priority: TaskPriority? = nil,
        action: @escaping (Session.Event) async throws -> Void = { _ in }
    ) -> BlockchainEventSubscription where Events: Sequence, Events.Element: Tag.Event {
        on(events.map { $0 as Tag.Event }, file: file, line: line, priority: priority, action: action)
    }

    @inlinable public func on(
        _ events: some Sequence<Tag.Event>,
        file: String = #fileID,
        line: Int = #line,
        action: @escaping (Session.Event) throws -> Void = { _ in }
    ) -> BlockchainEventSubscription {
        BlockchainEventSubscription(
            app: self,
            events: Array(events),
            file: file,
            line: line,
            action: action
        )
    }

    @inlinable public func on(
        _ events: some Sequence<Tag.Event>,
        file: String = #fileID,
        line: Int = #line,
        priority: TaskPriority? = nil,
        action: @escaping (Session.Event) async throws -> Void = { _ in }
    ) -> BlockchainEventSubscription {
        BlockchainEventSubscription(
            app: self,
            events: Array(events),
            file: file,
            line: line,
            priority: priority,
            action: action
        )
    }
}

public final class BlockchainEventSubscription: Hashable {

    private var lock: UnfairLock = UnfairLock()

    private var _count: Int = 0
    public private(set) var count: Int {
        get { lock.withLock { _count } }
        set { lock.withLock { _count = newValue } }
    }

    enum Action {
        case sync((Session.Event) throws -> Void)
        case async((Session.Event) async throws -> Void)
    }

    let id: UInt
    let app: AppProtocol
    let events: [Tag.Event]
    let action: Action
    let priority: TaskPriority?

    let file: String, line: Int

    deinit { stop() }

    @usableFromInline init(
        app: AppProtocol,
        events: [Tag.Event],
        file: String,
        line: Int,
        action: @escaping (Session.Event) throws -> Void
    ) {
        self.id = Self.id
        self.app = app
        self.events = events
        self.file = file
        self.line = line
        self.priority = nil
        self.action = .sync(action)
    }

    @usableFromInline init(
        app: AppProtocol,
        events: [Tag.Event],
        file: String,
        line: Int,
        priority: TaskPriority? = nil,
        action: @escaping (Session.Event) async throws -> Void
    ) {
        self.id = Self.id
        self.app = app
        self.events = events
        self.file = file
        self.line = line
        self.priority = priority
        self.action = .async(action)
    }

    private var subscription: AnyCancellable?

    @discardableResult
    public func start() -> Self {
        guard subscription == nil else { return self }
        subscription = app.on(events).handleEvents(receiveOutput: { [weak self] _ in self?.count += 1 }).sink(
            receiveValue: { [weak self] event in
                guard let self else { return }
                switch action {
                case .sync(let action):
                    do {
                        try action(event)
                    } catch {
                        app.post(error: error, file: file, line: line)
                    }
                case .async(let action):
                    Task(priority: priority) {
                        do {
                            try await action(event)
                        } catch {
                            self.app.post(error: error, file: self.file, line: self.line)
                        }
                    }
                }
            }
        )
        return self
    }

    public func cancel() {
        stop()
    }

    @discardableResult
    public func stop() -> Self {
        subscription?.cancel()
        subscription = nil
        return self
    }
}

extension BlockchainEventSubscription {

    @inlinable public func subscribe() -> AnyCancellable {
        start()
        return AnyCancellable { [self] in stop() }
    }

    @inlinable public func store(in set: inout Set<AnyCancellable>) {
        subscribe().store(in: &set)
    }

    @inlinable public func store<C>(in collection: inout C) where C: RangeReplaceableCollection, C.Element == AnyCancellable {
        subscribe().store(in: &collection)
    }

    private static var count: UInt = 0
    private static let lock = NSLock()
    private static var id: UInt {
        lock.lock()
        defer { lock.unlock() }
        count += 1
        return count
    }

    public static func == (lhs: BlockchainEventSubscription, rhs: BlockchainEventSubscription) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
