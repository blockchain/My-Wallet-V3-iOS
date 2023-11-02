// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Errors

/// A calculation state for value. Typically used to reflect an ongoing
/// calculation of values
public enum ValueCalculationState<Value> {

    public enum CalculationError: Error, Equatable {
        case valueCouldNotBeCalculated
        case empty
        case ux(UX.Error)
    }

    /// Value is available
    case value(Value)

    /// Value is being calculated
    case calculating

    case invalid(CalculationError)

    /// Returns the value when available
    public var value: Value? {
        switch self {
        case .value(let value):
            value
        case .calculating, .invalid:
            nil
        }
    }

    /// Returns `true` if has a value
    public var isValue: Bool {
        switch self {
        case .value:
            true
        case .calculating, .invalid:
            false
        }
    }

    /// Returns `true` if is invalid
    public var isInvalid: Bool {
        switch self {
        case .invalid:
            true
        case .calculating, .value:
            false
        }
    }

    public var isCalculating: Bool {
        switch self {
        case .calculating:
            true
        case .invalid, .value:
            false
        }
    }
}

extension ValueCalculationState: Equatable where Value: Equatable {
    public static func == (lhs: ValueCalculationState<Value>, rhs: ValueCalculationState<Value>) -> Bool {
        switch (lhs, rhs) {
        case (.value(let v1), .value(let v2)): v1 == v2
        case (.calculating, .calculating): true
        case (.invalid(.valueCouldNotBeCalculated), .invalid(.valueCouldNotBeCalculated)): true
        case (.invalid(.empty), .invalid(.empty)): true
        case (.invalid(.ux(let u1)), .invalid(.ux(let u2))): u1 == u2
        default: false
        }
    }
}
