#if canImport(SwiftUI)

import Extensions
import SwiftUI

public typealias NamespaceBinding = Pair<Tag.EventHashable, SetValueBinding>

extension View {

    @warn_unqualified_access public func bindings(
        managing updateManager: ((Bindings.Update) -> Void)? = nil, // Bindings._printChanges("⚠️")
        @SetBuilder<NamespaceBinding> _ subscriptions: () -> Set<NamespaceBinding>,
        file: String = #fileID,
        line: Int = #line
    ) -> some View {
        // swiftformat:disable:next redundantSelf
        self.bindings(managing: updateManager, subscriptions().set, file: file, line: line)
    }

    @warn_unqualified_access public func bindings(
        managing updateManager: ((Bindings.Update) -> Void)? = nil, // Bindings._printChanges("⚠️")
        _ subscriptions: Set<NamespaceBinding>,
        file: String = #fileID,
        line: Int = #line
    ) -> some View {
        modifier(BindingsSubscriptionModifier(subscriptions: subscriptions, updateManager: updateManager, source: (file, line)))
    }
}

extension Bindings {

    @inlinable public static func _printChanges(_ emoji: String) -> (_ change: Bindings.Update) -> Void {
        { Swift.print(emoji, $0) }
    }
}

@MainActor
@usableFromInline struct BindingsSubscriptionModifier: ViewModifier {

    @BlockchainApp var app
    @Environment(\.context) var context

    let subscriptions: Set<NamespaceBinding>
    let updateManager: ((Bindings.Update) -> Void)?
    let source: (file: String, line: Int)

    @State private var bindings: Bindings! {
        didSet { oldValue?.unsubscribe() }
    }

    @usableFromInline func body(content: Content) -> some View {
        content
            .onChange(of: subscriptions) { [subscriptions] newValue in subscribe(to: newValue, oldValue: subscriptions) }
            .onAppear { subscribe(to: subscriptions, oldValue: []) }
            .onDisappear { bindings = nil }
    }

    func subscribe(to keys: Set<NamespaceBinding>, oldValue: Set<NamespaceBinding>) {
        if bindings.isNil || bindings?.context != context {
            bindings = app.binding(.async, to: context, managing: updateManager)
            for key in keys { bindings.insert(key.right.binding(bindings)) }
        } else {
            let (new, old) = keys.diff(from: oldValue)
            for key in old { bindings.remove(key.right.binding(bindings)) }
            for key in new { bindings.insert(key.right.binding(bindings)) }
        }
        bindings.request()
    }
}

public struct SetValueBinding: Hashable {

    let id: String
    let binding: (Bindings) -> Bindings.Binding
    let subscribed: Bool

    public static func == (lhs: Self, rhs: Self) -> Bool { lhs.id == rhs.id }
    public func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

extension SetValueBinding {

    public init<T: Equatable & Decodable>(_ binding: Binding<T>, subscribed: Bool = true, event: Tag.Event, file: String, line: Int) {
        self.id = "\(event)@\(file):\(line)"
        self.binding = { bindings in
            bindings.bind(binding, to: event, subscribed: subscribed)
        }
        self.subscribed = subscribed
    }

    public init<T: Equatable & Decodable, U: Equatable & Decodable>(_ binding: Binding<T>, subscribed: Bool = true, as map: @escaping (U) -> T, event: Tag.Event, file: String, line: Int) {
        self.id = "\(event)@\(file):\(line)"
        self.binding = { bindings in
            bindings.bind(binding, to: event, subscribed: subscribed, map: map)
        }
        self.subscribed = subscribed
    }
}

public func subscribe(
    _ binding: Binding<some Equatable & Decodable>,
    to event: Tag.Event,
    file: String = #fileID,
    line: Int = #line
) -> NamespaceBinding {
    Pair(event, SetValueBinding(binding, event: event, file: file, line: line))
}

public func subscribe<T: Equatable & Decodable, U: Equatable & Decodable>(
    _ binding: Binding<T>,
    to event: Tag.Event,
    as map: @escaping (U) -> T,
    file: String = #fileID,
    line: Int = #line
) -> NamespaceBinding {
    Pair(event, SetValueBinding(binding, as: map, event: event, file: file, line: line))
}

public func set(
    _ binding: Binding<some Equatable & Decodable>,
    to event: Tag.Event,
    file: String = #fileID,
    line: Int = #line
) -> NamespaceBinding {
    Pair(event, SetValueBinding(binding, subscribed: false, event: event, file: file, line: line))
}

extension NamespaceBinding {
    init(_ event: Tag.Event, _ binding: SetValueBinding) { self.init(event.hashable(), binding) }
}

#endif

struct WithBinding<T: Decodable & Equatable, Content: View, Failure: View, Placeholder: View>: View {

    var event: Tag.Event
    var type: T.Type = T.self
    var content: (T) throws -> Content
    var placeholder: () -> Placeholder
    var failure: (Error) -> Failure
    var updateManager: ((Bindings.Update) -> Void)?

    @State private var isSynchronized = false
    @State private var data: T?

    var body: some View {
        Group {
            Do {
                if let data {
                    try content(data)
                } else if isSynchronized {
                    throw "Did synchronize, but no data"
                } else {
                    placeholder()
                }
            } catch: { e in
                failure(e)
            }
        }
        .bindings(managing: update) {
            subscribe($data, to: event)
        }
    }

    func update(_ update: Bindings.Update) {
        if case .didSynchronize = update {
            isSynchronized = true
        }
        updateManager?(update)
    }
}

public func withBinding<T: Decodable & Equatable>(
    to event: Tag.Event,
    as type: T.Type = T.self,
    managing updateManager: ((Bindings.Update) -> Void)? = nil,
    @ViewBuilder content: @escaping (T) throws -> some View,
    @ViewBuilder placeholder: @escaping () -> some View = { ProgressView() },
    @ViewBuilder failure: @escaping (Error) -> some View = EmptyView.init(ignored:)
) -> some View {
    WithBinding(event: event, type: type, content: content, placeholder: placeholder, failure: failure, updateManager: updateManager)
}
