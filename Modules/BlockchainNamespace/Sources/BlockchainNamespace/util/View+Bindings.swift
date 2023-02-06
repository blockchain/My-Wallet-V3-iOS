#if canImport(SwiftUI)

import Extensions
import SwiftUI

extension View {

    @warn_unqualified_access public func binding(
        _ bindings: Pair<Tag.Event, SetValueBinding>...,
        file: String = #file,
        line: Int = #line
    ) -> some View {
        modifier(BindingsSubscriptionModifier(bindings: bindings, source: (file, line)))
    }

    @warn_unqualified_access public func subscribe(
        _ binding: Binding<some Equatable & Decodable>,
        to tag: Tag.Event,
        file: String = #file,
        line: Int = #line
    ) -> some View {
        self.binding(.subscribe(binding, to: tag))
    }
}

@usableFromInline struct BindingsSubscriptionModifier: ViewModifier {

    typealias Subscription = Pair<Tag.Reference, SetValueBinding>

    @BlockchainApp var app
    @Environment(\.context) var context

    let bindings: [Pair<Tag.Event, SetValueBinding>]
    let source: (file: String, line: Int)

    var keys: [Subscription] {
        bindings.map { binding in
            binding.mapLeft { event in event.key(to: context) }
        }
    }

    @State private var subscription: AnyCancellable? {
        didSet { oldValue?.cancel() }
    }

    @usableFromInline func body(content: Content) -> some View {
        content.onChange(of: keys) { keys in
            subscribe(to: keys)
        }
        .onAppear {
            subscribe(to: keys)
        }
        .onDisappear {
            subscription = nil
        }
    }

    func subscribe(to keys: [Subscription]) {
        subscription = keys.map { binding -> AnyPublisher<(FetchResult, Subscription), Never> in
            let publisher = app.publisher(for: binding.left.in(app)).map { ($0, binding) }
            if binding.right.subscribed {
                return publisher.eraseToAnyPublisher()
            } else {
                return publisher.first().eraseToAnyPublisher()
            }
        }
        .combineLatest()
        .receive(on: DispatchQueue.main)
        .sink { bindings in
            for (value, binding) in bindings {
                binding.right.set(value)
            }
        }
    }
}

public struct SetValueBinding: Hashable {

    private static var count: UInt = 0
    private static let lock = NSLock()
    private static var id: UInt {
        lock.lock()
        defer { lock.unlock() }
        count += 1
        return count
    }

    let id: UInt
    let set: (FetchResult) -> Void
    let subscribed: Bool

    public static func == (lhs: Self, rhs: Self) -> Bool { lhs.id == rhs.id }
    public func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

extension SetValueBinding {

    public init<T>(_ binding: Binding<T>, subscribed: Bool = true) {
        self.id = Self.id
        self.set = { newValue in
            guard let newValue = newValue.value as? T else { return }
            binding.wrappedValue = newValue
        }
        self.subscribed = subscribed
    }

    public init<T: Decodable>(_ binding: Binding<T>, subscribed: Bool = true) {
        self.id = Self.id
        self.set = { newValue in
            guard let newValue = newValue.decode(T.self).value else { return }
            binding.wrappedValue = newValue
        }
        self.subscribed = subscribed
    }

    public init<T: Equatable & Decodable>(_ binding: Binding<T>, subscribed: Bool = true) {
        self.id = Self.id
        self.set = { newValue in
            guard let newValue = newValue.decode(T.self).value else { return }
            guard newValue != binding.wrappedValue else { return }
            binding.wrappedValue = newValue
        }
        self.subscribed = subscribed
    }

    public init<T: Equatable & Decodable & OptionalProtocol>(_ binding: Binding<T>, subscribed: Bool = true) {
        self.id = Self.id
        self.set = { newValue in
            let newValue = newValue.decode(T.self).value ?? .none
            guard newValue != binding.wrappedValue else { return }
            binding.wrappedValue = newValue
        }
        self.subscribed = subscribed
    }

    public init<Root: AnyObject, Value>(
        _ keyPath: ReferenceWritableKeyPath<Root, Value>,
        on root: Root,
        subscribed: Bool = true
    ) {
        self.id = Self.id
        self.set = { [weak root] newValue in
            guard let root else { return }
            guard let newValue = newValue.value as? Value else { return }
            root[keyPath: keyPath] = newValue
        }
        self.subscribed = subscribed
    }

    public init<Root: AnyObject, Value: Decodable>(
        _ keyPath: ReferenceWritableKeyPath<Root, Value>,
        on root: Root,
        subscribed: Bool = true
    ) {
        self.id = Self.id
        self.set = { [weak root] newValue in
            guard let root else { return }
            guard let newValue = newValue.decode(Value.self).value else { return }
            root[keyPath: keyPath] = newValue
        }
        self.subscribed = subscribed
    }

    public init<Root: AnyObject, Value: Equatable & Decodable>(
        _ keyPath: ReferenceWritableKeyPath<Root, Value>,
        on root: Root,
        subscribed: Bool = true
    ) {
        self.id = Self.id
        self.set = { [weak root] newValue in
            guard let root else { return }
            guard let newValue = newValue.decode(Value.self).value else { return }
            guard newValue != root[keyPath: keyPath] else { return }
            root[keyPath: keyPath] = newValue
        }
        self.subscribed = subscribed
    }

    public init<Root: AnyObject, Value: Equatable & Decodable & OptionalProtocol>(
        _ keyPath: ReferenceWritableKeyPath<Root, Value>,
        on root: Root,
        subscribed: Bool = true
    ) {
        self.id = Self.id
        self.set = { [weak root] newValue in
            guard let root else { return }
            let newValue = newValue.decode(Value.self).value ?? .none
            guard newValue != root[keyPath: keyPath] else { return }
            root[keyPath: keyPath] = newValue
        }
        self.subscribed = subscribed
    }
}

extension Pair where T == Tag.Event, U == SetValueBinding {

    public static func subscribe(
        _ binding: Binding<some Any>,
        to event: Tag.Event
    ) -> Pair {
        Pair(event, SetValueBinding(binding))
    }

    public static func set(
        _ binding: Binding<some Any>,
        to event: Tag.Event
    ) -> Pair {
        Pair(event, SetValueBinding(binding, subscribed: false))
    }

    public static func subscribe(
        _ binding: Binding<some Decodable>,
        to event: Tag.Event
    ) -> Pair {
        Pair(event, SetValueBinding(binding))
    }

    public static func set(
        _ binding: Binding<some Decodable>,
        to event: Tag.Event
    ) -> Pair {
        Pair(event, SetValueBinding(binding, subscribed: false))
    }

    public static func subscribe(
        _ binding: Binding<some Equatable & Decodable>,
        to event: Tag.Event
    ) -> Pair {
        Pair(event, SetValueBinding(binding))
    }

    public static func set(
        _ binding: Binding<some Equatable & Decodable>,
        to event: Tag.Event
    ) -> Pair {
        Pair(event, SetValueBinding(binding, subscribed: false))
    }

    public static func subscribe(
        _ binding: Binding<some Equatable & Decodable & OptionalProtocol>,
        to event: Tag.Event
    ) -> Pair {
        Pair(event, SetValueBinding(binding))
    }

    public static func set(
        _ binding: Binding<some Equatable & Decodable & OptionalProtocol>,
        to event: Tag.Event
    ) -> Pair {
        Pair(event, SetValueBinding(binding, subscribed: false))
    }

    public static func subscribe<Root: AnyObject>(
        _ keyPath: ReferenceWritableKeyPath<Root, some Any>,
        to event: Tag.Event,
        on root: Root
    ) -> Pair {
        Pair(event, SetValueBinding(keyPath, on: root))
    }

    public static func set<Root: AnyObject>(
        _ keyPath: ReferenceWritableKeyPath<Root, some Any>,
        to event: Tag.Event,
        on root: Root
    ) -> Pair {
        Pair(event, SetValueBinding(keyPath, on: root, subscribed: false))
    }

    public static func subscribe<Root: AnyObject>(
        _ keyPath: ReferenceWritableKeyPath<Root, some Decodable>,
        to event: Tag.Event,
        on root: Root
    ) -> Pair {
        Pair(event, SetValueBinding(keyPath, on: root))
    }

    public static func set<Root: AnyObject>(
        _ keyPath: ReferenceWritableKeyPath<Root, some Decodable>,
        to event: Tag.Event,
        on root: Root
    ) -> Pair {
        Pair(event, SetValueBinding(keyPath, on: root, subscribed: false))
    }

    public static func subscribe<Root: AnyObject>(
        _ keyPath: ReferenceWritableKeyPath<Root, some Equatable & Decodable>,
        to event: Tag.Event,
        on root: Root
    ) -> Pair {
        Pair(event, SetValueBinding(keyPath, on: root))
    }

    public static func set<Root: AnyObject>(
        _ keyPath: ReferenceWritableKeyPath<Root, some Equatable & Decodable>,
        to event: Tag.Event,
        on root: Root
    ) -> Pair {
        Pair(event, SetValueBinding(keyPath, on: root, subscribed: false))
    }

    public static func subscribe<Root: AnyObject>(
        _ keyPath: ReferenceWritableKeyPath<Root, some Equatable & Decodable & OptionalProtocol>,
        to event: Tag.Event,
        on root: Root
    ) -> Pair {
        Pair(event, SetValueBinding(keyPath, on: root))
    }

    public static func set<Root: AnyObject>(
        _ keyPath: ReferenceWritableKeyPath<Root, some Equatable & Decodable & OptionalProtocol>,
        to event: Tag.Event,
        on root: Root
    ) -> Pair {
        Pair(event, SetValueBinding(keyPath, on: root, subscribed: false))
    }
}

#endif
