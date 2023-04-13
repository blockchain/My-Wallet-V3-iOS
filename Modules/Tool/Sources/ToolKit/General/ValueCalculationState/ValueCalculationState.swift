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
            return value
        case .calculating, .invalid:
            return nil
        }
    }

    /// Returns `true` if has a value
    public var isValue: Bool {
        switch self {
        case .value:
            return true
        case .calculating, .invalid:
            return false
        }
    }

    /// Returns `true` if is invalid
    public var isInvalid: Bool {
        switch self {
        case .invalid:
            return true
        case .calculating, .value:
            return false
        }
    }

    public var isCalculating: Bool {
        switch self {
        case .calculating:
            return true
        case .invalid, .value:
            return false
        }
    }
}

extension ValueCalculationState: Equatable where Value: Equatable {
    public static func == (lhs: ValueCalculationState<Value>, rhs: ValueCalculationState<Value>) -> Bool {
        switch (lhs, rhs) {
        case (.value(let v1), .value(let v2)): return v1 == v2
        case (.calculating, .calculating): return true
        case (.invalid(.valueCouldNotBeCalculated), .invalid(.valueCouldNotBeCalculated)): return true
        case (.invalid(.empty), .invalid(.empty)): return true
        case (.invalid(.ux(let u1)), .invalid(.ux(let u2))): return u1 == u2
        default: return false
        }
    }
}
