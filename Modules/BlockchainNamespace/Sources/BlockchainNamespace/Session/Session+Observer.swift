import Combine

extension Session {

    public struct Observer: Hashable, Codable {

        public struct Event: Hashable, Codable {
            public let tag: Tag.Reference
            public let binding: Bool?
            public let notification: Bool?
            public let context: [String: String]?
        }

        public class Value {

            let didChange: (AnyJSON?) -> Void

            public internal(set) var current: FetchResult.Value<AnyJSON>? {
                didSet {
                    if case .error(FetchResult.Error.keyDoesNotExist, _) = current { return }
                    guard oldValue?.value != current?.value else { return }
                    didChange(current?.value)
                }
            }

            var bindings: AnyCancellable?

            init(_ value: FetchResult.Value<AnyJSON>?, handler: @escaping (AnyJSON?) -> Void) {
                self.current = value
                self.didChange = handler
            }
        }

        public let event: Event
        public let action: Tag.Reference
    }

    public class Observers {

        public typealias Event = Observer.Event
        public typealias Value = Observer.Value

        private weak var app: AppProtocol?

        private var subscription: AnyCancellable?

        private var events: [Observer: BlockchainEventSubscription] = [:]
        private var bindings: [Observer: Value] = [:]

        public fileprivate(set) var list: Set<Observer> = [] {
            didSet {
                for binding in list.filter(\.event.is.binding) {
                    let context = Tag.Context(binding.event.context?.compactMapKeys(\.tagReference) ?? [:])
                    let value = Value(bindings[binding]?.current) { [weak self] value in
                        guard let self else { return }
                        app?.post(event: binding.action.ref(to: context), context: [binding.event.tag: value])
                    }
                    bindings[binding] = value
                    value.bindings = app?.publisher(for: binding.event.tag.ref(to: context))
                        .assign(to: \.current, on: value)
                }

                let (added, removed) = list.diff(from: events.keys)

                for added in added.filter(\.event.is.notification) {
                    let context = Tag.Context(added.event.context?.compactMapKeys(\.tagReference) ?? [:])
                    events[added] = app?.on(added.event.tag) { [weak self] event in
                        guard let self else { return }
                        app?.post(event: added.action.ref(to: context), context: event.context + context)
                    }
                    .start()
                }

                for removed in removed {
                    if removed.event.is.notification { events.removeValue(forKey: removed)?.stop() }
                    if removed.event.is.binding { bindings.removeValue(forKey: removed) }
                }
            }
        }

        init(app: AppProtocol) {
            self.app = app
        }

        deinit { clear() }

        func clear() {
            subscription = nil
            list = []
        }

        func reset() {
            clear()
            subscribe()
        }

        func subscribe() {
            subscription = app?.publisher(for: blockchain.session.state.observers)
                .assign(to: \.list, on: self)
        }
    }
}

extension Session.Observer.Event {

    public var `is`: (notification: Bool, binding: Bool) {
        (notification ?? false, binding ?? false)
    }
}

public protocol ClientObserver: AnyObject, CustomStringConvertible {
    func start()
    func stop()
}

public enum Client {}

extension Client {

    public typealias Observer = ClientObserver

    public class Observers {

        var observers: Set<AnyHashable> = []

        public func insert(_ observer: some Observer) {
            let (inserted, _) = observers.insert(AnyHashable(Box(observer)))
            guard inserted else { return }
            observer.start()
        }

        public func remove<O: Observer>(_ observer: O) {
            (observers.remove(AnyHashable(Box(observer))) as? Box<O>)?.value?.stop()
        }
    }
}

extension ClientObserver {

    public var description: String { "\(type(of: self))" }
}

private struct Box<Wrapped: AnyObject> {
    var value: Wrapped?
    init(_ value: Wrapped? = nil) {
        self.value = value
    }
}

extension Box: Equatable {

    static func == (lhs: Box, rhs: Box) -> Bool {
        guard let lhs = lhs.value, let rhs = rhs.value else {
            return lhs.value == nil && rhs.value == nil
        }
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
}

extension Box: Hashable {

    func hash(into hasher: inout Hasher) {
        guard let value else { return }
        hasher.combine(ObjectIdentifier(value))
    }
}
