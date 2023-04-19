// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

#if os(iOS)

@available(iOS, deprecated: 15.0, message: "Backport is only useful when targeting iOS versions earlier than 15")
extension View {

    /// Attach an async task to this view, which will be performed
    /// when the view first appears, and cancelled if the view
    /// disappears (or is removed from the view hierarchy).
    /// - parameter priority: Any explicit priority that the async
    ///   task should have.
    /// - parameter action: The async action that the task should run.
    @_disfavoredOverload
    public func task(
        priority: TaskPriority = .userInitiated,
        _ action: @escaping () async -> Void
    ) -> some View {
        task(id: #function, priority: priority, action)
    }

    /// Adds a task to perform when this view appears or when a specified value changes.
    ///
    /// - parameter id: The value to observe for changes. The value must conform to the Equatable protocol.
    /// - parameter priority: Any explicit priority that the async
    ///   task should have.
    /// - parameter action: The async action that the task should run.
    @_disfavoredOverload
    public func task(
        id: some Equatable,
        priority: TaskPriority = .userInitiated,
        _ action: @escaping () async -> Void
    ) -> some View {
        modifier(
            TaskModifier(
                id: id,
                priority: priority,
                action: action
            )
        )
    }
}

private struct TaskModifier<Value: Equatable>: ViewModifier {

    var id: Value
    var priority: TaskPriority
    var action: () async -> Void

    @State private var task: Task<Void, Never>? {
        didSet { oldValue?.cancel() }
    }

    func body(content: Content) -> some View {
        content
            .preference(key: TaskIDPreferenceKey<Value>.self, value: id)
            .onPreferenceChange(TaskIDPreferenceKey<Value>.self) { _ in run() }
            .onAppear { run() }
            .onDisappear { task = nil }
    }

    private func run() {
        task = Task(priority: priority) {
            await action()
        }
    }
}

private struct TaskIDPreferenceKey<Value: Equatable>: PreferenceKey {
    static var defaultValue: Value { fatalError("No Default") }
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = nextValue()
    }
}
#endif
