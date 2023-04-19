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
    }

    func batch(_ updates: Set<ViewBatchUpdate>) {
        let updates = updates.map { update in
            update.mapLeft { event in event.key(to: context) }
        }
        Task {
            do {
                try await app.batch(updates: updates.map { ($0.left, $0.right.any) }, in: context)
            } catch {
                app.post(error: error, file: source.file, line: source.line)
            }
        }
    }
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
