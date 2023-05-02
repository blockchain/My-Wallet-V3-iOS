#if canImport(SwiftUI)

import AnyCoding
import Extensions
import SwiftUI

public typealias ViewBatchUpdate = Pair<Tag.EventHashable, AnyJSON>

extension View {

    @warn_unqualified_access public func batch(
        @SetBuilder<ViewBatchUpdate> _ updates: () -> Set<ViewBatchUpdate>,
        file: String = #fileID,
        line: Int = #line
    ) -> some View {
        modifier(BatchUpdatesViewModifier(updates: updates(), source: (file, line)))
    }

    @warn_unqualified_access public func batch(
        _ updates: Set<ViewBatchUpdate>,
        file: String = #fileID,
        line: Int = #line
    ) -> some View {
        modifier(BatchUpdatesViewModifier(updates: updates, source: (file, line)))
    }
}

public struct BatchUpdatesViewModifier: ViewModifier {

    @BlockchainApp var app
    @Environment(\.context) var context

    let updates: Set<ViewBatchUpdate>
    let source: (file: String, line: Int)

    public func body(content: Content) -> some View {
        content
            .onChange(of: updates) { updates in
                batch(updates)
            }
            .onAppear {
                batch(updates)
            }
            .onDisappear {
                subscription = nil
            }
    }

    @State private var subscription: AnyCancellable?

    func batch(_ updates: Set<ViewBatchUpdate>) {
        let (values, dynamic) = updates.partitioned { update in update.right.value is iTag }
        let updates = values.set
        let publishers = dynamic.compactMap { update -> AnyPublisher<ViewBatchUpdate, Never>? in
            let tag = update.right.value as! iTag
            return app.publisher(for: tag.id.key(to: context))
                .map { ViewBatchUpdate(update.left.hashable(), AnyJSON($0.value)) }
                .eraseToAnyPublisher()
        }
        if publishers.isNotEmpty {
            subscription = publishers.combineLatest()
                .map(updates.union)
                .sink(receiveValue: send)
        } else {
            subscription = nil
            send(updates)
        }
    }

    func send(_ updates: Set<ViewBatchUpdate>) {
        Task {
            do {
                try await app.batch(
                    updates: updates.map { update in (update.left, update.right.any) },
                    in: context,
                    file: source.file,
                    line: source.line
                )
            } catch {
                app.post(error: error, file: source.file, line: source.line)
            }
        }
    }
}

public func set(_ event: Tag.Event, to value: () -> Tag.Event) -> ViewBatchUpdate {
    .init(event.hashable(), AnyJSON(iTag(value)))
}

public func set(_ event: Tag.Event, to value: AnyJSON) -> ViewBatchUpdate {
    .init(event.hashable(), AnyJSON(value))
}

public func set(_ event: Tag.Event, to value: any AnyJSONConvertible) -> ViewBatchUpdate {
    .init(event.hashable(), value.toJSON())
}

@_disfavoredOverload
public func set(_ event: Tag.Event, to value: any Equatable) -> ViewBatchUpdate {
    .init(event.hashable(), AnyJSON(value))
}

#endif
