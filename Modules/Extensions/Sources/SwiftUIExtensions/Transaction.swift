import SwiftUI

@propertyWrapper
@dynamicMemberLookup
public struct TransactionBinding<Value>: DynamicProperty {

    @State private var _derived: Value
    @Binding private var _source: Value

    fileprivate init(source: Binding<Value>) {
        __source = source
        __derived = State(wrappedValue: source.wrappedValue)
    }

    public var wrappedValue: Value {
        get { _derived }
        nonmutating set { _derived = newValue }
    }

    public var projectedValue: TransactionBinding<Value> { self }

    public subscript<T>(dynamicMember keyPath: WritableKeyPath<Value, T>) -> Binding<T> {
        $_derived[dynamicMember: keyPath]
    }

    public var binding: Binding<Value> { $_derived }

    public func commit() {
        _source = _derived
    }

    public func rollback() {
        _derived = _source
    }
}

extension TransactionBinding where Value: Equatable {
    public var hasChanges: Bool { _source != _derived }
}

extension Binding {
    public func transaction() -> TransactionBinding<Value> { .init(source: self) }
}
