#if canImport(SwiftUI)

import AnyCoding
import Extensions
import SwiftUI

public typealias ViewBatchUpdate = Pair<Tag.Event, AnyJSON>

extension View {
    @warn_unqualified_access public func batch(
        _ updates: ViewBatchUpdate...,
        file: String = #file,
        line: Int = #line
    ) -> some View {
        modifier(BatchUpdatesViewModifier(updates: updates, source: (file, line)))
    }

    @warn_unqualified_access public func batch(
        _ updates: [ViewBatchUpdate],
        file: String = #file,
        line: Int = #line
    ) -> some View {
        modifier(BatchUpdatesViewModifier(updates: updates, source: (file, line)))
    }

    @warn_unqualified_access public func set(
        _ tag: Tag.Event,
        to value: some AnyJSONConvertible,
        file: String = #file,
        line: Int = #line
    ) -> some View {
        self.batch(.set(tag, to: value), file: file, line: line)
    }
}

public struct BatchUpdatesViewModifier: ViewModifier {

    @BlockchainApp var app
    @Environment(\.context) var context

    let updates: [Pair<Tag.Event, AnyJSON>]
    let source: (file: String, line: Int)

    private var withContext: [Pair<Tag.Reference, AnyJSON>] {
        updates.map { update in
            update.mapLeft { event in event.key(to: context) }
        }
    }

    public func body(content: Content) -> some View {
        content.onChange(of: withContext) { value in
            batch(value)
        }
        .onAppear {
            batch(withContext)
        }
    }

    func batch(_ updates: [Pair<Tag.Reference, AnyJSON>]) {
        Task {
            do {
                try await app.batch(updates: updates.map { ($0.left, $0.right.any) }, in: context)
            } catch {
                app.post(error: error, file: source.file, line: source.line)
            }
        }
    }
}

extension Pair where T == Tag.Event, U == AnyJSON {

    public static func set(_ event: Tag.Event, to value: U) -> Pair {
        .init(event, AnyJSON(value))
    }

    public static func set(_ event: Tag.Event, to value: any AnyJSONConvertible) -> Pair {
        .init(event, value.toJSON())
    }

    @_disfavoredOverload
    public static func set(_ event: Tag.Event, to value: any Equatable) -> Pair {
        .init(event, AnyJSON(value))
    }
}

#endif
