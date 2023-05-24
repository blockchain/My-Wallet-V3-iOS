import Extensions
#if canImport(SwiftUI)
import SwiftUI
#endif

protocol BindingsProtocol: AnyObject {
    var app: AppProtocol? { get }
    var context: Tag.Context { get }
    func didUpdate(_ binding: Bindings.Binding)
}

public class Bindings: BindingsProtocol {

    public enum Update {
        case request(Set<Bindings.Binding>)
        case updateError(Bindings.Binding, Error)
        case update(Bindings.Binding)
        case didSynchronize(Set<Bindings.Binding>)
    }

    private(set) weak var app: AppProtocol?
    public let context: Tag.Context
    private(set) var bindings: Set<Bindings.Binding> = []

    public let onSynchronization = AsyncStream<Void>.streamWithContinuation()

    public private(set) var isSynchronized: Bool = true

    var handle: ((Update) -> Void)?
    public internal(set) var depth = -1

    init(
        app: AppProtocol?,
        context: Tag.Context,
        handle: ((Update) -> Void)?
    ) {
        self.app = app
        self.context = context
        self.handle = handle
    }
}

extension Bindings {

    public var isEmpty: Bool { bindings.isEmpty }
    public var isNotEmpty: Bool { !isEmpty }

    public var recursiveBindings: Set<Bindings.Binding> {
        bindings.union(bindings.flatMap(\.recursiveBindings))
    }

    @discardableResult
    public func request() -> Self {
        for binding in bindings { binding.request() }
        handle?(.request(bindings))
        return self
    }

    public func unsubscribe() {
        for binding in bindings { binding.unsubscribe() }
    }

    func didUpdate(_ binding: Bindings.Binding) {
        if depth < 0 && binding.hasTransactionChanges { return }
        if case .failure(let error, _) = binding.result { handle?(.updateError(binding, error)) }
        if isSynchronized, binding.result.isSynchronized { apply(binding) }
        if !isSynchronized, bindings.allSatisfy(\.result.isSynchronized) { applyAll() }
    }

    func insert(_ binding: Bindings.Binding?) {
        guard let binding = binding else { return }
        isSynchronized = false
        bindings.remove(binding)
        bindings.insert(binding)
    }

    func remove(_ binding: Bindings.Binding?) {
        guard let binding = binding else { return }
        bindings.remove(binding)
    }

    func apply(_ binding: Bindings.Binding) {
        binding.apply()
        handle?(.update(binding))
    }

    func applyAll() {
        for binding in bindings { binding.apply() }
        isSynchronized = true
        handle?(.didSynchronize(bindings))
        onSynchronization.continuation.yield()
    }
}

extension Bindings.Update: CustomStringConvertible {

    public var description: String {
        switch self {
        case .request(let set):
            return "request(\(set))"
        case .updateError(let binding, let error):
            return "updateError(\(binding.reference), \(error))"
        case .update(let binding):
            return "update(\(binding.reference)"
        case .didSynchronize(let set):
            return "didSynchronize(\(set))"
        }
    }

    var depth: Int? {
        switch self {
        case .request: return nil
        case .updateError(let binding, _), .update(let binding): return binding.depth
        case .didSynchronize(let bindings): return bindings.first?.depth
        }
    }
}

extension Bindings {

    @discardableResult
    public func subscribe<Property: Decodable & Equatable>(to event: Tag.Event, ofType: Property.Type) -> Self {
        insert(Bindings.Binding(self, to: event.key(to: context), subscribed: true, as: Property.self))
        return self
    }

    @discardableResult
    public func set<Property: Decodable & Equatable>(to event: Tag.Event, ofType: Property.Type) -> Self {
        insert(Bindings.Binding(self, to: event.key(to: context), subscribed: false, as: Property.self))
        return self
    }

    @discardableResult
    public func subscribe<Property: Decodable & Equatable>(_ property: SwiftUI.Binding<Property>, to event: Tag.Event) -> Self {
        insert(bind(property, to: event, subscribed: true))
        return self
    }

    @discardableResult
    public func set<Property: Decodable & Equatable>(_ property: SwiftUI.Binding<Property>, to event: Tag.Event) -> Self {
        insert(bind(property, to: event, subscribed: false))
        return self
    }

    func bind<Property: Decodable & Equatable>(_ binding: SwiftUI.Binding<Property>, to event: Tag.Event, subscribed: Bool) -> Bindings.Binding {
        Bindings.Binding(self, binding: binding, to: event.key(to: context), subscribed: subscribed)
    }

    public struct ToObject<Object: AnyObject> {
        var _bindings: Bindings
        weak var object: Object?
    }

    public func object<Object: AnyObject>(_ object: Object) -> ToObject<Object> {
        ToObject(_bindings: self, object: object)
    }

    @discardableResult
    public func _printChanges(_ emoji: String = "🧿") -> Self {
        let handle = handle
        self.handle = { update in
            update.peek(emoji)
            handle?(update)
        }
        return self
    }
}

extension Bindings.ToObject {

    @discardableResult
    public func subscribe<Property: Decodable & Equatable>(_ property: ReferenceWritableKeyPath<Object, Property>, to event: Tag.Event) -> Self {
        _bindings.insert(bind(property, to: event, subscribed: true))
        return self
    }

    @discardableResult
    public func set<Property: Decodable & Equatable>(_ property: ReferenceWritableKeyPath<Object, Property>, to event: Tag.Event) -> Self {
        _bindings.insert(bind(property, to: event, subscribed: false))
        return self
    }

    @discardableResult
    public func subscribe(_ property: ReferenceWritableKeyPath<Object, Any>, to event: Tag.Event) -> Self {
        _bindings.insert(bind(property, to: event, subscribed: true))
        return self
    }

    @discardableResult
    public func set(_ property: ReferenceWritableKeyPath<Object, Any>, to event: Tag.Event) -> Self {
        _bindings.insert(bind(property, to: event, subscribed: false))
        return self
    }

    func bind<Property: Decodable & Equatable>(_ property: ReferenceWritableKeyPath<Object, Property>, to event: Tag.Event, subscribed: Bool) -> Bindings.Binding {
        Bindings.Binding(_bindings, reference: event.key(to: _bindings.context), to: object, property)
    }

    func bind(_ property: ReferenceWritableKeyPath<Object, Any>, to event: Tag.Event, subscribed: Bool) -> Bindings.Binding {
        Bindings.Binding(_bindings, reference: event.key(to: _bindings.context), to: object, property)
    }

    @discardableResult
    public func request() -> Self {
        _ = _bindings.request()
        return self
    }

    public func unsubscribe() {
        _bindings.unsubscribe()
    }

    @discardableResult
    public func _printChanges(_ emoji: String = "🧿") -> Self {
        _bindings._printChanges(emoji)
        return self
    }

    @discardableResult
    public func bindings() -> Bindings { _bindings }
}
