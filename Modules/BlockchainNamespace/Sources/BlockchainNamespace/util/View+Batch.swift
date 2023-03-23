#if canImport(SwiftUI)

import AnyCoding
import Extensions
import SwiftUI

public typealias ViewBatchUpdate = Pair<Tag.EventHashable, AnyJSON>

extension View {
    @warn_unqualified_access public func batch(
        _ updates: ViewBatchUpdate...,
        file: String = #fileID,
        line: Int = #line
    ) -> some View {
        modifier(BatchUpdatesViewModifier(updates: updates, source: (file, line)))
    }

    @warn_unqualified_access public func batch(
        _ updates: [ViewBatchUpdate],
        file: String = #fileID,
        line: Int = #line
    ) -> some View {
        modifier(BatchUpdatesViewModifier(updates: updates, source: (file, line)))
    }

    @warn_unqualified_access public func set(
        _ tag: Tag.Event,
        to value: some AnyJSONConvertible,
        file: String = #fileID,
        line: Int = #line
    ) -> some View {
        // swiftformat:disable:next redundantSelf
        self.batch(.set(tag.hashable(), to: value), file: file, line: line)
    }
}

public struct BatchUpdatesViewModifier: ViewModifier {

    @BlockchainApp var app
    @Environment(\.context) var context

    let updates: [Pair<Tag.EventHashable, AnyJSON>]
    let source: (file: String, line: Int)

    @State private var withContext: [Pair<Tag.Reference, AnyJSON>] = []

    public func body(content: Content) -> some View {
        content
            .onChange(of: updates) { value in
                generate(updates: value)
            }
            .onChange(of: withContext) { value in
                batch(value)
            }
            .onAppear {
                generate(updates: updates)
            }
    }

    func generate(updates: [ViewBatchUpdate]) {
        withContext = updates.map { update in
            update.mapLeft { event in event.key(to: context) }
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

extension Pair where T == Tag.EventHashable, U == AnyJSON {

    public static func set(_ event: Tag.Event, to value: U) -> Pair {
        .init(event.hashable(), AnyJSON(value))
    }

    public static func set(_ event: Tag.Event, to value: any AnyJSONConvertible) -> Pair {
        .init(event.hashable(), value.toJSON())
    }

    @_disfavoredOverload
    public static func set(_ event: Tag.Event, to value: any Equatable) -> Pair {
        .init(event.hashable(), AnyJSON(value))
    }
}

#endif
