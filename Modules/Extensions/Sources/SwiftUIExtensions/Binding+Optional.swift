// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftExtensions
import SwiftUI

public struct BindingPrint: OptionSet {
    public let rawValue: UInt
    public init(rawValue: UInt) { self.rawValue = rawValue }
    public static let get = BindingPrint(rawValue: 1 << 0)
    public static let set = BindingPrint(rawValue: 1 << 1)
}

extension Binding where Value == String {

    @inlinable public func prefix(_ n: Int) -> Binding {
        .init(
            get: { String(wrappedValue.prefix(n)) },
            set: { newValue in wrappedValue = String(newValue.prefix(n)) }
        )
    }
}

extension Binding where Value: CustomStringConvertible {

    @inlinable public func print(
        _ message: String = "",
        function: String = #function,
        file: String = #file,
        line: Int = #line
    ) -> Binding {
        print([.get, .set], message, function: function, file: file, line: line)
    }

    @inlinable public func print(
        _ print: BindingPrint,
        _ message: String = "",
        function: String = #function,
        file: String = #file,
        line: Int = #line
    ) -> Binding {
        Binding(
            get: {
                if print.contains(.get) {
                    Swift.print(message, "get", wrappedValue, CodeLocation(function, file, line))
                    return wrappedValue
                } else {
                    return wrappedValue
                }
            },
            set: { newValue in
                if print.contains(.set) {
                    Swift.print(message, "set", newValue, CodeLocation(function, file, line))
                    transaction(transaction).wrappedValue = newValue
                } else {
                    transaction(transaction).wrappedValue = newValue
                }
            }
        )
    }
}

extension Binding where Value: Equatable {

    @inlinable public func equals(
        _ value: Value,
        default defaultValue: Value
    ) -> Binding<Bool> {
        .init(
            get: { wrappedValue == value },
            set: { newValue in transaction(transaction).wrappedValue = newValue ? value : defaultValue }
        )
    }
}

extension Binding where Value: Equatable, Value: OptionalProtocol {

    @inlinable public func or(
        default defaultValue: Value.Wrapped
    ) -> Binding<Value.Wrapped> {
        .init(
            get: { wrappedValue.wrapped ?? defaultValue },
            set: { newValue in wrappedValue = Value.some(newValue) }
        )
    }

    @inlinable public func equals(
        _ value: Value,
        default defaultValue: Value = nil
    ) -> Binding<Bool> {
        .init(
            get: { wrappedValue == value },
            set: { newValue in transaction(transaction).wrappedValue = newValue ? value : defaultValue }
        )
    }

    @inlinable public func `if`(
        _ condition: @escaping (Value.Wrapped) -> Bool,
        default defaultValue: Bool = false
    ) -> Binding<Bool> {
        Binding<Bool>(
            get: { wrappedValue.wrapped.map(condition) ?? defaultValue },
            set: { newValue in
                guard !newValue else { return }
                transaction(transaction).wrappedValue = nil
            }
        )
    }

    @inlinable public func when(
        _ condition: @escaping (Value.Wrapped) -> Bool
    ) -> Binding<Value> {
        Binding<Value>(
            get: {
                if let wrapped = wrappedValue.wrapped, condition(wrapped) {
                    return wrappedValue
                } else {
                    return nil
                }
            },
            set: { newValue in
                transaction(transaction).wrappedValue = newValue
            }
        )
    }
}

extension Binding where Value == Bool {

    @inlinable public func inverted() -> Binding {
        .init(
            get: { !wrappedValue },
            set: { newValue, txn in transaction(txn).wrappedValue = !newValue }
        )
    }
}

extension Binding {

    public func didSet(_ perform: @escaping (Value) -> Void) -> Self {
        .init(
            get: { wrappedValue },
            set: { newValue, transaction in
                self.transaction(transaction).wrappedValue = newValue
                perform(newValue)
            }
        )
    }

    public func transform<T>(
        get: @escaping (Value) -> T,
        set: @escaping (T) -> Value
    ) -> Binding<T> {
        .init(
            get: { get(wrappedValue) },
            set: { newValue, tx in
                transaction(tx).wrappedValue = set(newValue)
            }
        )
    }
}
