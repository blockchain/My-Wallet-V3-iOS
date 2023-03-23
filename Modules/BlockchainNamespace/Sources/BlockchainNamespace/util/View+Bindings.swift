#if canImport(SwiftUI)

import Extensions
import SwiftUI

public typealias NamespaceBinding = Pair<Tag.EventHashable, SetValueBinding>

extension View {

    @warn_unqualified_access public func bindings(
        managing updateManager: ((BindingsUpdate) -> Void)? = nil,
        @SetBuilder<NamespaceBinding> _ bindings: () -> Set<NamespaceBinding>,
        file: String = #fileID,
        line: Int = #line
    ) -> some View {
        // swiftformat:disable:next redundantSelf
        self.bindings(managing: updateManager, bindings().set, file: file, line: line)
    }

    @warn_unqualified_access public func bindings(
        managing updateManager: ((BindingsUpdate) -> Void)? = nil,
        _ bindings: Set<NamespaceBinding>,
        file: String = #fileID,
        line: Int = #line
    ) -> some View {
        modifier(BindingsSubscriptionModifier(bindings: bindings, update: updateManager, source: (file, line)))
    }
}

public enum BindingsUpdate {
    case indexingError(Tag, Tag.Indexing.Error)
    case updateError(Tag.Reference, Error)
    case synchronizationError(bindings: [Tag.Reference], errors: [(reference: Tag.Reference, error: Error)])
    case didUpdate(Tag.Reference)
    case didSynchronize(Set<Tag.Reference>)
}

@MainActor
@usableFromInline struct BindingsSubscriptionModifier: ViewModifier {

    typealias SubscriptionBinding = Pair<Tag.Reference, SetValueBinding>

    @BlockchainApp var app
    @Environment(\.context) var context

    let bindings: Set<Pair<Tag.EventHashable, SetValueBinding>>
    let update: ((BindingsUpdate) -> Void)?
    let source: (file: String, line: Int)

    @State private var sets: [Tag.Reference: FetchResult] = [:]
    @State private var isSynchronized: Bool = false
    @State private var subscription: AnyCancellable? {
        didSet { oldValue?.cancel() }
    }

    func makeKeys(_ bindings: Set<Pair<Tag.EventHashable, SetValueBinding>>) -> Set<SubscriptionBinding> {
        bindings.map { binding in
            binding.mapLeft { event in event.key(to: context) }
        }.set
    }

    @usableFromInline func body(content: Content) -> some View {
        content.onChange(of: bindings) { newValue in
            subscribe(to: makeKeys(newValue))
        }
        .onAppear {
            subscribe(to: makeKeys(bindings))
        }
        .onDisappear {
            subscription = nil
        }
    }

    func subscribe(to keys: Set<SubscriptionBinding>) {
        if keys.isEmpty {
            isSynchronized = true
            sets.removeAll()
        }
        let subscriptions: [AnyPublisher<(FetchResult, SubscriptionBinding), Never>] = keys.map { binding -> AnyPublisher<(FetchResult, SubscriptionBinding), Never> in
            let reference = binding.left.in(app)
            let publisher = app.publisher(for: reference)
                .receive(on: DispatchQueue.main)
                .handleEvents(receiveOutput: { result in
                    switch result {
                    case .error(.other(let error as Tag.Indexing.Error), let metadata):
                        update?(.indexingError(metadata.ref.tag, error))
                    default:
                        break
                    }
                })
                .map { ($0, binding) }
            if binding.right.subscribed {
                return publisher.eraseToAnyPublisher()
            } else if let cache = sets[reference] {
                return Just((cache, binding)).eraseToAnyPublisher()
            } else {
                return publisher.first().handleEvents(
                    receiveOutput: { result, _ in sets[reference] = result }
                ).eraseToAnyPublisher()
            }
        }

        subscription = subscriptions
            .combineLatest()
            .sink { bindings in
                let results = bindings.map { value, binding in
                    Result<(Tag.Reference, () -> Void), Error>(catching: { try (value.metadata.ref, binding.right.set(value)) })
                        .mapError { error in _BindingError(reference: value.metadata.ref, source: error) }
                }
                if !isSynchronized, case let errors = results.compactMap(\.failure), errors.isNotEmpty {
                    update?(.synchronizationError(bindings: results.map(\.reference), errors: errors.map(\.tuple)))
                } else {
                    var synchronized: Set<Tag.Reference> = []
                    for result in results {
                        switch result {
                        case .success((let reference, let fire)):
                            fire()
                            if isSynchronized {
                                update?(.didUpdate(reference))
                            } else {
                                synchronized.insert(reference)
                            }
                        case .failure(let error) where isSynchronized:
                            update?(.updateError(error.reference, error.source))
                        default:
                            break
                        }
                    }
                    if !isSynchronized {
                        isSynchronized = true
                        update?(.didSynchronize(synchronized))
                    }
                }
            }
    }
}

private struct _BindingError: Error {
    let reference: Tag.Reference
    let source: Error
    var tuple: (Tag.Reference, Error) { (reference, source) }
}

extension Result<(Tag.Reference, () -> Void), _BindingError> {

    var reference: Tag.Reference {
        switch self {
        case .success((let reference, _)): return reference
        case .failure(let failure): return failure.reference
        }
    }
}

public struct SetValueBinding: Hashable {

    let id: String
    let set: (FetchResult) throws -> () -> Void
    let subscribed: Bool

    public static func == (lhs: Self, rhs: Self) -> Bool { lhs.id == rhs.id }
    public func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

extension SetValueBinding {

    public init<T>(_ binding: Binding<T>, subscribed: Bool = true, event: Tag.Event, file: String, line: Int) {
        self.id = "\(event)@\(file):\(line)"
        self.set = { newValue in
            let value = try (newValue.value as? T).or(throw: "\(String(describing: newValue.value)) is not type \(T.self)")
            return { binding.wrappedValue = value }
        }
        self.subscribed = subscribed
    }

    public init<T: Decodable>(_ binding: Binding<T>, subscribed: Bool = true, event: Tag.Event, file: String, line: Int) {
        self.id = "\(event)@\(file):\(line)"
        self.set = { newValue in
            let value = try newValue.decode(T.self).get()
            return { binding.wrappedValue = value }
        }
        self.subscribed = subscribed
    }

    public init<T: Equatable & Decodable>(_ binding: Binding<T>, subscribed: Bool = true, event: Tag.Event, file: String, line: Int) {
        self.id = "\(event)@\(file):\(line)"
        self.set = { newValue in
            let newValue = try newValue.decode(T.self).get()
            guard newValue != binding.wrappedValue else {
                return { /* ignore, values are equal */ }
            }
            return { binding.wrappedValue = newValue }
        }
        self.subscribed = subscribed
    }

    public init<T: Equatable & Decodable & OptionalProtocol>(_ binding: Binding<T>, subscribed: Bool = true, event: Tag.Event, file: String, line: Int) {
        self.id = "\(event)@\(file):\(line)"
        self.set = { newValue in
            do {
                let newValue = try newValue.decode(T.self).get()
                guard newValue != binding.wrappedValue else {
                    return { /* ignore, values are equal */ }
                }
                return { binding.wrappedValue = newValue }
            } catch {
                return { binding.wrappedValue = .none }
            }
        }
        self.subscribed = subscribed
    }
}

public func subscribe(
    _ binding: Binding<some Any>,
    to event: Tag.Event,
    file: String = #fileID,
    line: Int = #line
) -> Pair<Tag.EventHashable, SetValueBinding> {
    Pair(event, SetValueBinding(binding, event: event, file: file, line: line))
}

public func set(
    _ binding: Binding<some Any>,
    to event: Tag.Event,
    file: String = #fileID,
    line: Int = #line
) -> Pair<Tag.EventHashable, SetValueBinding> {
    Pair(event, SetValueBinding(binding, subscribed: false, event: event, file: file, line: line))
}

public func subscribe(
    _ binding: Binding<some Decodable>,
    to event: Tag.Event,
    file: String = #fileID,
    line: Int = #line
) -> Pair<Tag.EventHashable, SetValueBinding> {
    Pair(event, SetValueBinding(binding, event: event, file: file, line: line))
}

public func set(
    _ binding: Binding<some Decodable>,
    to event: Tag.Event,
    file: String = #fileID,
    line: Int = #line
) -> Pair<Tag.EventHashable, SetValueBinding> {
    Pair(event, SetValueBinding(binding, subscribed: false, event: event, file: file, line: line))
}

public func subscribe(
    _ binding: Binding<some Equatable & Decodable>,
    to event: Tag.Event,
    file: String = #fileID,
    line: Int = #line
) -> Pair<Tag.EventHashable, SetValueBinding> {
    Pair(event, SetValueBinding(binding, event: event, file: file, line: line))
}

public func set(
    _ binding: Binding<some Equatable & Decodable>,
    to event: Tag.Event,
    file: String = #fileID,
    line: Int = #line
) -> Pair<Tag.EventHashable, SetValueBinding> {
    Pair(event, SetValueBinding(binding, subscribed: false, event: event, file: file, line: line))
}

public func subscribe(
    _ binding: Binding<some Equatable & Decodable & OptionalProtocol>,
    to event: Tag.Event,
    file: String = #fileID,
    line: Int = #line
) -> Pair<Tag.EventHashable, SetValueBinding> {
    Pair(event, SetValueBinding(binding, event: event, file: file, line: line))
}

public func set(
    _ binding: Binding<some Equatable & Decodable & OptionalProtocol>,
    to event: Tag.Event,
    file: String = #fileID,
    line: Int = #line
) -> Pair<Tag.EventHashable, SetValueBinding> {
    Pair(event, SetValueBinding(binding, subscribed: false, event: event, file: file, line: line))
}

extension Pair<Tag.EventHashable, SetValueBinding> {

    init(_ event: Tag.Event, _ binding: SetValueBinding) {
        self.init(event.hashable(), binding)
    }
}

#endif
