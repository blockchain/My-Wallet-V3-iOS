// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

extension ValueCalculationState {
    public func mapValue<TargetValue>(_ map: (Value) -> TargetValue) -> ValueCalculationState<TargetValue> {
        switch self {
        case .calculating:
            return .calculating
        case .invalid(.empty):
            return .invalid(.empty)
        case .invalid(.valueCouldNotBeCalculated):
            return .invalid(.valueCouldNotBeCalculated)
        case .invalid(.ux(let ux)):
            return .invalid(.ux(ux))
        case .value(let value):
            return .value(map(value))
        }
    }
}
